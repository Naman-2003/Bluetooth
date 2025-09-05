import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  List<BluetoothService> services = [];
  bool isScanning = false;

  Future<void> startScan() async {
    setState(() {
      devicesList.clear();
      isScanning = true;
    });

    // Start scanning for 5 seconds
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Listen to results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devicesList.contains(r.device)) {
          setState(() => devicesList.add(r.device));
        }
      }
    });

    // When timeout finishes → scanning stops automatically
    FlutterBluePlus.isScanning.listen((scanning) {
      setState(() => isScanning = scanning);
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() => isScanning = false);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: false);
      setState(() => connectedDevice = device);

      services = await device.discoverServices();
      setState(() {});
    } catch (e) {
      debugPrint("Error connecting: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  Future<void> disconnectFromDevice() async {
    await connectedDevice?.disconnect();
    setState(() {
      connectedDevice = null;
      services.clear();
    });
  }

  Widget buildServiceTile(BluetoothService service) {
    return ExpansionTile(
      title: Text("Service: ${service.uuid}"),
      children: service.characteristics.map((c) {
        return ListTile(
          title: Text("Char: ${c.uuid}"),
          subtitle: Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  var value = await c.read();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Read: $value")),
                  );
                },
                child: const Text("Read"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await c.write([0x12, 0x34]);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data Written")),
                  );
                },
                child: const Text("Write"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await c.setNotifyValue(true);
                  c.onValueReceived.listen((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Notification: $value")),
                    );
                  });
                },
                child: const Text("Notify"),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Demo"),
        actions: [
          if (connectedDevice != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: disconnectFromDevice,
            ),
        ],
      ),
      body: connectedDevice == null
          ? Column(
        children: [
          const SizedBox(height: 10),
          isScanning
              ? ElevatedButton(
            onPressed: stopScan,
            child: const Text("Stop Scanning"),
          )
              : ElevatedButton(
            onPressed: startScan,
            child: const Text("Scan for Devices"),
          ),
          if (isScanning) const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                final device = devicesList[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty
                      ? device.name
                      : "Unknown Device"),
                  subtitle: Text(device.id.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectToDevice(device),
                    child: const Text("Connect"),
                  ),
                );
              },
            ),
          ),
        ],
      )
          : ListView(
        children: services.map((s) => buildServiceTile(s)).toList(),
      ),
    );
  }
}
