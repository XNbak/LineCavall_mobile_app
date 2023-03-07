// ignore_for_file: avoid_print

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'package:mobile_app/main.dart';

final FlutterReactiveBle ble = FlutterReactiveBle();
StreamSubscription? subscription;
StreamSubscription<ConnectionStateUpdate>? connection;
int temperature = 0;

void disconnect() async {
//    _subscription?.cancel();
  subscription?.cancel();
  if (connection != null) {
    await connection?.cancel();
  }
}

// added async to handle await
Future<void> connectBLE() async {
  // this section handles location services. no ble scan without them.
  // special thanks goes to ChatGPT

  final location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      // Handle the case where the user doesn't enable the location service.
      return;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      // Handle the case where the user doesn't grant the necessary permissions.
      return;
    }
  }

  // real connect ble void starts here
  disconnect();
  subscription = ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
      requireLocationServicesEnabled: true).listen((device) {
    if (device.name == 'Nano33BLESENSE') {
      print('Nano33BLESENSE found!');
      ble.connectToDevice(id: device.id).listen((connectionState) async {
        // Handle connection state updates
        print('connection state:');
        print(connectionState.connectionState);
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          final characteristic = QualifiedCharacteristic(
              serviceId: Uuid.parse("181A"),
              characteristicId: Uuid.parse("2A6E"),
              deviceId: device.id);
          final response = await ble.readCharacteristic(characteristic);
          print(response);
          temperature = response[0];
          var type = 1;
          var devId = device.id;
          var existCheck =
              await DeviceFieldDatabase.instance.getRowsWhereNameMatches(devId);
          // ignore: unnecessary_null_comparison
          if (existCheck.isEmpty) {
            var devIdInserter = devId;
            await DeviceFieldDatabase.instance.insertDeviceField(devIdInserter);
            print('database updated');
          }
          List<Map<String, dynamic>> addIdHelper =
              await DeviceFieldDatabase.instance.getRowsWhereNameMatches(devId);
          int idAdder = addIdHelper.first['id'];
          final time = DateTime.now();
          MeasFieldDatabase.instance.insertMeasField(
            type,
            temperature,
            idAdder,
            time.toIso8601String(),
          );
          //          }
          disconnect();
          print('disconnected');
        }
      }, onError: (dynamic error) {
        // Handle a possible error
        print(error.toString());
      });
    }
  }, onError: (error) {
    print('error!');
    print(error.toString());
  });
}
