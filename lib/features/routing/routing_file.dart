import 'package:flutter/material.dart';
import 'package:here_final/features/map/map_controller.dart';
import 'package:here_final/features/routing/fuel_based_soln.dart';
// import 'package:here_final/features/map/hcmap.dart';
import 'package:here_final/navigation/positioning_controller.dart';
import 'package:here_sdk/animation.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/location.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/navigation.dart';
import 'package:here_sdk/routing.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:here_sdk/trafficawarenavigation.dart';
import 'package:intl/intl.dart';

// A callback to notify the hosting widget.
typedef ShowDialogFunction = void Function(String title, String message);

class RoutingExample {
  final HereMapController _hereMapController;
  List<MapPolyline> _mapPolylines = [];
  late RoutingEngine _routingEngine;
  late DynamicRoutingEngine _dynamicRoutingEngine;
  List<Waypoint> waypoints = [];
  List<MapMarker> mapMarkers = [];
  Map? routeDetails;
  num? mileage;
  // for refresh route
  here.Route? route;
  here.Route? greenestRoute;
  final MapController? mapCh;

  MapMatchedLocation? _lastMapMatchedLocation;

  RoutingExample(
    // ShowDialogFunction showDialogCallback,
    HereMapController hereMapController,
    MapController mapC,
  )   : _hereMapController = hereMapController,
        mapCh = mapC {
    double distanceToEarthInMeters = 10000;
    MapMeasure mapMeasureZoom = MapMeasure(
      MapMeasureKind.distance,
      distanceToEarthInMeters,
    );

    _hereMapController.camera.lookAtPointWithMeasure(
      GeoCoordinates(52.520798, 13.409408),
      mapMeasureZoom,
    );

    routeDetails = {};

    try {
      _routingEngine = RoutingEngine();
      // _dynamicRoutingEngine = DynamicRoutingEngine();
    } on InstantiationException {
      throw ("Initialization of RoutingEngine failed.");
    }
  }

  RefreshRouteOptions refreshRouteOptions =
      RefreshRouteOptions.withCarOptions(CarOptions());

  void updateRoute(Waypoint w) {
    if (route == null) {
      return;
    } else {
      _routingEngine.refreshRoute(
          route?.routeHandle as RouteHandle, w, refreshRouteOptions,
          (routingError, routes) {
        if (routingError == null) {
          // HERE.Route newRoute = routes.first;
          here.Route newRoute = routes!.first;
          // _hereMapController.mapScene.removeMapPolyline(_mapPolylines.first);
          // ...
        } else {
          // Handle error.
        }
      });
    }
  }

  set routeDet(Map r) {
    routeDetails = r;
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

  void _startDynamicSearchForBetterRoutes(here.Route route) {
    try {
      // Note that the engine will be internally stopped, if it was started before.
      // Therefore, it is not necessary to stop the engine before starting it again.
      _dynamicRoutingEngine.start(
          route,
          // Notifies on traffic-optimized routes that are considered better than the current route.
          DynamicRoutingListener((here.Route newRoute,
              int etaDifferenceInSeconds, int distanceDifferenceInMeters) {
            print('DynamicRoutingEngine: Calculated a new route.');
            print(
                'DynamicRoutingEngine: etaDifferenceInSeconds: $etaDifferenceInSeconds.');
            print(
                'DynamicRoutingEngine: distanceDifferenceInMeters: $distanceDifferenceInMeters.');

            // An implementation needs to decide when to switch to the new route based
            // on above criteria.
          }, (RoutingError routingError) {
            final error = routingError.toString();
            print(
                'Error while dynamically searching for a better route: $error');
          }));
    } on DynamicRoutingEngineStartException {
      throw Exception(
          "Start of DynamicRoutingEngine failed. Is the RouteHandle missing?");
    }
  }

  Future<void> addRoute() async {
    CarOptions carOptions = CarOptions();

    DynamicRoutingEngineOptions dynamicRoutingEngineOptions =
        DynamicRoutingEngineOptions();

    dynamicRoutingEngineOptions.minTimeDifference = const Duration(seconds: 10);

    dynamicRoutingEngineOptions.minTimeDifferencePercentage = 0.1;

    _dynamicRoutingEngine = DynamicRoutingEngine(dynamicRoutingEngineOptions);

    carOptions.routeOptions.enableTolls = true;
    carOptions.routeOptions.enableRouteHandle = true;
    debugPrint(waypoints.length.toString());
    _routingEngine.calculateCarRoute(waypoints, carOptions,
        (RoutingError? routingError, List<here.Route>? routeList) async {
      if (routingError == null) {
        // When error is null, then the list guaranteed to be not null.
        // here.Route route = routeList!.first;
        route = routeList!.first;

        // fuel test
        // print('mileage is $mileage');
        int a = fuel_based_consumption(
            routeList,
            //  16
            mileage!);
        greenestRoute = routeList[a];
        debugPrint(routeList.length.toString());
        debugPrint("A: $a");

        if(greenestRoute == route){
          debugPrint("Same route");
        }
        else{
          debugPrint("Different route");
        }
        // fuel test ends

        showRouteDetails(route!);
        _showRouteOnMap(route!);
        _showGreenRouteOnMap(greenestRoute!);
        // _logRouteSectionDetails(route);
        _logRouteViolations(route!);
        _logTollDetails(route!);
        _animateToRoute(route!);
      } else {
        var error = routingError.toString();
        // _showDialog('Error', 'Error while calculating a route: $error');
      }
    });
  }

  late VisualNavigator visualNavigator;

  startGuidance(here.Route route) {
    try {
      // Without a route set, this starts tracking mode.
      visualNavigator = VisualNavigator();
    } on InstantiationException {
      throw Exception("Initialization of VisualNavigator failed.");
    }

    // This enables a navigation view including a rendered navigation arrow.
    visualNavigator!.startRendering(_hereMapController!);

    // Hook in one of the many listeners. Here we set up a listener to get instructions on the maneuvers to take while driving.
    // For more details, please check the "navigation_app" example and the Developer's Guide.

    // String _notification = "";

    // void notification(String val) {
    //   _notification = val;
    // }

    visualNavigator.routeProgressListener =
        RouteProgressListener((RouteProgress routeProgress) {
      // Handle results from onRouteProgressUpdated():
      // List<SectionProgress> sectionProgressList = routeProgress.sectionProgress;
      // // sectionProgressList is guaranteed to be non-empty.
      // SectionProgress lastSectionProgress = sectionProgressList.elementAt(sectionProgressList.length - 1);
      // print('Distance to destination in meters: ' + lastSectionProgress.remainingDistanceInMeters.toString());
      // print('Traffic delay ahead in seconds: ' + lastSectionProgress.trafficDelay.inSeconds.toString());

      // // Contains the progress for the next maneuver ahead and the next-next maneuvers, if any.
      // List<ManeuverProgress> nextManeuverList = routeProgress.maneuverProgress;

      // ManeuverProgress nextManeuverProgress = nextManeuverList.first;

      // int nextManeuverIndex = nextManeuverProgress.maneuverIndex;
      // Maneuver? nextManeuver = visualNavigator.getManeuver(nextManeuverIndex);
      // if (nextManeuver == null) {
      //   // Should never happen as we retrieved the next maneuver progress above.
      //   return;
      // }

      if (_lastMapMatchedLocation != null) {
        // Update the route based on the current location of the driver.
        // We periodically want to search for better traffic-optimized routes.
        _dynamicRoutingEngine.updateCurrentLocation(
            _lastMapMatchedLocation!, routeProgress.sectionIndex);
      }
    });

    visualNavigator.maneuverNotificationListener =
        ManeuverNotificationListener((String maneuverText) {
      mapCh?.updateNotification(maneuverText);
    });

    visualNavigator.navigableLocationListener =
        NavigableLocationListener((NavigableLocation currentNavigableLocation) {
      // Handle results from onNavigableLocationUpdated():
      MapMatchedLocation? mapMatchedLocation =
          currentNavigableLocation.mapMatchedLocation;
      if (mapMatchedLocation == null) {
        // print('This new location could not be map-matched. Are you off-road?');
        return;
      }
      _lastMapMatchedLocation = mapMatchedLocation;

      var speed =
          currentNavigableLocation.originalLocation.speedInMetersPerSecond;
      var accuracy = currentNavigableLocation
          .originalLocation.speedAccuracyInMetersPerSecond;
      mapCh?.updateSpeeds(speed!, accuracy!);
      print("Driving speed (m/s): $speed plus/minus an accuracy of: $accuracy");
    });

    // Set a route to follow. This leaves tracking mode.
    visualNavigator!.route = route;

    // VisualNavigator acts as LocationListener to receive location updates directly from a location provider.
    // Any progress along the route is a result of getting a new location fed into the VisualNavigator.
    _setupLocationSource(visualNavigator!, route);
  }

  late LocationSimulator _locationSimulator;
  HEREPositioningProvider? _herePositioningProvider;
  _setupLocationSource(LocationListener locationListener, here.Route route) {
    try {
      // Provides fake GPS signals based on the route geometry.
      _herePositioningProvider = HEREPositioningProvider();
      _herePositioningProvider?.startLocating(
          visualNavigator, LocationAccuracy.navigation);
    } on InstantiationException {
      throw Exception("Initialization of LocationSimulator failed.");
    }

    // _locationSimulator!.listener = locationListener;
    // _locationSimulator!.start();
  }

  stopLocationSimulator() {
    if (visualNavigator != null) {
      _herePositioningProvider?.stop();
      visualNavigator.stopRendering();
    }
  }

  // add streams to get data related to progress of navigation

  // navigation ends

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

  void showRouteDetails(here.Route route) {
    // estimatedTravelTimeInSeconds includes traffic delay.
    int estimatedTravelTimeInSeconds = route.duration.inSeconds;
    int estimatedTrafficDelayInSeconds = route.trafficDelay.inSeconds;
    int lengthInMeters = route.lengthInMeters;

    String routeDetails =
        'Travel Time: ${_formatTime(estimatedTravelTimeInSeconds)}, Traffic Delay: ${_formatTime(estimatedTrafficDelayInSeconds)}, Length: ${_formatLength(lengthInMeters)}';

    routeDet = {
      "total_time": _formatTime(estimatedTravelTimeInSeconds),
      "traffic": _formatTime(estimatedTrafficDelayInSeconds),
      "length": _formatLength(lengthInMeters),
    };
    // _showDialog('Route Details', routeDetails);
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
    // Color polylineColor = Color.fromARGB(244, 252, 252, 252);
    Color polylineColor = Colors.white.withOpacity(0.5);
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

  _showGreenRouteOnMap(here.Route route) {
    // Show route as polyline.
    if (this.greenestRoute == this.route) {
      // print("Same route");
      return;
    }
    GeoPolyline routeGeoPolyline = greenestRoute?.geometry as GeoPolyline;
    double widthInPixels = 20;
    // Color polylineColor = Color.fromARGB(244, 252, 252, 252);
    Color polylineColor = Colors.green;
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
      return const Color.fromARGB(160, 255, 255, 0); // Yellow
    } else if (jamFactor >= 8 && jamFactor < 10) {
      return const Color.fromARGB(160, 255, 0, 0); // Red
    }
    return const Color.fromARGB(160, 0, 0, 0); // Black
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
