import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:my_flutter_app/config/customThemes/utilities/Utilities.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/constants.dart';
import '../config/customThemes/elevatedButtonTheme.dart';

class SchedulerOutput extends StatefulWidget {
  final Map<String, dynamic> scheduleData;

  const SchedulerOutput({Key? key, required this.scheduleData})
      : super(key: key);

  @override
  _SchedulerOutputState createState() => _SchedulerOutputState();
}



class _SchedulerOutputState extends State<SchedulerOutput> {
  late List<MapEntry<String, dynamic>> sortedOTEntries;

  // Controllers for editable fields
  late List<TextEditingController> otNumberControllers;
  late List<TextEditingController> surgeonControllers;
  late List<TextEditingController> surgeryControllers;
  late List<TextEditingController> startTimeControllers;
  late List<TextEditingController> endTimeControllers;
  late List<TextEditingController> dateControllers;
  late List<TextEditingController> patientNameControllers;
  late List<TextEditingController> mrdControllers;
  late List<TextEditingController> specialEquipmentControllers;
  late List<TextEditingController> departmentControllers;
  late List<TextEditingController> ageSexControllers;
  late List<TextEditingController> technicalLeadsControllers;
  late List<TextEditingController> nursingLeadsControllers;
  late List<TextEditingController> bedControllers;
  late List<TextEditingController> contactControllers;

  static const double leftMargin = 180;
  static const Color headerTextColor = Colors.black87;
  static const double headerTextSize = 16.0;
  static const InputDecoration rowDecoration = InputDecoration(border: InputBorder.none,);
  String baseUrl = Constants.baseURL;
  bool isDownloadEnabled = false;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();


  String displayText1 = 'Scheduled Surgeries';
  String displayText2 = 'View all scheduled surgeries across all operation theaters';

  String otNumberToFilter= " ";
  var rows;

  var originalList;

  @override
  void initState() {
    super.initState();

    print("scheduleData:${widget.scheduleData}");

    // Initialize sortedOTEntries when the widget initializes
    sortedOTEntries = widget.scheduleData['OT'].entries.toList();
    sortedOTEntries.sort((a, b) => a.value.toString().compareTo(b.value.toString()));

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
    mrdControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['MRD'][sortedOTEntries[index].key].toString())
    );
    patientNameControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Name of the Patient'][sortedOTEntries[index].key])
    );
    specialEquipmentControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Special Equipment'][sortedOTEntries[index].key])
    );
    // print('Value type: ${widget.scheduleData['Department'][sortedOTEntries[0].key].runtimeType}');
    // print('Value: ${widget.scheduleData['Department'][sortedOTEntries[0].key]}');
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

    bedControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Bed No'][sortedOTEntries[index].key].toString()));

    contactControllers = List.generate(sortedOTEntries.length, (index) =>
        TextEditingController(text: widget.scheduleData['Contact No'][sortedOTEntries[index].key].toString()));


    // Define table rows
    rows = sortedOTEntries.map<DataRow>((entry) {
      final index = sortedOTEntries.indexOf(entry);
      return DataRow(
        cells: [
          DataCell(TextField(
            controller: otNumberControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update OT number and scheduleData on change
              setState(() {
                sortedOTEntries[index] = MapEntry(entry.key, int.tryParse(value) ?? entry.value);
              });
            },
          )),
          DataCell(TextField(
            controller: surgeonControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Surgeon'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: departmentControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Department'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: surgeryControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['surgery'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: startTimeControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Start_time'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: endTimeControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['End_time'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: mrdControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['MRD'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: bedControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Bed No'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: contactControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Contact No'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: specialEquipmentControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Special Equipment'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: technicalLeadsControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Technicial T/L'][entry.key] = value;
            },
          )),
          DataCell(TextField(
            controller: nursingLeadsControllers[index],
            decoration: rowDecoration,
            onChanged: (value) {
              // Update scheduleData on change
              widget.scheduleData['Nursing T/L'][entry.key] = value;
            },
          )),

        ],
      );
    }).toList();

    originalList = rows;
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    // Dispose controllers to free up resources
    otNumberControllers.forEach((controller) => controller.dispose());
    surgeonControllers.forEach((controller) => controller.dispose());
    surgeryControllers.forEach((controller) => controller.dispose());
    startTimeControllers.forEach((controller) => controller.dispose());
    endTimeControllers.forEach((controller) => controller.dispose());
    dateControllers.forEach((controller) => controller.dispose());
    mrdControllers.forEach((controller) => controller.dispose());
    patientNameControllers.forEach((controller) => controller.dispose());
    specialEquipmentControllers.forEach((controller) => controller.dispose());
    departmentControllers.forEach((controller) => controller.dispose());
    ageSexControllers.forEach((controller) => controller.dispose());
    technicalLeadsControllers.forEach((controller) => controller.dispose());
    nursingLeadsControllers.forEach((controller) => controller.dispose());
    bedControllers.forEach((controller) => controller.dispose());
    contactControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveChanges() async {

    // Update scheduleData with new values from controllers
    String inputDate = widget.scheduleData['Date of Surgery']['0'];

    // Parse the input date
    DateTime parsedDate = DateFormat('MM/dd/yyyy').parse(inputDate);

    // Format the parsed date into YYYY-MM-DD
    String _surgeryDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    print("widget date : ${widget.scheduleData['Date of Surgery']['0']}");
    print("widget date runtime type: ${widget.scheduleData['Date of Surgery']['0'].runtimeType}");

    //String _surgeryDate = DateFormat('yyyy-MM-dd').format(widget.scheduleData['Date of Surgery']['0']);

    print("surgery date : $_surgeryDate");

    try {

      //delete existing entries
      bool entriesExist = await _checkEntriesExist(_surgeryDate);
      if (entriesExist) {
        // Delete existing entries
        print("inside entriesExist");
        await _deleteEntriesFromSchedule(_surgeryDate);
        await _deleteEntriesFromPatients(_surgeryDate);
      }

      print("sortedOTEntries.length= ${sortedOTEntries.length}");
      for (int index = 0; index < sortedOTEntries.length; index++) {
        print(index);
        final String otNumber = otNumberControllers[index].text;
        final String surgeon = surgeonControllers[index].text;
        final String department = departmentControllers[index].text;
        final String procedure = surgeryControllers[index].text;
        final String startTime = startTimeControllers[index].text;
        final String endTime = endTimeControllers[index].text;
        final String mrd = mrdControllers[index].text;
        final String patient = patientNameControllers[index].text;
        final String ageSex = ageSexControllers[index].text;
        final String specialEquipment = specialEquipmentControllers[index].text;
        final String technicalLead = technicalLeadsControllers[index].text;
        final String nursingLead = nursingLeadsControllers[index].text;
print('Variables initialized');
        // Assuming you have a common date for all entries, otherwise adjust accordingly.
        final date = _surgeryDate; // replace with your actual date


        Future.delayed(Duration(milliseconds: 500));

        sendDoctorList(surgeon, department);
        print('Functions 1 called');
        Future.delayed(Duration(milliseconds: 500));
        sendScheduledOT(otNumber, department);
        print('Functions 2 called');
        Future.delayed(Duration(milliseconds: 500));
        var duration = calculateDuration(endTime, startTime);
        sendProcedureList(procedure, department, duration);
        print('Functions 3 called');
        Future.delayed(Duration(milliseconds: 500));
        print('Age Sex: $ageSex');
        sendPatientList(patient, ageSex.split('/')[0], ageSex.split('/')[1], int.parse(mrd),inputDate);
        print('Functions 4 called');
        Future.delayed(Duration(milliseconds: 500));
        sendOtStafffList(nursingLead, department, 'Nursing T/L');
        print('Functions 5 called');
        Future.delayed(Duration(milliseconds: 500));
        sendOtStafffList(technicalLead, department, 'Technical T/L');
        print('Functions 6 called');
        Future.delayed(Duration(milliseconds: 500));
print('All Functions called');
        sendScheduleSurgery(
          procedure,
          department,
          surgeon,
          patient, // Replace with actual patient name if available
          mrd,
          inputDate,
          startTime,
          endTime,
          otNumber,
          technicalLead,
          nursingLead,
          specialEquipment,
        );

        //sendDoctorList(doctor_name, department)
      }


    } catch(e) {
      print("myError--:$e");
    }

  }

  Future<void> _deleteEntriesFromSchedule(String uploadedDate) async {
    String apiUrl = '$baseUrl/schedule/';
    String deleteUrl = apiUrl + 'delete-all-on-date/?surgery_date=$uploadedDate';
    var deleteResponse = await http.delete(
      Uri.parse(deleteUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
      print('Entries deleted successfully.');
    } else {
      print('Error deleting entries: ${deleteResponse.statusCode}');
      print('Response body: ${deleteResponse.body}');
    }
  }

  Future<void> _deleteEntriesFromPatients(String uploadedDate) async{
    String apiUrl = '$baseUrl/patient/';
    String deleteUrl = apiUrl + 'delete-all-on-date/?registration_date=$uploadedDate';
    var deleteResponse = await http.delete(
      Uri.parse(deleteUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
      print('Entries deleted successfully.');
    } else {
      print('Error deleting entries: ${deleteResponse.statusCode}');
      print('Response body: ${deleteResponse.body}');
    }
  }

  Future<bool> _checkEntriesExist(String uploadedDate) async {

    String apiUrl = '$baseUrl/schedule/';
    String checkUrl = apiUrl + '?surgery_date=$uploadedDate';
    print('checkUrl:$checkUrl');

    var response = await http.get(
      Uri.parse(checkUrl),
      headers: {'Content-Type': 'application/json'},
      //body: jsonEncode({'surgery_date': date}),
    );

    if(response.statusCode == 200){
      List<dynamic> data = jsonDecode(response.body);
      print("_checkEntriesExist()-$data");
      return data.isNotEmpty;
    }
    else{
      print('Error checking entries: ${response.statusCode}');
      return false;
    }

  }

  void sendScheduledOT(String otNumber, String department) async {
    String databaseApiUrl = '$baseUrl/OT/';

    // Make HTTP POST request to the backend API
    var response = await http.post(
      Uri.parse(databaseApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ot_number': otNumber, 'department': department}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data sent to the backend successfully.');
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void sendDoctorList(String doctor_name, String department) async {
    String apiUrl = '$baseUrl/doctors/';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'doctor_name': doctor_name, 'department': department}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data sent to the backend successfully.');
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void sendOtStafffList(String staff_name, String department, String designation) async {
    String apiUrl = '$baseUrl/otstaff/';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'ot_staff_name': staff_name, 'ot_staff_department':
          department, 'ot_staff_designation': designation}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('otStafffList():Data sent to the backend successfully.');
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void sendPatientList(String name, String age, String gender, int mrd, String surgeryDate) async {
    String apiUrl = '$baseUrl/patient/';

    //DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(surgeryDate.toString());
    //String formattedDate = DateFormat('mm')
    print('sendPatientList_surgeryDate: $surgeryDate');

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'patient_name': name,
        'age': int.parse(age.split('Y')[0]),
        'gender': gender,
        'mrd': mrd,
        'registration_date' : surgeryDate
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('sendPatientList():Data sent to the backend successfully.');
      // Parse the response body
      //Map<String, dynamic> responseBody = jsonDecode(response.body);


      print('sendPatientList():${response.body}');
      // Retrieve the patient_id from the response body
      //var id = responseBody['patient_id'];
      //patient_id.add(id);
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void sendProcedureList(
      String procedure_name, String department, double duration) async {
    String apiUrl = '$baseUrl/procedure/';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'procedure_name': procedure_name,
        'department': department,
        'estimated_duration': duration
      }),
    );

    print('sendProcedureList:' + response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data sent to the backend successfully.');
      // Parse the response body
      //Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Retrieve the patient_id from the response body
      // procedure_id = responseBody['procedure_id'];
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  double calculateDuration(dynamic end_time, dynamic start_time) {
    // Parse start time and end time strings into hours and minutes
    List<String> startTimeParts = start_time.split(':');
    List<String> endTimeParts = end_time.split(':');

    int startHours = int.parse(startTimeParts[0]);
    int startMinutes = int.parse(startTimeParts[1]);

    int endHours = int.parse(endTimeParts[0]);
    int endMinutes = int.parse(endTimeParts[1]);

    // Calculate the time difference in minutes
    int startTimeInMinutes = startHours * 60 + startMinutes;
    int endTimeInMinutes = endHours * 60 + endMinutes;

    int differenceInMinutes = endTimeInMinutes - startTimeInMinutes;

    // Calculate the time difference in hours
    double differenceInHours = differenceInMinutes / 60.0;

    //print('Difference between $end_time and $start_time is ${differenceInHours.toStringAsFixed(2)} hours.');
    return differenceInHours;
  }

  void sendScheduleSurgery(procedure, department, doctor, patient, mrd, date,
      start_time, end_time, otData, technician_tl, nurse_tl, specialEquipment) async {
    String apiUrl = '$baseUrl/schedule/';
    print('DateFormat:${DateFormat('MM/dd/yyyy').parse(date).toString().split(' ')[0]}');

    // print('sendScheduleSurgery:$apiUrl');
    // print('sendScheduleSurgery()-date:${date.runtimeType} ${DateTime.parse(date)}');

    String formattedDate = DateFormat('MM/dd/yyyy').parse(date).toString().split(' ')[0];
    // print('formattedDate:$formattedDate');

    //String deleteUrl = apiUrl + 'delete-all-on-date/?surgery_date=$formattedDate';
    // String checkUrl = apiUrl + '?surgery_date=$formattedDate';
    // print('checkUrl:$checkUrl');
    // //
    // var getResponse = await http.get(
    //   Uri.parse(checkUrl),
    //   headers: {'Content-Type': 'application/json'},
    //   //body: jsonEncode({'surgery_date': date}),
    // );

    //print('responseGet.body::${getResponse.body}');

    // if (getResponse.statusCode == 200) {
    //   // Entries exist, proceed with deletion
    //   String deleteUrl = apiUrl + 'delete-all-on-date/?surgery_date=$formattedDate';
    //   var deleteResponse = await http.delete(
    //     Uri.parse(deleteUrl),
    //     headers: {'Content-Type': 'application/json'},
    //   );
    //
    //   if (deleteResponse.statusCode == 200 || deleteResponse.statusCode == 204) {
    //     print('Entries deleted successfully.');
    //   } else {
    //     print('Error deleting entries: ${deleteResponse.statusCode}');
    //     print('Response body: ${deleteResponse.body}');
    //   }
    // }
    //else {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'procedure_name': procedure,
        'department': department,
        'patient_name': patient,
        'mrd': mrd,
        'doctor_name': doctor,
        'surgery_start_time': start_time,
        'surgery_end_time': end_time,
        'surgery_date': date,
        'ot_number': otData,
        'technician_tl': technician_tl,
        'nurse_tl': nurse_tl,
        'special_equipment': specialEquipment,
      }),
    );

    print('sendScheduleSurgery:' + response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('sendScheduleSurgery()-Data sent to the backend successfully.');
      print('sendScheduleSurgery() ${response.body}');
      // Parse the response body
      //Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Retrieve the patient_id from the response body
      // procedure_id = responseBody['procedure_id'];
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
    //}
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
        'MRD Number',
        'Bed No',
        'Contact No',
        'Special Equipment',
        // 'Name of Patient',
        // 'Age/Sex',
        'Nursing T/l',
        'Technician T/L',
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
        //final String patientName = patientNameControllers[sortedOTEntries.indexOf(entry)].text;
        final String mrdNumber = mrdControllers[sortedOTEntries.indexOf(entry)].text;
        final String specialEquipment = specialEquipmentControllers[sortedOTEntries.indexOf(entry)].text;
        final String department = departmentControllers[sortedOTEntries.indexOf(entry)].text;
        //final String ageSex = ageSexControllers[sortedOTEntries.indexOf(entry)].text;
        final String nusringTL = nursingLeadsControllers[sortedOTEntries.indexOf(entry)].text;
        final String technicianTL = technicalLeadsControllers[sortedOTEntries.indexOf(entry)].text;

        final String bedNo = bedControllers[sortedOTEntries.indexOf(entry)].text;
        final String contactNo = contactControllers[sortedOTEntries.indexOf(entry)].text;

        rows.add([
          date,
          '$otNumber',
          surgeon,
          department,
          surgery,
          startTime,
          endTime,
          mrdNumber,
          bedNo,
          contactNo,
          specialEquipment,
          // patientName,
          // ageSex,
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

    setState(() {
      isDownloadEnabled = false;
    });

  }



  @override
  Widget build(BuildContext context) {
    // Define table columns
    final columns = [
      // DataColumn(
      //   label: Container(
      //     padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //     color: Colors.blueAccent,
      //     child: Text('Date', style: TextStyle(color: Colors.white)),
      //   ),
      // ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('OT', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('Surgeon', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.greenAccent,
          child: Text('Department', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.orangeAccent,
          child: Text('Surgery', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.purpleAccent,
          child: Text('Start Time', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.redAccent,
          child: Text('End Time', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.redAccent,
          child: Text('MRD Number', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('Bed No', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('Contact No', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      // DataColumn(
      //   label: Container(
      //     padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //     //color: Colors.blueAccent,
      //     child: Text('Name of Patient', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
      //   ),
      // ),
      // DataColumn(
      //   label: Container(
      //     padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      //     //color: Colors.blueAccent,
      //     child: Text('Age/Sex', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
      //   ),
      // ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child:
          Text('Special Equipment', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('Technical T/L', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),
      DataColumn(
        label: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.blueAccent,
          child: Text('Nursing T/L', style: TextStyle(color: headerTextColor,fontSize: headerTextSize,fontWeight: FontWeight.bold)),
        ),
      ),

    ];


    return Scaffold(
      appBar: MyAppBar(),
      body:
      Padding(
        padding: const EdgeInsets.only(left: leftMargin, right: 80, top: 10,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Text(
            //     'List of OT\'s Scheduled',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            // ),
            IntrinsicWidth(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayText1, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Text(displayText2,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                Divider(color: Colors.blueGrey[50], thickness: 2),
              ],
            )),
            SizedBox(height: 20),
            Text('OT NUMBER', style: TextStyle (fontSize: 16, fontWeight: FontWeight.w800,color: Colors.blueGrey),),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 220,
                  height: 45,
                  child: TextField(
                    decoration: Utilities.otSearchBoxDecoration,
                    onChanged: (value) {
                      otNumberToFilter = value;
                    },
                  ),
                ),

                SizedBox(width: 10),
                SizedBox(
                    width: 80,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[200],
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(15))),
                        padding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: isDownloadEnabled ? () {
                        setState(() {
                          rows = _filterRows(otNumberToFilter);
                        });
                      } : null,
                      child: Text(
                        'Go',
                        style: TextStyle(color: Colors.black87),
                      ),
                    )
                ),
                //SizedBox(width: 500), // Old - 900
                Spacer(),
                ElevatedButton (
                  style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                  onPressed: isDownloadEnabled ? _exportDataToCsv:null,
                  child: Text('Download',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            SizedBox(height:25),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey), // Ensure borders are visible
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Scrollbar(
                  controller: _horizontalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        child: DataTable(
                      columns: columns,
                      rows: rows,
                      dividerThickness: 1.5,
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.blueGrey),
                      //   borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      //
                      // ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                onPressed: () {
                  _saveChanges();
                  setState(() {
                    isDownloadEnabled = true;
                  });

                },
                child: Text('Update/Confirm',style: TextStyle(color: Colors.white),),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _exportDataToCsv,
      //   tooltip: 'Export CSV',
      //   child: Icon(Icons.file_download),
      // ),
    );
  }

  List<DataRow> _filterRows(String otNumber) {

    if(!otNumber.isEmpty){
      return sortedOTEntries.where((entry) {
        return entry.value.toString()== otNumber;
      }).map<DataRow>((entry) {
        final index = sortedOTEntries.indexOf(entry);
        return DataRow(
          cells: [
            DataCell(TextField(
              controller: otNumberControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update OT number and scheduleData on change
                setState(() {
                  sortedOTEntries[index] = MapEntry(entry.key, int.tryParse(value) ?? entry.value);
                });
              },
            )),
            DataCell(TextField(
              controller: surgeonControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Surgeon'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: departmentControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Department'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: surgeryControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['surgery'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: startTimeControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Start_time'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: endTimeControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['End_time'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: mrdControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['MRD'][entry.key] = value;
              },
            )),

            DataCell(TextField(
              controller: specialEquipmentControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Special Equipment'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: technicalLeadsControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Technicial T/L'][entry.key] = value;
              },
            )),
            DataCell(TextField(
              controller: nursingLeadsControllers[index],
              decoration: rowDecoration,
              onChanged: (value) {
                // Update scheduleData on change
                widget.scheduleData['Nursing T/L'][entry.key] = value;
              },
            )),
          ],
        );
      }).toList();
    }
    else
      return originalList;

  }

}
