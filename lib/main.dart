import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(BiometricApp());

class BiometricApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => BiometricScreen(),
        '/battery': (context) => BatteryScreen(),
        '/unauthenticated': (context) => UnauthenticatedScreen(),
      },
    );
  }
}

// Biometric Authentication Screen
class BiometricScreen extends StatelessWidget {
  static const platform = MethodChannel('com.example/biometric');

  Future<void> authenticate(BuildContext context) async {
    try {
      final bool result = await platform.invokeMethod('authenticate');
      if (result) {
        // Navigate to Battery Screen on successful authentication
        Navigator.pushReplacementNamed(context, '/battery');
      } else {
        // Navigate to Unauthenticated Screen on failure
        Navigator.pushReplacementNamed(context, '/unauthenticated');
      }
    } on PlatformException catch (e) {
      print('Authentication failed: ${e.message}');
      Navigator.pushReplacementNamed(context, '/unauthenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Biometric Authentication')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => authenticate(context),
          child: Text('Authenticate'),
        ),
      ),
    );
  }
}

// Battery Screen
class BatteryScreen extends StatefulWidget {
  @override
  _BatteryScreenState createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  static const platform = MethodChannel('com.example.flutter_platform_channels/battery');
  String _batteryLevel = "Unknown";

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Battery Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _batteryLevel,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: Text('Get Battery Level'),
            ),
          ],
        ),
      ),
    );
  }
}

// Unauthenticated Screen
class UnauthenticatedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unauthenticated')),
      body: Center(
        child: Text(
          'Authentication Failed',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}
