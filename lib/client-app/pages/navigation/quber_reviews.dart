import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/common/models/review.dart';

class QuberReviewsPage extends StatelessWidget {

  final List<Review> reviews;

  const QuberReviewsPage({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Comentarios"),
          titleTextStyle: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)
      ),
      body: ListView.separated(
          itemCount: reviews.length,
          itemBuilder: (context, index) => _buildReviewItem(context, reviews[index]),
          separatorBuilder: (context, index )=> Divider())
    );
  }

  Widget _buildReviewItem(BuildContext context, Review review) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image + Name
          Row(
            spacing: 8.0,
            children: [CircleAvatar(), Text(review.client.name)],
          ),
          // Rating + Date
          Row(
            spacing: 8.0,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        size: Theme.of(context).iconTheme.size! * 0.5,
                        color: Theme.of(context).colorScheme.primaryContainer
                    );
                  })
              ),
              Text(
                DateFormat("d 'de' MMMM 'de' y", 'es_ES').format(review.timestamp),
                style: Theme.of(context).textTheme.bodySmall,
              )
            ]
          ),
          // Comment text
          Text(review.comment)
        ]
      ),
    );
  }
}