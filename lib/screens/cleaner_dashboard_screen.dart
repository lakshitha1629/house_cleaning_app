import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';
import 'package:house_cleaning_app/screens/chat_screen.dart';

class CleanerDashboardScreen extends StatefulWidget {
  const CleanerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CleanerDashboardScreen> createState() => _CleanerDashboardScreenState();
}

class _CleanerDashboardScreenState extends State<CleanerDashboardScreen> {
  int _selectedIndex = 0;

  // For filtering
  String filterLocation = '';
  int? filterRooms;

  // Real data from Firestore
  List<House> availableHouses = [];
  List<House> ongoingHouses = [];

  // For notifications
  List<Map<String, dynamic>> notifications = [];

  // For the Chat tab, houses where this cleaner is the acceptedBy
  List<House> myHouses = [];

  final firebaseService = FirebaseService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    // Make sure someone is signed in
    final user = firebaseService.currentUser;
    if (user == null) {
      // Show a message or redirect user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is signed in.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (user.role != 'cleaner') {
      // Show a message or do something else if user is not a cleaner
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Load available houses
      final loadedAvailable = await firebaseService.getAvailableHouses();
      // 2. Load ongoing houses for this user
      final loadedOngoing =
          await firebaseService.getOngoingHouses(user.id, user.role);
      // 3. For chat tab, let's define "myHouses" as houses where acceptedBy == user.id
      final allHouses = await firebaseService.getAllHouses();
      final chatHouses =
          allHouses.where((h) => h.acceptedBy == user.id).toList();

      // 4. Notifications
      final loadedNotifs =
          await firebaseService.getNotificationsForUser(user.id);

      setState(() {
        availableHouses = loadedAvailable;
        ongoingHouses = loadedOngoing;
        myHouses = chatHouses;
        notifications = loadedNotifs;
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
    final List<Widget> pages = [
      _buildHomeTab(),
      _buildNotificationsTab(),
      _buildChatTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // -------------------- HOME TAB --------------------
  Widget _buildHomeTab() {
    // Filter available houses
    List<House> filteredHouses = availableHouses;
    if (filterLocation.isNotEmpty) {
      filteredHouses = filteredHouses
          .where((h) => h.location.toLowerCase().contains(filterLocation))
          .toList();
    }
    if (filterRooms != null) {
      filteredHouses =
          filteredHouses.where((h) => h.rooms == filterRooms).toList();
    }
    

    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color(0xFF503CB7),
      title: Center(
        child: const Text(
          "Cleaner Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
            ),
        ),
      ),
      ),
      body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                  height: 220,
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
                  height: 220,
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                house.imageUrls.isNotEmpty
                    ? house.imageUrls.first
                    : 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(house.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _acceptHouse(house);
                },
                child: const Text("Accept"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () {
                  // Hide house locally (not recommended in real app)
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
          MaterialPageRoute(
            builder: (_) => ChatScreen(house: house), // direct to ChatScreen
          ),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  house.imageUrls.isNotEmpty
                      ? house.imageUrls.first
                      : 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(house.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Accept a house job in Firestore
  Future<void> _acceptHouse(House house) async {
    final user = firebaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user signed in.')),
      );
      return;
    }
    try {
      await firebaseService.acceptHouse(house.id, user.id);

      // After acceptance, reload data
      await _fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accepted house: ${house.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting house: $e')),
      );
    }
  }

  // -------------------- NOTIFICATIONS TAB --------------------
  Widget _buildNotificationsTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchData,
        child: notifications.isEmpty
            ? const Center(child: Text("No notifications yet."))
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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

  // -------------------- CHAT TAB --------------------
  Widget _buildChatTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchData,
        child: myHouses.isEmpty
            ? const Center(child: Text("No chats available yet."))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myHouses.length,
                itemBuilder: (context, index) {
                  final house = myHouses[index];
                  final status = house.isFinished ? "Finished" : "Ongoing";
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        house.imageUrls.isNotEmpty
                            ? house.imageUrls.first
                            : 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(house.title),
                      subtitle: Text("Chat - $status"),
                      trailing: const Icon(Icons.chat),
                      onTap: () async {
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
    final contact =
        user.contactNumber.isEmpty ? 'No Contact' : user.contactNumber;
    final address = user.address.isEmpty ? 'No Address' : user.address;
    final ratingValue = user.rating;
    final pictureUrl = user.pictureUrl.isNotEmpty
        ? user.pictureUrl
        : 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg';

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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await firebaseService.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/welcome', (route) => false);
                }
              },
              child:
                  const Text("Log Out", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
