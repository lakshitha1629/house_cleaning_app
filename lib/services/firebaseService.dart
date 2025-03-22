import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_cleaning_app/models/user.dart' as app_user;
import 'package:house_cleaning_app/models/house.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app_user.User? currentUser;

  // Sign in user
  Future<bool> signIn(String username, String password) async {
    try {
      // Firebase Authentication uses email, so we'll use username as email
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: '$username@example.com',
        password: password,
      );
      
      if (userCredential.user != null) {
        // Get user details from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          currentUser = app_user.User(
            id: userCredential.user!.uid,
            name: userData['name'] ?? '',
            role: userData['role'] ?? '',
            username: userData['username'] ?? '',
            password: password, // Note: You shouldn't store passwords in the app
            contactNumber: userData['contactNumber'] ?? '',
            address: userData['address'] ?? '',
            pictureUrl: userData['pictureUrl'] ?? '',
          );
          
          // Set reviews and rating if they exist
          if (userData['reviews'] != null) {
            currentUser!.reviews = List<String>.from(userData['reviews']);
          }
          if (userData['rating'] != null) {
            currentUser!.rating = userData['rating'];
          }
          
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign up user
  Future<bool> signUp({
    required String name,
    required String role,
    required String username,
    required String password,
    required String email,
    required String contactNumber,
    required String address,
    required String pictureUrl,
  }) async {
    try {
      // Check if username already exists
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      
      if (usernameQuery.docs.isNotEmpty) {
        return false; // Username already exists
      }

      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: '$username@example.com',
        password: password,
      );

      if (userCredential.user != null) {
        // Store additional user data in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'role': role,
          'username': username,
          'contactNumber': contactNumber,
          'address': address,
          'pictureUrl': pictureUrl,
          'reviews': [],
          'rating': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Set current user
        currentUser = app_user.User(
          id: userCredential.user!.uid,
          name: name,
          role: role,
          username: username,
          password: password,
          contactNumber: contactNumber,
          address: address,
          pictureUrl: pictureUrl,
        );
        
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
  }

  // Get all users
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      return usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return app_user.User(
          id: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          username: data['username'] ?? '',
          password: '', // Don't store passwords
          contactNumber: data['contactNumber'] ?? '',
          address: data['address'] ?? '',
          pictureUrl: data['pictureUrl'] ?? '',
          reviews: data['reviews'] != null ? List<String>.from(data['reviews']) : [],
          rating: data['rating'] ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  // Get all cleaners
  Future<List<app_user.User>> getAllCleaners() async {
    try {
      final cleanersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'cleaner')
          .get();
      
      return cleanersSnapshot.docs.map((doc) {
        final data = doc.data();
        return app_user.User(
          id: doc.id,
          name: data['name'] ?? '',
          role: data['role'] ?? '',
          username: data['username'] ?? '',
          password: '', // Don't store passwords
          contactNumber: data['contactNumber'] ?? '',
          address: data['address'] ?? '',
          pictureUrl: data['pictureUrl'] ?? '',
          reviews: data['reviews'] != null ? List<String>.from(data['reviews']) : [],
          rating: data['rating'] ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print('Get all cleaners error: $e');
      return [];
    }
  }

  // Get all houses
  Future<List<House>> getAllHouses() async {
    try {
      final housesSnapshot = await _firestore.collection('houses').get();
      return housesSnapshot.docs.map((doc) {
        final data = doc.data();
        return House(
          id: doc.id,
          title: data['title'] ?? '',
          rooms: data['rooms'] ?? 0,
          bathrooms: data['bathrooms'] ?? 0,
          kitchen: data['kitchen'] ?? false,
          garage: data['garage'] ?? false,
          flooringType: data['flooringType'] ?? '',
          address: data['address'] ?? '',
          location: data['location'] ?? '',
          payment: data['payment'] ?? 0.0,
          ownerId: data['ownerId'] ?? '',
          imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
          acceptedBy: data['acceptedBy'],
          isFinished: data['isFinished'] ?? false,
          messages: data['messages'] != null ? 
            List<Map<String, String>>.from(
              (data['messages'] as List).map((msg) => 
                Map<String, String>.from(msg.map((k, v) => MapEntry(k.toString(), v.toString())))
              )
            ) : null,
        );
      }).toList();
    } catch (e) {
      print('Get all houses error: $e');
      return [];
    }
  }

  // Add a new house
  Future<House?> addHouse({
    required String title,
    required int rooms,
    required int bathrooms,
    required bool kitchen,
    required bool garage,
    required String flooringType,
    required String address,
    required String location,
    required double payment,
  }) async {
    try {
      if (currentUser == null) return null;
      
      final docRef = await _firestore.collection('houses').add({
        'title': title,
        'rooms': rooms,
        'bathrooms': bathrooms,
        'kitchen': kitchen,
        'garage': garage,
        'flooringType': flooringType,
        'address': address,
        'location': location,
        'payment': payment,
        'ownerId': currentUser!.id,
        'imageUrls': ['https://via.placeholder.com/400?text=NewHouse'],
        'acceptedBy': null,
        'isFinished': false,
        'messages': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      final newHouse = House(
        id: docRef.id,
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
        imageUrls: ['https://via.placeholder.com/400?text=NewHouse'],
      );
      
      return newHouse;
    } catch (e) {
      print('Add house error: $e');
      return null;
    }
  }

  // Get available houses
  Future<List<House>> getAvailableHouses() async {
    try {
      final housesSnapshot = await _firestore
          .collection('houses')
          .where('acceptedBy', isNull: true)
          .where('isFinished', isEqualTo: false)
          .get();
      
      return housesSnapshot.docs.map((doc) {
        final data = doc.data();
        return House(
          id: doc.id,
          title: data['title'] ?? '',
          rooms: data['rooms'] ?? 0,
          bathrooms: data['bathrooms'] ?? 0,
          kitchen: data['kitchen'] ?? false,
          garage: data['garage'] ?? false,
          flooringType: data['flooringType'] ?? '',
          address: data['address'] ?? '',
          location: data['location'] ?? '',
          payment: data['payment'] ?? 0.0,
          ownerId: data['ownerId'] ?? '',
          imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
          acceptedBy: data['acceptedBy'],
          isFinished: data['isFinished'] ?? false,
          messages: data['messages'] != null ? 
            List<Map<String, String>>.from(
              (data['messages'] as List).map((msg) => 
                Map<String, String>.from(msg.map((k, v) => MapEntry(k.toString(), v.toString())))
              )
            ) : null,
        );
      }).toList();
    } catch (e) {
      print('Get available houses error: $e');
      return [];
    }
  }

  // Get notifications for user
  Future<List<Map<String, dynamic>>> getNotificationsForUser(String userId) async {
    try {
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      
      return notificationsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'] ?? '',
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'timestamp': data['timestamp'] ?? FieldValue.serverTimestamp(),
        };
      }).toList();
    } catch (e) {
      print('Get notifications error: $e');
      return [];
    }
  }

  // Get ongoing houses
  Future<List<House>> getOngoingHouses(String userId, String role) async {
    try {
      late QuerySnapshot housesSnapshot;
      
      if (role == 'customer') {
        housesSnapshot = await _firestore
            .collection('houses')
            .where('ownerId', isEqualTo: userId)
            .where('acceptedBy', isNull: false)
            .where('isFinished', isEqualTo: false)
            .get();
      } else {
        housesSnapshot = await _firestore
            .collection('houses')
            .where('acceptedBy', isEqualTo: userId)
            .where('isFinished', isEqualTo: false)
            .get();
      }
      
      return housesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return House(
          id: doc.id,
          title: data['title'] ?? '',
          rooms: data['rooms'] ?? 0,
          bathrooms: data['bathrooms'] ?? 0,
          kitchen: data['kitchen'] ?? false,
          garage: data['garage'] ?? false,
          flooringType: data['flooringType'] ?? '',
          address: data['address'] ?? '',
          location: data['location'] ?? '',
          payment: data['payment'] ?? 0.0,
          ownerId: data['ownerId'] ?? '',
          imageUrls: data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
          acceptedBy: data['acceptedBy'],
          isFinished: data['isFinished'] ?? false,
          messages: data['messages'] != null ? 
            List<Map<String, String>>.from(
              (data['messages'] as List).map((msg) => 
                Map<String, String>.from(msg.map((k, v) => MapEntry(k.toString(), v.toString())))
              )
            ) : null,
        );
      }).toList();
    } catch (e) {
      print('Get ongoing houses error: $e');
      return [];
    }
  }

  // Accept a house job
  Future<void> acceptHouse(String houseId, String cleanerId) async {
    try {
      await _firestore.collection('houses').doc(houseId).update({
        'acceptedBy': cleanerId,
      });
      
      // Add notification for house owner
      final houseDoc = await _firestore.collection('houses').doc(houseId).get();
      if (houseDoc.exists) {
        final data = houseDoc.data() as Map<String, dynamic>;
        final ownerId = data['ownerId'];
        final title = data['title'];
        
        // Get cleaner name
        final cleanerDoc = await _firestore.collection('users').doc(cleanerId).get();
        String cleanerName = 'A cleaner';
        if (cleanerDoc.exists) {
          cleanerName = cleanerDoc.data()?['name'] ?? 'A cleaner';
        }
        
        await _firestore.collection('notifications').add({
          'userId': ownerId,
          'title': 'Job Accepted',
          'message': '$cleanerName accepted your cleaning request for $title',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Accept house error: $e');
    }
  }

  // More methods can be implemented similarly...
}