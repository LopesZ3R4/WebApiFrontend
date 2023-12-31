// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/warningservice.dart';
import '../services/forwardingservice.dart';
import '../model/warning.dart';
import '../utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _selectedType;
String? _selectedColor;
String? _selectedSeverity;
String? _selectedMachine;
DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
DateTime _endDate = DateTime.now();

Widget _buildDropdown(String label, List<String> items, String? selectedValue,
    Function(String?) onChanged) {
  items.insert(0, 'None');
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

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MobileHomeScreen> {
  final _warningService = WarningService();
  final _forwardingService = ForwardingService();
  Future<Map<String, dynamic>> _warningsFuture = Future.value({});
  Set<String> colorItems = {};
  Set<String> typeItems = {};
  Set<String> severityItems = {};
  Set<String> machineTypeItems = {};
  void populateFilters() {
    _warningsFuture.then((data) {
      List<Warning> warnings = data['warnings'];
      colorItems = warnings.map((warning) => warning.color).toSet();
      typeItems = warnings.map((warning) => warning.type).toSet();
      severityItems = warnings.map((warning) => warning.severity).toSet();
      machineTypeItems = warnings.map((warning) => warning.machineType).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWarnings();
  }

  Widget buildWarningCard(Map<String, int> warningCounts) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: warningCounts.entries.map((entry) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = entry.key;
                fetchWarnings();
              });
            },
            child: Card(
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
        buildFilterChip('Color', _selectedColor, () {
          setState(() {
            _selectedColor = null;
          });
        }, fetchWarnings),
        buildFilterChip('Type', _selectedType, () {
          setState(() {
            _selectedType = null;
          });
        }, fetchWarnings),
        buildFilterChip('Severity', _selectedSeverity, () {
          setState(() {
            _selectedSeverity = null;
          });
        }, fetchWarnings),
        buildFilterChip('Machine', _selectedMachine, () {
          setState(() {
            _selectedMachine = null;
          });
        }, fetchWarnings),
      ],
    );
  }

  Future<void> fetchWarnings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    _warningsFuture = _warningService.getWarnings(
      token,
      type: _selectedType,
      color: _selectedColor,
      severity: _selectedSeverity,
      startDate: _startDate,
      endDate: _endDate,
      machineType: _selectedMachine,
    );
    _warningsFuture.then((data) {
      List<Warning> warnings = data['warnings'];
      colorItems = warnings.map((warning) => warning.color).toSet();
      typeItems = warnings.map((warning) => warning.type).toSet();
      severityItems = warnings.map((warning) => warning.severity).toSet();
      machineTypeItems = warnings.map((warning) => warning.machineType).toSet();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts - Mobile',
          style: TextStyle(color: Colors.black),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
              ),
              onPressed: () {
                populateFilters();
                Scaffold.of(context).openDrawer();
              },
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
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _warningsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
                child: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Drawer(
                child: Center(child: Text('Error: ${snapshot.error}')));
          } else {
            return Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text('Filters'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: _buildDropdown(
                        'Color', colorItems.toList(), _selectedColor, (value) {
                      setState(() {
                        _selectedColor = value == 'None' ? null : value;
                        fetchWarnings();
                      });
                    }),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.sort_by_alpha),
                    title: _buildDropdown(
                        'Type', typeItems.toList(), _selectedType, (value) {
                      setState(() {
                        _selectedType = value == 'None' ? null : value;
                        fetchWarnings();
                      });
                    }),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.warning),
                    title: _buildDropdown(
                        'Severity', severityItems.toList(), _selectedSeverity,
                        (value) {
                      setState(() {
                        _selectedSeverity = value == 'None' ? null : value;
                        fetchWarnings();
                      });
                    }),
                  ),
                ],
              ),
            );
          }
        },
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
            colorItems = warnings.map((warning) => warning.color).toSet();
            typeItems = warnings.map((warning) => warning.type).toSet();
            severityItems = warnings.map((warning) => warning.severity).toSet();
            machineTypeItems =
                warnings.map((warning) => warning.machineType).toSet();
            Map<String, int> warningCounts = countWarningsByColor(warnings);
            Map<String, int> warningCountsbyType =
                countWarningsByMachineType(warnings);
            populateFilters();
            return Column(
              children: [
                _buildFilters(),
                buildWarningCard(warningCounts),
                buildMachineTypeFilter(machineTypeItems, warningCountsbyType,
                    (machineType) {
                  setState(() {
                    _selectedMachine = machineType;
                    fetchWarnings();
                  });
                }),
                Expanded(
                  child: ListView.builder(
                    itemCount: warnings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: warnings[index].sent
                              ? const BorderSide(color: Colors.green, width: 2)
                              : BorderSide.none,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
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
                                        warnings[index].selected = value!;
                                      });
                                    },
                                  )
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          warnings[index].definitionType,
                                          style: TextStyle(
                                            color: getColorFromWarning(
                                                warnings[index].color),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(warnings[index]
                                            .definitionDescription),
                                        Text(
                                            'Date: ${DateFormat('dd/MM/yyyy hh:mm').format(warnings[index].time)}'),
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
                                  'Duration Type: ${warnings[index].durationType}, Duration Value: ${warnings[index].durationValue}, Engine Hours Value: ${warnings[index].engineHoursValue}, Latitude: ${warnings[index].lat}, Longitude: ${warnings[index].lon}, Cliente: ${warnings[index].clientName}, Maquina: ${warnings[index].machineType}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text(warnings[index].isExpanded
                                  ? 'Hide Details'
                                  : 'Show Details'),
                              onPressed: () {
                                setState(() {
                                  warnings[index].isExpanded =
                                      !warnings[index].isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String token = prefs.getString('token') ?? '';
                    _forwardingService.sendWarnings(token, warnings);
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
