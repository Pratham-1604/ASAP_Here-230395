import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/components/search_bar.dart';
import 'package:here_final/features/map/hcmap.dart';

class CDraggable extends ConsumerStatefulWidget {
  const CDraggable({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CDraggableState();
}

class _CDraggableState extends ConsumerState<CDraggable> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DraggableScrollableSheet(
          key: ref.read(mapProvider).sheet,
          controller: ref.read(mapProvider).sheet_controller,
          initialChildSize: 0.2,
          minChildSize: 0.1,
          maxChildSize: 0.78,
          expand: true,
          
          // snap: true,
          // snapSizes: [
          //   60 / constraints.maxHeight,
          //   0.5,
          // ],
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              // physics: const BouncingScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.78,
                decoration:  BoxDecoration(
                    // color: Colors.white.withOpacity(0.5),
                    color: Colors.blueGrey.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.black12,
                        // color: Colors.white24,
                      )
                    ]),

                    child: const Column(
                      children: [
                        WSearchBar()
                      ],
                    ),
                ),
            );
          },
        );
      },
    );
  }
}
