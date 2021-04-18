import 'package:background_locator/settings/locator_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nomadas/Components/StartBottomSheet.dart';
import 'package:nomadas/Screens/ProfileScreen.dart';
import 'package:nomadas/Services/BackgroundTasks.dart';
import 'package:nomadas/Services/FirebaseInterface.dart';
import 'package:nomadas/Services/SharedPreferencesInterface.dart';
import 'package:provider/provider.dart';
import 'CurrentTravel.dart';

class HomeScreen_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initShortTrip(String title) {
      try {
        Provider.of<testLocation>(context, listen: false).init();
        Provider.of<testLocation>(context, listen: false).onStart(
            locationAccuracy: LocationAccuracy.NAVIGATION,
            interval: 15,
            distanceFilter: 20,
            title: title);
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
    }

    bottomSheet(value) {
      TextEditingController c = TextEditingController();
      final _formKey = GlobalKey<FormState>();
      if (value == 'corto') {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Nombre del Viaje:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: TextFormField(
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return 'Nombre vacío!!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                hintText: "Introduce un nombre!"),
                            controller: c,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton.icon(
                            icon: Icon(Icons.check),
                            label: Text("Empezar!"),
                            onPressed: () {
                              if (c.text.isNotEmpty) {
                                initShortTrip(c.text);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    "Introduce algo... no me seas... ",
                                    textAlign: TextAlign.center,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: StadiumBorder(),
                                  elevation: 10,
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 500),
                                ));
                              }
                              /*
                           if (_formKey.currentState
                               .validate()) {
                             initShortTrip(c.text);
                           }

                            */
                            },
                          ),
                        )
                      ],
                    ),
                  ),
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
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(0),
            ),
          ),
        );
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            elevation: 20,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => SingleChildScrollView(
              child: StartBottomSheet(),
            ),
          ).then((value) {
            if (value != null) {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (_) => bottomSheet(value));
            }
          });
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SearchAndProfile(),
              Quote(),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    TripsTitles(
                      firstWord: "Viaje ",
                      secondWord: "Actual",
                    ),
                    FutureBuilder(
                        future: getCurrentTravel(),
                        initialData: null,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return Text("Empieza a viajar!");
                          String title = snapshot.data.docs[0]['title'];
                          return CurrentTravelWidget(title: title);
                        }),
                    TripsTitles(
                      firstWord: "Más ",
                      secondWord: "Viajes",
                    ),
                    NestedTabBar()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NestedTabBar extends StatefulWidget {
  @override
  _NestedTabBarState createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.purpleAccent,
      labelColor: Colors.purple,
      unselectedLabelColor: Colors.black54,
      isScrollable: true,
      tabs: <Widget>[
        Tab(
          text: "Mis Viajes",
          icon: Icon(Icons.car_repair),
        ),
        Tab(
          text: "Cercanos",
          icon: Icon(Icons.map),
        ),
        Tab(
          text: "Amigos",
          icon: Icon(Icons.people),
        ),
        Tab(
          text: "Destacados",
          icon: Icon(Icons.star),
        ),
      ],
    );
  }
}

class CurrentTravelWidget extends StatelessWidget {
  const CurrentTravelWidget({
    Key key,
    @required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 150,
        width: MediaQuery.of(context).size.width / 1.2,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.blueGrey[200],
                Colors.white70
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) =>
                    CurrentTravel(title: title)));
          },
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                      gradient:
                          LinearGradient(colors: [Colors.red, Colors.pink]),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text("Foto")),
                ),
              ),
              Positioned(
                  right: 10,
                  top: 1,
                  child: Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width / 2.8,
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Pacifico",
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Marzo-2021",
                          style: TextStyle(fontFamily: "Pacifico"),
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  )),
            ],
          ),
        ));
  }
}

class TripsTitles extends StatelessWidget {
  String firstWord, secondWord;

  TripsTitles({this.firstWord, this.secondWord});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
              text: firstWord,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30,
                  letterSpacing: 3,
                  wordSpacing: 1,
                  fontFamily: 'Pacifico'),
              children: [
                TextSpan(
                    text: secondWord,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 28))
              ]),
        ),
      ),
    );
  }
}

class SearchAndProfile extends StatelessWidget {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.search,
            size: 36,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.grey[500],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                  image: DecorationImage(image: CachedNetworkImageProvider(user.photoURL))),
              //TODO poner icono del avatar seleccionado al principio
            ),
          ),
        ],
      ),
    );
  }
}

class Quote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      "El trabajo llena tus bolsillos, las aventuras llenan tu alma",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black45, fontFamily: 'Pacifico'),
    );
  }
}
