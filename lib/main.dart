import 'package:flutter/material.dart';
import 'package:house_cleaning_app/screens/welcome_screen.dart';
import 'package:house_cleaning_app/screens/sign_in_screen.dart';
import 'package:house_cleaning_app/screens/sign_up_screen.dart';
import 'package:house_cleaning_app/screens/customer_dashboard_screen.dart';
import 'package:house_cleaning_app/screens/cleaner_dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
