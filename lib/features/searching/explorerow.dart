import 'package:flutter/material.dart';

class ExploreRow extends StatelessWidget {
  ExploreRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Explore nearby",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.only(left: 24),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Colors.blue,
              size: 24,
            ),
          )
        ],
      ),
    );
  }
}
