# SnipSyncs Setup Instructions

## Prerequisites

### 1. Flutter Installation
If Flutter is not installed or not in your PATH:

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Extract to a location like `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH
4. Run `flutter doctor` to verify installation

### 2. Android Studio Setup
To fix the Android Studio opening issue:

1. Make sure you have Android Studio installed
2. Open Android Studio
3. Go to File > Open
4. Navigate to your project folder and select the `android` folder (not the root folder)
5. Let Android Studio sync the project
6. If you get Gradle errors, try:
   - File > Invalidate Caches and Restart
   - Clean and rebuild the project

### 3. Install Dependencies
After Flutter is properly set up, run:
```bash
flutter pub get
```

### 4. Supabase Setup
Follow the instructions in `SUPABASE_SETUP.md` to:
1. Create a Supabase project
2. Set up the database schema
3. Configure authentication
4. Update your app with the credentials

## Project Structure

Your app now includes:

### Backend Integration
- ✅ Supabase Flutter SDK integrated
- ✅ Authentication service with role-based access
- ✅ Database service for appointments, services, users
- ✅ Provider pattern for state management
- ✅ Updated models to work with Supabase

### Database Schema
- ✅ Users table with roles (admin, staff, customer)
- ✅ Services table for salon services
- ✅ Appointments table with status tracking
- ✅ Staff schedules for availability
- ✅ Queue management for real-time updates
- ✅ Notifications system

### Security Features
- ✅ Row Level Security (RLS) policies
- ✅ JWT-based authentication
- ✅ Role-based access control
- ✅ Secure API endpoints

## Next Steps

1. **Fix Flutter PATH**: Ensure Flutter is properly installed and in your system PATH
2. **Run Dependencies**: Execute `flutter pub get` to install packages
3. **Setup Supabase**: Follow the Supabase setup guide
4. **Test the App**: Run `flutter run` to test the integration
5. **Configure Android Studio**: Open the android folder in Android Studio

## Troubleshooting

### Android Studio Issues
- Open the `android` folder specifically, not the root project
- Ensure you have the latest Android Studio version
- Check that Android SDK is properly configured

### Flutter Issues
- Run `flutter doctor` to check for issues
- Ensure all dependencies are properly installed
- Check that your Flutter version supports the packages used

### Supabase Issues
- Verify your project URL and API keys are correct
- Check that the database schema was applied successfully
- Test authentication in the Supabase dashboard

## Your UI Components
All your existing UI components have been preserved:
- Custom buttons, text fields, and cards
- Gradient backgrounds and styling
- Screen layouts and navigation
- Color scheme and theming

The backend integration works seamlessly with your existing UI without changing the visual design.