import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/screens/add_house_screen.dart';
import 'package:house_cleaning_app/screens/house_details_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;
  
  // Sample direct data
  final List<House> ongoingHouses = [];
  final List<House> completedHouses = [];
  final List<Map<String, String>> notifications = [];
  final List<House> myHouses = [];
  
  // Sample user data
  final Map<String, dynamic> userData = {
    'name': 'John Doe',
    'contactNumber': '123-456-7890',
    'address': '123 Main St, City',
    'pictureUrl': 'https://via.placeholder.com/150',
    'rating': 4.5,
  };

  @override
  void initState() {
    super.initState();
    // Here you would normally fetch data from a real service
    _loadData();
  }

  void _loadData() {
    // This would be replaced with actual API calls
    setState(() {
      // Example data
      // Add some sample houses
    });
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
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Add Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // 1) HOME TAB
  Widget _buildHomeTab() {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF3A30A8),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5359BF), Color(0xFF3A30A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                // Menu action
              },
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  // Notification action
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(image: AssetImage("assets/living.jpg"),
              width: double.infinity,
              height: 500,
              fit: BoxFit.cover,
              ),
              SizedBox(
                height: 20,
              ),
              // Welcome section with gradient container
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5359BF), Color(0xFF3A30A8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(1, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${userData['name']}!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Find the best cleaning services for your home. Schedule your next cleaning session today!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Cleaning Categories Section
              const SizedBox(height: 24),
              const Text(
                "Cleaning Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Categories Row 1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                _buildCategoryButton(
                  icon: Icons.house_outlined,
                  label: "Regular",
                  color: Color(0xFF5359BF),
                ),
                _buildCategoryButton(
                  icon: Icons.cleaning_services_outlined, 
                  label: "Deep Clean",
                  color: Color(0xFF3A30A8),
                ),
                _buildCategoryButton(
                  icon: Icons.weekend_outlined,
                  label: "Furniture",
                  color: Color(0xFF5359BF),
                ),
                ],
              ),
              
              // Categories Row 2
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                _buildCategoryButton(
                  icon: Icons.window_outlined,
                  label: "Windows",
                  color: Color(0xFF3A30A8),
                ),
                _buildCategoryButton(
                  icon: Icons.kitchen_outlined,
                  label: "Kitchen",
                  color: Color(0xFF5359BF),
                ),
                ],
              ),
              const SizedBox(height: 20),
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
                  setState(() {
                    _loadData(); // Refresh data after returning
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add House"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHouseCard(House house, {required bool isOngoing}) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: true)),
        );
        setState(() {
          _loadData(); // Refresh data after returning
        });
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
  Widget _buildNotificationsTab() {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: GlobalKey<FormState>(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Add New Cleaning Request",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A30A8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Post Title
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Post Title",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Location
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Number of Rooms
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Number of Rooms",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bedroom_parent),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of rooms';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Number of Bathrooms
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Number of Bathrooms",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.bathroom),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of bathrooms';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Floor Type
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Floor Type",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.layers),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter floor type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Contact Number
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Contact Number",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A30A8),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          onPressed: () {
                            // Validate form
                            final formState = Form.of(context)?.validate() ?? false;
                            if (formState) {
                              // Process data
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing request...')),
                              );
                            }
                          },
                          child: const Text(
                            "Submit Request",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HouseDetailsScreen(house: house, isCustomerView: true)),
                );
                setState(() {
                  _loadData(); // Refresh data after returning
                });
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
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(userData['pictureUrl']),
            ),
            const SizedBox(height: 16),
            Text(
              userData['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Contact: ${userData['contactNumber']}"),
            Text("Address: ${userData['address']}"),
            const SizedBox(height: 8),
            if (userData['rating'] > 0)
              Text("Rating: ${userData['rating'].toStringAsFixed(1)}"),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Sign out logic
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
