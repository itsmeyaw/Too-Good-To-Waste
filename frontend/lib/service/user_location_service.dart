import 'package:location/location.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class UserLocationService {
  static final Location loc = Location();

  static Future<LocationData> getUserLocation() async {
    bool serviceEnabled = await loc.serviceEnabled();

    if (!serviceEnabled) {
      logger.d('Location service is not enabled, requesting service');
      loc.requestService();
    }
    if (!serviceEnabled) {
      throw Exception("Cannot enabled location service");
    }

    PermissionStatus permissionGranted = await loc.hasPermission();

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await loc.requestPermission();
    }

    switch (permissionGranted) {
      case PermissionStatus.granted:
      case PermissionStatus.grantedLimited:
        final LocationData locationData = await loc.getLocation();
        logger.d('Granted location permission, user location is $locationData');
        return locationData;
      case PermissionStatus.denied:
      case PermissionStatus.deniedForever:
        logger.e('Permission for location is denied');
        throw Exception('Location permission is denied');
    }
  }
}
