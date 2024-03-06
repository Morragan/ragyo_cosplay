import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bluetooth.g.dart';

enum Mode { rainbow, rave, static }

class BluetoothState {
  BluetoothState({
    required this.connected,
    required this.connecting,
    required this.mode,
    required this.hue,
    required this.rainbowSpeed,
    required this.raveSpeed,
    required this.brightness,
  });

  BluetoothState copyWith({
    bool? connected,
    bool? connecting,
    Mode? mode,
    double? hue,
    double? rainbowSpeed,
    double? raveSpeed,
    double? brightness,
  }) {
    return BluetoothState(
        connected: connected ?? this.connected,
        connecting: connecting ?? this.connecting,
        mode: mode ?? this.mode,
        hue: hue ?? this.hue,
        rainbowSpeed: rainbowSpeed ?? this.rainbowSpeed,
        raveSpeed: raveSpeed ?? this.raveSpeed,
        brightness: brightness ?? this.brightness);
  }

  final bool connected;
  final bool connecting;
  final Mode mode;
  final double hue;
  final double rainbowSpeed;
  final double raveSpeed;
  final double brightness;
}

@Riverpod(keepAlive: true)
class BluetoothNotifier extends _$BluetoothNotifier {
  @override
  BluetoothState build() {
    return BluetoothState(
      connected: false,
      connecting: false,
      mode: Mode.rainbow,
      hue: 0,
      rainbowSpeed: 30,
      raveSpeed: 900,
      brightness: 64,
    );
  }

  set connecting(bool connecting) =>
      state = state.copyWith(connecting: connecting);

  set connected(bool connected) => state = state.copyWith(connected: connected);

  set mode(Mode mode) => state = state.copyWith(mode: mode);

  set brightness(double brightness) =>
      state = state.copyWith(brightness: brightness);

  set hue(double hue) => state = state.copyWith(hue: hue);

  set rainbowSpeed(double speed) => state = state.copyWith(rainbowSpeed: speed);

  set raveSpeed(double speed) => state = state.copyWith(raveSpeed: speed);
}
