// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Widget buildWarningCard(Map<String, int> warningCounts) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: warningCounts.entries.map((entry) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: SizedBox(
              height: 100,
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    size: 40,
                    color: getColorFromWarning(entry.key),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    Map<String, int> warningCounts = { // testing purposes delete later
      'Red': 5,
      'Blue': 1,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts',
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () { Scaffold.of(context).openDrawer(); },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/logo.png',
            ),
          ),
        ],
        backgroundColor: const Color(0xFFE9E9E9),
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
                buildWarningCard(warningCounts),
                // _buildFilters(),
                // ExpansionPanelList(
                //   expansionCallback: (int index, bool isExpanded) {
                //     setState(() {
                //       _isFilterExpanded = !_isFilterExpanded;
                //     });
                //   },
                //   children: [
                //     ExpansionPanel(
                //       headerBuilder: (BuildContext context, bool isExpanded) {
                //         return const ListTile(
                //           title: Text('Filters'),
                //         );
                //       },
                //       body: Column(
                //         children: <Widget>[
                //           _buildDropdown('Color', colorItems.toList(), _selectedColor, (value) {
                //             setState(() {
                //               _selectedColor = value;
                //               _loadTokenAndFetchWarnings();
                //             });
                //           }),
                //           _buildDropdown('Type', typeItems.toList(), _selectedType, (value) {
                //             setState(() {
                //               _selectedType = value;
                //               _loadTokenAndFetchWarnings();
                //             });
                //           }),
                //           _buildDropdown('Severity', severityItems.toList(), _selectedSeverity, (value) {
                //             setState(() {
                //               _selectedSeverity = value;
                //               _loadTokenAndFetchWarnings();
                //             });
                //           }),
                //         ],
                //       ),
                //       isExpanded: _isFilterExpanded,
                //     ),
                //   ],
                // ),
                Expanded(
                  child: ListView.builder(
                    itemCount: warnings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: warnings[index].selected,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        warnings[index].selected = value;
                                      });
                                    },
                                  )
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          warnings[index].definitionType,
                                          style: TextStyle(
                                            color: getColorFromWarning(warnings[index].color),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(warnings[index].definitionDescription),
                                        Text('Date: ${DateFormat('dd/MM/yyyy hh:mm').format(warnings[index].time)}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: warnings[index].isExpanded,
                              child: ListTile(
                                title: Text(
                                  'Duration Type: ${warnings[index].durationType}, Duration Value: ${warnings[index].durationValue}, Engine Hours Value: ${warnings[index].engineHoursValue}, Latitude: ${warnings[index].lat}, Longitude: ${warnings[index].lon}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(warnings[index].isExpanded ? 'Hide Details' : 'Show Details'),
                              onPressed: () {
                                setState(() {
                                  warnings[index].isExpanded = !warnings[index].isExpanded;
                                });
                              },
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
        return const Color(0xFFF2392D);
      case 'YELLOW':
        return const Color(0xFFFECC1C);
      case 'BLUE':
        return const Color(0xFF3E74FE);
      default:
        return Colors.black;
    }
  }
}