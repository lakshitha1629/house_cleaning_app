import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';
import 'package:house_cleaning_app/screens/chat_screen.dart';
import 'package:house_cleaning_app/screens/review_screen.dart';

class HouseDetailsScreen extends StatefulWidget {
  final House house;
  final bool isCustomerView;

  const HouseDetailsScreen({
    Key? key,
    required this.house,
    required this.isCustomerView,
  }) : super(key: key);

  @override
  State<HouseDetailsScreen> createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  final mockService = MockDataService();

  @override
  Widget build(BuildContext context) {
    final house = widget.house;
    return Scaffold(
      appBar: AppBar(
        title: Text(house.title),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          // Gallery Section with rounded corners
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView(
                children: house.imageUrls.map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                  );
                }).toList(),
              ),
            ),
          ),
          // Details Section Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Payment Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          house.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${house.payment}",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Location and Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            house.location,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.home, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            house.address,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1),
                    // Features Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeatureItem(Icons.king_bed, "${house.rooms} Rooms"),
                        _buildFeatureItem(Icons.bathtub, "${house.bathrooms} Baths"),
                        _buildFeatureItem(
                            Icons.kitchen, house.kitchen ? "Kitchen" : "No Kitchen"),
                        _buildFeatureItem(
                            Icons.directions_car, house.garage ? "Garage" : "No Garage"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status
                    Text(
                      "Status: ${house.acceptedBy == null ? 'Not Accepted' : house.isFinished ? 'Finished' : 'In Progress'}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (house.acceptedBy != null && !house.isFinished)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(house: house),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat"),
                  ),
                if (house.acceptedBy != null &&
                    house.acceptedBy == mockService.currentUser?.id &&
                    !house.isFinished)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      mockService.finishHouse(house.id);
                      setState(() {});
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Finish Job"),
                  ),
                if (house.isFinished)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(house: house),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text("Review"),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
