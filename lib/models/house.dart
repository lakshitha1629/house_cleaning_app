class House {
  final String id;
  String title;
  int rooms;
  int bathrooms;
  bool kitchen;
  bool garage;
  String flooringType;
  String address;
  String location;
  double payment; // or budget
  String ownerId; // The Customer who posted
  String? acceptedBy; // The Cleaner who accepted (if any)
  List<String> imageUrls; // House pictures
  bool isFinished; // Mark if the job is finished
  List<Map<String, String>> messages; 
  // A very simple in-memory chat: each message = { 'senderId': '...', 'text': '...' }

  House({
    required this.id,
    required this.title,
    required this.rooms,
    required this.bathrooms,
    required this.kitchen,
    required this.garage,
    required this.flooringType,
    required this.address,
    required this.location,
    required this.payment,
    required this.ownerId,
    this.acceptedBy,
    List<String>? imageUrls,
    bool? isFinished,
    List<Map<String, String>>? messages,
  })  : imageUrls = imageUrls ?? [],
        isFinished = isFinished ?? false,
        messages = messages ?? [];
}
