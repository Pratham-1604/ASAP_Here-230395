import 'package:flutter/material.dart';

class CSearchBar extends StatelessWidget {
  const CSearchBar({super.key, required this.height, required this.baseTop});

  final double height;
  final double baseTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      padding: const EdgeInsets.only(top: 6),
      margin: const EdgeInsets.only(left: 10, right: 10),
      transform: Matrix4.translationValues(0.0, -20.0, 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Icon(Icons.search, color: Colors.white, size: 20),
                  Container(
                    child: const Opacity(
                      opacity: 0.8,
                      child: Text(
                        'Search here',
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                  const Opacity(
                      opacity: 0.6,
                      child: Icon(Icons.mic, color: Colors.white, size: 20))
                ],
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 100.0,
              height: 4,
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2 - 60.0 / 2,
                right: MediaQuery.of(context).size.width / 2 - 60.0 / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
