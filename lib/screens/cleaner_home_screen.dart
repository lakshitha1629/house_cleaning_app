import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  final mockService = MockDataService();
  String filterLocation = '';
  int? filterRooms;

  @override
  Widget build(BuildContext context) {
    // Filter houses based on location / rooms if needed
    List<House> availableHouses = mockService.getAvailableHouses();

    if (filterLocation.isNotEmpty) {
      availableHouses = availableHouses
          .where((h) => h.location.toLowerCase().contains(filterLocation))
          .toList();
    }
    if (filterRooms != null) {
      availableHouses =
          availableHouses.where((h) => h.rooms == filterRooms).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleaner Home'),
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
      body: Column(
        children: [
          // Simple filter UI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: 'Filter by location'),
                    onChanged: (val) {
                      setState(() {
                        filterLocation = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    decoration:
                        const InputDecoration(labelText: 'Rooms = ?'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setState(() {
                        if (val.isEmpty) {
                          filterRooms = null;
                        } else {
                          filterRooms = int.tryParse(val);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var house in availableHouses)
                  ListTile(
                    title: Text(house.title),
                    subtitle: Text(
                        'Location: ${house.location}, Payment: \$${house.payment}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Accept
                            mockService.acceptHouse(
                              house.id,
                              mockService.currentUser!.id,
                            );
                            setState(() {});
                          },
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          onPressed: () {
                            // Hide (just remove from local UI for now)
                            setState(() {
                              availableHouses.remove(house);
                            });
                          },
                          child: const Text('Hide'),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HouseDetailsScreen(
                            house: house,
                            isCustomerView: false,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
