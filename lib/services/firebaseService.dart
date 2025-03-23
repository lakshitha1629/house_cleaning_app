import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:house_cleaning_app/models/user.dart' as app_user;
import 'package:house_cleaning_app/models/house.dart';

class FirebaseService {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase references
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // The currently logged-in user
  app_user.User? currentUser;

  // ================== SIGN IN ==================
  Future<bool> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        final docRef =
            _firestore.collection('users').doc(userCredential.user!.uid);
        final userDoc = await docRef.get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          currentUser = app_user.User(
            id: userCredential.user!.uid,
            name: userData['name'] ?? '',
            role: userData['role'] ?? '',
            username: userData['username'] ?? '',
            password: '', // do not store the real password
            contactNumber: userData['contactNumber'] ?? '',
            address: userData['address'] ?? '',
            pictureUrl: userData['pictureUrl'] ?? '',
          );
          if (userData['reviews'] != null) {
            currentUser!.reviews = List<String>.from(userData['reviews']);
          }
          if (userData['rating'] != null) {
            currentUser!.rating = (userData['rating'] as num).toDouble();
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

  // ================== SIGN UP ==================
  Future<bool> signUp({
    required String name,
    required String role,
    required String username,
    required String email,
    required String password,
    required String contactNumber,
    required String address,
    required String pictureUrl,
  }) async {
    try {
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        print('Sign up error: username already in use.');
        return false;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final docRef =
            _firestore.collection('users').doc(userCredential.user!.uid);
        // Initialize with reviews and ratingValues arrays
        await docRef.set({
          'name': name,
          'role': role,
          'username': username,
          'contactNumber': contactNumber,
          'address': address,
          'pictureUrl': pictureUrl,
          'reviews': [],
          'ratingValues': [],
          'rating': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

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

  // ================== SIGN OUT ==================
  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
  }

  // ================== GET ALL HOUSES ==================
  Future<List<House>> getAllHouses() async {
    try {
      final snapshot = await _firestore.collection('houses').get();
      return snapshot.docs.map((doc) => _houseFromDoc(doc)).toList();
    } catch (e) {
      print('Get all houses error: $e');
      return [];
    }
  }

  House _houseFromDoc(QueryDocumentSnapshot doc) {
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
      payment:
          data['payment'] != null ? (data['payment'] as num).toDouble() : 0.0,
      ownerId: data['ownerId'] ?? '',
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      acceptedBy: data['acceptedBy'],
      isFinished: data['isFinished'] ?? false,
      messages: data['messages'] != null
          ? List<Map<String, String>>.from((data['messages'] as List).map(
              (msg) => Map<String, String>.from((msg as Map)
                  .map((k, v) => MapEntry(k.toString(), v.toString())))))
          : [],
    );
  }

  // ================== ADD HOUSE ==================
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
      if (currentUser == null) {
        print('No current user found. Cannot add house.');
        return null;
      }
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
        'imageUrls': ['https://media-cdn.tripadvisor.com/media/photo-s/2c/b0/b6/2b/apartment-hotels.jpg'],
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
        imageUrls: ['https://media-cdn.tripadvisor.com/media/photo-s/2c/b0/b6/2b/apartment-hotels.jpg'],
      );
      return newHouse;
    } catch (e) {
      print('Add house error: $e');
      return null;
    }
  }

  // ================== GET AVAILABLE HOUSES ==================
  Future<List<House>> getAvailableHouses() async {
    try {
      final snapshot = await _firestore
          .collection('houses')
          .where('acceptedBy', isNull: true)
          .where('isFinished', isEqualTo: false)
          .get();
      return snapshot.docs.map((doc) => _houseFromDoc(doc)).toList();
    } catch (e) {
      print('Get available houses error: $e');
      return [];
    }
  }

  // ================== GET ONGOING HOUSES ==================
  Future<List<House>> getOngoingHouses(String userId, String role) async {
    try {
      if (role == 'customer') {
        // For customers: Query houses by ownerId and isFinished false.
        // Then filter out houses that are not accepted (acceptedBy == null).
        final query = await _firestore
            .collection('houses')
            .where('ownerId', isEqualTo: userId)
            .where('isFinished', isEqualTo: false)
            .get();
        final houses = query.docs.map((doc) => _houseFromDoc(doc)).toList();
        return houses.where((h) => h.acceptedBy != null).toList();
      } else {
        // For cleaner: Query houses where acceptedBy equals userId and isFinished false.
        final query = await _firestore
            .collection('houses')
            .where('acceptedBy', isEqualTo: userId)
            .where('isFinished', isEqualTo: false)
            .get();
        return query.docs.map((doc) => _houseFromDoc(doc)).toList();
      }
    } catch (e) {
      print('Get ongoing houses error: $e');
      return [];
    }
  }

  // ================== GET COMPLETED HOUSES ==================
  Future<List<House>> getCompletedHouses(String userId, String role) async {
    try {
      late QuerySnapshot query;
      if (role == 'customer') {
        query = await _firestore
            .collection('houses')
            .where('ownerId', isEqualTo: userId)
            .where('isFinished', isEqualTo: true)
            .get();
      } else {
        query = await _firestore
            .collection('houses')
            .where('acceptedBy', isEqualTo: userId)
            .where('isFinished', isEqualTo: true)
            .get();
      }
      return query.docs.map((doc) => _houseFromDoc(doc)).toList();
    } catch (e) {
      print('Get completed houses error: $e');
      return [];
    }
  }

  // ================== ACCEPT HOUSE ==================
  Future<void> acceptHouse(String houseId, String cleanerId) async {
    try {
      await _firestore.collection('houses').doc(houseId).update({
        'acceptedBy': cleanerId,
      });
      final houseDoc = await _firestore.collection('houses').doc(houseId).get();
      if (houseDoc.exists) {
        final data = houseDoc.data()!;
        final ownerId = data['ownerId'];
        final title = data['title'];
        final cleanerDoc =
            await _firestore.collection('users').doc(cleanerId).get();
        String cleanerName = 'A cleaner';
        if (cleanerDoc.exists) {
          cleanerName = cleanerDoc.data()!['name'] ?? 'A cleaner';
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

  // ================== GET NOTIFICATIONS ==================
  Future<List<Map<String, dynamic>>> getNotificationsForUser(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
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

  // ================== FINISH HOUSE ==================
  Future<void> finishHouse(String houseId) async {
    try {
      await _firestore.collection('houses').doc(houseId).update({
        'isFinished': true,
      });
    } catch (e) {
      print('Finish house error: $e');
    }
  }

  // ================== SEND MESSAGE ==================
  Future<void> sendMessage(String houseId, String senderId, String text) async {
    try {
      final houseRef = _firestore.collection('houses').doc(houseId);
      final houseDoc = await houseRef.get();
      if (!houseDoc.exists) return;

      final data = houseDoc.data() as Map<String, dynamic>;
      final messages = data['messages'] ?? [];
      messages.add({'senderId': senderId, 'text': text});

      await houseRef.update({'messages': messages});
    } catch (e) {
      print('Send message error: $e');
    }
  }

  // ================== REVIEWS ==================
  Future<void> addReviewToUser(
      String userId, String review, double rating) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userSnap = await userRef.get();
      if (!userSnap.exists) return;
      final data = userSnap.data() as Map<String, dynamic>;
      final existingReviews =
          data['reviews'] != null ? List<String>.from(data['reviews']) : [];
      final existingRatingValues = data['ratingValues'] != null
          ? (data['ratingValues'] as List).map((v) => v as double).toList()
          : [];
      existingReviews.add(review);
      existingRatingValues.add(rating);
      final double sum =
          existingRatingValues.fold(0.0, (acc, val) => acc + val);
      final double newAverageRating = existingRatingValues.isEmpty
          ? 0.0
          : sum / existingRatingValues.length;
      await userRef.update({
        'reviews': existingReviews,
        'ratingValues': existingRatingValues,
        'rating': newAverageRating,
      });
      print(
          'Successfully added review "$review" with rating $rating to user $userId');
    } catch (e) {
      print('Add review to user error: $e');
      rethrow;
    }
  }

  Future<void> addReviewToHouse(String houseId, String review) async {
    try {
      final docRef = _firestore.collection('houses').doc(houseId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) return;
      final data = docSnapshot.data() as Map<String, dynamic>;
      final currentMessages = data['messages'] ?? [];
      currentMessages.add({'senderId': 'system', 'text': 'Review: $review'});
      await docRef.update({'messages': currentMessages});
    } catch (e) {
      print('Add review to house error: $e');
      rethrow;
    }
  }
}
