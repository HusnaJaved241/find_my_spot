// import 'package:latlong2/latlong.dart';

// class SpotModel {
//   final String id;
//   final String name;
//   final String description;
//   final double latitude;
//   final double longitude;
//   final List<String> imagePaths;
//   final DateTime createdAt;

//   SpotModel({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.latitude,
//     required this.longitude,
//     required this.imagePaths,
//     required this.createdAt,
//   });

//   LatLng get location => LatLng(latitude, longitude);

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'latitude': latitude,
//       'longitude': longitude,
//       'imagePaths': imagePaths,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }

//   factory SpotModel.fromJson(Map<String, dynamic> json) {
//     return SpotModel(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       latitude: json['latitude'],
//       longitude: json['longitude'],
//       imagePaths: List<String>.from(json['imagePaths']),
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }

class Spot {
  final int? id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imagePaths;
  final DateTime createdAt;

  Spot({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imagePaths,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imagePaths': imagePaths.join(','),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Spot fromMap(Map<String, dynamic> map) {
    return Spot(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      imagePaths: (map['imagePaths'] as String).split(','),
      // createdAt: DateTime.parse(map['createdAt'])
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
    );
  }
}
