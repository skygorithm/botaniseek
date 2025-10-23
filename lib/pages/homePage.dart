import 'package:flutter/material.dart';
import 'plantDetailsPage.dart';

class HomePage extends StatelessWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> plants = [
      {
        'name': 'Monstera Deliciosa',
        'image':
            'https://images.unsplash.com/photo-1616627455152-fdd8a1e3d9f3?auto=format&fit=crop&w=400&q=60',
        'location': 'Central America'
      },
      {
        'name': 'Snake Plant',
        'image':
            'https://images.unsplash.com/photo-1598620617135-5b8b40f0b0b8?auto=format&fit=crop&w=400&q=60',
        'location': 'West Africa'
      },
      {
        'name': 'Peace Lily',
        'image':
            'https://images.unsplash.com/photo-1587502536263-1f6e3b8c4b1d?auto=format&fit=crop&w=400&q=60',
        'location': 'Tropical Americas'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    plant['image']!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const Icon(Icons.image_not_supported, size: 60);
                    },
                  ),
                ),
                title: Text(
                  plant['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Location: ${plant['location']}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlantDetailPage(
                        name: plant['name']!,
                        image: plant['image']!,
                        location: plant['location']!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
