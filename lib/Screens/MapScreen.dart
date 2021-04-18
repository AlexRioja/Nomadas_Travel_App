import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:nomadas/Services/BackgroundTasks.dart';
import 'package:nomadas/Services/FirebaseInterface.dart';
import 'package:nomadas/tappable_polylines/flutter_map_tappable_polyline.dart';
import 'package:provider/provider.dart';
import 'package:user_location/user_location.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}

class MapScreen extends StatelessWidget {
  String title;

  MapScreen({this.title});

  @override
  Widget build(BuildContext context) {
    return Test(title: title);
  }
}

class Test extends StatelessWidget {
  User user = FirebaseAuth.instance.currentUser;
  String title;

  Test({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image(
                        image: AssetImage("assets/icons/back_arrow.png"),
                        width: 40,
                      )),
                  Expanded(
                    child: Text(
                      title,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.grey[500],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                        image: DecorationImage(
                            image: CachedNetworkImageProvider(user.photoURL))),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  Provider.of<testLocation>(context, listen: false).onStop();
                },
                child: Text(
                  "Cancelar seguimiento",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Expanded(child: Mapa())
            /*
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Lista de footprints que se van añadiendo"),
            ),
            Expanded(child: ListFootprints())

             */
          ],
        ),
      ),
    );
  }
}

class Mapa extends StatefulWidget {
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  ElevationPoint hoverPoint;
  MapController mapController;
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];
  List<ElevationPoint> elevatedPoints = [];
  bool showAltitude;
  Widget buttonLocation = Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 8.0)]),
    child: Image(
      image: AssetImage("assets/icons/location_map.png"),
    ),
  );

  @override
  void initState() {
    showAltitude = false;
    mapController = MapController();
    getFootprints().listen((snapshot) {
      setState(() {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (int i = 0; i < docs.length; i++) {
          Map<String, dynamic> info = docs[i].data();
          elevatedPoints.add(ElevationPoint(
              info['latitude'], info['longitude'], info['altitude']));
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // You can use the userLocationOptions object to change the properties
    // of UserLocationOptions in runtime
    userLocationOptions = UserLocationOptions(
        context: context,
        mapController: mapController,
        markers: markers,
        locationUpdateIntervalMs: 4000,
        zoomToCurrentLocationOnLoad: true,
        updateMapLocationOnPositionChange: false,
        defaultZoom: 14.5,
        fabBottom: MediaQuery.of(context).size.height / 1.4,
        locationUpdateInBackground: false,
        moveToCurrentLocationFloatingActionButton: buttonLocation);
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(children: [
        FlutterMap(
          options: MapOptions(
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            center: LatLng(42.824176370182684, -2.0875488387232775),
            controller: mapController,
            plugins: [
              UserLocationPlugin(),
              TappablePolylineMapPlugin(),
            ],
          ),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                tileProvider: const CachedTileProvider()),
            TappablePolylineLayerOptions(
                // Will only render visible polylines, increasing performance
                polylineCulling: true,
                polylines: [
                  TaggedPolyline(
                    tag: "Test",
                    // An optional tag to distinguish polylines in callback
                    points: elevatedPoints,
                    color: Colors.red,
                    strokeWidth: 4.0,
                  ),
                ],
                onTap: (TaggedPolyline polyline) {
                  print("CACA DE LA VACA");
                  return Container(
                    child: FlutterLogo(),
                  );
                },
                onMiss: () => print("No polyline tapped")),
            MarkerLayerOptions(markers: [
              if (hoverPoint is LatLng)
                Marker(
                    point: hoverPoint,
                    width: 8,
                    height: 8,
                    builder: (BuildContext context) => Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8)),
                        ))
            ]),
            // ADD THIS
            MarkerLayerOptions(markers: markers),
            // ADD THIS
            userLocationOptions,
          ],
          mapController: mapController,
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height / 1.42,
          left: 8,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                children: [
                  Text(
                    "Elevación",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: showAltitude,
                    onChanged: (value) {
                      setState(() {
                        showAltitude = !showAltitude;
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        showAltitude
            ? Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  color: Colors.white.withOpacity(0.6),
                  child: NotificationListener<ElevationHoverNotification>(
                      onNotification:
                          (ElevationHoverNotification notification) {
                        setState(() {
                          hoverPoint = notification.position;
                        });
                        return true;
                      },
                      child: Elevation(
                        elevatedPoints,
                        color: Colors.grey,
                        elevationGradientColors: ElevationGradientColors(
                            gt10: Colors.green,
                            gt20: Colors.orangeAccent,
                            gt30: Colors.redAccent),
                      )),
                ),
              )
            : Container()
      ]),
    );
  }
}

class ListFootprints extends StatefulWidget {
  @override
  _ListFootprintsState createState() => _ListFootprintsState();
}

class _ListFootprintsState extends State<ListFootprints> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getFootprints(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            );
          }
          List<ListTile> lt = [];
          List<DocumentSnapshot> docs = snapshot.data.docs;
          for (int i = 0; i < docs.length; i++) {
            Map<String, dynamic> info = docs[i].data();
            lt.add(ListTile(
              title: Text(info['timestamp'].toString()),
              subtitle: Text(info['latitude'].toString() +
                  info['longitude'].toString() +
                  info['altitude'].toString()),
            ));
          }
          return ListView(
            children: lt,
          );
        });
  }
}
