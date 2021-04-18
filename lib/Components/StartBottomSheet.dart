import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nomadas/Services/BackgroundTasks.dart';
import 'package:nomadas/Services/SharedPreferencesInterface.dart';
import 'package:provider/provider.dart';

class StartBottomSheet extends StatelessWidget {
  final String long_trip = "assets/icons/long_trip.png";
  final String short_trip = "assets/icons/short_trip.png";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TypeTravel(
            image: short_trip,
            title: "Viaje Corto",
            onTap: () {

              /*
              try {
                Provider.of<testLocation>(context, listen: false).init();
                Provider.of<testLocation>(context, listen: false).onStart(
                  locationAccuracy: LocationAccuracy.NAVIGATION,
                  interval: 15,
                  distanceFilter: 20,
                );
                setTravel();
              } catch (e) {
                print("LOCATION SERVICE ALREADY RUNNING?");
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Reinicia la app para registrar un nuevo viaje!",
                    textAlign: TextAlign.center,
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: StadiumBorder(),
                  elevation: 10,
                  duration: Duration(seconds: 10),
                ));
              }
              */
              Navigator.of(context).pop("corto");
            },
            desc:
                "Ideal para caminatas, paseos, rutas...\nEl algoritmo grabará las rutas con mayor precisión. También implica un mayor consumo de batería.",
          ),
          TypeTravel(
            image: long_trip,
            title: "Viaje Largo",
            onTap: () {
              Navigator.of(context).pop("largo");
              /*
              Provider.of<BackgroundLocationInterface>(context, listen: false)
                  .init(
                title: "Largo Viaje",
                accuracy: LocationAccuracy.POWERSAVE,
                distanceFilter: 500.0,
                intervalSeconds: 700,
              );
              Provider.of<BackgroundLocationInterface>(context, listen: false)
                  .start();

               */
            },
            desc:
                "Ideal para viajes en coche, avión...\nEl algoritmo se optimiza para consumir una menor cantidad de batería, a cambio de una ligeramente menor precisión",
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black87,
                        offset: Offset(5, 5),
                        blurRadius: 10)
                  ]),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  size: 30,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TypeTravel extends StatelessWidget {
  String image, title, desc;
  Function onTap;

  TypeTravel({this.image, this.title, this.desc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 9),
        height: 200,
        width: MediaQuery.of(context).size.width / 1.4,
        child: Card(
          elevation: 8,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Positioned(
                  left: -50,
                  top: 50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black45,
                            offset: Offset(5, 5),
                            blurRadius: 6)
                      ],
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.fill),
                    ),
                  ),
                ),
                Positioned(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(4, 4),
                              blurRadius: 10)
                        ]),
                  ),
                  top: 5,
                  left: MediaQuery.of(context).size.width / 6,
                ),
                Positioned(
                  child: Text(
                    desc,
                    style: TextStyle(height: 1.3),
                  ),
                  top: 40,
                  width: MediaQuery.of(context).size.width / 2,
                  left: MediaQuery.of(context).size.width / 6,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
