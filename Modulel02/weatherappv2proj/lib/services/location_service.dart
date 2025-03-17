import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<LocationData> determinePosition() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Vérifier si le service est activé
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    // Vérifier les permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }

    // Obtenir la position
    return await location.getLocation();
  }
}
