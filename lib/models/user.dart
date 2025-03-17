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
}
