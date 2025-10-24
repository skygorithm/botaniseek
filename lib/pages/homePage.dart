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
  List<Map<String, dynamic>> filteredPlants = [];
  bool isLoading = true;
  String searchQuery = '';
  bool isAscending = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadLocalPlants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadLocalPlants() async {
    setState(() => isLoading = true);

    try {
      print('Attempting to load medicinal_plants.json from assets...');
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
      
      filteredPlants = List.from(plants);
      _sortPlants();
    } catch (e, stackTrace) {
      print('Error loading plants: $e');
      print('Stack trace: $stackTrace');
      
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
                  loadLocalPlants();
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

  void _filterPlants(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredPlants = List.from(plants);
      } else {
        filteredPlants = plants.where((plant) {
          final name = plant['name']!.toLowerCase();
          final scientificName = plant['scientific_name']!.toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || scientificName.contains(searchLower);
        }).toList();
      }
      _sortPlants();
    });
  }

  void _sortPlants() {
    setState(() {
      filteredPlants.sort((a, b) {
        if (isAscending) {
          return a['name']!.compareTo(b['name']!);
        } else {
          return b['name']!.compareTo(a['name']!);
        }
      });
    });
  }

  void _toggleSort() {
    setState(() {
      isAscending = !isAscending;
      _sortPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreenAccent,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: _toggleSort,
            tooltip: isAscending ? 'Sort Z-A' : 'Sort A-Z',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPlants,
              decoration: InputDecoration(
                hintText: 'Search plants...',
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPlants('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                filled: true,
                fillColor: Colors.green[50],
              ),
            ),
          ),
          
          // Results count
          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Text(
                'Found ${filteredPlants.length} plant${filteredPlants.length != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          
          // Plants List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPlants.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty 
                                  ? 'No plants found'
                                  : 'No plants match "$searchQuery"',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: ClipOval(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.lightGreenAccent,
                                  child: Image.asset(
                                    plant['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: ${plant['image']}');
                                      print('Error: $error');
                                      return const Icon(Icons.eco, color: Colors.green);
                                    },
                                  ),
                                ),
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
                                      // Plant Image Preview
                                      Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.asset(
                                            plant['image']!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading expanded image: ${plant['image']}');
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
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
                                        ...(plant['properties'] as List<dynamic>).take(2).map((prop) =>
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
                                        if ((plant['properties'] as List).length > 2)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 16.0),
                                            child: Text('... (view more in details)', 
                                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                                          ),
                                        const SizedBox(height: 16),
                                      ],

                                      Text('Uses:', 
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                          )),
                                      const SizedBox(height: 4),
                                      ...(plant['uses'] as List<dynamic>).take(2).map((use) =>
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
                                      if ((plant['uses'] as List).length > 2)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Text('... (view more in details)', 
                                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
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
          ),
        ],
      ),
    );
  }
}