// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:here_sdk/routing.dart';

class RoutingUI extends StatelessWidget {
  const RoutingUI({
    Key? key,
    required this.waypoints,
  }) : super(key: key);

  final List<Waypoint> waypoints;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: waypoints.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(waypoints[index].coordinates.latitude.toString(),),
      ),
    );
  }
}
