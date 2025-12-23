-- Enable Row Level Security
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create users table (extends auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('admin', 'staff', 'customer')),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create services table
CREATE TABLE public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration INTEGER NOT NULL, -- in minutes
    category TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create appointments table
CREATE TABLE public.appointments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) NOT NULL,
    service_id UUID REFERENCES public.services(id) NOT NULL,
    staff_id UUID REFERENCES public.users(id),
    appointment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    total_amount DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create staff_schedules table
CREATE TABLE public.staff_schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    staff_id UUID REFERENCES public.users(id) NOT NULL,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0 = Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create queue_management table
CREATE TABLE public.queue_management (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    appointment_id UUID REFERENCES public.appointments(id) NOT NULL,
    queue_position INTEGER NOT NULL,
    estimated_wait_time INTEGER, -- in minutes
    actual_start_time TIMESTAMP WITH TIME ZONE,
    actual_end_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create salons table
CREATE TABLE public.salons (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    image TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add salon_id to appointments table
ALTER TABLE public.appointments 
ADD COLUMN salon_id UUID REFERENCES public.salons(id);

-- Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.queue_management ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salons ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admin can view all users" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for services table
CREATE POLICY "Anyone can view active services" ON public.services
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admin can manage services" ON public.services
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- RLS Policies for appointments table
DROP POLICY IF EXISTS "Users can view their own appointments" ON public.appointments;
CREATE POLICY "Users can view their own appointments" ON public.appointments
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.uid() = staff_id OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'staff')
        )
    );

CREATE POLICY "Users can create their own appointments" ON public.appointments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Staff and admin can update appointments" ON public.appointments
    FOR UPDATE USING (
        auth.uid() = staff_id OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'staff')
        )
    );

-- RLS Policies for staff_schedules table
CREATE POLICY "Staff can manage their own schedule" ON public.staff_schedules
    FOR ALL USING (auth.uid() = staff_id);

CREATE POLICY "Admin can manage all schedules" ON public.staff_schedules
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- RLS Policies for queue_management table
CREATE POLICY "Users can view queue for their appointments" ON public.queue_management
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.appointments 
            WHERE id = appointment_id AND user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'staff')
        )
    );

-- RLS Policies for notifications table
CREATE POLICY "Users can view their own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for salons table
CREATE POLICY "Anyone can view active salons" ON public.salons
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admin can manage salons" ON public.salons
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create functions and triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON public.services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON public.appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_staff_schedules_updated_at BEFORE UPDATE ON public.staff_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_queue_management_updated_at BEFORE UPDATE ON public.queue_management
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO public.services (name, description, price, duration, category) VALUES
('Haircut', 'Professional haircut and styling', 25.00, 30, 'Hair'),
('Hair Wash & Blow Dry', 'Shampoo, conditioning, and blow dry', 15.00, 20, 'Hair'),
('Hair Coloring', 'Full hair coloring service', 80.00, 120, 'Hair'),
('Beard Trim', 'Professional beard trimming and shaping', 15.00, 15, 'Grooming'),
('Facial Treatment', 'Deep cleansing facial treatment', 45.00, 60, 'Skincare'),
('Manicure', 'Complete nail care and polish', 20.00, 30, 'Nails'),
('Pedicure', 'Foot care and nail treatment', 25.00, 45, 'Nails');

-- Insert sample salons
INSERT INTO public.salons (name, address, phone, email, description) VALUES
('Salon Anura', '123 Main Street, Colombo', '+94 11 234 5678', 'anura@snipsyncs.com', 'Premium hair salon in Colombo'),
('Kandy Salon', '456 Temple Road, Kandy', '+94 81 234 5678', 'kandy@snipsyncs.com', 'Traditional barber shop in Kandy'),
('Shire Design', '789 Hill Street, Nuwara Eliya', '+94 52 234 5678', 'shire@snipsyncs.com', 'Modern beauty salon in Nuwara Eliya');

-- NOTE: Admin users must be created through the app first, then their roles updated
-- Sample admin credentials you can use:
-- 1. Salon Anura Admin:
--    Email: admin@anura.com
--    Password: Admin123!
-- 2. Kandy Salon Admin:
--    Email: admin@kandy.com
--    Password: Admin123!
-- 3. Shire Design Admin:
--    Email: admin@shire.com
--    Password: Admin123!

-- After registering these accounts through the app, update their roles with:
-- UPDATE public.users SET role = 'admin' WHERE email = 'admin@anura.com';
-- UPDATE public.users SET role = 'admin' WHERE email = 'admin@kandy.com';
-- UPDATE public.users SET role = 'admin' WHERE email = 'admin@shire.com';