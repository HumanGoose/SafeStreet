import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class Reports {
  GeoPoint location;
  String type;

  Reports({required this.location, required this.type});

  Reports.fromJson(Map<String, Object?> json)
      : this(
          location: json['location']! as GeoPoint,
          type: json['type']! as String,
        );

  Reports copyWith({
    GeoPoint? location,
    String? type,
  }) {
    return Reports(
        location: location ?? this.location, type: type ?? this.type);
  }

  Map<String, Object?> toJson() {
    return {'location': location, 'type': type};
  }
}
