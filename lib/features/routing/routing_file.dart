import 'dart:math';

import 'package:flutter/material.dart';
import 'package:here_sdk/animation.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:intl/intl.dart';

// A callback to notify the hosting widget.
typedef ShowDialogFunction = void Function(String title, String message);

class RoutingExample {
  final HereMapController _hereMapController;
  List<MapPolyline> _mapPolylines = [];
  late RoutingEngine _routingEngine;
  final ShowDialogFunction _showDialog;
  List<Waypoint> waypoints = [];
  List<MapMarker> mapMarkers = [];

  RoutingExample(
    ShowDialogFunction showDialogCallback,
    HereMapController hereMapController,
  )   : _showDialog = showDialogCallback,
        _hereMapController = hereMapController {
    double distanceToEarthInMeters = 10000;
    MapMeasure mapMeasureZoom = MapMeasure(
      MapMeasureKind.distance,
      distanceToEarthInMeters,
    );

    _hereMapController.camera.lookAtPointWithMeasure(
      GeoCoordinates(52.520798, 13.409408),
      mapMeasureZoom,
    );

    try {
      _routingEngine = RoutingEngine();
    } on InstantiationException {
      throw ("Initialization of RoutingEngine failed.");
    }
  }

  void addWaypoint(Waypoint a) {
    waypoints.add(a);
    return;
  }

  void removeWayPoint(int index) {
    waypoints.removeAt(index);
    return;
  }

  void updateWayPoint(Waypoint w) {
    waypoints[0] = w;
    return;
  }

  Future<void> addRoute() async {
    CarOptions carOptions = CarOptions();
    carOptions.routeOptions.enableTolls = true;
    debugPrint(waypoints.length.toString());
    _routingEngine.calculateCarRoute(waypoints, carOptions,
        (RoutingError? routingError, List<here.Route>? routeList) async {
      if (routingError == null) {
        // When error is null, then the list guaranteed to be not null.
        here.Route route = routeList!.first;
        _showRouteDetails(route);
        _showRouteOnMap(route);
        // _logRouteSectionDetails(route);
        _logRouteViolations(route);
        _logTollDetails(route);
        _animateToRoute(route);
      } else {
        var error = routingError.toString();
        _showDialog('Error', 'Error while calculating a route: $error');
      }
    });
  }

  // A route may contain several warnings, for example, when a certain route option could not be fulfilled.
  // An implementation may decide to reject a route if one or more violations are detected.
  void _logRouteViolations(here.Route route) {
    for (var section in route.sections) {
      for (var notice in section.sectionNotices) {
        debugPrint("This route contains the following warning: ${notice.code}");
      }
    }
  }

  void _logTollDetails(here.Route route) {
    for (Section section in route.sections) {
      // The spans that make up the polyline along which tolls are required or
      // where toll booths are located.
      List<Span> spans = section.spans;
      List<Toll> tolls = section.tolls;
      if (tolls.isNotEmpty) {
        debugPrint("Attention: This route may require tolls to be paid.");
      }
      for (Toll toll in tolls) {
        debugPrint("Toll information valid for this list of spans:");
        debugPrint("Toll system: ${toll.tollSystem}");
        debugPrint(
            "Toll country code (ISO-3166-1 alpha-3): ${toll.countryCode}");
        debugPrint("Toll fare information: ");
        for (TollFare tollFare in toll.fares) {
          // A list of possible toll fares which may depend on time of day, payment method and
          // vehicle characteristics. For further details please consult the local
          // authorities.
          debugPrint("Toll price: ${tollFare.price} ${tollFare.currency}");
          for (PaymentMethod paymentMethod in tollFare.paymentMethods) {
            debugPrint(
                "Accepted payment methods for this price: $paymentMethod");
          }
        }
      }
    }
  }

  void clearMap() {
    for (var mapPolyline in _mapPolylines) {
      _hereMapController.mapScene.removeMapPolyline(mapPolyline);
    }
    _mapPolylines.clear();
  }

  void clearMarkers() {
    _hereMapController.mapScene.removeMapMarkers(mapMarkers);
  }

  void clearWayPoints() {
    waypoints.clear();
  }

  void _logRouteSectionDetails(here.Route route) {
    DateFormat dateFormat = DateFormat().add_Hm();

    for (int i = 0; i < route.sections.length; i++) {
      Section section = route.sections.elementAt(i);

      print("Route Section : ${i + 1}");
      print(
          "Route Section Departure Time : ${dateFormat.format(section.departureLocationTime!.localTime)}");
      print(
          "Route Section Arrival Time : ${dateFormat.format(section.arrivalLocationTime!.localTime)}");
      print("Route Section length : ${section.lengthInMeters} m");
      print("Route Section duration : ${section.duration.inSeconds} s");
    }
  }

  void _showAavatars(Waypoint a, bool isFirst, bool isLast) {
    debugPrint("${a.coordinates} $isFirst $isLast");
    final marker = MapMarker(
      a.coordinates,
      MapImage.withFilePathAndWidthAndHeight(
        isFirst
            ? 'assets/poi.png'
            : isLast
                ? 'assets/poi2.png'
                : 'assets/poi3.png',
        50,
        50,
      ),
    );
    _hereMapController.mapScene.addMapMarker(
      marker,
    );
    mapMarkers.add(marker);
    // sheet_controller.animateTo(0.1,
    // duration: const Duration(milliseconds: 200), curve: Curves.easeInSine);
  }

  void _showRouteDetails(here.Route route) {
    // estimatedTravelTimeInSeconds includes traffic delay.
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;
    int estimatedTrafficDelayInSeconds = route.trafficDelay.inSeconds;
    int lengthInMeters = route.lengthInMeters;

    String routeDetails =
        'Travel Time: ${_formatTime(estimatedTravelTimeInSeconds)}, Traffic Delay: ${_formatTime(estimatedTrafficDelayInSeconds)}, Length: ${_formatLength(lengthInMeters)}';

    _showDialog('Route Details', routeDetails);
  }

  String _formatTime(int sec) {
    int hours = sec ~/ 3600;
    int minutes = (sec % 3600) ~/ 60;

    return '${hours}h ${minutes}m';
  }

  String _formatLength(int meters) {
    int kilometers = meters ~/ 1000;
    int remainingMeters = meters % 1000;

    return '$kilometers.$remainingMeters km';
  }

  _showRouteOnMap(here.Route route) {
    // Show route as polyline.
    GeoPolyline routeGeoPolyline = route.geometry;
    double widthInPixels = 20;
    Color polylineColor = Color.fromARGB(244, 241, 5, 5);
    MapPolyline routeMapPolyline;
    try {
      routeMapPolyline = MapPolyline.withRepresentation(
          routeGeoPolyline,
          MapPolylineSolidRepresentation(
              MapMeasureDependentRenderSize.withSingleSize(
                  RenderSizeUnit.pixels, widthInPixels),
              polylineColor,
              LineCap.round));
      _hereMapController.mapScene.addMapPolyline(routeMapPolyline);
      _mapPolylines.add(routeMapPolyline);

      _showAavatars(waypoints[0], true, false);
      for (int i = 1; i < waypoints.length - 1; i++) {
        _showAavatars(waypoints[i], false, false);
      }
      _showAavatars(waypoints[waypoints.length - 1], false, true);
    } on MapPolylineRepresentationInstantiationException catch (e) {
      print("MapPolylineRepresentation Exception:${e.error.name}");
      return;
    } on MapMeasureDependentRenderSizeInstantiationException catch (e) {
      print("MapMeasureDependentRenderSize Exception:${e.error.name}");
      return;
    }

    // Optionally, render traffic on route.
    _showTrafficOnRoute(route);
  }

  // This renders the traffic jam factor on top of the route as multiple MapPolylines per span.
  _showTrafficOnRoute(here.Route route) {
    if (route.lengthInMeters / 1000 > 5000) {
      print("Skip showing traffic-on-route for longer routes.");
      return;
    }

    for (var section in route.sections) {
      for (var span in section.spans) {
        TrafficSpeed trafficSpeed = span.trafficSpeed;
        Color? lineColor = _getTrafficColor(trafficSpeed.jamFactor);
        if (lineColor == null) {
          // We skip rendering low traffic.
          continue;
        }
        double widthInPixels = 10;
        MapPolyline trafficSpanMapPolyline;
        try {
          trafficSpanMapPolyline = new MapPolyline.withRepresentation(
              span.geometry,
              MapPolylineSolidRepresentation(
                  MapMeasureDependentRenderSize.withSingleSize(
                      RenderSizeUnit.pixels, widthInPixels),
                  lineColor,
                  LineCap.round));
          _hereMapController.mapScene.addMapPolyline(trafficSpanMapPolyline);
          _mapPolylines.add(trafficSpanMapPolyline);
        } on MapPolylineRepresentationInstantiationException catch (e) {
          print("MapPolylineRepresentation Exception:${e.error.name}");
          return;
        } on MapMeasureDependentRenderSizeInstantiationException catch (e) {
          print("MapMeasureDependentRenderSize Exception:${e.error.name}");
          return;
        }
      }
    }
  }

  // Define a traffic color scheme based on the route's jam factor.
  // 0 <= jamFactor < 4: No or light traffic.
  // 4 <= jamFactor < 8: Moderate or slow traffic.
  // 8 <= jamFactor < 10: Severe traffic.
  // jamFactor = 10: No traffic, ie. the road is blocked.
  // Returns null in case of no or light traffic.

  Color? _getTrafficColor(double? jamFactor) {
    if (jamFactor == null || jamFactor < 4) {
      return null;
    } else if (jamFactor >= 4 && jamFactor < 8) {
      return Color.fromARGB(160, 255, 255, 0); // Yellow
    } else if (jamFactor >= 8 && jamFactor < 10) {
      return Color.fromARGB(160, 255, 0, 0); // Red
    }
    return Color.fromARGB(160, 0, 0, 0); // Black
  }

  void _animateToRoute(here.Route route) {
    // The animation results in an untilted and unrotated map.
    double bearing = 0;
    double tilt = 0;
    // We want to show the route fitting in the map view with an additional padding of 50 pixels.
    Point2D origin = Point2D(50, 50);
    Size2D sizeInPixels = Size2D(_hereMapController.viewportSize.width - 100,
        _hereMapController.viewportSize.height - 100);
    Rectangle2D mapViewport = Rectangle2D(origin, sizeInPixels);

    // Animate to the route within a duration of 3 seconds.
    MapCameraUpdate update =
        MapCameraUpdateFactory.lookAtAreaWithGeoOrientationAndViewRectangle(
            route.boundingBox,
            GeoOrientationUpdate(bearing, tilt),
            mapViewport);
    MapCameraAnimation animation =
        MapCameraAnimationFactory.createAnimationFromUpdate(
            update, const Duration(milliseconds: 3000), EasingFunction.inCirc);
    _hereMapController.camera.startAnimation(animation);
  }
}
