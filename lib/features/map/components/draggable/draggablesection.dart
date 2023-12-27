import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/components/draggable/children/csearch_bar.dart';
import 'package:here_final/features/map/components/search_bar.dart';
import 'package:here_final/features/map/hcmap.dart';
// import 'package:test_flutter/widgets/explorerow.dart';
// import 'package:test_flutter/widgets/rowwidgets.dart';
// import 'package:test_flutter/widgets/rowimages.dart';
// import 'package:test_flutter/widgets/rowevents.dart';
// import 'package:test_flutter/widgets/rowlists.dart';
// import 'package:test_flutter/widgets/searchbar.dart';

class DraggableSection extends StatelessWidget {
  final double top;
  final double searchBarHeight;

  const DraggableSection(
      {super.key, required this.top, required this.searchBarHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 1.1,
        margin: EdgeInsets.only(top: top),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                blurRadius: 30,
                color: Colors.grey[300] as Color,
              )
            ]),
        child: Stack(
          children: <Widget>[
            ListView(children: const <Widget>[
              // ExploreRow(),
              // RowWidgets(),
              // RowImages(),
              // RowEvents(),
              // RowLists()
            ]),
            CSearchBar(
                baseTop: top == 0.0 ? 0.0 : top, height: searchBarHeight),
          ],
        ));
  }
}

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
          maxChildSize: 0.95,
          expand: true,
          
          // snap: true,
          // snapSizes: [
          //   60 / constraints.maxHeight,
          //   0.5,
          // ],
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 1.1,
                decoration:  BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        blurRadius: 30,
                        color: Colors.black12,
                      )
                    ]),

                    child: Column(
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
