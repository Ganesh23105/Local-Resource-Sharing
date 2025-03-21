import 'package:flutter/material.dart';
import 'package:local_resource_sharing/models/resource_item.dart';
import 'package:local_resource_sharing/screens/item_detail_screen.dart';

/// **ResourceCard Widget**
/// Displays a resource item in a structured card format.
class ResourceCard extends StatelessWidget {
  final ResourceItem item;

  const ResourceCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemDetailScreen(item: item)),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Display
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Owner: ${item.owner}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        Text(
                          'Category: ${item.category}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
