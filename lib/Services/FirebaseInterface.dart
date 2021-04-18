import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nomadas/data/DataModels.dart';

getAllTravels() {
  return FirebaseFirestore.instance
      .collection("viajes")
      .orderBy("date", descending: true)
      .snapshots();
}

Future<QuerySnapshot> getCurrentTravel() async{
  User user = FirebaseAuth.instance.currentUser;
  return await FirebaseFirestore.instance
      .collection("Users")
      .doc(user.email)
      .collection("CurrentTravel").get();
}

createUser(User user) {
  FirebaseFirestore.instance.collection('Users').doc(user.email).set({
    "timestamp": DateTime.now(),
    "uid": user.uid,
    "name": user.displayName,
    "email": user.email,
    "photo": user.photoURL,
  });
}

addTravel(Travel travel) {
  User user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore.instance
      .collection('Users')
      .doc(user.email)
      .collection("CurrentTravel")
      .doc("currTravel")
      .set({
    "timestamp": travel.initDate,
    "title": travel.title,
    "description": travel.description,
    "public": travel.public,
    "footprints": travel.footprints,
  });
}

Stream<QuerySnapshot> getFootprints() {
  return FirebaseFirestore.instance.collection("huellas").snapshots();
}

addFootprint(Footprint f) {
  User user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore.instance
      .collection('Users')
      .doc(user.email)
      .collection("CurrentTravel")
      .doc("currTravel")
      .collection("footprints")
      .doc(DateTime.now().toString())
      .set({
    "timestamp": DateTime.now(),
    "id": f.id,
    "latitude": f.lat,
    "longitude": f.lon,
    "altitude": f.altitude,
  });
}
