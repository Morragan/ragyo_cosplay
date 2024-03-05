import "dart:async";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:ragyo_cosplay/bluetooth/bluetooth.dart";
import "package:ragyo_cosplay/providers/bluetooth.dart";
import "package:ragyo_cosplay/widgets/drawer_item.dart";

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({super.key, required this.bluetooth});

  final Bluetooth bluetooth;

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  Timer? _timer;
  double _lastHue = 0;
  Color _iconColor = const Color.fromARGB(255, 131, 70, 143); // primary
  Random random = Random();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      double hue = random.nextDouble() * 360;
      while ((hue - _lastHue).abs() < 60) {
        hue = random.nextDouble() * 360;
      }
      _lastHue = hue;
      setState(() {
        _iconColor = HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(bluetoothNotifierProvider).mode;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Icon(
                  Icons.light_mode,
                  size: 48,
                  color: _iconColor,
                ),
                const SizedBox(width: 16),
                Text(
                  "Select mode",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          DrawerItem(
            onTap: () {
              widget.bluetooth.mode = Mode.rainbow;
              Navigator.of(context).pop();
            },
            icon: Icons.looks,
            title: "Rainbow",
            selected: mode == Mode.rainbow,
          ),
          DrawerItem(
            onTap: () {
              widget.bluetooth.mode = Mode.rave;
              Navigator.of(context).pop();
            },
            icon: Icons.celebration,
            title: "Rave",
            selected: mode == Mode.rave,
          ),
          DrawerItem(
            onTap: () {
              widget.bluetooth.mode = Mode.static;
              Navigator.of(context).pop();
            },
            icon: Icons.tune,
            title: "Static",
            selected: mode == Mode.static,
          ),
          const Spacer(),
          ListTile(
            onTap: () {
              widget.bluetooth.disconnect();
              Navigator.of(context).pop();
            },
            leading: const Icon(Icons.power_settings_new),
            title: Text(
              "Disconnect",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
