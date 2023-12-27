import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:here_final/features/map/components/constants.dart';
import 'package:here_final/features/map/components/draggable/draggablesection.dart';
// import 'package:here_final/features/map/components/map_utils.dart';
import 'package:here_final/features/map/components/top_side_bar/sidebar.dart';
// import 'package:here_final/features/map/components/search_bar.dart';
import 'package:here_final/features/map/map_controller.dart';
import 'package:here_sdk/consent.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:here_sdk/routing.dart';
// import '../routing/routing_file.dart';

final mapProvider = ChangeNotifierProvider<MapController>((ref) {
  return MapController();
});

class CHereMap extends ConsumerStatefulWidget {
  const CHereMap({super.key});

  @override
  ConsumerState<CHereMap> createState() => _CHereMapState();
}

class _CHereMapState extends ConsumerState<CHereMap> {
  // here positioning

  static const String _trackingOn = "Tracking: ON";
  static const String _trackingOff = "Tracking: OFF";
  String _trackingState = "Pending ...";
  bool _isTracking = true;

  // When using HERE Positioning in your app, it is required to request and to show the user's consent decision.
  // In addition, users must be able to change their consent decision at any time.
  // Note that this is only needed when running on Android devices.
  ConsentEngine? _consentEngine;
  String _consentState = "Pending ...";
  String _messageState = "";

  // here positioning

  GeoCoordinates _currentPosition = GeoCoordinates(18.516726, 73.856255);
  // HereMapController? hereMapController;
  // MapController mapController = MapController();
  bool _locationIndicatorVisible = false;
  HereMapController? get hereMapController =>
      ref.read(mapProvider).hereMapController;
// class _CHereMapState extends State<CHereMap> {
  // HereMapController? hereMapController;
  MapController mapController = MapController();

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

  void _onMapCreated(HereMapController controller) async {
    try {
      _consentEngine = ConsentEngine();
      debugPrint(_consentEngine?.userConsentState.toString());
    } on InstantiationException {
      throw ("Initialization of ConsentEngine failed.");
    }
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalNight,
        (MapError? error) async {
      if (error == null) {
        if (!await _requestPermissions()) {
          await _showDialog("Error",
              "Cannot start app: Location service and permissions are needed for this app.");
          // Let the user set the permissions from the system settings as fallback.
          openAppSettings();
          SystemNavigator.pop();
          return;
        }
        // _routingExample = RoutingExample(controller);
        if (_consentEngine?.userConsentState == ConsentUserReply.notHandled) {
          await _requestConsent();
        } else {
          _updateConsentState();
        }
        controller.camera.lookAtPoint(GeoCoordinates(
            _currentPosition.latitude, _currentPosition.longitude));
        ref.read(mapProvider).customController = controller;
        if (!_locationIndicatorVisible) {
          ref.read(mapProvider).addLocationIndicator(_currentPosition);
        }
      } else {}
    });
  }

  Future<void> _requestConsent() async {
    if (!Platform.isIOS) {
      // This shows a localized widget that asks the user if data can be collected or not.
      await _consentEngine?.requestUserConsent(context);
    }

    _updateConsentState();
  }

  Future<bool> _requestPermissions() async {
    if (!await Permission.location.serviceStatus.isEnabled) {
      return false;
    }

    if (!await Permission.location.request().isGranted) {
      return false;
    }

    if (Platform.isAndroid) {
      // This permission is optionally needed on Android devices >= Q to improve the positioning signal.
      Permission.activityRecognition.request();
    }

    // All required permissions granted.
    return true;
  }

  // Update the button's text showing the current consent decision of the user.
  void _updateConsentState() {
    String stateMessage;
    if (Platform.isIOS) {
      stateMessage =
          "Info: On iOS no consent is required as on iOS no data is collected.";
    } else if (_consentEngine?.userConsentState == ConsentUserReply.granted) {
      stateMessage =
          "Positioning consent: You have granted consent to the data collection.";
    } else {
      stateMessage =
          "Positioning consent: You have denied consent to the data collection.";
    }

    setState(() {
      _consentState = stateMessage;
    });
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

        // Positioned(
        //   bottom: 50,
        //   left: 20,
        //   child: Center(
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         button('Add Route', _addRouteButtonClicked),
        //         button('Clear Map', _clearMapButtonClicked),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
