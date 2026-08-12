import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OTScheduleListScreen extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const OTScheduleListScreen({Key? key, required this.scheduleData})
      : super(key: key);

  @override
  _OTScheduleListScreenState createState() => _OTScheduleListScreenState();
}

class _OTScheduleListScreenState extends State<OTScheduleListScreen> {
  late List<MapEntry<String, dynamic>> sortedOTEntries;

  // Controllers for editable fields
  late List<TextEditingController> otNumberControllers;
  late List<TextEditingController> surgeonControllers;
  late List<TextEditingController> surgeryControllers;
  late List<TextEditingController> startTimeControllers;
  late List<TextEditingController> endTimeControllers;
  late List<TextEditingController> dateControllers;
  late List<TextEditingController> patientNameControllers;
  late List<TextEditingController> specialEquipmentControllers;
  late List<TextEditingController> departmentControllers;
  late List<TextEditingController> ageSexControllers;
  late List<TextEditingController> technicalLeadsControllers;
  late List<TextEditingController> nursingLeadsControllers;

  @override
  void initState() {
    super.initState();

    // Initialize sortedOTEntries when the widget initializes
    sortedOTEntries = widget.scheduleData['OT'].entries.toList();
    sortedOTEntries.sort((a, b) => a.value.compareTo(b.value));

    // Initialize controllers for each field
    otNumberControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: sortedOTEntries[index].value.toString())
    );
    surgeonControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Surgeon'][sortedOTEntries[index].key])
    );
    surgeryControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['surgery'][sortedOTEntries[index].key])
    );
    startTimeControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Start_time'][sortedOTEntries[index].key])
    );
    endTimeControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['End_time'][sortedOTEntries[index].key])
    );
    dateControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Date of Surgery'][sortedOTEntries[index].key])
    );
    patientNameControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Name of the Patient'][sortedOTEntries[index].key])
    );
    specialEquipmentControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Special Equipment'][sortedOTEntries[index].key])
    );
    departmentControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Department'][sortedOTEntries[index].key])
    );
    ageSexControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Age/Sex'][sortedOTEntries[index].key])
    );
    technicalLeadsControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Technicial T/L'][sortedOTEntries[index].key])
    );
    nursingLeadsControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Nursing T/L'][sortedOTEntries[index].key])
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    otNumberControllers.forEach((controller) => controller.dispose());
    surgeonControllers.forEach((controller) => controller.dispose());
    surgeryControllers.forEach((controller) => controller.dispose());
    startTimeControllers.forEach((controller) => controller.dispose());
    endTimeControllers.forEach((controller) => controller.dispose());
    dateControllers.forEach((controller) => controller.dispose());
    patientNameControllers.forEach((controller) => controller.dispose());
    specialEquipmentControllers.forEach((controller) => controller.dispose());
    departmentControllers.forEach((controller) => controller.dispose());
    ageSexControllers.forEach((controller) => controller.dispose());
    technicalLeadsControllers.forEach((controller) => controller.dispose());
    nursingLeadsControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveChanges() {
    // Update scheduleData with new values from controllers
    for (int i = 0; i < sortedOTEntries.length; i++) {
      final newOTNumber = int.tryParse(otNumberControllers[i].text) ?? sortedOTEntries[i].value;
      widget.scheduleData['OT'].remove(sortedOTEntries[i].key); // Remove old key
      widget.scheduleData['OT']['OT $newOTNumber'] = sortedOTEntries[i].key; // Add new key
      sortedOTEntries[i] = MapEntry(sortedOTEntries[i].key, newOTNumber); // Update sortedOTEntries

      widget.scheduleData['Surgeon'][sortedOTEntries[i].key] = surgeonControllers[i].text;
      widget.scheduleData['surgery'][sortedOTEntries[i].key] = surgeryControllers[i].text;
      widget.scheduleData['Start_time'][sortedOTEntries[i].key] = startTimeControllers[i].text;
      widget.scheduleData['End_time'][sortedOTEntries[i].key] = endTimeControllers[i].text;
      widget.scheduleData['Date of Surgery'][sortedOTEntries[i].key] = dateControllers[i].text;
      widget.scheduleData['Name of the Patient'][sortedOTEntries[i].key] = patientNameControllers[i].text;
      widget.scheduleData['Special Equipment'][sortedOTEntries[i].key] = specialEquipmentControllers[i].text;
      widget.scheduleData['Department'][sortedOTEntries[i].key] = departmentControllers[i].text;
      widget.scheduleData['Age/Sex'][sortedOTEntries[i].key] = ageSexControllers[i].text;
      widget.scheduleData['Technicial T/L'][sortedOTEntries[i].key] = technicalLeadsControllers[i].text;
      widget.scheduleData['Nursing T/L'][sortedOTEntries[i].key] = nursingLeadsControllers[i].text;
    }

    // Save to backend or local storage here if needed
    // Example:
    // _saveToLocalStorage();
    // _saveToBackend();
  }

  Future<void> _exportDataToCsv() async {
    try {
      List<List<dynamic>> rows = [];
      // Add header row
      List<String> headers = [
        'Date',
        'OT Number',
        'Surgeon',
        'Department',
        'Surgery',
        'Start Time',
        'End Time',
        'Special Equipment',
        'Name of Patient',
        'Age/Sex',
        'Nursing T/l',
        'Technician T/L'
      ];
      rows.add(headers);

      // Add data rows
      sortedOTEntries.forEach((entry) {
        final otNumber = entry.value.toString();
        final String surgeon = surgeonControllers[sortedOTEntries.indexOf(entry)].text;
        final String surgery = surgeryControllers[sortedOTEntries.indexOf(entry)].text;
        final String startTime = startTimeControllers[sortedOTEntries.indexOf(entry)].text;
        final String endTime = endTimeControllers[sortedOTEntries.indexOf(entry)].text;
        final String date = dateControllers[sortedOTEntries.indexOf(entry)].text;
        final String patientName = patientNameControllers[sortedOTEntries.indexOf(entry)].text;
        final String specialEquipment = specialEquipmentControllers[sortedOTEntries.indexOf(entry)].text;
        final String department = departmentControllers[sortedOTEntries.indexOf(entry)].text;
        final String ageSex = ageSexControllers[sortedOTEntries.indexOf(entry)].text;
        final String nusringTL = nursingLeadsControllers[sortedOTEntries.indexOf(entry)].text;
        final String technicianTL = technicalLeadsControllers[sortedOTEntries.indexOf(entry)].text;

        rows.add([
          date,
          'OT $otNumber',
          surgeon,
          department,
          surgery,
          startTime,
          endTime,
          specialEquipment,
          patientName,
          ageSex,
          nusringTL,
          technicianTL,
        ]);
      });

      // Generate CSV string
      String csvString = const ListToCsvConverter().convert(rows);

      if (kIsWeb) {
        // Generate download link for web
        final anchor = html.AnchorElement(
            href:
            'data:text/csv;charset=utf-8,${Uri.encodeComponent(csvString)}')
          ..setAttribute('download', 'ot_schedule.csv')
          ..click();
      } else {
        // Get the directory for saving the CSV file
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String filePath = '${directory.path}/ot_schedule.csv';

          // Write CSV string to file
          File file = File(filePath);
          await file.writeAsString(csvString);

          print('CSV file exported to: $filePath');
        } else {
          print('Error: Directory not found');
        }
      }
    } catch (e) {
      print('Error exporting data to CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define table columns
    final columns = [
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Date', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('OT Number', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Surgeon', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.greenAccent,
          child: Text('Department', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.orangeAccent,
          child: Text('Surgery', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.purpleAccent,
          child: Text('Start Time', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.redAccent,
          child: Text('End Time', style: TextStyle(color: Colors.white)),
        ),
      ),

      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Name of Patient', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Age/Sex', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child:
          Text('Special Equipment', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Technical T/L', style: TextStyle(color: Colors.white)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.blueAccent,
          child: Text('Nursing T/L', style: TextStyle(color: Colors.white)),
        ),
      ),
    ];

    // Define table rows
    final rows = sortedOTEntries.map<DataRow>((entry) {
      final index = sortedOTEntries.indexOf(entry);
      return DataRow(
        color: MaterialStateColor.resolveWith((states) {
          // Alternate row color
          return index % 2 == 0 ? Colors.grey[200]! : Colors.white;
        }),
        cells: [
          DataCell(TextField(
            controller: dateControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Date of Surgery'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: otNumberControllers[index],
            onChanged: (value) {
              // Update OT number and scheduleData on change
              setState(() {
                sortedOTEntries[index] = MapEntry(entry.key, int.tryParse(value) ?? entry.value);
              });
            },
          )),
          DataCell(TextField(
            controller: surgeonControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Surgeon'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: departmentControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Department'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: surgeryControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['surgery'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: startTimeControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Start_time'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: endTimeControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['End_time'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: patientNameControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Name of the Patient'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: ageSexControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Age/Sex'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: specialEquipmentControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Special Equipment'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: technicalLeadsControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Technicial T/L'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: nursingLeadsControllers[index],
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Nursing T/L'][entry.key] = value;
            },
          )),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'List of OT\'s Scheduled',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: columns,
                  rows: rows,
                  dividerThickness: 2.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportDataToCsv,
        tooltip: 'Export CSV',
        child: Icon(Icons.file_download),
      ),
    );
  }
}
