import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/add_house_screen.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final mockService = MockDataService();

  @override
  Widget build(BuildContext context) {
    final myHouses = mockService.allHouses
        .where((h) => h.ownerId == mockService.currentUser!.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),
        actions: [
          IconButton(
            onPressed: () {
              mockService.signOut();
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Posted Houses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          for (var house in myHouses)
            ListTile(
              title: Text(house.title),
              subtitle: Text('Rooms: ${house.rooms}, Baths: ${house.bathrooms}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    mockService.deleteHouse(house.id);
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HouseDetailsScreen(
                      house: house,
                      isCustomerView: true,
                    ),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Go to add house page
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddHouseScreen()),
          );
          setState(() {});
        },
      ),
    );
  }
}
