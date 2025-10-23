import 'package:flutter/material.dart';

class PlantDetailPage extends StatelessWidget {
  final String name;
  final String image;
  final String location;

  const PlantDetailPage({
    super.key,
    required this.name,
    required this.image,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Image.network(
            image,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 80),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Scientific Name: $location',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
