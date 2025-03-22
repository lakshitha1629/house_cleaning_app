import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/add_house_screen.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';
import 'package:house_cleaning_app/screens/chat_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  // Houses loaded from Firebase
  List<House> ongoingHouses = [];
  List<House> completedHouses = [];
  List<House> allPosts = []; // All houses posted by the customer
  List<House> chatHouses = []; // Houses with an active chat (accepted)

  bool _isLoading = false;
  final firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _fetchData(); // Load data from Firestore
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final user = firebaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is signed in.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (user.role != 'customer') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are a ${user.role}, not a customer.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch ongoing houses for this customer (ownerId == user.id, acceptedBy != null, not finished)
      final loadedOngoing =
          await firebaseService.getOngoingHouses(user.id, 'customer');
      // Fetch completed houses for this customer (ownerId == user.id, isFinished == true)
      final loadedCompleted =
          await firebaseService.getCompletedHouses(user.id, 'customer');
      // All posts: houses where ownerId == user.id
      final loadedPosts = (await firebaseService.getAllHouses())
          .where((h) => h.ownerId == user.id)
          .toList();
      // Chat houses: posts with acceptedBy != null
      final loadedChat =
          loadedPosts.where((h) => h.acceptedBy != null).toList();

      print("Loaded ${loadedOngoing.length} ongoing houses");
      print("Loaded ${loadedCompleted.length} completed houses");
      print("Loaded ${loadedPosts.length} posts");
      print("Loaded ${loadedChat.length} chat houses");

      setState(() {
        ongoingHouses = loadedOngoing;
        completedHouses = loadedCompleted;
        allPosts = loadedPosts;
        chatHouses = loadedChat;
      });
    } catch (e) {
      print('Error fetching data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      _buildPostTab(),
      _buildChatTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      // Floating action button visible on Home tab
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHouseScreen()),
                );
                _fetchData();
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // -------------------- HOME TAB --------------------
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner image
            Image.asset(
              "assets/living.jpg",
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text(
              "Ongoing Cleanings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (ongoingHouses.isEmpty)
              const Text("No ongoing cleanings yet.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ongoingHouses.length,
                  itemBuilder: (context, index) {
                    final house = ongoingHouses[index];
                    return _buildHouseCard(house);
                  },
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Completed Cleanings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (completedHouses.isEmpty)
              const Text("No completed cleanings yet.")
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: completedHouses.length,
                  itemBuilder: (context, index) {
                    final house = completedHouses[index];
                    return _buildHouseCard(house);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- House Card Widget --------------------
  Widget _buildHouseCard(House house) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                HouseDetailsScreen(house: house, isCustomerView: true),
          ),
        );
        _fetchData(); // Refresh data after returning
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
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

  // -------------------- POST TAB --------------------
  Widget _buildPostTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Posts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (allPosts.isEmpty)
              const Text("You haven't posted any cleaning requests yet.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final house = allPosts[index];
                  String status;
                  if (house.acceptedBy == null) {
                    status = 'Not Accepted';
                  } else if (!house.isFinished) {
                    status = 'In Progress';
                  } else {
                    status = 'Finished';
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        house.imageUrls.isNotEmpty
                            ? house.imageUrls.first
                            : 'https://via.placeholder.com/100?text=No+Image',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(house.title),
                      subtitle: Text("Status: $status"),
                      trailing: Icon(
                        Icons.flag,
                        color: house.acceptedBy != null
                            ? Colors.green
                            : Colors.red,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => HouseDetailsScreen(
                                  house: house, isCustomerView: true)),
                        );
                        _fetchData();
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- CHAT TAB --------------------
  Widget _buildChatTab() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Chats",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (chatHouses.isEmpty)
              const Text("No chats available yet.")
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chatHouses.length,
                itemBuilder: (context, index) {
                  final house = chatHouses[index];
                  String status = house.isFinished ? "Finished" : "Ongoing";
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        house.imageUrls.isNotEmpty
                            ? house.imageUrls.first
                            : 'https://via.placeholder.com/100?text=No+Image',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(house.title),
                      subtitle: Text("Chat - $status"),
                      trailing: const Icon(Icons.chat),
                      onTap: () async {
                        // Instead of going to HouseDetailsScreen, you might want to go directly to ChatScreen:
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(house: house),
                          ),
                        );
                        _fetchData();
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // -------------------- PROFILE TAB --------------------
  Widget _buildProfileTab() {
    final user = firebaseService.currentUser;
    if (user == null) {
      return const Center(child: Text("No user signed in."));
    }
    final name = user.name.isEmpty ? 'No Name' : user.name;
    final contact = user.contactNumber.isEmpty ? 'No Contact' : user.contactNumber;
    final address = user.address.isEmpty ? 'No Address' : user.address;
    final ratingValue = user.rating;
    final pictureUrl = user.pictureUrl.isNotEmpty ? user.pictureUrl : 'https://via.placeholder.com/100';

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(pictureUrl),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Contact: $contact"),
            Text("Address: $address"),
            const SizedBox(height: 8),
            Text("Rating: ${ratingValue.toStringAsFixed(1)}"),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await firebaseService.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                }
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
