import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';

class CleanerDashboardScreen extends StatefulWidget {
  const CleanerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CleanerDashboardScreen> createState() => _CleanerDashboardScreenState();
}

class _CleanerDashboardScreenState extends State<CleanerDashboardScreen> {
  int _selectedIndex = 0;
  String filterLocation = '';
  int? filterRooms;
  
  // Sample data
  List<House> availableHouses = [];
  List<House> ongoingHouses = [];
  List<Map<String, String>> notifications = [];
  List<House> myHouses = [];
  
  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _loadSampleData();
  }
  
  void _loadSampleData() {
    // This would be replaced with actual data loading in a real app
    availableHouses = [];
    ongoingHouses = [];
    notifications = [];
    myHouses = [];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(),
      _buildNotificationsTab(),
      _buildChatTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F7),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // 1) HOME TAB
  Widget _buildHomeTab() {
    // Filter available houses
    List<House> filteredHouses = availableHouses;
    if (filterLocation.isNotEmpty) {
      filteredHouses = filteredHouses
          .where((h) => h.location.toLowerCase().contains(filterLocation))
          .toList();
    }
    if (filterRooms != null) {
      filteredHouses = filteredHouses.where((h) => h.rooms == filterRooms).toList();
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Filter by location',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        filterLocation = val.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Rooms?',
                      border: OutlineInputBorder(),
                    ),
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
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available Houses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (filteredHouses.isEmpty)
              const Text("No available houses at the moment.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredHouses.length,
                  itemBuilder: (context, index) {
                    final house = filteredHouses[index];
                    return _buildAvailableCard(house);
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ongoing Jobs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (ongoingHouses.isEmpty)
              const Text("No ongoing jobs yet.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ongoingHouses.length,
                  itemBuilder: (context, index) {
                    final house = ongoingHouses[index];
                    return _buildOngoingCard(house);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCard(House house) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // House image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                house.imageUrls.isNotEmpty
                    ? house.imageUrls.first
                    : 'https://via.placeholder.com/400?text=No+Image',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Accept house logic
                  setState(() {
                    ongoingHouses.add(house);
                    availableHouses.remove(house);
                  });
                },
                child: const Text("Accept"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  // Hide house
                  setState(() {
                    availableHouses.remove(house);
                  });
                },
                child: const Text("Hide"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingCard(House house) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: false)),
        );
        setState(() {});
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // House image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  house.imageUrls.isNotEmpty
                      ? house.imageUrls.first
                      : 'https://via.placeholder.com/400?text=No+Image',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(house.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // 2) NOTIFICATIONS TAB
  Widget _buildNotificationsTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: notifications.isEmpty
            ? const Center(child: Text("No notifications yet."))
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return Card(
                    child: ListTile(
                      title: Text(n['title'] ?? ''),
                      subtitle: Text(n['message'] ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // 3) CHAT TAB
  Widget _buildChatTab() {
    if (myHouses.isEmpty) {
      return const SafeArea(
        child: Center(child: Text("No chat available yet.")),
      );
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myHouses.length,
        itemBuilder: (context, index) {
          final house = myHouses[index];
          return Card(
            child: ListTile(
              title: Text(house.title),
              subtitle: Text(
                  house.isFinished ? "Finished" : (house.acceptedBy == null ? "Not Accepted" : "Ongoing")),
              onTap: () async {
                // Go to House Details
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: false)),
                );
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  // 4) PROFILE TAB
  Widget _buildProfileTab() {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://via.placeholder.com/100"),
            ),
            const SizedBox(height: 16),
            const Text(
              "John Doe",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Contact: +1234567890"),
            const Text("Address: 123 Main St"),
            const SizedBox(height: 8),
            const Text("Rating: 4.5"),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
              },
              child: const Text(
                "Log Out",
                style: TextStyle(color: Colors.white),
              )
            ),
          ],
        ),
      ),
    );
  }
}
