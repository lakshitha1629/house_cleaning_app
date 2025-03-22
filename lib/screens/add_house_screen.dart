import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({Key? key}) : super(key: key);

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();
  final _bathroomsCtrl = TextEditingController();
  final _floorTypeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _paymentCtrl = TextEditingController();

  bool _kitchen = false;
  bool _garage = false;
  final firebaseService = FirebaseService();

  Future<void> _saveHouse() async {
    if (_formKey.currentState!.validate()) {
      final rooms = int.tryParse(_roomsCtrl.text.trim());
      final bathrooms = int.tryParse(_bathroomsCtrl.text.trim());
      final payment = double.tryParse(_paymentCtrl.text.trim());

      if (rooms == null || bathrooms == null || payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter valid numbers for rooms, bathrooms, and payment.',
            ),
          ),
        );
        return;
      }

      // Check if there is a signed-in user
      if (firebaseService.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user is signed in. Please sign in first.'),
          ),
        );
        return;
      }

      // Call FirebaseService to add the house
      final newHouse = await firebaseService.addHouse(
        title: _titleCtrl.text.trim(),
        rooms: rooms,
        bathrooms: bathrooms,
        kitchen: _kitchen,
        garage: _garage,
        flooringType: _floorTypeCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        payment: payment,
      );

      if (newHouse != null) {
        // Successfully added to Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('House "${newHouse.title}" added successfully!'),
          ),
        );
        Navigator.pop(context);
      } else {
        // Something went wrong
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add house.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _roomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _floorTypeCtrl.dispose();
    _addressCtrl.dispose();
    _locationCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add House'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // House Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'House Title',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter house title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Number of Rooms
                      TextFormField(
                        controller: _roomsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Number of Rooms',
                          prefixIcon: Icon(Icons.king_bed),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter rooms count';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Number of Bathrooms
                      TextFormField(
                        controller: _bathroomsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Number of Bathrooms',
                          prefixIcon: Icon(Icons.bathtub),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter bathrooms count';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kitchen switch
                      SwitchListTile(
                        title: const Text('Kitchen'),
                        value: _kitchen,
                        activeColor: Colors.blueAccent,
                        onChanged: (val) {
                          setState(() {
                            _kitchen = val;
                          });
                        },
                      ),
                      // Garage switch
                      SwitchListTile(
                        title: const Text('Garage'),
                        value: _garage,
                        activeColor: Colors.blueAccent,
                        onChanged: (val) {
                          setState(() {
                            _garage = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Flooring Type
                      TextFormField(
                        controller: _floorTypeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Flooring Type',
                          prefixIcon: Icon(Icons.layers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter floor type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Location (City)
                      TextFormField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Location (City)',
                          prefixIcon: Icon(Icons.map),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment (Budget)
                      TextFormField(
                        controller: _paymentCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Payment (Budget)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter payment';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _saveHouse,
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
