import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_final/features/routing/routing_file.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
// import 'package:here_sdk/routing.dart';
import 'package:here_sdk/search.dart';
import 'package:here_sdk/routing.dart' as here;

class MapController extends ChangeNotifier {
  // map stuff only
  HereMapController? hereMapController;
  LocationIndicator locationIndicator = LocationIndicator();
  bool trafficEnabled = true;
  bool isAnimated = false;
  StreamSubscription<Position>? positionStream;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
  );

  List<MapMarker> mapMarkers = [];
  List<GeoCoordinates> geo = [];

  // map stuff only -ends

  // search stuff only
  List<Map> searchResult = [];
  TextEditingController textEditor = TextEditingController();
  void emptySearchResult() {
    searchResult = [];
    notifyListeners();
  }

  bool isSearching = false;

  // search stuff only -ends

  // bottom sheet stuff only

  final sheet = GlobalKey();
  final sheet_controller = DraggableScrollableController();

  // bottom sheet stuff only -ends

  // routing stuff only

  RoutingExample? routingExample;
  bool isRouting = false;

  set routerExamplee(RoutingExample? value) {
    routingExample = value;
  }

  void toggleRouting() {
    if (!isRouting && routingExample != null && routingExample?.route != null) {
      routingExample?.startGuidance(routingExample?.route as here.Route);
    } else if (isRouting &&
        routingExample != null &&
        routingExample?.route != null) {
      routingExample?.stopLocationSimulator();
    }
    isRouting = !isRouting;

    notifyListeners();
  }

  // routing stuff only -ends

  // search controls

  Future<void> searchPlace(String query, GeoCoordinates start) async {
    isSearching = true;
    // print("searching for $query");
    if (query == "") {
      searchResult = [];
      isSearching = false;
      notifyListeners();
      return;
    }
    notifyListeners();
    SearchEngine searchEngine = SearchEngine();
    SearchOptions searchOptions = SearchOptions();
    GeoCircle geoCircle = GeoCircle(start, 100000000);
    TextQueryArea queryArea = TextQueryArea.withCircle(geoCircle);
    TextQuery squery = TextQuery.withArea(query, queryArea);
    List<Map> res = [];
    searchEngine.suggest(squery, searchOptions, (p0, p1) async {
      if (p1 == null) {
        return;
      }
      for (var i = 0; i < p1.length; i++) {
        final place = p1[i].place;
        if (place == null) {
          continue;
        }
        final title = p1[i].title;
        if (title == null) {
          continue;
        }
        final address = place!.address;
        if (address == null) {
          continue;
        }
        final addressText = address.addressText;
        if (addressText == null) {
          continue;
        }
        final geoCoordinates = place.geoCoordinates;
        if (geoCoordinates == null) {
          continue;
        }
        // final latitude = geoCoordinates!.latitude;
        // final longitude = geoCoordinates.longitude;
        final data = {
          "title": title,
          "address": addressText,
          // "latitude": latitude,
          // "longitude": longitude,
          "geo": geoCoordinates
        };
        if (geoCoordinates != null) {
          res.add(data);
        }
      }
      // isSearching = false;
      await Future.delayed(const Duration(seconds: 1));
      searchResult = res;
      isSearching = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    searchResult = [];
    isSearching = false;
    notifyListeners();
  }

  // search controls -ends

  // map controls only

  void addMarker(int selectedIndex) {
    if (hereMapController != null) {
      // first remove all markers
      // hereMapController?.mapScene.removeMapMarker(marker);
      hereMapController?.mapScene.removeMapMarkers(mapMarkers);
      final marker = MapMarker(
        searchResult[selectedIndex]['geo'],
        MapImage.withFilePathAndWidthAndHeight(
          'assets/poi.png',
          50,
          50,
        ),
      );
      hereMapController?.mapScene.addMapMarker(
        marker,
      );
      mapMarkers.add(marker);
      sheet_controller.animateTo(0.1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInSine);
    }
  }

  void showMultipleMarkers(List<GeoCoordinates> a) {
    if (hereMapController != null) {
      List<MapMarker> markers = [];
      for (var i in a) {
        final marker = MapMarker(
          i,
          MapImage.withFilePathAndWidthAndHeight(
            'assets/poi2.png',
            50,
            50,
          ),
        );
        markers.add(marker);
      }
      hereMapController?.mapScene.addMapMarkers(
        markers,
      );
      // mapMarkers.add(marker);

      flyTo(a[0]);
    }
  }

  void toggleTraffic() {
    trafficEnabled = !trafficEnabled;
    if (hereMapController != null && trafficEnabled) {
      hereMapController?.mapScene.enableFeatures(
          {MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow});
      hereMapController?.mapScene.enableFeatures(
          {MapFeatures.trafficIncidents: MapFeatureModes.defaultMode});
    } else if (hereMapController != null && !trafficEnabled) {
      hereMapController?.mapScene.disableFeatures(
          [MapFeatures.trafficFlow, MapFeatures.trafficIncidents]);
    }
    notifyListeners();
  }

  void centerCamera() async {
    if (hereMapController != null) {
      GeoCoordinates geo = await getPermisson();
      flyTo(geo);
    }
  }

  void toggleAnimation() {
    isAnimated = !isAnimated;
    notifyListeners();
  }

  void flyTo(GeoCoordinates geoCoordinates) {
    GeoCoordinatesUpdate geoCoordinatesUpdate =
        GeoCoordinatesUpdate.fromGeoCoordinates(geoCoordinates);
    double bowFactor = 1;
    MapCameraAnimation animation = MapCameraAnimationFactory.flyTo(
        geoCoordinatesUpdate, bowFactor, const Duration(seconds: 1));
    hereMapController?.camera.startAnimation(animation);
  }

  MapController() {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      updateLocationIndicator(
          GeoCoordinates(position!.latitude, position.longitude),
          LocationIndicatorIndicatorStyle.pedestrian,
          position.heading);

      if (isAnimated && hereMapController != null) {
        flyTo(GeoCoordinates(position.latitude, position.longitude));
      }
      // if (isRouting) {
      //   debugPrint("tedrouting ${routingExample?.waypoints.length}");
      //   routingExample?.updateWayPoint(
      //       Waypoint(GeoCoordinates(position.latitude, position.longitude)));
      //   routingExample?.addRoute();
      // }
    });
  }

  set customController(HereMapController? value) {
    hereMapController = value;
    hereMapController?.mapScene.enableFeatures(
        {MapFeatures.trafficFlow: MapFeatureModes.trafficFlowWithFreeFlow});
    hereMapController?.mapScene.enableFeatures(
        {MapFeatures.trafficIncidents: MapFeatureModes.defaultMode});
    notifyListeners();
  }

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

  _getRandom(int min, int max) {
    return min + (max - min) * Random().nextDouble();
  }

  void addLocationIndicator(GeoCoordinates geoCoordinates) {
    if (hereMapController != null) {
      if (hereMapController != null) {
        hereMapController!.addLifecycleListener(locationIndicator);
      }
    }
  }

  LocationIndicator updateLocationIndicator(GeoCoordinates geoCoordinates,
      LocationIndicatorIndicatorStyle indicatorStyle, double? bearing) {
    // LocationIndicator locationIndicator = LocationIndicator();
    locationIndicator.locationIndicatorStyle = indicatorStyle;

    Location location = Location.withCoordinates(geoCoordinates);
    location.time = DateTime.now();
    location.bearingInDegrees = bearing ?? 0;
    // location.bearingInDegrees = _getRandom(0, 360);

    locationIndicator.updateLocation(location);
    return locationIndicator;
  }

  // map controls only -ends
}
