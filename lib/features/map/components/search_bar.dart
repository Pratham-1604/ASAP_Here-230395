// ignore_for_file: prefer_conditional_assignment

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/hcmap.dart';
import 'package:here_final/features/routing/routing_file.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';

class WSearchBar extends StatelessWidget {
  const WSearchBar({super.key});

  static RoutingExample? _routingExample;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(mapProvider);
                  return TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0),
                    ),
                    onTap: () {
                      state.sheet_controller.animateTo(1,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn);
                    },
                    onTapOutside: (event) {
                      // hide the keyboard
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    onChanged: (value) async {
                      final GeoCoordinates currentLocation =
                          await state.getPermisson();
                      await state.searchPlace(value, currentLocation);
                    },
                  );
                }),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Consumer(builder: (context, ref, child) {
          final state = ref.watch(mapProvider);
          if (state.searchResult.isEmpty) {
            return Container();
          }
          return Container(
            height: (state.searchResult.isEmpty)
                ? MediaQuery.of(context).size.height * 0.3
                : MediaQuery.of(context).size.height * 0.65,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: (state.isSearching)
                ? const Center(child: CircularProgressIndicator())
                : (state.searchResult.isEmpty)
                    ? const Center(
                        child: Text(
                          "No results found",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      // shrinkWrap: true,
                        itemCount: state.searchResult.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () async {
                              final mapController = ref.read(mapProvider);
                              mapController.addMarker(index);
                              if (_routingExample == null) {
                                _routingExample = RoutingExample(
                                    mapController.hereMapController!);
                              }
                              if (_routingExample!.waypoints.isEmpty) {
                                GeoCoordinates geo =
                                    await mapController.getPermisson();
                                _routingExample!.addWaypoint(Waypoint(geo));
                              }
                              _routingExample!.addWaypoint(
                                  Waypoint(state.searchResult[index]['geo']));
                              debugPrint("${_routingExample!.waypoints.length}");
                              mapController.routingExample = _routingExample;
                              _routingExample!.addRoute();

                              mapController
                                  .flyTo(state.searchResult[index]['geo']);
                            },
                            title: Text(
                              state.searchResult[index]['title'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              state.searchResult[index]['address'],
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
          );
        }),
      ],
    );
  }
}
