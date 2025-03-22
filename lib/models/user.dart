class User {
  final String id;
  String name;
  String role; // 'customer' or 'cleaner'
  String username;
  String password;
  String contactNumber;
  String address;
  String pictureUrl; // Placeholder for user image
  double rating; // Average rating
  List<String> reviews; // Store textual reviews from others

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.password,
    required this.contactNumber,
    required this.address,
    required this.pictureUrl,
    this.rating = 0.0,
    List<String>? reviews,
  }) : reviews = reviews ?? [];

  factory User.fromJson(Map<String, dynamic> doc, String docId) {
    return User(
        id: docId,
        name: doc['name'] ?? 'No name',
        role: doc['role'] ?? 'No role',
        username: doc['username'] ?? 'No username',
        password: doc['password'] ?? 'No password',
        contactNumber: doc['contactNumber'] ?? 'No contact number',
        address: doc['address'] ?? 'No address',
        pictureUrl: doc['pictureUrl'] ?? 'No picture URL',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'username': username,
      'password': password,
      'contactNumber': contactNumber,
      'address': address,
      'pictureUrl': pictureUrl,
    };
  }



}
