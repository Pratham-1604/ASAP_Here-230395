// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class KPIWidget extends StatelessWidget {
  const KPIWidget({
    Key? key,
    required this.name,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 0.23 * MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Colors.white30,
                    Colors.white38,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: 40,
                    color: Colors.grey.shade300,
                  )
                ],
              ),
              child: this.child,
            ),
            Container(
              margin: EdgeInsets.only(top: 6),
              child: Text(
                this.name,
                style: TextStyle(
                  color: Color.fromARGB(255, 147, 202, 231),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
