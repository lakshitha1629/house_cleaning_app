import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optionally remove the appBar to have a fullscreen welcome
      // appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          // A light gradient background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Top illustration
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.network(
                    'https://cdni.iconscout.com/illustration/premium/thumb/young-workers-are-cleaning-office-illustration-download-in-svg-png-gif-file-formats--service-factory-production-pack-people-illustrations-6430818.png',
                    // Or replace with your actual asset image
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Welcome text
              const Text(
                "Welcome to HouseClean",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  "Get professional cleaning services at your fingertips or become a cleaner to earn!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const Spacer(),

              // Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to sign in
                      Navigator.pushNamed(context, '/signIn');
                    },
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
