import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';

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

  final mockService = MockDataService();

  void _saveHouse() {
    if (_formKey.currentState!.validate()) {
      mockService.addHouse(
        title: _titleCtrl.text.trim(),
        rooms: int.parse(_roomsCtrl.text.trim()),
        bathrooms: int.parse(_bathroomsCtrl.text.trim()),
        kitchen: _kitchen,
        garage: _garage,
        flooringType: _floorTypeCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        payment: double.parse(_paymentCtrl.text.trim()),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add House'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'House Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter house title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomsCtrl,
                decoration: const InputDecoration(labelText: 'Number of Rooms'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Enter rooms count' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bathroomsCtrl,
                decoration: const InputDecoration(labelText: 'Number of Bathrooms'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Enter bathrooms count' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Kitchen'),
                value: _kitchen,
                onChanged: (val) {
                  setState(() {
                    _kitchen = val;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Garage'),
                value: _garage,
                onChanged: (val) {
                  setState(() {
                    _garage = val;
                  });
                },
              ),
              TextFormField(
                controller: _floorTypeCtrl,
                decoration: const InputDecoration(labelText: 'Flooring Type'),
                validator: (val) => val == null || val.isEmpty ? 'Enter floor type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (val) => val == null || val.isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location (City)'),
                validator: (val) => val == null || val.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paymentCtrl,
                decoration: const InputDecoration(labelText: 'Payment (Budget)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Enter payment' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHouse,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
