import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:nomadas/Services/FirebaseInterface.dart';
import 'package:nomadas/Services/Location.dart';
import 'package:nomadas/data/DataModels.dart';

import 'Location/location_callback_handler.dart';
import 'Location/location_service_repository.dart';

class testLocation with ChangeNotifier {
  LocationDto lastLocation;
  DateTime lastTimeLocation;
  ReceivePort port = ReceivePort();
  bool isRunning;

  init() {
    isRunning = false;
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);
    port.listen(
      (dynamic data) async {
        _updateNotificationText(data);
      },
    );
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    print('[BACKGROUND LOCATOR] Cargando background...');
    await BackgroundLocator.initialize();
    print('[BACKGROUND LOCATOR] Cargado!');
    isRunning = await BackgroundLocator.isServiceRunning();
  }

  void onStart({locationAccuracy, interval, distanceFilter, title}) async {
    if (await _checkLocationPermission()) {
      _startLocator(
          locationAccuracy: locationAccuracy,
          distanceFilter: distanceFilter,
          interval: interval,title: title);
      isRunning = await BackgroundLocator.isServiceRunning();
    } else {
      // show error
    }
  }

  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  void _startLocator({locationAccuracy, interval, distanceFilter,title}) {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        //initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: locationAccuracy,
            interval: interval,
            distanceFilter: double.tryParse(distanceFilter.toString()),
            client: LocationClient.google,
            wakeLockTime: 180,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
    addTravel(Travel(description: "", title: title));
  }

  void onStop() async {
    IsolateNameServer.removePortNameMapping(
        LocationServiceRepository.isolateName);
    BackgroundLocator.unRegisterLocationUpdate();
    port.close();
    isRunning = await BackgroundLocator.isServiceRunning();
  }

  Future<void> _updateNotificationText(LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "Nómadas está procesando las ubicaciones :)",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  addFootprintBackground(LocationDto dto) async {
    await determinePosition().then((value) {
      print("Tratando de guardar....");
      Footprint f = Footprint(
          id: "",
          lat: dto.latitude,
          lon: dto.longitude,
          altitude: dto.altitude);
      addFootprint(f);
      print("POSICIÓN GUARDADA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    });

    /*
        1.- Get Location
        2.- Get travel name (SharedPreferences)
        2.- Create Footprint object
        3.- Insert Footprint into Travel on local database
   */
  }
}
