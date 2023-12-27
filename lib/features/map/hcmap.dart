import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_final/features/map/map_controller.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

final mapProvider = ChangeNotifierProvider<MapController>((ref) {
  return MapController();
});

class CHereMap extends StatefulWidget {
  const CHereMap({super.key});

  @override
  State<CHereMap> createState() => _CHereMapState();
}

class _CHereMapState extends State<CHereMap> {
  GeoCoordinates _currentPosition = GeoCoordinates(18.516726, 73.856255);
  HereMapController? hereMapController;
  MapController mapController = MapController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read(mapProvider).getPermisson();
      mapController.determinePosition().then((value) => setState(() {
            _currentPosition = value;
          }));
    });
  }

  void _onMapCreated(HereMapController controller) {
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalNight,
        (MapError? error) {
      if (error == null) {
        controller.camera.lookAtPoint(GeoCoordinates(
            _currentPosition.latitude, _currentPosition.longitude));
      } else {
        debugPrint("Map scene not loaded. MapError: $error");
      }
    });
    hereMapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return HereMap(
      onMapCreated: _onMapCreated,
    );
  }
}
