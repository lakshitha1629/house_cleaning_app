import 'package:flutter/material.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/add_house_screen.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';
import 'package:house_cleaning_app/screens/chat_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  final mockService = MockDataService();

  @override
  Widget build(BuildContext context) {
    final user = mockService.currentUser!;
    final role = user.role; // "customer"

    final List<Widget> pages = [
      _buildHomeTab(user.id, role),
      _buildNotificationsTab(user.id),
      _buildChatTab(user.id),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F7), // light background
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
  Widget _buildHomeTab(String userId, String role) {
    final ongoingHouses = mockService.getOngoingHouses(userId, role);
    final completedHouses = mockService.getCompletedHouses(userId, role);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ongoing Cleaners",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Horizontal list of ongoing houses
            if (ongoingHouses.isEmpty)
              const Text("No ongoing cleaners yet.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ongoingHouses.length,
                  itemBuilder: (context, index) {
                    final house = ongoingHouses[index];
                    return _buildHouseCard(house, isOngoing: true);
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Completed Reviews",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Horizontal list of completed houses
            if (completedHouses.isEmpty)
              const Text("No completed jobs yet.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: completedHouses.length,
                  itemBuilder: (context, index) {
                    final house = completedHouses[index];
                    return _buildHouseCard(house, isOngoing: false);
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Add House button
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHouseScreen()),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text("Add House"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseCard(House house, {required bool isOngoing}) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: true)),
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
              child: Text(
                house.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2) NOTIFICATIONS TAB
  Widget _buildNotificationsTab(String userId) {
    final notifs = mockService.getNotificationsForUser(userId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: notifs.isEmpty
            ? const Center(child: Text("No notifications yet."))
            : ListView.builder(
                itemCount: notifs.length,
                itemBuilder: (context, index) {
                  final n = notifs[index];
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
  Widget _buildChatTab(String userId) {
    // Show any houses that belong to or are accepted by this user
    final myHouses = mockService.allHouses.where((h) =>
      h.ownerId == userId || h.acceptedBy == userId
    ).toList();

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
                // Go to Chat screen
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: true)),
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
    final user = mockService.currentUser!;
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.pictureUrl),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Contact: ${user.contactNumber}"),
            Text("Address: ${user.address}"),
            const SizedBox(height: 8),
            // Show rating if you want
            if (user.rating > 0)
              Text("Rating: ${user.rating.toStringAsFixed(1)}"),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                mockService.signOut();
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
