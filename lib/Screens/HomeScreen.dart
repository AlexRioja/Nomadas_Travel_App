import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nomadas/Helpers/ColorHelper.dart';
import 'package:nomadas/Services/FirebaseInterface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomadas/data/DataModels.dart';

import 'CurrentTravel.dart';

//import 'package:background_location/background_location.dart';
class HomeScreen extends StatelessWidget {
  int month = new DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    //print(month);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: mine_wine,
          flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.all(8),
              centerTitle: true,
              title: Center(
                child: Text("Nómadas",
                    style: TextStyle(
                      letterSpacing: 1.5,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0,
                    )),
              ),
              background: Image.asset(
                "assets/months_backgrounds/$month.jpg",
                fit: BoxFit.cover,
              )),
          expandedHeight: 180,
        ),
        StreamBuilder(
          stream: getAllTravels(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    List<DocumentSnapshot> docs = snapshot.data.docs;
                    return Column(
                      children: [
                        FutureBuilder(
                          future: getCurrentTravel(),
                          initialData: null,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return Text("Empieza a viajar!");
                            //print(snapshot.data.docs.l);
                            if (snapshot.data.docs.length > 0) {
                              String title = "Sin poner";
                              try {
                                title = snapshot.data.docs[0]['title'];
                              } catch (e) {
                                print(e);
                              }
                              return CurrentTravelCard(
                                travel: Travel(title: title, description: ""),
                              );
                            }
                            return Text("Empieza a viajar!");
                          },
                        ),
                        TravelCard(name: docs[index].data()['name']),
                      ],
                    );
                  } else {
                    List<DocumentSnapshot> docs = snapshot.data.docs;
                    return TravelCard(name: docs[index].data()['name']);
                  }
                },
                childCount: snapshot.hasData ? snapshot.data.docs.length : 0,
              ),
            );
          },
        )
      ]),
    );
  }
}

class CurrentTravelCard extends StatelessWidget {
  Travel travel;

  CurrentTravelCard({this.travel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 18, bottom: 8),
      child: Container(
        height: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.height / 1.2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.transparent),
        child: Stack(
          overflow: Overflow.visible,
          children: [
            Positioned(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => CurrentTravel()));
                },
                child: Container(
                  height: MediaQuery.of(context).size.height / 4,
                  width: MediaQuery.of(context).size.height / 1.2,
                  margin: EdgeInsets.only(left: 50),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(35),
                          topLeft: Radius.circular(35),
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35)),
                      image: DecorationImage(
                          image: AssetImage("assets/icons/map.png"),
                          fit: BoxFit.fitWidth,
                          colorFilter: ColorFilter.linearToSrgbGamma()),
                      border: Border.all(color: Colors.black45)),
                  child: Container(
                    margin: EdgeInsets.only(left: 50),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          travel.title,
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: MediaQuery.of(context).size.height / 28,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/icons/current_travel.png"),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelCard extends StatelessWidget {
  String name;

  TravelCard({this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 4.5,
          child: Stack(
            children: [CardInfo(name: name), LittleButton()],
          ),
        )
        //child: Stack(CardInfo(name: name)),
        );
  }
}

class LittleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: mine_marineBlue,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          width: MediaQuery.of(context).size.width / 6,
          child: Icon(Icons.people)),
      right: 8,
    );
  }
}

class CardInfo extends StatelessWidget {
  const CardInfo({
    Key key,
    @required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 14,
      child: Container(
          height: MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width / 1.05,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: mine_violet,
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10.0,
                offset: Offset(5, 10.0),
              ),
            ],
          ),
          child: Center(
              child: Text(
            name,
            style: TextStyle(fontSize: 30),
          ))),
    );
  }
}
