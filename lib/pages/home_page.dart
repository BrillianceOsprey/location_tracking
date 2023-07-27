// import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nb_utils/nb_utils.dart';

import '../background_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final hasPermission = await Geolocator.checkPermission();

    if (hasPermission != LocationPermission.always) {
      // ignore: use_build_context_synchronously
      showConfirmDialog(
        context,
        'You must allow the location permission to allow all the time.',
        positiveText: 'OK',
        onAccept: () async {
          final permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.always) {
            await Geolocator.requestPermission();
          }
        },
        barrierDismissible: false,
      );
    }

    // Geolocator.getServiceStatusStream().listen((event) async {
    //   if (event == ServiceStatus.disabled) {
    //     log('Location service is disabled.');
    //     await Geolocator.openLocationSettings();
    //   } else {
    //     log('Location service is enabled.');
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 60),
          // Forground Mode
          ElevatedButton(
            child: const Text("Foreground Mode"),
            onPressed: () {
              FlutterBackgroundService().invoke("setAsForeground");
            },
          ),
          const SizedBox(height: 20),
          // Background Mode
          ElevatedButton(
            child: const Text("Background Mode"),
            onPressed: () {
              FlutterBackgroundService().invoke("setAsBackground");
            },
          ),
          const SizedBox(height: 20),
          // Start Button
          ElevatedButton(
            onPressed: () async {
              final service = FlutterBackgroundService();
              var isRunning = await service.isRunning();
              if (!isRunning) {
                if (!await Geolocator.isLocationServiceEnabled()) {
                  log('Location service is disabled.');
                  await Geolocator.openLocationSettings();
                } else {
                  log('Location service is enabled.');
                  await BackgroundService.initBackgroundService();
                }
              }
            },
            child: const Text('Start Service'),
          ),
          const SizedBox(height: 20),
          // Stop Button
          ElevatedButton(
            child: const Text('Stop Service'),
            onPressed: () async {
              final service = FlutterBackgroundService();
              var isRunning = await service.isRunning();
              if (isRunning) {
                service.invoke("stopService");
              }
            },
          ),
          const SizedBox(height: 20),
          StreamBuilder<Map<String, dynamic>?>(
            stream: FlutterBackgroundService().on('update'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = snapshot.data!;
              String? location = data["user_location"];
              DateTime? date = DateTime.tryParse(data["current_date"]);
              return Column(
                children: [
                  Text(location ?? 'Unknown'),
                  Text(date.toString()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
