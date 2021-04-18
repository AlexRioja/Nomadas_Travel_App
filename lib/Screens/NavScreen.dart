import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nomadas/Components/StartBottomSheet.dart';
import 'package:nomadas/Helpers/ColorHelper.dart';
import 'package:nomadas/Screens/HomeScreen.dart';
import 'package:nomadas/Services/BackgroundTasks.dart';
import 'package:nomadas/Services/SharedPreferencesInterface.dart';
import 'package:nomadas/navBar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'HomeScreen_2.dart';
import 'MapScreen.dart';
import 'ProfileScreen.dart';
import 'SettingsScreen.dart';

class NavScreen extends StatefulWidget {
  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  int _currentIndex = 0;
  var iconList;
  bool details = false;

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  AnimationController _animationController;
  CurvedAnimation curve;

  @override
  void initState() {
    /*
    final systemTheme = SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Color(0xFF373A36),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.purple
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

     */

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
    _pageController = PageController();
    iconList = <IconData>[
      Icons.directions_car,
      Icons.map,
      Icons.people,
      Icons.settings,
    ];

    super.initState();
  }

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
                          decoration:
                              InputDecoration(hintText: "Introduce un nombre!"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: mine_wine,
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            elevation: 20,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => SingleChildScrollView(
              child: StartBottomSheet(),
            ),
          ).then((value) => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (_) => bottomSheet(value)));
        },
      ),
      body: SafeArea(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            HomeScreen_2(),
            MapScreen(),
            ProfileScreen(),
            SettingsScreen()
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        onTap: (index) => setState(() {
          _currentIndex = index;
          _pageController.animateToPage(index,
              duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
          //_pageController.jumpToPage(index);
        }),
        backgroundColor: Colors.greenAccent,
        elevation: 8,
        leftCornerRadius: 5,
        rightCornerRadius: 5,
      ),
    );
  }
}
