import 'package:find_my_spot/providers/location_provider.dart';
import 'package:find_my_spot/screens/spot_screen.dart';
import 'package:find_my_spot/widgets/add_spot_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    final granted =
        await Provider.of<LocationProvider>(
          context,
          listen: false,
        ).determinePosition();
    if (!granted && mounted) {
      final error =
          Provider.of<LocationProvider>(context, listen: false).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Geolocator.openAppSettings();
            },
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.currentPosition == null &&
            locationProvider.errorMessage.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final LatLng initialCenter =
            locationProvider.markerPosition ?? const LatLng(33.6844, 73.049);
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 15,
                    onLongPress: (tapPosition, latLng) {
                      locationProvider.updateMarkerPosition(latLng);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: 'com.example.find_my_spot',
                    ),
                    if (locationProvider.markerPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: locationProvider.markerPosition!,
                            width: 60,
                            height: 60,
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
               
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SpotScreen()),
                        ),
                    child: Text("Show Spot List"),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (locationProvider.markerPosition == null) return;
              showDialog(
                context: context,
                builder:
                    (_) => AddSpotDialog(
                      formKey: _formKey,
                      nameController: _nameController,
                      descController: _descController,
                      selectedLocation: locationProvider.markerPosition!,
                      // selectedLocation: _markerPosition!,
                    ),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
