import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:ragyo_cosplay/screens/home.dart";
import "package:ragyo_cosplay/widgets/permission_button.dart";

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

// TODO: add an event channel to check if bluetooth/location is enabled?
class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool _bluetoothPermissionGranted = false;
  bool _locationPermissionGranted = false;
  bool _checkingPermissions = true;

  void _checkPermissions() async {
    setState(() {
      _checkingPermissions = true;
    });
    final bluetoothStatus = await Permission.bluetoothConnect.status;
    final locationStatus = await Permission.locationWhenInUse.status;

    if (bluetoothStatus == PermissionStatus.granted &&
        locationStatus == PermissionStatus.granted &&
        context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const HomeScreen()));
    }

    setState(() {
      _bluetoothPermissionGranted = bluetoothStatus == PermissionStatus.granted;
      _locationPermissionGranted = locationStatus == PermissionStatus.granted;
      _checkingPermissions = false;
    });
  }

  void _requestBluetooth() async {
    setState(() {
      _checkingPermissions = true;
    });
    final bluetoothStatus = await Permission.bluetoothConnect.request();

    setState(() {
      _bluetoothPermissionGranted = bluetoothStatus == PermissionStatus.granted;
      _checkingPermissions = false;
    });

    if (bluetoothStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  void _requestLocation() async {
    setState(() {
      _checkingPermissions = true;
    });
    final locationStatus = await Permission.locationWhenInUse.request();

    setState(() {
      _locationPermissionGranted = locationStatus == PermissionStatus.granted;
      _checkingPermissions = false;
    });

    if (locationStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _checkingPermissions
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "This app needs access to bluetooth and location",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  PermissionButton(
                    text: "Grant Bluetooth permission",
                    completed: _bluetoothPermissionGranted,
                    onPressed:
                        !_bluetoothPermissionGranted ? _requestBluetooth : null,
                  ),
                  const SizedBox(height: 4),
                  PermissionButton(
                    text: "Grant Location permission",
                    completed: _locationPermissionGranted,
                    onPressed:
                        !_locationPermissionGranted ? _requestLocation : null,
                  ),
                ],
              ),
      ),
    );
  }
}
