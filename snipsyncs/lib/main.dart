import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'utils/colors.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'providers/appointment_provider.dart';
import 'providers/service_provider.dart';
import 'providers/salon_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Handle deep links for email verification
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) async {
    if (uri.path == '/verify' && uri.queryParameters.containsKey('token')) {
      try {
        final token = uri.queryParameters['token']!;
        final type = uri.queryParameters['type'] ?? 'email';
        
        // Verify the token with Supabase
        await SupabaseService.client.auth.verifyOTP(
          token: token,
          type: (type == 'email') ? OtpType.email : OtpType.magiclink,
        );
      } catch (e) {
        // Handle verification error
        print('Email verification failed: $e');
      }
    }
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => AppointmentProvider()),
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => SalonProvider()),
      ],
      child: MaterialApp(
        title: 'SnipSyncs',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}