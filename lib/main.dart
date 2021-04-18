import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Photos_API/model/photos_library_api_model.dart';
import 'Screens/AuthScreen.dart';
import 'Services/BackgroundTasks.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark
    ),
  );
  final apiModel = PhotosLibraryApiModel();
  apiModel.signInSilently();



  runApp(ScopedModel<PhotosLibraryApiModel>(
    model: apiModel,
    child: Nomadas_App(),
  ),);
}

class Nomadas_App extends StatefulWidget {
  @override
  _Nomadas_AppState createState() => _Nomadas_AppState();
}

class _Nomadas_AppState extends State<Nomadas_App> {
  static const String _isolateName = "LocatorIsolate";
  Future<FirebaseApp> _initialization;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (context) => testLocation(),
            child: App(),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nomadas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: "Nunito",
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.purple),
      home: SplashPage(seconds: 3, goToPage: AuthScreen()),
    );
  }
}

class SplashPage extends StatelessWidget {
  int seconds = 0;
  Widget goToPage;

  SplashPage({this.seconds, this.goToPage});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: this.seconds), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => goToPage));
    });
    return Scaffold(
      body: Container(
        color: Colors.green,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              Icons.card_travel,
              size: 150,
              color: Colors.white,
            ),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
