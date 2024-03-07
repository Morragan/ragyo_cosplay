import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ragyo_cosplay/bluetooth/bluetooth.dart';
import 'package:ragyo_cosplay/providers/bluetooth.dart';
import 'package:ragyo_cosplay/screens/main_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? debouncer;
  late Bluetooth bluetooth;

  @override
  void initState() {
    super.initState();
    bluetooth = Bluetooth(ref: ref);
  }

  @override
  void dispose() {
    bluetooth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = ref.watch(bluetoothNotifierProvider);

    Widget content = Center(
      child: OutlinedButton.icon(
        onPressed:
            !bluetoothState.connecting ? bluetooth.startConnection : null,
        icon: bluetoothState.connecting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : const Icon(Icons.bluetooth),
        label: Text(
          "Connect",
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
              ),
        ),
      ),
    );

    if (bluetoothState.connected) {
      content = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Brightness",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${(bluetoothState.brightness / 255 * 100).toInt()}%",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )
                ],
              ),
            ),
            Slider(
              label: bluetoothState.brightness.toInt().toString(),
              value: bluetoothState.brightness,
              onChanged: (brightness) => bluetooth.brightness = brightness,
              divisions: 100,
              min: 0,
              max: 255,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Hue",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    bluetoothState.hue.toInt().toString(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )
                ],
              ),
            ),
            Slider(
              label: bluetoothState.hue.toInt().toString(),
              value: bluetoothState.hue,
              onChanged: (hue) => bluetooth.hue = hue,
              divisions: 100,
              min: 0,
              max: 255,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Rainbow speed",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${((bluetoothState.rainbowSpeed) / 500 * 100).toInt()}%",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )
                ],
              ),
            ),
            Slider(
              label: bluetoothState.rainbowSpeed.toInt().toString(),
              value: bluetoothState.rainbowSpeed,
              onChanged: (speed) => bluetooth.rainbowSpeed = speed,
              divisions: 100,
              min: 10,
              max: 500,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    "Rave speed",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${((bluetoothState.raveSpeed) / 1000 * 100).toInt()}%",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  )
                ],
              ),
            ),
            Slider(
              label: bluetoothState.raveSpeed.toInt().toString(),
              value: bluetoothState.raveSpeed,
              onChanged: (speed) => bluetooth.raveSpeed = speed,
              divisions: 100,
              min: 120,
              max: 1000,
            ),
          ],
        ),
      );
    }

    final modeName =
        "${bluetoothState.mode.name[0].toUpperCase()}${bluetoothState.mode.name.substring(1)} Mode";
    return Scaffold(
      appBar: AppBar(
        title: Text(
          bluetoothState.connected
              ? "Ragyo Kiryuin - $modeName"
              : "Ragyo Kiryuin",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      drawer:
          bluetoothState.connected ? MainDrawer(bluetooth: bluetooth) : null,
      body: content,
    );
  }
}
