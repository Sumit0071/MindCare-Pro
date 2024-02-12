/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DoctorList extends StatefulWidget {
  DoctorList({super.key});

  @override
  _DoctorListState createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  final String apiKey = 'AIzaSyCziohWLShsNK_saNAbBWe9UTouW1MgwCo';
  GoogleMapController? mapController;
  List<Marker> markers = [];
  LocationData? currentLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Psychiatrist Map'),
      ),
      body: FutureBuilder<void>(
        future: getLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.from(markers),
              initialCameraPosition: currentLocation != null
                  ? CameraPosition(
                      target: LatLng(currentLocation?.latitude ?? 0.0,
                          currentLocation?.longitude ?? 0.0),
                      zoom: 13.0,
                    )
                  : CameraPosition(
                      target: LatLng(0.0, 0.0),
                      zoom: 1.0,
                    ),
            );
          }
        },
      ),
    );
  }

  Future<void> getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw 'Location services are disabled.';
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw 'Location permission is denied.';
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      currentLocation = _locationData;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    fetchPsychiatrists();
  }

  Future<void> fetchPsychiatrists() async {
    if (currentLocation == null) {
      return;
    }

    final response = await http.get(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentLocation!.latitude},${currentLocation!.longitude}&radius=5000&type=doctor&keyword=psychiatrist&key=$apiKey'
          as Uri,
    );
    print('API Response: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      markers = results.map<Marker>((result) {
        final Map<String, dynamic> location = result['geometry']['location'];
        return Marker(
          markerId: MarkerId(result['place_id']),
          position: LatLng(location['lat'], location['lng']),
          infoWindow: InfoWindow(
            title: result['name'],
            snippet: result['vicinity'],
          ),
        );
      }).toList();

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(currentLocation?.latitude ?? 0.0,
                currentLocation?.longitude ?? 0.0),
            13.0,
          ),
        );
      }
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }
}
*/
import 'package:flutter/material.dart';
import 'schedule.dart';

class DoctorList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Psychiatrist List',
            style: TextStyle(
              color: Colors.black,
            )),
        backgroundColor: Color(0xFFA770EF),
      ),
      backgroundColor: Color.fromARGB(255, 215, 174, 236),
      body: Container(
        // height: 300,
        width: double
            .infinity, // Set width to infinity to allow vertical scrolling

        child: ListView.builder(
          // scrollDirection: Axis.horizontal,
          scrollDirection:
              Axis.vertical, // Change the scroll direction to vertical

          itemCount: 5,
          itemBuilder: (context, index) {
            return buildDoctorCard(context, index);
          },
        ),
      ),
    );
  }

  Widget buildDoctorCard(BuildContext context, int index) {
    final doctorsData = [
      {
        'image': 'assets/images/doctor1.jpeg',
        'name': 'Dr. Ethan Hunt',
        'degree': 'MD, Psychiatry',
        'distance': '3.5 km away',
        'address': '123 Main St',
        'clinicName': 'ABC Clinic',
      },
      {
        'image': 'assets/images/doctor2.jpeg',
        'name': 'Dr. Jane Smith',
        'degree': 'DO, Psychiatry',
        'distance': '5.0 km away',
        'address': '456 Oak St',
        'clinicName': 'XYZ Clinic',
      },
      {
        'image': 'assets/images/doctor3.jpeg',
        'name': 'Dr. James Johnson',
        'degree': 'PhD, Psychiatry',
        'distance': '2.2 km away',
        'address': '789 Pine St',
        'clinicName': 'PQR Clinic',
      },
      {
        'image': 'assets/images/doctor4.jpeg',
        'name': 'Dr. Emily Davis',
        'degree': 'MD, Psychiatry',
        'distance': '4.5 km away',
        'address': '101 Maple St',
        'clinicName': 'LMN Clinic',
      },
      {
        'image': 'assets/images/doctor5.jpg',
        'name': 'Dr. Julia Fox',
        'degree': 'DO, Psychiatry',
        'distance': '1.8 km away',
        'address': '202 Elm St',
        'clinicName': 'JKL Clinic',
      },
    ];

    if (index < 0 || index >= doctorsData.length) {
      return Container(); // Return an empty container if the index is out of bounds.
    }

    final doctor = doctorsData[index];

    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  doctor['image'] ?? 'assets/placeholder.jpg',
                  height: 120, // Adjusted height
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 8.0), // Add spacing between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(doctor['degree'] ?? ''),
                    SizedBox(height: 4.0),
                    Text(
                      doctor['distance'] ?? '',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(doctor['address'] ?? ''),
                    Text(
                      'Clinic: ${doctor['clinicName'] ?? ''}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16.0), // Adjusted height
                  ],
                ),
              ),
            ],
          ),
          // "Schedule Appointment" button placed at the bottom of the card
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle appointment scheduling
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleAppointment(
                      doctorName: doctor['name'] ?? '',
                      clinicName: doctor['clinicName'] ?? '',
                      address: doctor['address'] ?? '',
                      imageUrl: doctor['image'] ?? 'assets/placeholder.jpg',

                      // Add more parameters as needed
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Schedule Appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0, // Adjusted font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
