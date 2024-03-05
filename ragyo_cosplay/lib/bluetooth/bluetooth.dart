import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ragyo_cosplay/providers/bluetooth.dart';
import 'package:ragyo_cosplay/secrets.dart';

class Bluetooth {
  Bluetooth({required this.ref});

  final WidgetRef ref;

  final ble = FlutterReactiveBle();
  final _hueCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: hueCharacteristicUUID);
  final _modeCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: modeCharacteristicUUID);
  final _disconnectCharacteristic = QualifiedCharacteristic(
    characteristicId: disconnectCharacteristicUUID,
    serviceId: serviceUUID,
    deviceId: arduinoID,
  );

  Timer? _hueDebouncer;
  StreamSubscription? _connection;

  void startConnection() {
    ref.read(bluetoothNotifierProvider.notifier).connecting = true;
    final connection = ble
        .connectToDevice(id: arduinoID, servicesWithCharacteristicsToDiscover: {
      serviceUUID: [hueCharacteristicUUID]
    });
    _connection = connection.listen((connectedDevice) {
      if (connectedDevice.connectionState != DeviceConnectionState.connected) {
        ref.read(bluetoothNotifierProvider.notifier).connected = false;
        return;
      } else {
        ref.read(bluetoothNotifierProvider.notifier).connected = true;
        ref.read(bluetoothNotifierProvider.notifier).connecting = false;
      }
    });
  }

  void disconnect() {
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    ble.writeCharacteristicWithoutResponse(
      _disconnectCharacteristic,
      value: [1],
    );
  }

  set mode(Mode mode) {
    ref.read(bluetoothNotifierProvider.notifier).mode = mode;

    if (!ref.read(bluetoothNotifierProvider).connected) return;
    ble.writeCharacteristicWithoutResponse(
      _modeCharacteristic,
      value: [Mode.values.indexOf(mode)],
    );
    print(Mode.values.indexOf(mode));
  }

  set hue(double hue) {
    ref.read(bluetoothNotifierProvider.notifier).hue = hue;
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    if (_hueDebouncer?.isActive ?? false) _hueDebouncer?.cancel();
    _hueDebouncer = Timer(const Duration(milliseconds: 1), () {
      ble.writeCharacteristicWithoutResponse(
        _hueCharacteristic,
        value: [hue.toInt()],
      );
    });
  }

  void dispose() {
    _connection?.cancel();
    _hueDebouncer?.cancel();
  }
}
