import 'package:shared_preferences/shared_preferences.dart';

setTravel() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("travel", true);
}
clearTravel() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
Future<bool> checkTravel() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return  prefs.getBool("travel") ?? false;
}