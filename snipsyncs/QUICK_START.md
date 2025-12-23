# Quick Start - Ready for Demo Tomorrow

## Easy Setup Instructions

To get your app ready for tomorrow with all three panels working:

### 1. Test Accounts to Use:
- **Admin Panel**: Log in with any email containing "admin"
  - Example: admin@test.com / anypassword
- **Staff Panel**: Log in with any email containing "staff"
  - Example: staff@test.com / anypassword
- **Customer Panel**: Log in with any other email
  - Example: customer@test.com / anypassword

### 2. Three Salons Already Available in Admin Panel:
1. **Salon Anura** - Premium hair salon in Colombo
2. **Kandy Salon** - Traditional barber shop in Kandy
3. **Shire Design** - Modern beauty salon in Nuwara Eliya

### 3. Features by Role:

#### Admin Panel:
- Manage Services (Add/Edit/Delete services)
- Manage Staff (Add/Edit staff members)
- View Appointments
- Access Reports
- Switch between salons using dropdown

#### Staff Panel:
- View assigned appointments
- Update appointment status
- See daily schedule

#### Customer Panel:
- Browse services
- View queue status
- Book appointments

### 4. Database Setup (Optional for full functionality):
If you want to persist data:

1. Go to Supabase SQL Editor
2. Run this command:
```sql
INSERT INTO public.salons (name, address, phone, email, description) VALUES
('Salon Anura', '123 Main Street, Colombo', '+94 11 234 5678', 'anura@snipsyncs.com', 'Premium hair salon in Colombo'),
('Kandy Salon', '456 Temple Road, Kandy', '+94 81 234 5678', 'kandy@snipsyncs.com', 'Traditional barber shop in Kandy'),
('Shire Design', '789 Hill Street, Nuwara Eliya', '+94 52 234 5678', 'shire@snipsyncs.com', 'Modern beauty salon in Nuwara Eliya');
```

3. Create admin accounts by registering through the app, then update their roles:
```sql
UPDATE public.users SET role = 'admin' WHERE email = 'your-admin-email@test.com';
```

### 5. Running the App:
Just run `flutter run` and you're good to go!

The app is now ready for your demo tomorrow with all three panels working correctly.