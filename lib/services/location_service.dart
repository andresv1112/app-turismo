import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sendero_seguro/models/danger_zone.dart';

class LocationService {
  static LocationService? _instance;
  LocationService._();
  
  static LocationService get instance => _instance ??= LocationService._();

  Future<PermissionStatus> requestLocationPermission() async {
    final currentStatus = await Permission.location.status;
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      return currentStatus;
    }

    final permission = await Permission.location.request();
    if (permission == PermissionStatus.permanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    }

    return permission;
  }

  Future<Position?> getCurrentLocation({bool requestPermission = true}) async {
    try {
      PermissionStatus status;
      if (requestPermission) {
        status = await requestLocationPermission();
      } else {
        status = await Permission.location.status;
      }

      if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  bool isInsideDangerZone(Position userPosition, DangerZone zone) {
    final distance = calculateDistance(
      userPosition.latitude,
      userPosition.longitude,
      zone.latitude,
      zone.longitude,
    );
    return distance <= zone.radius;
  }

  List<DangerZone> getNearbyDangerZones(Position userPosition, List<DangerZone> zones, {double maxDistance = 500}) {
    return zones.where((zone) {
      final distance = calculateDistance(
        userPosition.latitude,
        userPosition.longitude,
        zone.latitude,
        zone.longitude,
      );
      return distance <= maxDistance;
    }).toList();
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}