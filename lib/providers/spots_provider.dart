import 'package:find_my_spot/models/spot_model.dart';
import 'package:find_my_spot/services/database_service.dart';
import 'package:flutter/material.dart';

class SpotsProvider extends ChangeNotifier {
  List<Spot> _spots = [];
  List<Spot> get spots => _spots;

  Future<void> fetchSpots() async {
    final data = await DatabaseService.instance.getAllSpots();
    _spots = data;
    notifyListeners();
  }

  void addSpot(Spot spot) {
    _spots.add(spot);
    notifyListeners();
  }
}
