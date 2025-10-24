import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlantDetailsPage extends StatefulWidget {
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
  State<PlantDetailsPage> createState() => _PlantDetailsPageState();
}

class _PlantDetailsPageState extends State<PlantDetailsPage> {
  MapController? _mapController;
  List<LatLng> _plantLocations = [];
  List<Marker> _markers = [];
  LatLng? _centerLocation;
  int? _selectedMarkerIndex;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _parseCoordinates();
  }

  void _parseCoordinates() {
    try {
      print('Parsing coordinates: ${widget.coordinates}');
      
      // Split by newlines to get each coordinate pair
      final coordLines = widget.coordinates.split('\n');
      
      for (var line in coordLines) {
        if (line.trim().isEmpty) continue;
        
        // Extract lat and lon from format: "Lat: 14.715, Lon: 120.333"
        final latMatch = RegExp(r'Lat:\s*([-\d.]+)').firstMatch(line);
        final lonMatch = RegExp(r'Lon:\s*([-\d.]+)').firstMatch(line);
        
        if (latMatch != null && lonMatch != null) {
          final lat = double.parse(latMatch.group(1)!);
          final lon = double.parse(lonMatch.group(1)!);
          final location = LatLng(lat, lon);
          
          _plantLocations.add(location);
          print('Added location: $lat, $lon');
        }
      }
      
      // Calculate center point if multiple locations
      if (_plantLocations.isNotEmpty) {
        if (_plantLocations.length == 1) {
          _centerLocation = _plantLocations[0];
        } else {
          // Calculate average of all coordinates
          double avgLat = _plantLocations.map((l) => l.latitude).reduce((a, b) => a + b) / _plantLocations.length;
          double avgLon = _plantLocations.map((l) => l.longitude).reduce((a, b) => a + b) / _plantLocations.length;
          _centerLocation = LatLng(avgLat, avgLon);
        }
        
        print('Center location: $_centerLocation');
        _buildMarkers(); // Build markers after parsing
        setState(() {}); // Force rebuild
      } else {
        print('No valid coordinates found');
      }
    } catch (e, stackTrace) {
      print('Error parsing coordinates: $e');
      print('Stack trace: $stackTrace');
      print('Coordinates string: ${widget.coordinates}');
    }
  }

  void _buildMarkers() {
    _markers.clear();
    for (int i = 0; i < _plantLocations.length; i++) {
      final location = _plantLocations[i];
      final isSelected = _selectedMarkerIndex == i;
      
      _markers.add(
        Marker(
          point: location,
          width: isSelected ? 90 : 70,
          height: isSelected ? 120 : 100,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () => _onMarkerTapped(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Always show plant image
                Container(
                  width: isSelected ? 80 : 60,
                  height: isSelected ? 60 : 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.green,
                      width: isSelected ? 2.5 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: isSelected ? 6 : 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      widget.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(
                            Icons.eco, 
                            size: isSelected ? 30 : 25, 
                            color: Colors.green,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Location number badge (for multiple locations)
                if (_plantLocations.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.green,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                // Pin icon
                Icon(
                  Icons.location_pin,
                  color: isSelected ? Colors.red : Colors.green,
                  size: isSelected ? 35 : 30,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void _onMarkerTapped(int index) {
    setState(() {
      _selectedMarkerIndex = index;
      _buildMarkers(); // Rebuild markers with new selection
    });
    
    // Zoom to the selected location
    _mapController?.move(_plantLocations[index], 16.0);
  }

  void _resetMapView() {
    if (_mapController != null && _centerLocation != null) {
      setState(() {
        _selectedMarkerIndex = null;
        _buildMarkers(); // Reset markers to unselected state
      });
      
      _mapController!.move(
        _centerLocation!,
        _plantLocations.length > 1 ? 6.0 : 15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
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
                    widget.image,
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
                  widget.name,
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
                  widget.scientificName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Interactive Map Section
              if (_centerLocation != null && _plantLocations.isNotEmpty) ...[
                _buildSectionTitle(context, 'Location Map', Icons.map),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _centerLocation!,
                            initialZoom: _plantLocations.length > 1 ? 6.0 : 15.0,
                            minZoom: 5.0,
                            maxZoom: 18.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.medicinal_plants',
                              tileProvider: NetworkTileProvider(),
                            ),
                            MarkerLayer(
                              markers: _markers,
                            ),
                          ],
                        ),
                      ),
                      // Reset View Button
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          elevation: 4,
                          onPressed: _resetMapView,
                          tooltip: 'Reset to plant locations',
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_plantLocations.length > 1)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_plantLocations.length} locations marked on the map',
                            style: const TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
              
              // Locations Section
              _buildSectionTitle(context, 'Locations', Icons.location_on),
              const SizedBox(height: 8),
              _buildSectionContent(widget.location),
              const SizedBox(height: 20),
              
              // Coordinates Section
              _buildSectionTitle(context, 'Coordinates', Icons.gps_fixed),
              const SizedBox(height: 8),
              _buildSectionContent(widget.coordinates),
              const SizedBox(height: 20),
              
              // Properties Section
              if (widget.properties.isNotEmpty) ...[
                _buildSectionTitle(context, 'Properties', Icons.science),
                const SizedBox(height: 8),
                _buildSectionContent(widget.properties),
                const SizedBox(height: 20),
              ],
              
              // Uses Section
              _buildSectionTitle(context, 'Medicinal Uses', Icons.medical_services),
              const SizedBox(height: 8),
              _buildSectionContent(widget.uses),
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

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}