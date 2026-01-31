import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/OTSchedule/SchedulerOutput.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';

class ListConfirmation extends StatefulWidget {
  final List<int> fileBytes;
  final String fileName;
  final List<dynamic>? jsonData;

  const ListConfirmation({
    Key? key,
    required this.fileBytes,
    required this.fileName,
    this.jsonData,
  }) : super(key: key);

  @override
  _ListConfirmationState createState() => _ListConfirmationState();
}


class _ListConfirmationState extends State<ListConfirmation> {
  // Master Data
  Map<String, SurgeryMasterItem> surgeryMasterData = {};
  List<String> surgeryNameList = [];
  List<String> surgeryCodeList = [];
  List<String> specialityList = [];

  // Table Data
  List<ConfirmationRow> tableRows = [];
  List<SurgeryMasterItem> allMasterItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _loadMasterData();
      if (widget.jsonData != null) {
        await _parseJsonData();
      } else {
        await _parseInputExcel();
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMasterData() async {
    try {
      // Load asset
      ByteData data = await rootBundle.load('assets/docs/Cash_SOC_Surgery.xlsx');
      var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.isNotEmpty) {
        var sheet = excel.tables[excel.tables.keys.first];
        // Assuming Entry rows start from index 1 (0 is header)
        // We need to find column indices for 'Surgery Name', 'Code', 'Speciality'
        // For now, let's assume specific columns or try to find headers
        // Just iterating and checking
        if (sheet != null) {
          int nameIdx = -1;
          int codeIdx = -1;
          int specIdx = -1;
          int startRow = 0;

          // Search for header row in first 20 rows
          for (int r = 0; r < 20 && r < sheet.rows.length; r++) {
             var row = sheet.rows[r];
             bool foundHeader = false;
             for(int c=0; c<row.length; c++) {
                var val = row[c]?.value.toString().toLowerCase() ?? '';
                if(val.contains('surgery') && !val.contains('code') && !val.contains('date')) {
                   // Found potential Surgery Name column
                   foundHeader = true;
                   break;
                }
             }
             if(foundHeader) {
                startRow = r;
                // Identify columns in this row
                for(int i=0; i<row.length; i++) {
                   var val = row[i]?.value.toString().toLowerCase() ?? '';
                   if(val.contains('surgery') && !val.contains('code') && !val.contains('date')) nameIdx = i;
                   else if(val.contains('code') || val.contains('cp')) codeIdx = i; // 'cp' for CPT Code?
                   else if(val.contains('speciality') || val.contains('department')) specIdx = i;
                }
                break;
             }
          }
          
          print('Header Row found at: $startRow');
          print('Indices: Name=$nameIdx, Code=$codeIdx, Spec=$specIdx');

          // Fallback if not found (assuming standard order: 0: Code, 1: Name, 2: Speciality - adapt as needed)
          if(codeIdx == -1) codeIdx = 0;
          if(nameIdx == -1) nameIdx = 1;
          if(specIdx == -1) specIdx = 2; // Adjust based on real file if this fails

          for (int i = startRow + 1; i < sheet.rows.length; i++) {
            var row = sheet.rows[i];
            if (row.isEmpty) continue;
            
            String code = row.length > codeIdx ? row[codeIdx]?.value.toString() ?? '' : '';
            String name = row.length > nameIdx ? row[nameIdx]?.value.toString() ?? '' : '';
            String spec = row.length > specIdx ? row[specIdx]?.value.toString() ?? '' : '';
            
            // Clean up values
            code = code.trim();
            name = name.trim();
            spec = spec.trim();

            if (code.isNotEmpty || name.isNotEmpty) {
              var item = SurgeryMasterItem(code: code, name: name, speciality: spec);
              allMasterItems.add(item);
              // Store by Code and Name for easy lookup
              if(code.isNotEmpty) surgeryMasterData[code] = item;
              if(name.isNotEmpty) surgeryMasterData[name] = item; 
              
              if(code.isNotEmpty && !surgeryCodeList.contains(code)) surgeryCodeList.add(code);
              if(name.isNotEmpty && !surgeryNameList.contains(name)) surgeryNameList.add(name);
              if(spec.isNotEmpty && !specialityList.contains(spec)) specialityList.add(spec);
            }
          }
        }
      }
    } catch (e) {
      print('Error loading master data: $e');
      // Non-fatal, just empty dropdowns
    } finally {
      print('Master Data Loaded:');
      print('Surgery Names: ${surgeryNameList.length}');
      print('Surgery Codes: ${surgeryCodeList.length}');
      print('Specialities: ${specialityList.length}');
      if(surgeryNameList.isNotEmpty) print('Sample Name: ${surgeryNameList.first}');
    }
  }

  Future<void> _parseJsonData() async {
    if (widget.jsonData == null) return;

    for (var item in widget.jsonData!) {
      String date = item['DATE OF SURGERY']?.toString() ?? '';
      String ageSex = item['AGE/SEX']?.toString() ?? '';
      String surgeon = item['SURGEON']?.toString() ?? '';
      String defaultSpeciality = item['SPECIALITY']?.toString() ?? '';
      String patientName = item['Name of the Patient']?.toString() ?? '';
      String specialRequest = item['Special Request']?.toString() ?? '';
      String mrdNumber = item['Mrd Number']?.toString() ?? '';

      // Handle SURGERY list
      List<dynamic> surgeryList = [];
      if (item['SURGERY'] is List) {
        surgeryList = item['SURGERY'];
      } else if (item['SURGERY'] != null) {
        surgeryList = [item['SURGERY']];
      } else {
        surgeryList = [null]; // Default to at least one entry
      }

      // Handle duration list
      List<dynamic> durationList = [];
      if (item['duration'] is List) {
        durationList = item['duration'];
      } else if (item['duration'] != null) {
        durationList = [item['duration']];
      }

      // Determine number of rows (use max length of arrays)
      int rowCount = surgeryList.length;
      if (rowCount < durationList.length) rowCount = durationList.length;
      if (rowCount == 0) rowCount = 1;

      for (int i = 0; i < rowCount; i++) {
        dynamic rawSurgery = (i < surgeryList.length) ? surgeryList[i] : null;
        dynamic rawDuration = (i < durationList.length) ? durationList[i] : null;

        String surgeryName = '';
        String surgeryCode = '';
        String rowSpeciality = defaultSpeciality;

        if (rawSurgery != null && rawSurgery.toString().trim().isNotEmpty) {
          surgeryName = rawSurgery.toString().trim();

          // Try to match with master data to get code and speciality
          if (surgeryMasterData.containsKey(surgeryName)) {
            var master = surgeryMasterData[surgeryName]!;
            surgeryCode = master.code;
            rowSpeciality = master.speciality;
          } else {
            // Try to extract code from parentheses e.g. "Surgery Name(CODE123)"
            RegExp codeRegex = RegExp(r'\(([^)]+)\)');
            Iterable<RegExpMatch> matches = codeRegex.allMatches(surgeryName);
            if (matches.isNotEmpty) {
               String extractedCode = matches.last.group(1)!;
               if (surgeryMasterData.containsKey(extractedCode)) {
                  var master = surgeryMasterData[extractedCode]!;
                  surgeryName = master.name;
                  surgeryCode = master.code;
                  rowSpeciality = master.speciality;
               }
            }
          }
        }

        String durationStr = '';
        if (rawDuration != null && rawDuration.toString().trim().isNotEmpty) {
           durationStr = rawDuration.toString().trim();
        }

        tableRows.add(ConfirmationRow(
          date: date,
          ageSex: ageSex,
          surgery: surgeryName,
          surgeon: surgeon,
          speciality: rowSpeciality,
          patientName: patientName,
          specialRequest: specialRequest,
          mrdNumber: mrdNumber,
          duration: durationStr,
          surgeryCode: surgeryCode,
        ));
      }
    }
  }

  Future<void> _parseInputExcel() async {
    var excel = Excel.decodeBytes(widget.fileBytes);
    if (excel.tables.isNotEmpty) {
       // Assuming 'Surgery Report' or first sheet
       var sheet = excel.tables['Surgery Report'] ?? excel.tables[excel.tables.keys.first];
       if(sheet != null) {
          // Headers are in row 0. Data starts row 1.
          // Expected cols: DATE OF SURGERY, AGE/SEX, SURGERY, SURGEON, SPECIALITY, Name of the Patient, Special Request, Mrd Number
          // We map these to our row object
          // Let's assume standard order from generation logic
          for(int i=1; i<sheet.rows.length; i++) {
             var row = sheet.rows[i];
             if(row.isEmpty) continue;
             
             // Check if all null
             bool allNull = row.every((c) => c?.value == null);
             if(allNull) continue;

             tableRows.add(ConfirmationRow(
               date: _getVal(row, 0),
               ageSex: _getVal(row, 1),
               surgery: _getVal(row, 2),
               surgeon: _getVal(row, 3),
               speciality: _getVal(row, 4),
               patientName: _getVal(row, 5),
               specialRequest: _getVal(row, 6),
               mrdNumber: _getVal(row, 7),
               duration: '', // New field
               surgeryCode: '', // New field, initially empty? Or try to match surgery name?
             ));
             
             // Try to pre-fill code if surgery name matches master
             String currentSurgery = _getVal(row, 2);
             if(surgeryMasterData.containsKey(currentSurgery)) {
                tableRows.last.surgeryCode = surgeryMasterData[currentSurgery]?.code ?? '';
                // Also update speciality if matches master? User said Default value = value from generated Excel.
             }
          }
       }
    }
  }
  
  String _getVal(List<Data? > row, int index) {
     if(index >= row.length) return '';
     return row[index]?.value.toString() ?? '';
  }

  Future<void> _handleScheduleButtonPress() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Generate Excel from tableRows
      var excel = Excel.createExcel();
      var sheet = excel['Sheet1'];
      excel.rename('Sheet1', 'Surgery Report');
      var surgerySheet = excel['Surgery Report'];

      // Headers matching what the backend expects
      // Note: Backend might rely on specific headers or order. using the standard set.
      final headers = [
        'DATE OF SURGERY',
        'AGE/SEX',
        'SURGERY',
        'SURGEON',
        'SPECIALITY',
        'Name of the Patient',
        'Special Request',
        'Mrd Number'
      ];

      // Add header row
      for (int i = 0; i < headers.length; i++) {
        surgerySheet
            .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'))
            .value = TextCellValue(headers[i]);
      }

      // Add data rows
      for (int i = 0; i < tableRows.length; i++) {
        var row = tableRows[i];
        final r = i + 2;
        
        surgerySheet.cell(CellIndex.indexByString('A$r')).value = TextCellValue(row.date);
        surgerySheet.cell(CellIndex.indexByString('B$r')).value = TextCellValue(row.ageSex);
        surgerySheet.cell(CellIndex.indexByString('C$r')).value = TextCellValue(row.surgery);
        surgerySheet.cell(CellIndex.indexByString('D$r')).value = TextCellValue(row.surgeon);
        surgerySheet.cell(CellIndex.indexByString('E$r')).value = TextCellValue(row.speciality);
        surgerySheet.cell(CellIndex.indexByString('F$r')).value = TextCellValue(row.patientName);
        surgerySheet.cell(CellIndex.indexByString('G$r')).value = TextCellValue(row.specialRequest);
        surgerySheet.cell(CellIndex.indexByString('H$r')).value = TextCellValue(row.mrdNumber);
        // We are NOT sending Duration or Surgery Code for now as backend might not support it / expects specific format
        // If backend needs them we would add them here.
      }

      var fileBytes = excel.encode()!;
      String base64File = base64Encode(fileBytes);

      // 2. Send to Backend
      String apiUrl = 'https://us-central1-amrita-body-scan.cloudfunctions.net/OTSchedulerv2';
      Map<String, dynamic> requestBody = {'doc': base64File};
      
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        // 3. Navigate to SchedulerOutput
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulerOutput(scheduleData: jsonResponse),
          ),
        );
      } else {
        print('Error from backend: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error in schedule button: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // ... existing scroll views
              child: SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: DataTable(
                    // ... existing columns
                    // ... existing rows
                    columns: [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Age/Sex')),
                        DataColumn(label: Text('Surgery')),
                        DataColumn(label: Text('Surgery Code')),
                        DataColumn(label: Text('Speciality')),
                        DataColumn(label: Text('Surgeon')),
                        DataColumn(label: Text('Patient')),
                        DataColumn(label: Text('MRD')),
                        DataColumn(label: Text('Duration (Hrs)')),
                        DataColumn(label: Text('Request')),
                    ],
                    rows: tableRows.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(row.date)),
                        // ... cells mapped from tableRows (same as before)
                        DataCell(Text(row.ageSex)),
                        DataCell(DropdownButton<String>(
                            value: surgeryNameList.contains(row.surgery) ? row.surgery : null,
                            hint: Text(row.surgery.isEmpty ? 'Select' : row.surgery),
                            items: (row.speciality.isEmpty 
                                ? surgeryNameList 
                                : allMasterItems.where((m) => m.speciality == row.speciality).map((m) => m.name).where((n) => n.isNotEmpty).toSet().toList())
                              .map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val));
                              }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                row.surgery = newValue!;
                                if(surgeryMasterData.containsKey(newValue)) {
                                  row.surgeryCode = surgeryMasterData[newValue]!.code;
                                  if (row.speciality.isEmpty) row.speciality = surgeryMasterData[newValue]!.speciality;
                                }
                              });
                            },
                        )),
                        DataCell(DropdownButton<String>(
                            value: surgeryCodeList.contains(row.surgeryCode) ? row.surgeryCode : null,
                            hint: Text(row.surgeryCode.isEmpty ? 'Select' : row.surgeryCode),
                            items: (row.speciality.isEmpty 
                                ? surgeryCodeList 
                                : allMasterItems.where((m) => m.speciality == row.speciality).map((m) => m.code).where((c) => c.isNotEmpty).toSet().toList())
                              .map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val));
                              }).toList(),
                            onChanged: (newValue) {
                               setState(() {
                                  row.surgeryCode = newValue!;
                                  if(surgeryMasterData.containsKey(newValue)) {
                                     row.surgery = surgeryMasterData[newValue]!.name;
                                     if (row.speciality.isEmpty) row.speciality = surgeryMasterData[newValue]!.speciality;
                                  }
                               });
                            },
                        )),
                        DataCell(DropdownButton<String>(
                            value: specialityList.contains(row.speciality) ? row.speciality : null,
                            hint: Text(row.speciality.isEmpty ? 'Select' : row.speciality),
                            items: specialityList.map((String val) {
                              return DropdownMenuItem<String>(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (newValue) {
                               setState(() {
                                  row.speciality = newValue!;
                                  // Reset surgery and code if they don't belong to new speciality
                                  row.surgery = '';
                                  row.surgeryCode = '';
                               });
                            },
                        )),
                        DataCell(Text(row.surgeon)),
                        DataCell(Text(row.patientName)),
                        DataCell(Text(row.mrdNumber)),
                        DataCell(TextFormField(
                            initialValue: row.duration,
                            onChanged: (val) { row.duration = val; },
                        )),
                        DataCell(Text(row.specialRequest)),
                      ]);
                    }).toList(),
                 ),
              ),
            ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleScheduleButtonPress,
        label: Text('Schedule'),
        icon: Icon(Icons.calendar_today),
       ),
    );
  }
}



class SurgeryMasterItem {
  final String code;
  final String name;
  final String speciality;
  
  SurgeryMasterItem({required this.code, required this.name, required this.speciality});
}

class ConfirmationRow {
  String date;
  String ageSex;
  String surgery;
  String surgeon;
  String speciality;
  String patientName;
  String specialRequest;
  String mrdNumber;
  String duration;
  String surgeryCode;

  ConfirmationRow({
    required this.date,
    required this.ageSex,
    required this.surgery,
    required this.surgeon,
    required this.speciality,
    required this.patientName,
    required this.specialRequest,
    required this.mrdNumber,
    required this.duration,
    required this.surgeryCode,
  });
}
