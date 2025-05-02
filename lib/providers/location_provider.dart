import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  LatLng? _markerPosition;
  String _errorMessage = '';

  Position? get currentPosition => _currentPosition;
  LatLng? get markerPosition => _markerPosition;
  String get errorMessage => _errorMessage;

  Future<bool> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'Location Services are disabled';
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'Location permissions are denied';
          notifyListeners();
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location Permissions are permanently denied';
        notifyListeners();
        return false;
      }
      _currentPosition = await Geolocator.getCurrentPosition();
      _markerPosition = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void updateMarkerPosition(LatLng position) {
    _markerPosition = position;
    notifyListeners();
  }
}
