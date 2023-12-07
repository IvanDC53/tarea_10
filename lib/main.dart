import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: latController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Latitud'),
            ),
            TextField(
              controller: longController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Longitud'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                double lat = double.tryParse(latController.text) ?? 0.0;
                double long = double.tryParse(longController.text) ?? 0.0;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapDisplayScreen(
                      name: nameController.text,
                      lastName: lastNameController.text,
                      initialPosition: LatLng(lat, long),
                    ),
                  ),
                );
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}

class MapDisplayScreen extends StatelessWidget {
  final String name;
  final String lastName;
  final LatLng initialPosition;

  MapDisplayScreen({
    required this.name,
    required this.lastName,
    required this.initialPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa con Marcador'),
      ),
      body: FutureBuilder(
        future: _getMarkerPosition(initialPosition),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            LatLng markerPosition = snapshot.data as LatLng;
            return FlutterMap(
              options: MapOptions(
                center: markerPosition,
                zoom: 15.0,
              ),
              layers: [
                TileLayerOptions(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      point: markerPosition,
                      builder: (context) => PopupContainer(
                        name: name,
                        lastName: lastName,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<LatLng> _getMarkerPosition(LatLng initialPosition) async {
    // You can add additional logic to fetch the marker position based on initialPosition
    return initialPosition;
  }
}

class PopupContainer extends StatelessWidget {
  final String name;
  final String lastName;

  PopupContainer({required this.name, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$name $lastName'),
          const Text('Ciudad/País aquí'),
        ],
      ),
    );
  }
}
