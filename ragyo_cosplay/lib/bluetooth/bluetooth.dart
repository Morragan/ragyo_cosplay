import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ragyo_cosplay/providers/bluetooth.dart';
import 'package:ragyo_cosplay/secrets.dart';

const CHAR_WRITE_RATE_MS = 10;

List<int> intToBytes(int value) {
  // Assuming a 16-bit integer (2 bytes)
  return [
    (value & 0xFF), // Least significant byte
    ((value >> 8) & 0xFF), // Most significant byte
  ];
}

class Bluetooth {
  Bluetooth({required this.ref});

  final WidgetRef ref;

  final ble = FlutterReactiveBle();
  final _disconnectCharacteristic = QualifiedCharacteristic(
    characteristicId: disconnectCharacteristicUUID,
    serviceId: serviceUUID,
    deviceId: arduinoID,
  );
  final _modeCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: modeCharacteristicUUID);
  final _brightnessCharacteristic = QualifiedCharacteristic(
    characteristicId: brightnessCharacteristicUUID,
    serviceId: serviceUUID,
    deviceId: arduinoID,
  );
  final _hueCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: hueCharacteristicUUID);
  final _rainbowSpeedCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: rainbowSpeedCharacteristicUUID);
  final _raveSpeedCharacteristic = QualifiedCharacteristic(
      deviceId: arduinoID,
      serviceId: serviceUUID,
      characteristicId: raveSpeedCharacteristicUUID);

  Timer? _brightnessDebouncer;
  Timer? _hueDebouncer;
  Timer? _rainbowSpeedDebouncer;
  Timer? _raveSpeedDebouncer;
  StreamSubscription? _connection;

  void startConnection() {
    ref.read(bluetoothNotifierProvider.notifier).connecting = true;
    final connection = ble
        .connectToDevice(id: arduinoID, servicesWithCharacteristicsToDiscover: {
      serviceUUID: [
        disconnectCharacteristicUUID,
        hueCharacteristicUUID,
        modeCharacteristicUUID
      ]
    });
    _connection = connection.listen((connectedDevice) {
      if (connectedDevice.connectionState ==
          DeviceConnectionState.disconnected) {
        ref.read(bluetoothNotifierProvider.notifier).connected = false;
        ref.read(bluetoothNotifierProvider.notifier).connecting = false;
      } else if (connectedDevice.connectionState !=
          DeviceConnectionState.connected) {
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
  }

  set brightness(double brightness) {
    ref.read(bluetoothNotifierProvider.notifier).brightness = brightness;
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    if (_hueDebouncer?.isActive ?? false) _hueDebouncer?.cancel();
    _hueDebouncer = Timer(const Duration(milliseconds: CHAR_WRITE_RATE_MS), () {
      ble.writeCharacteristicWithoutResponse(
        _brightnessCharacteristic,
        value: [brightness.toInt()],
      );
    });
  }

  set hue(double hue) {
    ref.read(bluetoothNotifierProvider.notifier).hue = hue;
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    if (_hueDebouncer?.isActive ?? false) _hueDebouncer?.cancel();
    _hueDebouncer = Timer(const Duration(milliseconds: CHAR_WRITE_RATE_MS), () {
      ble.writeCharacteristicWithoutResponse(
        _hueCharacteristic,
        value: [hue.toInt()],
      );
    });
  }

  set rainbowSpeed(double speed) {
    ref.read(bluetoothNotifierProvider.notifier).rainbowSpeed = speed;
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    if (_rainbowSpeedDebouncer?.isActive ?? false) {
      _rainbowSpeedDebouncer?.cancel();
    }
    _rainbowSpeedDebouncer =
        Timer(const Duration(milliseconds: CHAR_WRITE_RATE_MS), () {
      ble.writeCharacteristicWithoutResponse(
        _rainbowSpeedCharacteristic,
        value: intToBytes(510 - speed.toInt()),
      );
    });
  }

  set raveSpeed(double speed) {
    ref.read(bluetoothNotifierProvider.notifier).raveSpeed = speed;
    if (!ref.read(bluetoothNotifierProvider).connected) return;

    if (_raveSpeedDebouncer?.isActive ?? false) _raveSpeedDebouncer?.cancel();
    _raveSpeedDebouncer =
        Timer(const Duration(milliseconds: CHAR_WRITE_RATE_MS), () {
      ble.writeCharacteristicWithoutResponse(
        _raveSpeedCharacteristic,
        value: intToBytes(1120 - speed.toInt()),
      );
    });
  }

  void dispose() {
    _connection?.cancel();
    _brightnessDebouncer?.cancel();
    _hueDebouncer?.cancel();
    _rainbowSpeedDebouncer?.cancel();
    _raveSpeedDebouncer?.cancel();
  }
}
