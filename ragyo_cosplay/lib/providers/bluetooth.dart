import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bluetooth.g.dart';

enum Mode { rainbow, rave, static }

class BluetoothState {
  BluetoothState({
    required this.connected,
    required this.connecting,
    required this.mode,
    required this.hue,
    required this.speed,
    required this.brightness,
  });

  BluetoothState copyWith({
    bool? connected,
    bool? connecting,
    Mode? mode,
    double? hue,
    double? speed,
    double? brightness,
  }) {
    return BluetoothState(
        connected: connected ?? this.connected,
        connecting: connecting ?? this.connecting,
        mode: mode ?? this.mode,
        hue: hue ?? this.hue,
        speed: speed ?? this.speed,
        brightness: brightness ?? this.brightness);
  }

  final bool connected;
  final bool connecting;
  final Mode mode;
  final double hue;
  final double speed;
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
      speed: 50,
      brightness: 64,
    );
  }

  set connecting(bool connecting) {
    state = state.copyWith(connecting: connecting);
  }

  set connected(bool connected) {
    state = state.copyWith(connected: connected);
  }

  set mode(Mode mode) {
    state = state.copyWith(mode: mode);
  }

  set hue(double hue) => state = state.copyWith(hue: hue);
}
