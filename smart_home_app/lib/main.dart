import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink[300],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.pink,
        ),
      ),
      home: DeviceListScreen(),
    );
  }
}

class Device {
  int id;
  String name;
  String type;
  bool status;

  Device(
      {required this.id,
      required this.name,
      required this.type,
      required this.status});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: int.parse(json['id']),
      name: json['name'],
      type: json['type'],
      status: json['status'] == "1",
    );
  }
}

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final String apiUrl = "http://localhost/smart_home/";
  List<Device> devices = [];

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    final response = await http.get(Uri.parse("${apiUrl}get_devices.php"));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        devices =
            jsonResponse.map((device) => Device.fromJson(device)).toList();
      });
    }
  }

  Future<void> toggleStatus(Device device) async {
    await http.post(Uri.parse("${apiUrl}update_device.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
            {"id": device.id.toString(), "status": device.status ? "0" : "1"}));
    fetchDevices();
  }

  Future<void> deleteDevice(int id) async {
    await http.post(Uri.parse("${apiUrl}delete_device.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id.toString()}));
    fetchDevices();
  }

  // 📌 ฟังก์ชันเปิด Dialog สำหรับแก้ไขอุปกรณ์
  void editDevice(Device device) {
    TextEditingController nameController =
        TextEditingController(text: device.name);
    TextEditingController typeController =
        TextEditingController(text: device.type);
    bool status = device.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('แก้ไขอุปกรณ์', style: TextStyle(color: Colors.pink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'ชื่ออุปกรณ์', prefixIcon: Icon(Icons.devices)),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                    labelText: 'ประเภท', prefixIcon: Icon(Icons.category)),
              ),
              SwitchListTile(
                title: Text('สถานะ'),
                value: status,
                activeColor: Colors.pink,
                onChanged: (value) {
                  setState(() {
                    status = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.pink)),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    typeController.text.isNotEmpty) {
                  await http.post(Uri.parse("${apiUrl}update_device.php"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "id": device.id.toString(),
                        "name": nameController.text,
                        "type": typeController.text,
                        "status": status ? "1" : "0"
                      }));
                  fetchDevices();
                  Navigator.pop(context);
                }
              },
              child: Text('บันทึก', style: TextStyle(color: Colors.pink)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Home Devices')),
      body: devices.isEmpty
          ? Center(
              child: Text("ไม่มีอุปกรณ์ที่เชื่อมต่อ",
                  style: TextStyle(fontSize: 18, color: Colors.pink[900])))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Icon(
                      device.type == "Light"
                          ? Icons.lightbulb
                          : device.type == "Fan"
                              ? Icons.ac_unit
                              : Icons.devices_other,
                      color: device.status ? Colors.pink[700] : Colors.grey,
                      size: 30,
                    ),
                    title: Text(
                      device.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      device.type,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    trailing: Switch(
                      value: device.status,
                      onChanged: (value) => toggleStatus(device),
                      activeColor: Colors.pink,
                    ),
                    onTap: () => editDevice(device), // 📌 กดเพื่อแก้ไข
                    onLongPress: () => deleteDevice(device.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddDeviceDialog(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void showAddDeviceDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    bool status = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('เพิ่มอุปกรณ์ใหม่', style: TextStyle(color: Colors.pink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'ชื่ออุปกรณ์', prefixIcon: Icon(Icons.devices)),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(
                    labelText: 'ประเภท', prefixIcon: Icon(Icons.category)),
              ),
              SwitchListTile(
                title: Text('สถานะ'),
                value: status,
                activeColor: Colors.pink,
                onChanged: (value) {
                  status = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: TextStyle(color: Colors.pink)),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    typeController.text.isNotEmpty) {
                  try {
                    final response = await http.post(
                      Uri.parse("${apiUrl}create_device.php"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "name": nameController.text,
                        "type": typeController.text,
                        "status": status ? "1" : "0"
                      }),
                    );

                    if (response.statusCode == 200) {
                      print("✅ เพิ่มอุปกรณ์สำเร็จ!");
                      fetchDevices(); // โหลดข้อมูลใหม่หลังเพิ่ม
                      Navigator.pop(context);
                    } else {
                      print("❌ เพิ่มอุปกรณ์ล้มเหลว: ${response.body}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ เพิ่มอุปกรณ์ล้มเหลว!")),
                      );
                    }
                  } catch (e) {
                    print("❌ Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ เกิดข้อผิดพลาด!")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ กรุณากรอกข้อมูลให้ครบถ้วน!")),
                  );
                }
              },
              child: Text('เพิ่ม', style: TextStyle(color: Colors.pink)),
            )
          ],
        );
      },
    );
  }
}
