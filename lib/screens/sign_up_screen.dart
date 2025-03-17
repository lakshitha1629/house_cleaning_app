import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final mockService = MockDataService();

  // Let the user pick 'customer' or 'cleaner'
  String _selectedRole = 'customer';

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      bool success = mockService.signUp(
        name: _nameCtrl.text.trim(),
        role: _selectedRole, // use the dropdown value
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        contactNumber: _contactCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        pictureUrl: 'https://cdn.iconscout.com/icon/free/png-256/free-user-icon-download-in-svg-png-gif-file-formats--profile-avatar-account-person-app-interface-pack-icons-1401302.png',
      );
      if (success) {
        // If sign-up succeeded, we can directly go to the right home screen
        if (_selectedRole == 'customer') {
          Navigator.pushReplacementNamed(context, '/customerHome');
        } else {
          Navigator.pushReplacementNamed(context, '/cleanerHome');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top image or illustration
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Image.network(
                 'https://cdni.iconscout.com/illustration/premium/thumb/cleaning-man-clean-house-floor-with-broomstick-illustration-download-in-svg-png-gif-file-formats--woman-cleaner-pack-services-illustrations-3322070.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Sign up to get started",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Sign up form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Role (dropdown)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: const [
                              DropdownMenuItem(
                                value: 'customer',
                                child: Text('Customer'),
                              ),
                              DropdownMenuItem(
                                value: 'cleaner',
                                child: Text('Cleaner'),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedRole = val ?? 'customer';
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact
                      TextFormField(
                        controller: _contactCtrl,
                        decoration: InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Username
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (val.length < 3) {
                            return 'Password must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _signUp,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Already have an account?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signIn');
                    },
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.blueAccent.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
