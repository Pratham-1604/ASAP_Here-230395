import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:here_final/features/map/components/constants.dart';
import 'package:here_final/features/map/components/draggable/draggablesection.dart';
// import 'package:here_final/features/map/components/map_utils.dart';
import 'package:here_final/features/map/components/top_side_bar/sidebar.dart';
// import 'package:here_final/features/map/components/search_bar.dart';
import 'package:here_final/features/map/map_controller.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
import '../routing/routing_file.dart';

final mapProvider = ChangeNotifierProvider<MapController>((ref) {
  return MapController();
});

class CHereMap extends ConsumerStatefulWidget {
  const CHereMap({super.key});

  @override
  ConsumerState<CHereMap> createState() => _CHereMapState();
}

class _CHereMapState extends ConsumerState<CHereMap> {
  GeoCoordinates _currentPosition = GeoCoordinates(18.516726, 73.856255);
  // HereMapController? hereMapController;
  // MapController mapController = MapController();
  bool _locationIndicatorVisible = false;
  HereMapController? get hereMapController => ref.read(mapProvider).hereMapController;
// class _CHereMapState extends State<CHereMap> {
  // HereMapController? hereMapController;
  MapController mapController = MapController();
  RoutingExample? _routingExample;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapController = ref.read(mapProvider);
      mapController.getPermisson().then((value) => setState(() {
            _currentPosition = value;
            if (hereMapController != null) {
              hereMapController!.camera.lookAtPoint(_currentPosition);
              mapController.addLocationIndicator(_currentPosition);
              _locationIndicatorVisible = true;
            }
          }));
    });
  }

  void _onMapCreated(HereMapController controller) {
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalNight,
        (MapError? error) {
      if (error == null) {
        controller.camera.lookAtPoint(GeoCoordinates(
            _currentPosition.latitude, _currentPosition.longitude));
        ref.read(mapProvider).customController = controller;
        if (!_locationIndicatorVisible) {
          ref.read(mapProvider).addLocationIndicator(_currentPosition);
        }
        _routingExample = RoutingExample(_showDialog, controller);
      } else {}
    });
  }

  void _addRouteButtonClicked(){
    _routingExample?.addWaypoint(
      Waypoint(
        GeoCoordinates(18.3663,73.7559),
      ),
    );
    _routingExample?.addWaypoint(
      Waypoint(
        GeoCoordinates(18.4454, 73.7801),
      ),
    );
    _routingExample?.addWaypoint(
      Waypoint(
        GeoCoordinates(18.6783, 73.8950),
      ),
    );
    _routingExample?.addRoute();
  }

  void _clearMapButtonClicked() {
    _routingExample?.clearMap();
  }

  // A helper method to add a button on top of the HERE map.
  Align button(String buttonLabel, Function callbackFunction) {
    return Align(
      alignment: Alignment.topCenter,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlueAccent,
        ),
        onPressed: () => callbackFunction(),
        child: Text(buttonLabel, style: TextStyle(fontSize: 20)),
      ),
    );
  }

  // A helper method to show a dialog.
  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        HereMap(
          onMapCreated: _onMapCreated,
        ),

          const TopSection(),

          GestureDetector(
            child: const CDraggable(),
          ),



        Positioned(
          bottom: 50,
          left: 20,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                button('Add Route', _addRouteButtonClicked),
                button('Clear Map', _clearMapButtonClicked),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
