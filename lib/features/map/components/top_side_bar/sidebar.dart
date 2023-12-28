import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/components/top_side_bar/components/fancybar.dart';
import 'package:here_final/features/map/hcmap.dart';

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Column(
            children: <Widget>[
              FancyBar(
                height: 46,
                margin: EdgeInsets.only(left: 20, top: 48),
                child: Icon(Icons.menu, color: Colors.white, size: 20),
              )
            ],
          ),
          Consumer(builder: (context, ref, child) {
            final mapController = ref.watch(mapProvider);

            return Column(
              children: <Widget>[
                FancyBar(
                  height: 46 * 3.0,
                  margin: const EdgeInsets.only(right: 20, top: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                        onTap: () => {mapController.toggleTraffic()},
                        child:  Icon(Icons.layers, color: (mapController.trafficEnabled) ? Colors.redAccent : Colors.green, size: 20)),
                      InkWell(
                        onTap: () => {mapController.centerCamera()},
                        onLongPress: () {
                          mapController.toggleAnimation();
                        },
                        child: Transform.rotate(
                            angle: 3.14 / 4,
                            child: Icon(Icons.navigation,
                            
                                color: (mapController.isAnimated) ? Colors.red : Colors.blue, size: 20)),
                      ),
                      InkWell(
                        onTap: () => {
                          // mapController.sheet_controller.animateTo(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInSine)
                          // mapController.isRouting = true,
                          mapController.toggleRouting()
                          },
                        child: Icon(Icons.directions,
                            color: (mapController.isRouting) ? Colors.teal : Colors.orange, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            );
          })
        ],
      ),
    );
  }
}
