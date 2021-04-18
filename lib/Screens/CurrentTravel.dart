import 'package:flutter/material.dart';
import 'package:nomadas/Screens/MapScreen.dart';

class CurrentTravel extends StatelessWidget {
  String title;
  CurrentTravel({this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: MapScreen(title:title)));
  }
}
