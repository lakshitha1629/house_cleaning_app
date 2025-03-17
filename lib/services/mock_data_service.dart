import 'package:house_cleaning_app/models/user.dart';
import 'package:house_cleaning_app/models/house.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final List<User> _users = [];
  final List<House> _houses = [];
  User? currentUser;

  // NEW: Store some mock notifications
  final List<Map<String, String>> _notifications = [];

  // Return notifications for a specific user
  List<Map<String, String>> getNotificationsForUser(String userId) {
    return _notifications.where((n) => n['userId'] == userId).toList();
  }

  void initializeMockData() {
    // Add some default users
    _users.addAll([
      User(
        id: 'u1',
        name: 'Alice Customer',
        role: 'customer',
        username: 'alice',
        password: '123',
        contactNumber: '123-456-7890',
        address: '123 Main St',
        pictureUrl: 'https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_0.jpg',
     ),
      User(
        id: 'u2',
        name: 'Bob Cleaner',
        role: 'cleaner',
        username: 'bob',
        password: '123',
        contactNumber: '987-654-3210',
        address: '456 Side St',
        pictureUrl: 'https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg',
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
          'https://www.lankaislandproperties.com/wp-content/uploads/2024/02/1-11-400x263.jpg',
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
        ],
      ),
       House(
        id: 'h3',
        title: '2-Bedroom House (Available)',
        rooms: 2,
        bathrooms: 1,
        kitchen: true,
        garage: false,
        flooringType: 'Wood',
        address: '789 Another St',
        location: 'Chicago',
        payment: 80.0,
        ownerId: 'u1',
        imageUrls: [
          'https://nexahomes.com.au/wp-content/uploads/2023/10/facade-min.png',
        ],
      ),
    ]);

    // Make h1 ongoing (accepted by Bob but not finished)
    _houses[0].acceptedBy = 'u2'; 
    _houses[0].isFinished = false;
    _houses[0].messages.addAll([
      {'senderId': 'u1', 'text': 'Hello, can you clean my house?'},
      {'senderId': 'u2', 'text': 'Sure, see you at 10 AM.'},
    ]);

    // Make h2 completed (accepted by Bob, finished)
    _houses[1].acceptedBy = 'u2';
    _houses[1].isFinished = true;
    _houses[1].messages.addAll([
      {'senderId': 'u1', 'text': 'Thanks for cleaning!'},
      {'senderId': 'u2', 'text': 'My pleasure!'},
    ]);

    // Mock notifications
    _notifications.addAll([
      {
        'id': 'n1',
        'userId': 'u1',
        'title': 'Job Accepted',
        'message': 'Bob accepted your cleaning request for Cozy 3-Bedroom House',
      },
      {
        'id': 'n2',
        'userId': 'u1',
        'title': 'Job Completed',
        'message': 'Bob has completed cleaning 1-Bedroom Apartment',
      },
      {
        'id': 'n3',
        'userId': 'u2',
        'title': 'New Job Posted',
        'message': 'Alice posted a new job: Cozy 3-Bedroom House',
      },
    ]);
  }

  // getters
  List<User> get allUsers => _users;
  List<House> get allHouses => _houses;

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

  bool signUp({
    required String name,
    required String role,
    required String username,
    required String password,
    required String contactNumber,
    required String address,
    required String pictureUrl,
  }) {
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

  void signOut() {
    currentUser = null;
  }

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
        'https://via.placeholder.com/400?text=House${_houses.length + 1}A',
      ],
    );
    _houses.add(newHouse);
    return newHouse;
  }

  void deleteHouse(String houseId) {
    _houses.removeWhere((h) => h.id == houseId);
  }

  void updateHouse(House house) {
    final index = _houses.indexWhere((h) => h.id == house.id);
    if (index >= 0) {
      _houses[index] = house;
    }
  }

  List<House> getAvailableHouses() {
    return _houses.where((h) => h.acceptedBy == null && !h.isFinished).toList();
  }

  List<House> getOngoingHouses(String userId, String role) {
    if (role == 'customer') {
      return _houses.where((h) => 
        h.ownerId == userId && 
        h.acceptedBy != null && 
        !h.isFinished
      ).toList();
    } else {
      return _houses.where((h) => 
        h.acceptedBy == userId && 
        !h.isFinished
      ).toList();
    }
  }

  List<House> getCompletedHouses(String userId, String role) {
    if (role == 'customer') {
      return _houses.where((h) => 
        h.ownerId == userId && 
        h.isFinished
      ).toList();
    } else {
      return _houses.where((h) => 
        h.acceptedBy == userId && 
        h.isFinished
      ).toList();
    }
  }

  List<User> getAllCleaners() {
    return _users.where((u) => u.role == 'cleaner').toList();
  }

  void acceptHouse(String houseId, String cleanerId) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.acceptedBy = cleanerId;
    updateHouse(house);
  }

  void sendMessage(String houseId, String senderId, String text) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.messages.add({'senderId': senderId, 'text': text});
    updateHouse(house);
  }

  void finishHouse(String houseId) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.isFinished = true;
    updateHouse(house);
  }

  void addReviewToUser(String userId, String review, double rating) {
    final user = _users.firstWhere((u) => u.id == userId);
    user.reviews.add(review);
    final count = user.reviews.length;
    user.rating = ((user.rating * (count - 1)) + rating) / count;
  }

  void addReviewToHouse(String houseId, String review) {
    final house = _houses.firstWhere((h) => h.id == houseId);
    house.messages.add({'senderId': 'system', 'text': 'Review: $review'});
    updateHouse(house);
  }
}
