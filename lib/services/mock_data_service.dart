import 'package:house_cleaning_app/models/user.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'dart:math';

class MockDataService {
  // Singleton pattern (optional)
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // In-memory lists for users and houses
  final List<User> _users = [];
  final List<House> _houses = [];

  // Currently logged in user
  User? currentUser;

  // Simulate loading some JSON data at startup
  void initializeMockData() {
    // Add some default users (customers & cleaners)
    _users.addAll([
      User(
        id: 'u1',
        name: 'Alice Customer',
        role: 'customer',
        username: 'alice',
        password: '123',
        contactNumber: '123-456-7890',
        address: '123 Main St',
        pictureUrl: 'https://cdn.iconscout.com/icon/free/png-256/free-user-icon-download-in-svg-png-gif-file-formats--profile-avatar-account-person-app-interface-pack-icons-1401302.png',
      ),
      User(
        id: 'u2',
        name: 'Bob Cleaner',
        role: 'cleaner',
        username: 'bob',
        password: '123',
        contactNumber: '987-654-3210',
        address: '456 Side St',
        pictureUrl: 'https://cdn.iconscout.com/icon/free/png-256/free-user-icon-download-in-svg-png-gif-file-formats--profile-avatar-account-person-app-interface-pack-icons-1401302.png',
      ),
    ]);

    // Add some default houses
    _houses.addAll([
      House(
        id: 'h1',
        title: 'Cozy 3-Bedroom House',
        rooms: 3,
        bathrooms: 2,
        kitchen: true,
        garage: true,
        flooringType: 'Tile',
        address: '123 Main St',
        location: 'New York',
        payment: 100.0,
        ownerId: 'u1',
        imageUrls: [
          'https://media-cdn.tripadvisor.com/media/photo-s/2c/b0/b6/2b/apartment-hotels.jpg',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSagfZcNvESS-xuuzqBMOn124U07WyjRrxzpQ&s',
        ],
      ),
      House(
        id: 'h2',
        title: '1-Bedroom Apartment',
        rooms: 1,
        bathrooms: 1,
        kitchen: true,
        garage: false,
        flooringType: 'Carpet',
        address: '45 Park Ave',
        location: 'Boston',
        payment: 60.0,
        ownerId: 'u1',
        imageUrls: [
          'https://media-cdn.tripadvisor.com/media/photo-s/2c/b0/b6/2b/apartment-hotels.jpg',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSagfZcNvESS-xuuzqBMOn124U07WyjRrxzpQ&s',
        ],
      ),
    ]);
  }

  // Get read-only lists
  List<User> get allUsers => _users;
  List<House> get allHouses => _houses;

  // Sign In
  bool signIn(String username, String password) {
    final user = _users.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => User(
        id: '',
        name: '',
        role: '',
        username: '',
        password: '',
        contactNumber: '',
        address: '',
        pictureUrl: '',
      ),
    );
    if (user.id.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }

  // Sign Up
  bool signUp({
    required String name,
    required String role,
    required String username,
    required String password,
    required String contactNumber,
    required String address,
    required String pictureUrl,
  }) {
    // Check if username already exists
    final existing = _users.any((u) => u.username == username);
    if (existing) return false;

    final newUser = User(
      id: 'u${_users.length + 1}',
      name: name,
      role: role,
      username: username,
      password: password,
      contactNumber: contactNumber,
      address: address,
      pictureUrl: pictureUrl,
    );
    _users.add(newUser);
    currentUser = newUser;
    return true;
  }

  // Sign Out
  void signOut() {
    currentUser = null;
  }

  // Add House
  House addHouse({
    required String title,
    required int rooms,
    required int bathrooms,
    required bool kitchen,
    required bool garage,
    required String flooringType,
    required String address,
    required String location,
    required double payment,
  }) {
    final newHouse = House(
      id: 'h${_houses.length + 1}',
      title: title,
      rooms: rooms,
      bathrooms: bathrooms,
      kitchen: kitchen,
      garage: garage,
      flooringType: flooringType,
      address: address,
      location: location,
      payment: payment,
      ownerId: currentUser!.id,
      imageUrls: [
        // In a real app, user picks images. We'll store placeholders for now.
        'https://via.placeholder.com/400?text=House${_houses.length + 1}A',
      ],
    );
    _houses.add(newHouse);
    return newHouse;
  }

  // Update House
  void updateHouse(House house) {
    final index = _houses.indexWhere((h) => h.id == house.id);
    if (index >= 0) {
      _houses[index] = house;
    }
  }

  // Delete House
  void deleteHouse(String houseId) {
    _houses.removeWhere((h) => h.id == houseId);
  }

  // Filter houses for a cleaner (only those that are not accepted yet)
  List<House> getAvailableHouses() {
    return _houses.where((h) => h.acceptedBy == null && !h.isFinished).toList();
  }

  // Accept House
  void acceptHouse(String houseId, String cleanerId) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.acceptedBy = cleanerId;
    updateHouse(house);
  }

  // Send Chat Message
  void sendMessage(String houseId, String senderId, String text) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.messages.add({'senderId': senderId, 'text': text});
    updateHouse(house);
  }

  // Mark House as finished
  void finishHouse(String houseId) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.isFinished = true;
    updateHouse(house);
  }

  // Add review to user
  void addReviewToUser(String userId, String review, double rating) {
    final user = _users.firstWhere((u) => u.id == userId);
    user.reviews.add(review);
    // Recalculate average rating
    final totalReviews = user.reviews.length;
    // Just a naive approach: average rating as sum of rating / count
    // In a real scenario, you'd store numeric ratings separately
    user.rating = ((user.rating * (totalReviews - 1)) + rating) / totalReviews;
  }

  // Add review to House
  void addReviewToHouse(String houseId, String review) {
    // Could store a separate list if needed
    // For simplicity, let's just add a message in the chat as "house review"
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.messages.add({'senderId': 'system', 'text': 'House Review: $review'});
    updateHouse(house);
  }
}
