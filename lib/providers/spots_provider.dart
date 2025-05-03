import 'package:find_my_spot/models/spot_model.dart';
import 'package:find_my_spot/services/database_service.dart';
import 'package:flutter/material.dart';

class SpotsProvider extends ChangeNotifier {
  List<Spot> _spots = [];
  List<Spot> get spots => _spots;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchSpots() async {
    _isLoading = true;
    notifyListeners();

    final data = await DatabaseService.instance.getAllSpots();
    _spots = data;
    _isLoading = false;
    notifyListeners();
  }

  void addSpot(Spot spot) {
    _spots.add(spot);
    notifyListeners();
  }
}
