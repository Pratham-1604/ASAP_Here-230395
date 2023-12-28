// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:here_final/features/map/hcmap.dart';
import 'package:here_final/features/searching/searching.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/search.dart';
import 'kpiwidget.dart';

class RowWidgets extends ConsumerStatefulWidget {
  const RowWidgets({super.key});

  static Searching newSearchEngine = Searching();

  @override
  ConsumerState<RowWidgets> createState() => _RowWidgetsState();
}

class _RowWidgetsState extends ConsumerState<RowWidgets> {
  @override
  Widget build(BuildContext context) {
    final mapController = ref.watch(mapProvider);
    return Container(
      margin: EdgeInsets.only(top: 16, left: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          KPIWidget(
            name: "Restaurant",
            child: Icon(
              Icons.restaurant,
              color: Color(0xffFF2D55),
              size: 26,
            ),
            onTap: () async {
              List<GeoCoordinates> abc =
                  await RowWidgets.newSearchEngine.getPlaces(
                categoryList: PlaceCategory(
                  PlaceCategory.eatAndDrinkRestaurant,
                ),
                geoCoordinates: GeoCoordinates(18.6783, 73.8950),
              );
              debugPrint(abc.length.toString());
              mapController.showMultipleMarkers(abc);
            },
          ),
          KPIWidget(
            name: "Hotels",
            child: Icon(
              Icons.hotel,
              color: Color(0xff27AE60),
              size: 26,
            ),
            onTap: () async {
              await RowWidgets.newSearchEngine.getPlaces(
                categoryList: PlaceCategory(
                  PlaceCategory.accommodation,
                ),
                geoCoordinates: GeoCoordinates(0, 0),
              );
            },
          ),
          KPIWidget(
            name: "Fuel Station",
            child: Icon(
              Icons.local_gas_station,
              color: Color(0xff2F80ED),
              size: 26,
            ),
            onTap: () async {
            await  RowWidgets.newSearchEngine.getPlaces(
                categoryList: PlaceCategory(
                  PlaceCategory.businessAndServicesFuelingStation,
                ),
                geoCoordinates: GeoCoordinates(0, 0),
              );
            },
          ),
          KPIWidget(
            name: "More",
            child: Icon(
              Icons.more_horiz,
              color: Color(0xffF2994A),
              size: 26,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
