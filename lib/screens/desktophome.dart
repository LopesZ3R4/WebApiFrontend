// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/machineservices.dart';
import '../services/warningservice.dart';
import '../services/forwardingservice.dart';
import '../model/warning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/icon_utils.dart';
import '../utils/utils.dart';

String? _selectedType;
String? _selectedColor;
String? _selectedSeverity;
String? _selectedMachine;
DateTime? _selectedDate;

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

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DesktopHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _warningService = WarningService();
  //final _machineService = MachineService();
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

  Future<String> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    return token;
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
        buildFilterChip('Date', _selectedDate as String?, () {
          setState(() {
            _selectedDate = null;
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
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? '';
    _warningsFuture = _warningService.getWarnings(
      token,
      type: _selectedType,
      color: _selectedColor,
      severity: _selectedSeverity,
      date: _selectedDate,
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
          'Alerts - Desktop',
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
            machineTypeItems = warnings.map((warning) => warning.machineType).toSet();
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
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        sortColumnIndex: 0,
                        sortAscending: true,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text('Sent'),
                          ),
                          DataColumn(
                            label: Text('Type'),
                          ),
                          DataColumn(
                            label: Text('Occurrences'),
                          ),
                          DataColumn(
                            label: Text('Engine Hours'),
                          ),
                          DataColumn(
                            label: Text('Time'),
                          ),
                          DataColumn(
                            label: Text('Long'),
                          ),
                          DataColumn(
                            label: Text('Color'),
                          ),
                          DataColumn(
                            label: Text('Severity'),
                          ),
                          DataColumn(
                            label: Text('Definition Type'),
                          ),
                          DataColumn(
                            label: Text('Description'),
                          ),
                          DataColumn(
                            label: Text('Client'),
                          ),
                          DataColumn(
                            label: Text('MachineType'),
                          ),
                        ],
                        rows: warnings.map<DataRow>((warning) {
                          return DataRow(
                            selected: warning.selected,
                            onSelectChanged: (bool? value) {
                              setState(() {
                                warning.selected = value!;
                              });
                            },
                            cells: <DataCell>[
                              DataCell(
                                SelectableText(
                                    warning.sent ? 'Sent' : 'Not Sent'),
                              ),
                              DataCell(
                                SelectableText(warning.type),
                              ),
                              DataCell(
                                SelectableText(warning.occurrences),
                              ),
                              DataCell(
                                SelectableText(
                                    '${warning.engineHoursValue} ${warning.engineHoursUnit}'),
                              ),
                              DataCell(
                                SelectableText(DateFormat('dd/MM/yyyy hh:mm')
                                    .format(warning.time)),
                              ),
                              DataCell(
                                SelectableText(
                                    '${warning.lat}, ${warning.lon}'),
                              ),
                              DataCell(
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: getColorFromWarning(warning.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              DataCell(
                                SelectableText(warning.severity),
                              ),
                              DataCell(
                                SelectableText(warning.definitionType),
                              ),
                              DataCell(
                                SelectableText(warning.definitionDescription),
                              ),
                              DataCell(
                                SelectableText(warning.clientName),
                              ),
                              DataCell(
                                SelectableText(warning.machineType),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    var token = loadToken();
                    _forwardingService.sendWarnings(token as String, warnings);
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
