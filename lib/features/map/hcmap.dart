import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/components/constants.dart';
import 'package:here_final/features/map/components/draggable/draggablesection.dart';
import 'package:here_final/features/map/components/map_utils.dart';
import 'package:here_final/features/map/components/search_bar.dart';
import 'package:here_final/features/map/map_controller.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

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
      } else {}
    });
    // hereMapController = controller;
  }

  double top = 0.0;
  double initialTop = 0.0;

  @override
  Widget build(BuildContext context) {
    final baseTop = MediaQuery.of(context).size.height * 0.9;

    return Stack(
      children: [
        HereMap(
          onMapCreated: _onMapCreated,
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.only(bottom: 32.0, right: 16.0),
            child: AnimationToggle(),
          ),
          ),
          // const Align(
          //   alignment: Alignment.topCenter,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal:16.0, vertical: 32),
          //     child: CSearchBar(),
          //   ),
          // )

          GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              final double scrollPos = details.globalPosition.dy;
              if (scrollPos < baseTop && scrollPos > searchBarHeight) {
                setState(() {
                  top = scrollPos;
                });
              }
            },
            // child: DraggableSection(
            //   top: top == 0.0 ? baseTop : top,
            //   searchBarHeight: searchBarHeight,
            // ),
            child: CDraggable(),
          )



      ],
    );
  }
}
