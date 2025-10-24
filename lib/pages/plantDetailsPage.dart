import 'package:flutter/material.dart';

class PlantDetailsPage extends StatelessWidget {
  final String name;
  final String scientificName;
  final String image;
  final String location;
  final String coordinates;
  final String properties;
  final String uses;

  const PlantDetailsPage({
    super.key,
    required this.name,
    required this.scientificName,
    required this.image,
    required this.location,
    required this.coordinates,
    required this.properties,
    required this.uses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    image,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Plant Name
              Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              
              // Scientific Name
              Center(
                child: Text(
                  scientificName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Locations Section
              _buildSectionTitle(context, 'Locations', Icons.location_on),
              const SizedBox(height: 8),
              _buildSectionContent(location),
              const SizedBox(height: 20),
              
              // Coordinates Section
              _buildSectionTitle(context, 'Coordinates', Icons.map),
              const SizedBox(height: 8),
              _buildSectionContent(coordinates),
              const SizedBox(height: 20),
              
              // Properties Section
              if (properties.isNotEmpty) ...[
                _buildSectionTitle(context, 'Properties', Icons.science),
                const SizedBox(height: 8),
                _buildSectionContent(properties),
                const SizedBox(height: 20),
              ],
              
              // Uses Section
              _buildSectionTitle(context, 'Medicinal Uses', Icons.medical_services),
              const SizedBox(height: 8),
              _buildSectionContent(uses),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionContent(String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}