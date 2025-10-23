import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'plantDetailsPage.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _baseUrl = 'https://trefle.io/api/v1/species';
  final String _token = 'usr-cAyqJ9IQMBn4B-pK1pZnCHGOAzlpGOlP5dEDAYvuIVM';
  final String _corsProxy = 'https://api.allorigins.win/raw?url='; // for web

  List<Map<String, String>> plants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlants();
  }

  Future<void> fetchPlants() async {
    setState(() => isLoading = true);

    try {
      Uri url;

      if (kIsWeb) {
        // Web: use proxy to avoid CORS
        final fullUrl = '$_baseUrl?token=$_token&page=1';
        url = Uri.parse('$_corsProxy$fullUrl');
      } else {
        // Mobile: direct API call
        url = Uri.parse('$_baseUrl?token=$_token&page=1');
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allPlants = data['data'] as List<dynamic>? ?? [];

        plants = allPlants
            .where((p) => p['image_url'] != null)
            .map((p) => {
                  'name': (p['common_name'] ?? p['scientific_name'] ?? 'Unknown')
                      .toString(),
                  'image': p['image_url'].toString(), // <- direct image URL
                  'location': (p['family_common_name'] ?? 'Unknown').toString(),
                })
            .toList();
      } else {
        print('Failed to load plants: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plants: $e');
    } finally {
      setState(() => isLoading = false);
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
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: buildImage(plant['image']!),
                        ),
                        title: Text(
                          plant['name']!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Family: ${plant['location']}'),
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
    );
  }
}
