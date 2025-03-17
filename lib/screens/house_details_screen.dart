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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gallery of images
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  for (var url in house.imageUrls)
                    Image.network(url, fit: BoxFit.cover),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Rooms: ${house.rooms}, Bathrooms: ${house.bathrooms}'),
            Text('Kitchen: ${house.kitchen ? 'Yes' : 'No'}'),
            Text('Garage: ${house.garage ? 'Yes' : 'No'}'),
            Text('Flooring Type: ${house.flooringType}'),
            Text('Address: ${house.address}'),
            Text('Location: ${house.location}'),
            Text('Payment: \$${house.payment}'),
            const Divider(),
            Text('Status: '
                '${house.acceptedBy == null ? 'Not Accepted' : house.isFinished ? 'Finished' : 'In Progress'}'),
            const SizedBox(height: 20),
            if (house.acceptedBy != null && !house.isFinished)
              ElevatedButton(
                onPressed: () {
                  // Go to Chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(house: house),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: const Text('Go to Chat'),
              ),
            if (house.acceptedBy != null &&
                house.acceptedBy == mockService.currentUser?.id &&
                !house.isFinished)
              ElevatedButton(
                onPressed: () {
                  // Mark as finished
                  mockService.finishHouse(house.id);
                  setState(() {});
                },
                child: const Text('Mark as Finished'),
              ),
            if (house.isFinished)
              ElevatedButton(
                onPressed: () {
                  // Add review
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(house: house),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: const Text('Leave a Review'),
              ),
          ],
        ),
      ),
    );
  }
}
