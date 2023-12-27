import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/hcmap.dart';

class AnimationToggle extends ConsumerStatefulWidget {
  const AnimationToggle({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimationToggleState();
}

class _AnimationToggleState extends ConsumerState<AnimationToggle> {
  @override
  Widget build(BuildContext context) {
    final mapController = ref.watch(mapProvider);

    return InkWell(
      onTap: () => {mapController.centerCamera()},
      onLongPress: () {
        mapController.toggleAnimation();
      },
      child: Consumer(builder: (context, ref, child) {
        return CircleAvatar(
            backgroundColor: Colors.blueGrey.withOpacity(0.5),
            child: Icon(
              Icons.gps_fixed_rounded,
              color: (mapController.isAnimated) ? Colors.red : Colors.blue,
            ));
      }),
    );
  }
}
