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
      content = Column(
        children: [
          Slider(
            value: bluetoothState.hue,
            onChanged: (hue) => bluetooth.hue = hue,
            min: 0,
            max: 255,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ragyo Kiryuin",
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
