import 'package:flutter/material.dart';
import 'package:house_cleaning_app/models/house.dart';
import 'package:house_cleaning_app/services/firebaseService.dart';

class ReviewScreen extends StatefulWidget {
  final House house;
  const ReviewScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _feedbackCtrl = TextEditingController();
  double _rating = 0.0;
  final firebaseService = FirebaseService();

  Future<void> _submitReview() async {
    final feedback = _feedbackCtrl.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }
    final house = widget.house;
    final currentUser = firebaseService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user signed in.')),
      );
      return;
    }

    try {
      if (currentUser.role == 'customer' && house.acceptedBy != null) {
        // If customer, review the cleaner.
        await firebaseService.addReviewToUser(house.acceptedBy!, 'Customer Feedback: $feedback (Rating: $_rating)', _rating);
        await firebaseService.addReviewToHouse(house.id, 'Customer Feedback: $feedback (Rating: $_rating)');
      } else if (currentUser.role == 'cleaner') {
        // If cleaner, review the customer (house owner)
        await firebaseService.addReviewToUser(house.ownerId, 'Cleaner Feedback: $feedback (Rating: $_rating)', _rating);
        await firebaseService.addReviewToHouse(house.id, 'Cleaner Feedback: $feedback (Rating: $_rating)');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
        backgroundColor: Colors.blueAccent,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
