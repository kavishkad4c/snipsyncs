# Supabase Setup Guide for SnipSyncs

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - Name: `snipsyncs`
   - Database Password: (create a strong password)
   - Region: Choose closest to your users
5. Click "Create new project"

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to Settings > API
2. Copy the following values:
   - Project URL
   - Project API Key (anon public)

## Step 3: Update Your Flutter App

1. Open `lib/services/supabase_service.dart`
2. Replace the placeholder values:
   ```dart
   static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```

## Step 4: Set Up Database Schema

1. In your Supabase dashboard, go to SQL Editor
2. Copy the contents of `supabase_schema.sql` file
3. Paste it into the SQL Editor and run it
4. This will create all necessary tables and security policies

## Step 5: Configure Authentication

1. In Supabase dashboard, go to Authentication > Settings
2. Configure the following:
   - Site URL: `http://localhost:3000` (for development)
   - Redirect URLs: Add your app's redirect URLs
   - Email templates: Customize if needed

## Step 6: Test Your Setup

1. Run `flutter pub get` to install dependencies
2. Run your Flutter app
3. Try signing up a new user
4. Check your Supabase dashboard to see if the user was created

## Database Tables Created

- **users**: Extended user profiles with roles (admin, staff, customer)
- **services**: Salon services with pricing and duration
- **appointments**: Booking system with status tracking
- **staff_schedules**: Staff availability management
- **queue_management**: Real-time queue tracking
- **notifications**: In-app notification system

## Security Features

- Row Level Security (RLS) enabled on all tables
- Role-based access control
- Secure authentication with JWT tokens
- Data isolation between users

## Next Steps

After completing the setup:
1. Test user registration and login
2. Add sample services through the admin panel
3. Test appointment booking flow
4. Configure real-time subscriptions for queue updates

## Troubleshooting

- If you get connection errors, check your URL and API key
- Ensure your database schema was applied correctly
- Check the Supabase logs for any errors
- Verify RLS policies are working as expected