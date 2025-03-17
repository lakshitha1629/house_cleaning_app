import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/services/mock_data_service.dart';

class ReviewScreen extends StatefulWidget {
  final House house;
  const ReviewScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _feedbackCtrl = TextEditingController();
  double _rating = 0.0;
  final mockService = MockDataService();

  void _submitReview() {
    final feedback = _feedbackCtrl.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }
    final house = widget.house;
    final currentUser = mockService.currentUser;
    if (currentUser == null) return;

    if (currentUser.role == 'customer' && house.acceptedBy != null) {
      // review the cleaner
      mockService.addReviewToUser(house.acceptedBy!, feedback, _rating);
      mockService.addReviewToHouse(
        house.id,
        'Customer Feedback: $feedback (Rating: $_rating)',
      );
    } else if (currentUser.role == 'cleaner') {
      // review the customer (house owner)
      mockService.addReviewToUser(house.ownerId, feedback, _rating);
      mockService.addReviewToHouse(
        house.id,
        'Cleaner Feedback: $feedback (Rating: $_rating)',
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Rate and review your experience',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Rating:'),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: _rating.toString(),
                    onChanged: (val) {
                      setState(() {
                        _rating = val;
                      });
                    },
                  ),
                ),
                Text(_rating.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackCtrl,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
