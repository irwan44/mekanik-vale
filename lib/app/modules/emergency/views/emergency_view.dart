import 'dart:async';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/endpoint.dart';
import '../../approve/componen/emergency_card.dart';

class EmergencyView extends StatefulWidget {
  const EmergencyView({Key? key}) : super(key: key);

  @override
  State<EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  late GoogleMapController _controller;
  Position? _currentPosition;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  final PanelController _panelController = PanelController();
  String _currentAddress = 'Mengambil lokasi...';
  String _estimatedTime = 'Menghitung estimasi waktu...';
  BitmapDescriptor? _customIcon;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadCustomIcon();
  }
  late double latitude ;
  late double longitude;
  Future<void> _loadCustomIcon() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/drop.png', // Path to your custom marker image
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Current position: $_currentPosition');
      _getAddressFromLatLng();
      setState(() {});
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.subAdministrativeArea}";
      });
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    print('Permission status: $status');
    if (status.isGranted) {
      print('Permission already granted');
      await _getCurrentLocation();
    } else {
      var requestedStatus = await Permission.location.request();
      print('Requested permission status: $requestedStatus');
      if (requestedStatus.isGranted) {
        print('Permission granted');
        await _getCurrentLocation();
      } else {
        print('Permission denied');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Permission denied'),
        ));
      }
    }
  }

  Future<void> _getPolyline(double startLatitude, double startLongitude, double endLatitude, double endLongitude) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'YOUR_API_KEY', // Ganti dengan API key Google Maps Anda
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(endLatitude, endLongitude),
      travelMode: TravelMode.driving, // Mode perjalanan bisa diganti dengan walking, bicycling, atau transit
    );

    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('polyline_id'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 3,
        ));
      });
    } else {
      print('Error: ${result.errorMessage}');
    }
  }

  double _calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude) / 1000;
  }

  String _calculateTravelTime(double distance) {
    const averageSpeed = 50.0; // Average speed in km/h
    double timeInHours = distance / averageSpeed; // Time in hours
    int hours = timeInHours.floor();
    int minutes = ((timeInHours - hours) * 60).round();
    return '${hours} jam ${minutes} menit';
  }

  void _moveCamera(double lat, double lng) {
    _controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(lat, lng),
      ),
    );
  }

  Future<void> _updateEstimatedTime(double destinationLat, double destinationLng) async {
    if (_currentPosition != null) {
      double distance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        destinationLat,
        destinationLng,
      );
      String travelTime = _calculateTravelTime(distance);
      setState(() {
        _estimatedTime = 'Estimasi waktu: $travelTime';
      });
    } else {
      setState(() {
        _estimatedTime = 'Gagal menghitung estimasi waktu';
      });
    }
  }
  late final String phoneNumber;
  bool isLoading = false;
  bool isMenujuLokasi = true;
  void _launchPhoneCall(String phoneNumber) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunch(phoneLaunchUri.toString())) {
        await launch(phoneLaunchUri.toString());
      } else {
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: phoneLaunchUri.toString(),
        );
        await intent.launch();
      }
    } catch (e) {
      print('Error launching phone call: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    final String location = arguments?['location'] ?? '';
    final String hp = arguments?['hp'] ?? '';

    // Pisahkan log dan leng dari string location
    List<String> coordinates = location.isEmpty ? [] : location.split(',');
    double latitude = coordinates.isNotEmpty ? double.parse(coordinates[0]) : 0.0;
    double longitude = coordinates.length > 1 ? double.parse(coordinates[1]) : 0.0;

    _updateEstimatedTime(latitude, longitude);
    final Map args = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
        title: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lokasi Saat ini', style: GoogleFonts.nunito(fontSize: 12)),
                Text(_currentAddress, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: _currentPosition == null
          ? Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            const SizedBox(height: 10,),
            const Text('Sedang memuat lokasi...')
          ],
        ),
      )
          : Stack(
        children: [
        GoogleMap(
        mapType: MapType.terrain,
        zoomGesturesEnabled: true,
        mapToolbarEnabled: true,
        compassEnabled: true,
        zoomControlsEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: Set<Polyline>.of(_polylines),
        onMapCreated: (controller) {
          _controller = controller;

          // Tambahkan marker pada posisi log dan leng dari API
          setState(() {
            _markers.add(
              Marker(
                markerId: const MarkerId('apiLocation'),
                position: LatLng(latitude, longitude),
                icon: _customIcon ?? BitmapDescriptor.defaultMarker,
              ),
            );
          });

          // Dapatkan polyline ke tujuan
          double destinationLatitude = 0.0; // Ganti dengan latitude tujuan
          double destinationLongitude = 0.0; // Ganti dengan longitude tujuan
          _getPolyline(
            latitude,
            longitude,
            destinationLatitude,
            destinationLongitude,
          );
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14,
        ),
        markers: Set<Marker>.of(_markers),
        padding: const EdgeInsets.only(bottom: 240),
      ),
      SlidingUpPanel(
        controller: _panelController,
        panel: _buildSlidingPanel(),
        minHeight: 230,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        parallaxEnabled: true,
        parallaxOffset: 0.5,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: BottomAppBar(
          height: 65,
          elevation: 0,
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child:
          ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        String idKaryawan = GetStorage().read('idKaryawan') ?? '';
                        try {
                          if (isMenujuLokasi) {
                            var response = await API.MenujudiLokasiID(
                              idkaryawan: idKaryawan,
                              kodebooking: args['kode_booking'] ?? '',
                              kodepelanggan: args['tipe_svc'] ?? '',
                              kodekendaraan: args['kode_kendaraan'] ?? '',
                            );
                            if (response.success == true) {  // Asumsi response memiliki field 'status'
                              setState(() {
                                isMenujuLokasi = false;
                              });
                            }
                          } else {
                            var response = await API.TibadiLokasiID(
                              idkaryawan: idKaryawan,
                              kodebooking: args['kode_booking'] ?? '',
                              kodepelanggan: args['tipe_svc'] ?? '',
                              kodekendaraan: args['kode_kendaraan'] ?? '',
                            );
                          }
                        } catch (e) {
                          // Handle error
                          print('Error: $e');
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMenujuLokasi ? Colors.blue : Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        isMenujuLokasi ? 'Menuju lokasi' : 'Tiba dilokasi',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                  ),
              ),

        ],
      ),
    );
  }

  Widget _buildSlidingPanel() {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    final String hp = arguments?['hp'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10, right: 170, left: 170),
          height: 5,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _estimatedTime,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10,),
                Container(
                  margin: EdgeInsets.only(right: 100, left: 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(' Directions', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.directions),
                        onPressed: () async {
                          final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$LatLng&travelmode=driving";
                          if (await canLaunch(googleMapsUrl)) {
                            await launch(googleMapsUrl);
                          } else {
                            throw 'Could not launch $googleMapsUrl';
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                const CardEmergencyPKB(),
                SizedBox(height: 100,),
                // Add more CardEmergencyPKB() widgets here if needed
              ],
            ),
          ),
        ),
      ],
    );
  }

}

