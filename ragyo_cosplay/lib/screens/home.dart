import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ragyo_cosplay/secrets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _hue = 0.0;
  var _connected = false;
  var _connections = 0;
  Timer? _debounce;

  final _hueCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: hueCharacteristicUUID);
  final _syncCharacteristic = QualifiedCharacteristic(
    characteristicId: syncCharacteristicUUID,
    serviceId: serviceUUID,
    deviceId: arduinoID,
  );
  final _disconnectCharacteristic = QualifiedCharacteristic(
    characteristicId: disconnectCharacteristicUUID,
    serviceId: serviceUUID,
    deviceId: arduinoID,
  );
  final ble = FlutterReactiveBle();

  Future<void> _connectBluetooth() async {
    await Permission.locationWhenInUse.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();

    ble.connectToDevice(id: arduinoID, servicesWithCharacteristicsToDiscover: {
      serviceUUID: [hueCharacteristicUUID]
    }).listen((connectedDevice) {
      setState(() {
        _connections++;
      });
      if (connectedDevice.connectionState != DeviceConnectionState.connected) {
        setState(() {
          _connected = false;
        });
        return;
      } else {
        ble.writeCharacteristicWithoutResponse(_syncCharacteristic, value: [1]);
        setState(() {
          _connected = true;
          debugPrint("Characteristic set!");
        });
      }
    });
  }

  Future<void> _disconnectBluetooth() async {
    if (!_connected) return;

    ble.writeCharacteristicWithoutResponse(
      _disconnectCharacteristic,
      value: [1],
    );
  }

  _onHueChange(double hue) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1), () {
      if (_connected) {
        ble.writeCharacteristicWithoutResponse(
          _hueCharacteristic,
          value: [hue.toInt()],
        );
      }
    });
    setState(() {
      _hue = hue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ragyo Kiryuin"),
        ),
        body: Column(
          children: [
            Text(
              _connected ? "Connected!" : "Disconnected!",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
            Slider(
              value: _hue,
              onChanged: _onHueChange,
              divisions: 255,
              label: _hue.round().toString(),
              min: 0,
              max: 255,
            ),
            TextButton(
              onPressed: _connectBluetooth,
              child: const Text("Connect"),
            ),
            TextButton(
              onPressed: _disconnectBluetooth,
              child: const Text("Disconnect"),
            ),
            Text("Connections: $_connections")
          ],
        ));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
