import 'dart:convert';
import 'package:http/http.dart' as http;

class PlantService {
  final String _baseUrl = 'https://trefle.io/api/v1/species';
  final String _token = 'usr-cAyqJ9IQMBn4B-pK1pZnCHGOAzlpGOlP5dEDAYvuIVM';
  final String _corsProxy = 'https://api.allorigins.win/raw?url=';

  Future<List<dynamic>> fetchPlants() async {
    final String fullUrl = '$_baseUrl?token=$_token&page=1';
    final Uri proxyUrl = Uri.parse('$_corsProxy$fullUrl');

    final response = await http.get(proxyUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final plants = data['data'] as List;
      return plants.where((plant) => plant['image_url'] != null).toList();
    } else {
      throw Exception('Failed to load plants: ${response.statusCode}');
    }
  }
}
