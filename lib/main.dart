import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:house_cleaning_app/screens/welcome_screen.dart';
import 'package:house_cleaning_app/screens/sign_in_screen.dart';
import 'package:house_cleaning_app/screens/sign_up_screen.dart';
import 'package:house_cleaning_app/screens/customer_dashboard_screen.dart';
import 'package:house_cleaning_app/screens/cleaner_dashboard_screen.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  if(kIsWeb){
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyDtIo0VB3b3r_T7Y1e0ik3I0no0QLAd6hY",
        authDomain: "house-cleaning-22216.firebaseapp.com",
        projectId: "house-cleaning-22216",
        storageBucket: "house-cleaning-22216.firebasestorage.app",
        messagingSenderId: "978636082936",
        appId: "1:978636082936:web:3d221ee9ffa2644df1350d"

    ));
  }else{
    await Firebase.initializeApp();
  }

   try {
    await Firebase.initializeApp();
    print("✅Firebase is connected successfully!");

  } catch (e) {
    print("❌Firebase connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'House Cleaning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),

        // Single Sign In route
        '/signIn': (context) => const SignInScreen(),

        // Single Sign Up route
        '/signUp': (context) => const SignUpScreen(),

        // Home pages
        '/customerDashboard': (context) => const CustomerDashboardScreen(),
        '/cleanerDashboard': (context) => const CleanerDashboardScreen(),
      },
    );
  }
}
