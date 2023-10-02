// lib/screens/home.dart
import 'package:flutter/material.dart';
import '../services/warningservice.dart';
import '../model/warning.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _warningService = WarningService();
  Future<Map<String, dynamic>> _warningsFuture = Future.value({});

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchWarnings();
  }

  Future<void> _loadTokenAndFetchWarnings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    _warningsFuture = _warningService.getWarnings(token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _warningsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Warning> warnings = snapshot.data!['warnings'];
            return Column(
              children: [
                Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text('Total Warnings: ${warnings.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Color'),
                      ),
                      DataColumn(
                        label: Text('Type'),
                      ),
                      DataColumn(
                        label: Text('Duration Type'),
                      ),
                      DataColumn(
                        label: Text('Duration Value'), 
                      ),
                      DataColumn(
                        label: Text('Engine Hours Value'), 
                      ),
                      DataColumn(
                        label: Text('Latitude'), 
                      ),
                      DataColumn(
                        label: Text('Longitude'), 
                      ),
                      // Add more DataColumn for each field
                    ],
                    rows: warnings.map<DataRow>((Warning warning) {
                      return DataRow(
                        selected: warning.ignored,
                        onSelectChanged: (bool? value) {
                          setState(() {
                            warning.selected = value!;
                          });
                        },
                        cells: <DataCell>[
                          DataCell(Text(warning.color)),
                          DataCell(Text(warning.type)),
                          DataCell(Text(warning.durationType)),
                          DataCell(Text(warning.durationValue.toString())), 
                          DataCell(Text(warning.engineHoursValue.toString())), 
                          DataCell(Text(warning.lat.toString())), 
                          DataCell(Text(warning.lon.toString())), 
                          // Add more DataCell for each field
                        ],
                      );
                    }).toList(),
                  ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}