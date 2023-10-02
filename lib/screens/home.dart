// lib/screens/home.dart
import 'package:flutter/material.dart';
import '../services/warningservice.dart';
import '../model/warning.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _selectedType;
String? _selectedColor;
String? _selectedSeverity;
DateTime? _selectedDate;

Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
  return DropdownButton<String>(
    hint: Row(
      children: [
        const Icon(Icons.search),
        const SizedBox(width: 10),
        Text(label),
      ],
    ),
    value: selectedValue,
    isExpanded: true,
    onChanged: onChanged,
    items: items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Row(
          children: [
            Text(value),
          ],
        ),
      );
    }).toList(),
  );
}
Widget _buildFilterChip(String label, String? value, Function() onRemove) {
  return value != null
      ? Chip(
          label: Text('$label: $value'),
          deleteIcon: const Icon(Icons.close),
          onDeleted: onRemove,
        )
      : Container();
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _warningService = WarningService();
  Future<Map<String, dynamic>> _warningsFuture = Future.value({});
  bool _isFilterExpanded = false;
  

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchWarnings();
  }
  Widget _buildFilters() {
  return Wrap(
    spacing: 8.0,
    runSpacing: 4.0,
    children: <Widget>[
      _buildFilterChip('Color', _selectedColor, () {
        setState(() {
          _selectedColor = null;
          _loadTokenAndFetchWarnings();
        });
      }),
      _buildFilterChip('Type', _selectedType, () {
        setState(() {
          _selectedType = null;
          _loadTokenAndFetchWarnings();
        });
      }),
      _buildFilterChip('Severity', _selectedSeverity, () {
        setState(() {
          _selectedSeverity = null;
          _loadTokenAndFetchWarnings();
        });
      }),
      _buildFilterChip('Date', _selectedDate?.toIso8601String(), () {
        setState(() {
          _selectedDate = null;
          _loadTokenAndFetchWarnings();
        });
      }),
    ],
  );
}
  Future<void> _loadTokenAndFetchWarnings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    _warningsFuture = _warningService.getWarnings(token,
      type: _selectedType,
      color: _selectedColor,
      severity: _selectedSeverity,
      date: _selectedDate,);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.blueGrey,
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
            Set<String> colorItems = warnings.map((warning) => warning.color).toSet();
            Set<String> typeItems = warnings.map((warning) => warning.type).toSet();
            Set<String> severityItems = warnings.map((warning) => warning.severity).toSet();
            return Column(
              children: [
                Card(
                  elevation: 5,
                  child: ListTile(
                    title: Text('Total Warnings: ${warnings.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                _buildFilters(),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          title: Text('Filters'),
                        );
                      },
                      body: Column(
                        children: <Widget>[
                          _buildDropdown('Color', colorItems.toList(), _selectedColor, (value) {
                            setState(() {
                              _selectedColor = value;
                              _loadTokenAndFetchWarnings();
                            });
                          }),
                          _buildDropdown('Type', typeItems.toList(), _selectedType, (value) {
                            setState(() {
                              _selectedType = value;
                              _loadTokenAndFetchWarnings();
                            });
                          }),
                          _buildDropdown('Severity', severityItems.toList(), _selectedSeverity, (value) {
                            setState(() {
                              _selectedSeverity = value;
                              _loadTokenAndFetchWarnings();
                            });
                          }),
                        ],
                      ),
                      isExpanded: _isFilterExpanded,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: warnings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        child: ExpansionPanelList(
                          expansionCallback: (int item, bool status) {
                            setState(() {
                              warnings[index].isExpanded = !warnings[index].isExpanded;
                            });
                          },
                          children: [
                            ExpansionPanel(
                              headerBuilder: (BuildContext context, bool isExpanded) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: getColorFromWarning(warnings[index].color),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'Color: ${warnings[index].color}, ID: ${warnings[index].id}, Type: ${warnings[index].type}',
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                );
                              },
                              body: ListTile(
                                title: Text(
                                  'Duration Type: ${warnings[index].durationType}, Duration Value: ${warnings[index].durationValue}, Engine Hours Value: ${warnings[index].engineHoursValue}, Latitude: ${warnings[index].lat}, Longitude: ${warnings[index].lon}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              isExpanded: warnings[index].isExpanded,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Color getColorFromWarning(String color) {
    switch (color.toUpperCase()) {
      case 'RED':
        return Colors.red;
      case 'YELLOW':
        return Colors.yellow;
      case 'BLUE':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}