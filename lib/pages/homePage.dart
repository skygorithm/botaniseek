import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'plantDetailsPage.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLocalPlants();
  }

  Future<void> loadLocalPlants() async {
    setState(() => isLoading = true);

    try {
      print('Attempting to load medicinal_plants.json from assets...');
      // Verify asset exists
      final AssetBundle rootBundle = DefaultAssetBundle.of(context);
      final String jsonString = await rootBundle
          .loadString('assets/medicinal_plants.json')
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Failed to load asset file'),
          );
      
      if (jsonString.isEmpty) {
        throw Exception('Asset file is empty');
      }
      
      print('JSON file loaded successfully: ${jsonString.length} bytes');
      
      print('Parsing JSON data...');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> jsonData = jsonMap['plants'] as List<dynamic>;
      print('Found ${jsonData.length} plants in the JSON file');

      plants = jsonData.map((p) => {
        'name': p['name'] ?? 'Unknown',
        'scientific_name': p['scientific_name'] ?? 'Unknown',
        'location': p['location'] as List<dynamic>,
        'coordinates': (p['coordinates'] as List<dynamic>?)?.map((coord) => 
          {'lat': coord['lat'], 'lon': coord['lon']}).toList() ?? [],
        'properties': p['properties'] as List<dynamic>,
        'uses': p['uses'] as List<dynamic>,
        'image': p['image'].toString(),
      }).toList();
    } catch (e, stackTrace) {
      print('Error loading plants: $e');
      print('Stack trace: $stackTrace');
      
      // Show error dialog to user
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load plant data: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  loadLocalPlants(); // Retry loading
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget buildImage(String url) {
    return Image.network(
      url,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported, size: 60),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : plants.isEmpty
              ? const Center(child: Text('No plants found'))
              : ListView.builder(
                  itemCount: plants.length,
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.lightGreenAccent,
                          child: Icon(Icons.eco, color: Colors.green),
                        ),
                        title: Text(
                          plant['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          plant['scientific_name']!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Locations:', 
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 4),
                                ...(plant['location'] as List<dynamic>).map((loc) => 
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            loc.toString(),
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                if ((plant['properties'] as List).isNotEmpty) ...[
                                  Text('Properties:', 
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      )),
                                  const SizedBox(height: 4),
                                  ...(plant['properties'] as List<dynamic>).map((prop) =>
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('•', style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(prop.toString()),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                Text('Uses:', 
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    )),
                                const SizedBox(height: 4),
                                ...(plant['uses'] as List<dynamic>).map((use) =>
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('•', style: TextStyle(fontSize: 16)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(use.toString()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlantDetailsPage(
                                            name: plant['name']!,
                                            scientificName: plant['scientific_name']!,
                                            image: plant['image']!,
                                            location: '• ${(plant['location'] as List).join('\n• ')}',
                                            coordinates: (plant['coordinates'] as List).map((coord) => 
                                              'Lat: ${coord['lat']}, Lon: ${coord['lon']}').join('\n'),
                                            properties: (plant['properties'] as List).isNotEmpty 
                                              ? '• ${(plant['properties'] as List).join('\n\n• ')}'
                                              : '',
                                            uses: '• ${(plant['uses'] as List).join('\n\n• ')}',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View Full Details'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}