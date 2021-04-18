import 'package:flutter/material.dart';

class Travel {
  String title, description;
  bool public;
  List<Footprint> footprints=[];
  DateTime initDate=DateTime.now();

  Travel({
    @required this.description,
    @required this.title,
    public=true
  });

  addFootprint(Footprint footprint){
    footprints.add(footprint);
  }
  deleteFootprint(Footprint footprint){
    footprints.remove(footprint);
  }
  getNumFootprints(){
    return footprints.length;
  }
}

class Footprint {
  String id;
  double lat, lon,altitude;
  bool fromBackground;

  Footprint({
    @required this.id,
    @required this.lat,
    @required this.lon,
    @required this.altitude,
    fromBackground=true
  });
}
