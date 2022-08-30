import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

class BackgroundService {
  BackgroundService._();

  static Future<void> initBackgroundService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: onStart,
        isForegroundMode: true,
      ),
    );

    service.startService();
  }

  // to ensure this is executed
  // run app from xcode, then from xcode menu, select Simulate Background Fetch
  static bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    log('FLUTTER BACKGROUND FETCH');

    return true;
  }

  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // BackgroundLocation.startLocationService();

    // Android only
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    startLocationListen(service);
  }
}

void startLocationServiceListen(ServiceInstance service) async {
  final serviceStatusStream = Geolocator.getServiceStatusStream();
  serviceStatusStream.listen((status) async {
    if (status == ServiceStatus.disabled) {
      log('FLUTTER BACKGROUND SERVICE: Location service is disabled.');
      await Geolocator.openLocationSettings();
    } else {
      log('FLUTTER BACKGROUND SERVICE: Location service is enabled.');
    }
  });
}

void startLocationListen(ServiceInstance service) async {
  final positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
    ),
  );
  positionStream.listen((location) {
    log('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    log(
      'LOCATION_UPDATE: ${location.latitude}, ${location.longitude}',
    );

    // ${location.latitude}, ${location.longitude}
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Track My Locat",
        content:
            "Updated at ${DateTime.now()}\n${location.latitude}, ${location.longitude}",
      );
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "user_location": '${location.latitude}, ${location.longitude}',
      },
    );
  });
}
