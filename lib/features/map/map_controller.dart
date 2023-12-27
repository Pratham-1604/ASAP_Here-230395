import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';

class MapController extends ChangeNotifier {
  Future<GeoCoordinates> getPermisson() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return GeoCoordinates(18.516726, 73.856255);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // showsnackbar(context: context, msg: 'Pls allow location services!');
        permission = await Geolocator.requestPermission();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // showsnackbar(context: context, msg: 'Permissions denied forever!');

      // Set default coordinates or handle as needed
      return GeoCoordinates(18.516726, 73.856255);
    }

    // Continue with normal flow
    Position a = await Geolocator.getCurrentPosition();
    GeoCoordinates geo = GeoCoordinates(a.latitude, a.longitude);
    return geo;
  }
}
