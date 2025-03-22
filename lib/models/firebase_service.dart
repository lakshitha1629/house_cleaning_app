import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_cleaning_app/models/user.dart';

class FirebaseService {

  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection("users");

  // Future<void> addUser(String id, String name, String role, String username,
  //     String password, String contactNumber, String address, String pictureUrl) async {
  //   try{
  //     final newUser = User(
  //       id: id,
  //       name: name,
  //       role: role,
  //       username: username,
  //       password: password,
  //       contactNumber: contactNumber,
  //       address: address,
  //       pictureUrl: pictureUrl,
  //     );
  //
  //     final Map<String, dynamic> user = newUser.toJson();
  //     await usersCollection.doc(id).set(user);
  //     print("✅User added successfully!");
  //   }
  //   catch(e){
  //     print("❌Error adding user: $e");
  //   }
  //
  //
  // }
  Future<void> addUser({
    required String name,
    required String role,
    required String username,
    required String password,
    required String contactNumber,
    required String address,
    required String pictureUrl,
  }) async {
    try {
      // Generate a unique ID for the user
      String docId = usersCollection.doc().id;

      final newUser = User(
        id: docId,
        name: name,
        role: role,
        username: username,
        password: password,
        contactNumber: contactNumber,
        address: address,
        pictureUrl: pictureUrl,
      );

      final Map<String, dynamic> user = newUser.toJson();
      await usersCollection.doc(docId).set(user);
      print("✅ User added successfully with ID: $docId");
    } catch (e) {
      print("❌ Error adding user: $e");
    }
  }

  Stream<List<User>> getUsers(){
    return usersCollection.snapshots().map((snapshot) => snapshot.docs.map((doc) => User.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

}