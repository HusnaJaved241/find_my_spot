import 'dart:io';

import 'package:find_my_spot/models/spot_model.dart';
import 'package:find_my_spot/providers/location_provider.dart';
import 'package:find_my_spot/providers/spots_provider.dart';
import 'package:find_my_spot/providers/theme_provider.dart';
import 'package:find_my_spot/screens/spot_screen.dart';
import 'package:find_my_spot/widgets/add_spot_dialog.dart';
import 'package:find_my_spot/widgets/custom_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  final MapController _mapController = MapController();

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
    final granted = await Provider.of<LocationProvider>(
      context,
      listen: false,
    ).determinePosition(context);
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

  void _showSpotsModelBottomSheet(BuildContext context, Spot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Half the screen
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder:
              (_, controller) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    // Indicator line
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Images
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: spot.imagePaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(spot.imagePaths[index]),
                              width: 240,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Spot Name
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Spot Description
                    Text(
                      spot.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Saved on: ${DateFormat.yMMMd().format(spot.createdAt)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocationProvider, SpotsProvider>(
      builder: (context, locationProvider, spotsProvider, child) {
        if (locationProvider.currentPosition == null &&
            locationProvider.errorMessage.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final LatLng initialCenter =
            locationProvider.markerPosition ?? const LatLng(33.6844, 73.049);
        final spots = spotsProvider.spots;
        final newLocation = locationProvider.markerPosition;

        final markers = <Marker>[
          ...spots.map(
            (spot) => Marker(
              point: LatLng(spot.latitude, spot.longitude),
              width: 20,
              height: 20,
              child: GestureDetector(
                onTap: () => _showSpotsModelBottomSheet(context, spot),
                child: Icon(Icons.location_pin, color: Colors.green, size: 40),
              ),
            ),
          ),
          if (newLocation != null &&
              !spots.any(
                (spot) =>
                    spot.latitude == newLocation.latitude &&
                    spot.longitude == newLocation.longitude,
              ))
            Marker(
              point: newLocation,
              height: 20,
              width: 20,
              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
        ];

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
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
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  top: 15,
                  right: 12,
                  child: CustomFloatingActionButton(
                    heroTag: 'toggle-theme',
                    onPressed: () {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme();
                    },
                    icon: Icon(
                      Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode,
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomFloatingActionButton(
                heroTag: 'spot-list',
                onPressed: () async {
                  final selectedSpot = await Navigator.push<Spot>(
                    context,
                    MaterialPageRoute(builder: (context) => const SpotScreen()),
                  );

                  if (selectedSpot != null) {
                    _mapController.move(
                      LatLng(selectedSpot.latitude, selectedSpot.longitude),
                      16, // zoom level
                    );
                    _showSpotsModelBottomSheet(context, selectedSpot);
                  }
                },
                icon: Icon(Icons.list),
              ),
              SizedBox(height: 12),
              CustomFloatingActionButton(
                heroTag: 'locate-btn',
                // mini: true,
                icon: Icon(Icons.my_location),
                onPressed: () async {
                  // Provider.of<LocationProvider>(
                  //   context,
                  //   listen: false,
                  // ).determinePosition(context);
                  final locationProvider = Provider.of<LocationProvider>(
                    context,
                    listen: false,
                  );
                  await locationProvider.determinePosition(context);
                },
              ),
              SizedBox(height: 12),
              CustomFloatingActionButton(
                heroTag: 'add-btn',

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
                        ),
                  );
                },

                icon: const Icon(Icons.add),
              ),
            ],
          ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        );
      },
    );
  }
}
