import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/OTSchedule/OTScheduleListScreen.dart';

class OTScheduleScreen extends StatefulWidget {
  @override
  _OTScheduleScreenState createState() => _OTScheduleScreenState();
}

class _OTScheduleScreenState extends State<OTScheduleScreen> {
  DateTime? _selectedDate;
  String _uploadedDate ='';
  TextEditingController fromDateController = TextEditingController();
  bool isDateSelected = true;
  bool isOTButtonVisible = false;
  File? _file;
  Uint8List? _webFile;
  String _notificationMessage = '';
  //TextEditingController fromDateController = TextEditingController();
  String baseUrl = 'http://10.125.11.203:8091/api';
  //String baseUrl = 'https://9c79-2409-40d0-b5-dafe-c4cf-904e-59b2-3fd4.ngrok-free.app/api';
  Map<String, dynamic> scheduledOTList = {};
  Map<String, dynamic> doctorList = {};
  // double duration = 0.0 ;
  // int patient_id = 0;
  // String doctor_id = '';
  // String user_id = '';
  // String ot_id ='';
  // String procedure_id ='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OT Schedule',
          style: TextStyle(fontSize: 24),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Set the height of the divider
          child: Divider(color: Colors.grey), // Divider below the app bar title
        ),
        centerTitle: true,
      ),
      body: Center(
        // child: Padding(
        //   padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    child: TextField(
                      controller: fromDateController,
                      canRequestFocus: false,
                      decoration: InputDecoration(labelText: 'Select date', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.calendar_month_rounded, size: 20),),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Circular shape
                      color: Colors.indigoAccent, // Lavender background color
                    ),
                    child: IconButton(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_month_outlined),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80),
              GestureDetector(
                onTap: isDateSelected
                    ? null
                    : () {
                  _pickFile();
                },
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 100),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isDateSelected
                          ? null
                          : () {
                        _pickFile();
                      },
                      child: Text('Upload'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              _file != null || _webFile != null
                  ? ElevatedButton(
                      onPressed: () {
                        _handleOTScheduleButtonPress();
                      },
                      child: Text('OT Schedule'),
                    )
                  : Container(),
              SizedBox(height: 10),
              Text(_notificationMessage),
            ],
          ),
        //),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2023),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        String date = "${_selectedDate}".split(' ')[0];
        fromDateController?.text = date;
        isDateSelected = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      print("[DEBUG] Attempting to open file picker for spreadsheet files (v8.x cleaner API)");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        String fileName = result.files.single.name;
        String fileNameLower = fileName.toLowerCase();
        print("[DEBUG] File selected: $fileName");

        // Manual validation for Excel/CSV
        if (!fileNameLower.endsWith('.xlsx') && 
            !fileNameLower.endsWith('.xls') && 
            !fileNameLower.endsWith('.csv')) {
          print("[DEBUG] Invalid file extension selected: $fileName");
          setState(() {
            _notificationMessage = 'Invalid file type. Please select an Excel (.xlsx, .xls) or CSV file.';
          });
          return;
        }

        if (kIsWeb) {
          Uint8List fileBytes = result.files.single.bytes!;
          _webFile = fileBytes;
          print("[DEBUG] Web mode. File bytes length: ${fileBytes.length}");
          setState(() {
            _notificationMessage = 'File Uploaded: $fileName';
          });
          _extractDateFromFile();
        } else {
          _file = File(result.files.single.path!);
          print("[DEBUG] Native mode. File path: ${_file!.path}, Exists: ${await _file!.exists()}");
          setState(() {
            _notificationMessage = 'File Uploaded: ${_file!.path}';
          });
        }
      } else {
        print("[DEBUG] File picker returned null. The dialog might have been cancelled, or the OS silently failed to return a file.");
        setState(() {
          _notificationMessage = 'No file selected';
        });
      }
    } catch (e, stacktrace) {
      print('[DEBUG] Error picking file (Exception caught): $e\nStacktrace: $stacktrace');
      setState(() {
        _notificationMessage = 'Error picking file: $e';
      });
    }
  }

  void _handleOTScheduleButtonPress() async {

    setState(() {
      _notificationMessage = ' '; // Show processing message
      // _webFile = null;
      // _file = null;
    });

    try {

      print('_selectedDate: $_selectedDate');
      print('_uploadedDate: $_uploadedDate');
      String formattedDate = _selectedDate.toString().split(' ')[0];
      print('formattedDate:$formattedDate');
      if (formattedDate != _uploadedDate) {
        // setState(() {
        //   _notificationMessage = 'Selected date does not match date in the uploaded file';
        // });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content:
            Text('Selected date does not match date in the uploaded file.PLease select correct date'),
          ),
        );
        return;
      }

      List<int> fileBytes =
          _file != null ? await _file!.readAsBytes() : _webFile!;
      String base64File = base64Encode(fileBytes);


      // Check if entries exist for the _uploadedDate
      bool entriesExist = await _checkEntriesExist(_uploadedDate);
      if (entriesExist) {
        // Delete existing entries
        await _deleteEntriesFromSchedule(_uploadedDate);
        await _deleteEntriesFromPatients(_uploadedDate);
      }


      String apiUrl =
          'https://us-central1-amrita-body-scan.cloudfunctions.net/OT_Scheduler';
      Map<String, dynamic> requestBody = {'doc': base64File};
      String requestBodyJson = jsonEncode(requestBody);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Processing...'),
              ],
            ),
          );
        },
      );

      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBodyJson,
      );

      Navigator.pop(context);
      //print('Response body: ${response.body}'); // Add this line

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        setState(() {
          //_notificationMessage = ' '; // Show processing message
          _webFile = null;
          _file = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OTScheduleListScreen(scheduleData: jsonResponse),
          ),
        );

        // print('OT - ${jsonResponse['OT']}');
        // print('Department - ${jsonResponse['Department']}');
        // print('Doctor-${jsonResponse['Surgeon']}');
        print('jsonResponse-${jsonResponse}');
        print('age-${jsonResponse['Age/Sex'][0].toString().split('/')[0]}');

        // Extract the value of the "OT" key
        Map<String, dynamic> otData = jsonResponse['OT'];
        Map<String, dynamic> department = jsonResponse['Department'];
        Map<String, dynamic> doctor = jsonResponse['Surgeon'];
        Map<String, dynamic> patient = jsonResponse['Name of the Patient'];
        Map<String, dynamic> age = jsonResponse['Age/Sex'];

        Map<String, dynamic> procedure = jsonResponse['surgery'];
        Map<String, dynamic> start_time = jsonResponse['Start_time'];
        Map<String, dynamic> end_time = jsonResponse['End_time'];
        Map<String, dynamic> date = jsonResponse['Date of Surgery'];
        Map<String, dynamic> mrdNumbers = jsonResponse['MRD'];
        Map<String, dynamic> technicalLeads = jsonResponse['Technicial T/L'];
        Map<String, dynamic> nursingLeads = jsonResponse['Nursing T/L'];
        Map<String, dynamic> specialEquipment = jsonResponse['Special Equipment'];

        //print(mrdNumbers.values);
        //print('nursingLeads $nursingLeads');

        for (var key in otData.keys) {
          // scheduledOTList[otData[key].toString()] = department[key];
          sendScheduledOT(otData[key].toString(), department[key]);
          //print('${otData[key]} : ${depart[key]} | ');
        }
        //print(scheduledOTList);

        //API for Doctor
        for (var key in doctor.keys) {
          await Future.delayed(Duration(milliseconds: 500));
          sendDoctorList(doctor[key].toString(), department[key]);
        }

        //API call for procedure_list
        for (var key in procedure.keys) {
          await Future.delayed(Duration(milliseconds: 600));

          var duration = calculateDuration(end_time[key], start_time[key]);
          //print('duration - $duration');
          // duration = parseTime(end_time[key]).
          sendProcedureList(
              procedure[key].toString(), department[key].toString(), duration);
        }

        //API for patient
        for (var key in patient.keys) {
          //print('age-${jsonResponse['Age/Sex'][key].toString().split('/')[0].split('Y')[0]}');
          // Introduce a delay of 1000 milliseconds (1 second)
          await Future.delayed(Duration(milliseconds: 500));
          sendPatientList(patient[key].toString(), age[key].split('/')[0],
              age[key].split('/')[1], mrdNumbers[key], date[key]);
        }

        //API for OT staff
        for (var key in nursingLeads.keys) {
          await Future.delayed(Duration(milliseconds: 500));
          sendOtStafffList(nursingLeads[key], department[key], 'Nursing T/L');
        }

        for (var key in technicalLeads.keys) {
          await Future.delayed(Duration(milliseconds: 500));
          sendOtStafffList(technicalLeads[key], department[key], 'Technical T/L');
        }

        //print(patient_id);
        //API for scheduled surgeries
        //DateFormat format = DateFormat('MM/dd/yy');
        //DateFormat inputFormat = DateFormat('dd/MM/yyyy');

        for (var key in procedure.keys) {
          //print('age-${jsonResponse['Age/Sex'][key].toString().split('/')[0].split('Y')[0]}');
          // Introduce a delay of 1000 milliseconds (1 second)
          // print('date: ${inputFormat.parse((date[key]))}');
          // print('Data type of date[key]: ${inputFormat.parse(date[key])}');
          await Future.delayed(Duration(milliseconds: 500));
          //deleteEntries(date[key]);
          sendScheduleSurgery(
              procedure[key],
              department[key],
              doctor[key],
              patient[key],
              mrdNumbers[key].toString(),
              date[key],
              start_time[key],
              end_time[key],
              otData[key],
              technicalLeads[key],
              nursingLeads[key],
              specialEquipment[key],

          );
        }
      } else {
        setState(() {
          _notificationMessage =
              'Error: ${response.statusCode}'; // Update notification message with error
        });
        // print('Error-1: ${response.statusCode}');
        // print('Response body-1: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _notificationMessage =
            'Error: $e'; // Update notification message with error
      });
      print('Error-2: $e');
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

  String detectDateFormat(String dateString) {
    List<String> dateFormats = [
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd",
      "MM/dd/yyyy",
      "dd/MM/yyyy",
      "yyyy/MM/dd",
      // Add more formats as needed
    ];

    for (String format in dateFormats) {
      try {
        DateFormat dateFormat = DateFormat(format);
        dateFormat.parseStrict(dateString); // If parsing succeeds, the format is correct
        return format; // Return the format that successfully parsed the date
      } catch (e) {
        // Continue to the next format if parsing fails
      }
    }

    throw FormatException("Unknown date format: $dateString");
  }

  Future<void> _extractDateFromFile() async {

    DateTime parsedDate = DateTime(1970, 1, 1);
    String formattedDate ='';

    try {
      var bytes = _file != null ? await _file!.readAsBytes() : _webFile!;
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.keys.isNotEmpty) {
        var table = excel.tables.values.first; // Assuming only one sheet
        var dateColumn = table.cell(CellIndex.indexByString('A2')).value; // Adjust cell index as per your file

        print('dateColumn: ${dateColumn.toString()}');

        String format = detectDateFormat(dateColumn.toString());
        print('Detected date format: $format');//Detected date format: MM/dd/yyyy
        parsedDate = DateFormat(format).parse(dateColumn.toString());
        //print('parsedDate:$parsedDate');
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        //print('formattedDate:$formattedDate');
        //formattedDate:2024-05-20

        setState(() {
          _uploadedDate = formattedDate;
        });
      }
    } catch (e) {
      print('Error reading Excel file: $e');
      setState(() {
        _notificationMessage = 'Error reading Excel file: $e';
      });
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
      return data.isNotEmpty;
    }
    else{
      print('Error checking entries: ${response.statusCode}');
      return false;
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

}
