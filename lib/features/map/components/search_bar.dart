// ignore_for_file: prefer_conditional_assignment, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/hcmap.dart';
import 'package:here_final/features/routing/routing_file.dart';
import 'package:here_final/features/searching/explorerow.dart';
import 'package:here_final/features/searching/rowwidgets.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';

class WSearchBar extends StatefulWidget {
  const WSearchBar({super.key});

  @override
  State<WSearchBar> createState() => _WSearchBarState();
}

class _WSearchBarState extends State<WSearchBar> {
  RoutingExample? _routingExample;
  List<String> places = [];
  Map routeDet = {};
  bool toAdd = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer(builder: (context, ref, child) {
          final state = ref.watch(mapProvider);
          if (state.isRouting && state.manuverNotify != "") {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  state.manuverNotify,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          } else {
            return Container();
          }
        }),
        if (places.isNotEmpty && routeDet.isEmpty)
          const Padding(padding: EdgeInsets.all(16)),
        if (places.isNotEmpty && routeDet.isNotEmpty)
          Container(
            color: Colors.blueGrey.withAlpha(25),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Consumer(builder: (context, ref, child) {
                  final state = ref.watch(mapProvider);
                  if (state.isRouting) {
                    double speed = 0;
                    final random = Random();
                    int randomValue = random.nextInt(2);
                    if (randomValue == 0) {
                      speed = state.drivingSpeed - state.speedAccuracy;
                    } else {
                      speed = state.drivingSpeed + state.speedAccuracy;
                    }
                    return Text(
                      "${routeDet["total_time"]} | ${speed.toStringAsFixed(2)} m/s",
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  return Text(
                    routeDet["total_time"],
                    style: TextStyle(color: Colors.white),
                  );
                }),
                subtitle: Text(
                  "${routeDet["traffic"]} ,${routeDet["length"]}",
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer(builder: (context, ref, child) {
                      final state = ref.watch(mapProvider);
                      return IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          state.toggleRouting();
                        },
                        icon: Icon(
                          Icons.start,
                          size: 30,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        if (places.isNotEmpty) Divider(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (places.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          left: 10,
                          top: 2,
                          bottom: 2,
                        ),
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          debugPrint(places.length.toString());
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.5),
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.all(4),
                            child: ListTile(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                places[index],
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (toAdd)
                      Row(
                        children: [
                          Expanded(
                            child: Consumer(builder: (context, ref, child) {
                              final state = ref.watch(mapProvider);
                              return TextField(
                                controller: state.textEditor,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 15.0),
                                ),
                                onTap: () {
                                  state.sheet_controller.animateTo(1,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeIn);
                                },
                                onTapOutside: (event) {
                                  // hide the keyboard
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                onChanged: (value) async {
                                  final GeoCoordinates currentLocation =
                                      await state.getPermisson();
                                  await state.searchPlace(
                                      value, currentLocation);
                                },
                              );
                            }),
                          ),
                          Consumer(builder: (ctx, ref, child) {
                            final state = ref.watch(mapProvider);
                            return InkWell(
                              onTap: () {
                                if (state.searchResult.isNotEmpty) {
                                  state.emptySearchResult();
                                  state.textEditor.clear();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Icon(
                                  (state.searchResult.isEmpty
                                      ? Icons.search
                                      : Icons.cancel_rounded),
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              if (places.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white54,
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          toAdd = true;
                        });
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
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
                                    mapController.hereMapController!,
                                    mapController);
                              }
                              if (_routingExample!.waypoints.isEmpty) {
                                GeoCoordinates geo =
                                    await mapController.getPermisson();
                                _routingExample!.addWaypoint(Waypoint(geo));
                              }
                              _routingExample!.addWaypoint(
                                  Waypoint(state.searchResult[index]['geo']));
                              mapController.routingExample = _routingExample;

                              // ignore: use_build_context_synchronously
                              await showDialog(
                                
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.blueGrey.withOpacity(0.6),
                                      title:
                                          const Text('Mileage based Routing', style: TextStyle(color: Colors.white),),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                              'Enter Mileage for your vehicle', style: TextStyle(color: Colors.white),),
                                          TextField(
                                            // controller: state.mileageController,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            decoration: InputDecoration(
                                              
                                              
                                              hintText: "Mileage",
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              // border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(left: 15.0),
                                            ),
                                            onChanged: (value) {
                                              if (num.tryParse(value) != null) {
                                                // state.mileage = num.parse(value);
                                                _routingExample?.mileage =
                                                    num.parse(value);
                                                // print(_routingExample?.mileage);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.blueGrey.withOpacity(0.8),
                                          ),
                                          child: const Text('Done', style: TextStyle(color: Colors.white),),
                                        ),
                                      ],
                                    );
                                  });

                              await _routingExample!.addRoute();
                              setState(() {
                                toAdd = false;
                                if (places.isEmpty) places.add("Your Location");
                                places.add(state.searchResult[index]['title']);
                                // _routingExample!
                                //     .showRouteDetails(_routingExample!.route!);
                                routeDet = _routingExample!.routeDetails!;
                              });
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: ExploreRow(),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: RowWidgets(),
        ),
      ],
    );
  }
}
