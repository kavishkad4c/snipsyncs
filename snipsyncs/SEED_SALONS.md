# Seed Salons Data

To easily add the three salons to your database, run the following SQL commands in your Supabase SQL Editor:

```sql
-- Insert the three salons if they don't already exist
INSERT INTO public.salons (name, address, phone, email, description) VALUES
('Salon Anura', '123 Main Street, Colombo', '+94 11 234 5678', 'anura@snipsyncs.com', 'Premium hair salon in Colombo'),
('Kandy Salon', '456 Temple Road, Kandy', '+94 81 234 5678', 'kandy@snipsyncs.com', 'Traditional barber shop in Kandy'),
('Shire Design', '789 Hill Street, Nuwara Eliya', '+94 52 234 5678', 'shire@snipsyncs.com', 'Modern beauty salon in Nuwara Eliya');
```

## How to run this:

1. Go to your Supabase Dashboard
2. Navigate to SQL Editor
3. Paste the above SQL commands
4. Click "Run"

After running this, when you log in as an admin, you should see these three salons in the dropdown menu on the admin dashboard.

## Creating Admin Accounts:

After seeding the salons, create admin accounts:

1. Register through the app using these credentials:
   - Email: admin@anura.com, Password: Admin123!
   - Email: admin@kandy.com, Password: Admin123!
   - Email: admin@shire.com, Password: Admin123!

2. Update their roles in the database:
```sql
UPDATE public.users SET role = 'admin' WHERE email = 'admin@anura.com';
UPDATE public.users SET role = 'admin' WHERE email = 'admin@kandy.com';
UPDATE public.users SET role = 'admin' WHERE email = 'admin@shire.com';
```

Once you've done this, you can log in as any of these admins and you'll see the salons automatically loaded in the admin panel.