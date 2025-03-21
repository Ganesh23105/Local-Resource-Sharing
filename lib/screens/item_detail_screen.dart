import 'package:flutter/material.dart';
import 'package:local_resource_sharing/models/resource_item.dart';

/// **ItemDetailScreen Class**
/// Displays detailed information about a selected resource.
class ItemDetailScreen extends StatelessWidget {
  final ResourceItem item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Display
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image Not Found'));
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Item Name
            Text(
              item.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              item.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Owner
            Text(
              'Owner: ${item.owner}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Category
            Text(
              'Category: ${item.category}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Borrow Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have requested to borrow ${item.name}')),
                  );
                },
                child: const Text('Borrow Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
