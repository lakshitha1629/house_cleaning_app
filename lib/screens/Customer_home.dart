import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}


class _CustomerHomeState extends State<CustomerHome> {

  int _selectedIndex = 0;

  List<Widget> pages = [
    _buildHomeTab(),
    _buildNotificationsTab(),
    _buildChatTab(),
    _buildProfileTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Home'),

      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: pages[_selectedIndex],
    );
  }
}

Widget _buildHomeTab() {
  return Scaffold(
    body: Column(
      children: [
        Image(image: AssetImage("")),
        Text("Welcome to the Customer Home Page",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        ),
      ],
    )
  );
}

Widget _buildNotificationsTab() {
  return const Text('Notifications');
}

Widget _buildChatTab() {
  return const Text('Chat');
}

Widget _buildProfileTab() {
  return const Text('Profile');
}