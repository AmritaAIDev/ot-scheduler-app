import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/OTSchedule/OTScheduleListScreen.dart';
import 'package:my_flutter_app/OTSchedule/SchedulerOutput.dart';
import 'package:my_flutter_app/OTSchedule/pastSurgeries.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:my_flutter_app/config/customThemes/elevatedButtonTheme.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/surgery_models.dart';

class SchedulerInput extends StatefulWidget {
  @override
  _SchedulerInputState createState() => _SchedulerInputState();
}

class _SchedulerInputState extends State<SchedulerInput> {
  DateTime selectedDate = DateTime.now();
  bool isDateSelected = true;
  static const double leftMargin = 180;
  static const double rightMargin = 180;
  static const double gap = 20;
  String displayText1 = 'Schedule all operation';
  String displayText2 =
      'Select a date and upload a Excel file to schedule the procedure.';
  String displayText3 =
      "Please upload a Excel file. The file should contain all the necessary information for the operation,"
      " including patient, doctor, and equipment details.";
  String uploadFileText = 'Upload your file here';

  //String baseUrl = 'http://127.0.0.1:8000/api';

  File? _file;
  Uint8List? _webFile;
  String _notificationMessage = '';
  String _uploadedDate = '';
  String baseUrl = 'http://10.125.11.203:8091/api';
  List<dynamic> previousScheduledData = [];

  var uploadButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            left: leftMargin, right: rightMargin, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayText1,
                        style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    Text(displayText2,
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey[600])),
                    Divider(color: Colors.blueGrey[50], thickness: 2),
                  ],
                )),
            //SizedBox(height: 1),

            SizedBox(height: 15),
            Center(
              child: Column(
                children: [
                  Container(width: 520, child: _buildCalendar()),
                  // SizedBox(height: gap),
                  // _buildUploadButton(),
                  SizedBox(height: gap),
                  _buildFileDropArea(),
                  SizedBox(height: gap),
                  Text(
                    displayText3,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: isDateSelected
                        ? () {
                      _handleOTScheduleButtonPress();
                    }
                        : () {
                      _viewPastHistory();
                    },
                    style: MyElevatedButtonTheme.elevatedButtonTheme1.style,
                    child: isDateSelected
                        ? Text(
                      'Schedule',
                      style: TextStyle(color: Colors.white),
                    )
                        : Text(
                      'View Past Surgeries',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    DateTime currentDay =
    DateTime(DateTime
        .now()
        .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day);
    DateTime nextDay =
    DateTime(currentDay.year, currentDay.month, currentDay.day + 7);

    return Column(
      children: [
        // Text(DateFormat.yMMMM().format(selectedDate), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // SizedBox(height: 10),
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime(2024),
          lastDay: DateTime(2030),
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              selectedDate = selectedDay;
              print('onDaySelected:selectedDate :$selectedDate');
              print('onDaySelected:selectedDay :$selectedDay');
              if (selectedDay.isBefore(DateTime(
                  currentDay.year, currentDay.month, currentDay.day))) {
                print('Selected date is before currentDay.');
                isDateSelected = false;
              } else {
                isDateSelected = true;
              }
            });
          },
          headerStyle: HeaderStyle(
              formatButtonVisible: false, // This hides the "2 weeks" button
              titleCentered: true,
              titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold) // Keep the title centered
          ),
          enabledDayPredicate: (day) {
            // Enable only dates till tomorrow
            return day.isBefore(nextDay.add(Duration(days: 1)));
          },
        ),
      ],
    );
  }

  Widget _buildFileDropArea() {
    return DottedBorder(
      color: Colors.blueGrey[200]!,
      strokeWidth: 2,
      dashPattern: [6, 6],
      borderType: BorderType.RRect,
      radius: Radius.circular(10),
      child: Container(
        height: 120,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(uploadFileText, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 10),
            ElevatedButton(
              //key: uploadButton,
              onPressed: isDateSelected
                  ? () {
                // Handle file browsing
                _pickFile();
              }
                  : null,
              //Colors.grey[200],
              style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
              child: Text('Upload file', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  //
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (kIsWeb) {
          Uint8List fileBytes = result.files.single.bytes!;

          try {
            final outputBytes = await generateSurgeryExcel(
              fileBytes,
              result.files.single.name,
            );
            _webFile = Uint8List.fromList(outputBytes);
            setState(() {
              _notificationMessage =
              'File Processed: ${result.files.single.name}';
              uploadFileText = _notificationMessage;
            });
          } catch (e) {
            print('Error converting file: $e');
            // Fallback or error handling
            _webFile = fileBytes;
            setState(() {
              _notificationMessage =
              'Error processing file, using raw: ${result.files.single.name}';
            });
          }

          _extractDateFromFile();
        } else {
          _file = File(result.files.single.path!);
          setState(() {
            _notificationMessage = 'File Uploaded: ${_file!.path}';
            uploadFileText = _notificationMessage;
          });
        }
      } else {
        setState(() {
          _notificationMessage = 'No file selected';
          uploadFileText = _notificationMessage;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      setState(() {
        _notificationMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _extractDateFromFile() async {
    DateTime parsedDate = DateTime.now();
    String formattedDate = '';

    try {
      var bytes = _file != null ? await _file!.readAsBytes() : _webFile!;
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.keys.isNotEmpty) {
        var table = excel.tables.values.first; // Assuming only one sheet
        var dateColumn = table
            .cell(CellIndex.indexByString('A2'))
            .value; // Adjust cell index as per your file

        print('dateColumn: ${dateColumn.toString()}');

        String format = detectDateFormat(dateColumn.toString());
        print(
            'Detected date format: $format'); //Detected date format: MM/dd/yyyy
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


  String detectDateFormat(String dateString) {
    List<String> dateFormats = [
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd",
      "MM/dd/yyyy",
      "dd/MM/yyyy",
      "dd-MM-yyyy",
      "yyyy/MM/dd",
      // Add more formats as needed
    ];

    for (String format in dateFormats) {
      try {
        DateFormat dateFormat = DateFormat(format);
        dateFormat.parseStrict(
            dateString); // If parsing succeeds, the format is correct
        return format; // Return the format that successfully parsed the date
      } catch (e) {
        // Continue to the next format if parsing fails
      }
    }

    throw FormatException("Unknown date format: $dateString");
  }

  void _handleOTScheduleButtonPress() async {
    setState(() {
      _notificationMessage = ' '; // Show processing message
      // _webFile = null;
      // _file = null;
    });

    print(_file);
    try {
      print('_selectedDate: $selectedDate');
      print('_uploadedDate: $_uploadedDate');
      String formattedDate = selectedDate.toString().split(' ')[0];
      print('formattedDate:$formattedDate');
      if (formattedDate != _uploadedDate) {
        // setState(() {
        //   _notificationMessage = 'Selected date does not match date in the uploaded file';
        // });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
                'Selected date does not match date in the uploaded file.Please select correct date'),
          ),
        );
        return;
      }

      // if (_file ==null) {
      //   // setState(() {
      //   //   _notificationMessage = 'Selected date does not match date in the uploaded file';
      //   // });
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       backgroundColor: Colors.redAccent,
      //       content:
      //       Text('Please upload the file'),
      //     ),
      //   );
      //   return;
      // }

      List<int> fileBytes =
      _file != null ? await _file!.readAsBytes() : _webFile!;
      String base64File = base64Encode(fileBytes);

      // Check if entries exist for the _uploadedDate
      // bool entriesExist = await _checkEntriesExist(_uploadedDate);
      // if (entriesExist) {
      //   // Delete existing entries
      //   await _deleteEntriesFromSchedule(_uploadedDate);
      //   await _deleteEntriesFromPatients(_uploadedDate);
      // }

      // String apiUrl =
      //     'https://us-central1-amrita-body-scan.cloudfunctions.net/OT_Scheduler';
      String apiUrl =
          'https://us-central1-amrita-body-scan.cloudfunctions.net/OTSchedulerv2';
      //ot-schedule/
      //String apiUrl = '$baseUrl/ot-schedule/';
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
        print('jsonResponse: ${jsonResponse}');

        setState(() {
          //_notificationMessage = ' '; // Show processing message
          _webFile = null;
          _file = null;
          uploadFileText = 'Upload your file here';
          //isDateSelected = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            //OTScheduleListScreen(scheduleData: jsonResponse),
            SchedulerOutput(scheduleData: jsonResponse),
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
        Map<String, dynamic> specialEquipment =
        jsonResponse['Special Equipment'];
        print("Date:${date['0']}");
        print("Date-runtimeType:${date['0'].runtimeType}");
        //print(mrdNumbers.values);
        //print('nursingLeads $nursingLeads');

        // for (var key in otData.keys) {
        //   // scheduledOTList[otData[key].toString()] = department[key];
        //   sendScheduledOT(otData[key].toString(), department[key]);
        //   //print('${otData[key]} : ${depart[key]} | ');
        // }
        //print(scheduledOTList);

        //API for Doctor
        // for (var key in doctor.keys) {
        //   await Future.delayed(Duration(milliseconds: 500));
        //   sendDoctorList(doctor[key].toString(), department[key]);
        // }

        //API call for procedure_list
        // for (var key in procedure.keys) {
        //   await Future.delayed(Duration(milliseconds: 600));
        //
        //   var duration = calculateDuration(end_time[key], start_time[key]);
        //   //print('duration - $duration');
        //   // duration = parseTime(end_time[key]).
        //   sendProcedureList(
        //       procedure[key].toString(), department[key].toString(), duration);
        // }

        //API for patient
        // for (var key in patient.keys) {
        //   //print('age-${jsonResponse['Age/Sex'][key].toString().split('/')[0].split('Y')[0]}');
        //   // Introduce a delay of 1000 milliseconds (1 second)
        //   await Future.delayed(Duration(milliseconds: 500));
        //   sendPatientList(patient[key].toString(), age[key].split('/')[0],
        //       age[key].split('/')[1], mrdNumbers[key], date[key]);
        // }

        //API for OT staff
        // for (var key in nursingLeads.keys) {
        //   await Future.delayed(Duration(milliseconds: 500));
        //   sendOtStafffList(nursingLeads[key], department[key], 'Nursing T/L');
        // }

        // for (var key in technicalLeads.keys) {
        //   await Future.delayed(Duration(milliseconds: 500));
        //   sendOtStafffList(technicalLeads[key], department[key], 'Technical T/L');
        // }

        //print(patient_id);
        //API for scheduled surgeries
        //DateFormat format = DateFormat('MM/dd/yy');
        //DateFormat inputFormat = DateFormat('dd/MM/yyyy');

        // for (var key in procedure.keys) {
        //   //print('age-${jsonResponse['Age/Sex'][key].toString().split('/')[0].split('Y')[0]}');
        //   // Introduce a delay of 1000 milliseconds (1 second)
        //   // print('date: ${inputFormat.parse((date[key]))}');
        //   // print('Data type of date[key]: ${inputFormat.parse(date[key])}');
        //   await Future.delayed(Duration(milliseconds: 500));
        //   //deleteEntries(date[key]);
        //   sendScheduleSurgery(
        //     procedure[key],
        //     department[key],
        //     doctor[key],
        //     patient[key],
        //     mrdNumbers[key].toString(),
        //     date[key],
        //     start_time[key],
        //     end_time[key],
        //     otData[key],
        //     technicalLeads[key],
        //     nursingLeads[key],
        //     specialEquipment[key],
        //
        //   );
        // }
      } else {
        setState(() {
          _notificationMessage =
          'Error: ${response
              .statusCode}'; // Update notification message with error
        });
        // print('Error-1: ${response.statusCode}');
        // print('Response body-1: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _notificationMessage =
        'Error: $e'; // Update notification message with error
      });
      print('Error-2 -: $e');
    }
  }

  Future<void> _deleteEntriesFromSchedule(String uploadedDate) async {
    String apiUrl = '$baseUrl/schedule/';
    String deleteUrl =
        apiUrl + 'delete-all-on-date/?surgery_date=$uploadedDate';
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

  Future<void> _deleteEntriesFromPatients(String uploadedDate) async {
    String apiUrl = '$baseUrl/patient/';
    String deleteUrl =
        apiUrl + 'delete-all-on-date/?registration_date=$uploadedDate';
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

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        previousScheduledData = data;
      });
      print('_checkEntriesExist():$data');
      return data.isNotEmpty;
    } else {
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

  void sendOtStafffList(String staff_name, String department,
      String designation) async {
    String apiUrl = '$baseUrl/otstaff/';

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ot_staff_name': staff_name,
        'ot_staff_department': department,
        'ot_staff_designation': designation
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('otStafffList():Data sent to the backend successfully.');
      // Optionally, handle the response from the backend if needed
    } else {
      print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void sendPatientList(String name, String age, String gender, int mrd,
      String surgeryDate) async {
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
        'registration_date': surgeryDate
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

  void sendProcedureList(String procedure_name, String department,
      double duration) async {
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

  void sendScheduleSurgery(procedure,
      department,
      doctor,
      patient,
      mrd,
      date,
      start_time,
      end_time,
      otData,
      technician_tl,
      nurse_tl,
      specialEquipment) async {
    String apiUrl = '$baseUrl/schedule/';
    print(
        'DateFormat:${DateFormat('MM/dd/yyyy').parse(date).toString().split(
            ' ')[0]}');

    // print('sendScheduleSurgery:$apiUrl');
    // print('sendScheduleSurgery()-date:${date.runtimeType} ${DateTime.parse(date)}');

    String formattedDate =
    DateFormat('MM/dd/yyyy').parse(date).toString().split(' ')[0];
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

  _viewPastHistory() async {
    String parsedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    //DateFormat('MM/dd/yyyy').parse(date).toString().split(' ')[0]}'
    if (await _checkEntriesExist(parsedDate)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
            //OTScheduleListScreen(scheduleData: jsonResponse),
            PastSurgeries(previousScheduledData, selectedDate)),
      );
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Surgeries Scheduled'),
              //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme
                        .of(context)
                        .textTheme
                        .labelLarge,
                  ),
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //print(widget.surgeryId);
                    //Navigator.of(context).pop('${widget.surgeryId} is done');
                    //Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  String determineSpecialty(String surgeon, String procedure) {
    print("surgeon:${surgeon}");
    print("procedure:${procedure}");
    String lowerSurgeon = surgeon.toLowerCase();
    String lowerProcedure = procedure.toLowerCase();

    if (lowerSurgeon.contains('ortho') || lowerProcedure.contains('fracture') ||
        lowerProcedure.contains('acl') || lowerProcedure.contains('tkr') ||
        lowerProcedure.contains('thr')) return 'Orthopaedics';
    if (lowerSurgeon.contains('gyn') ||
        lowerProcedure.contains('hysteroscopy') ||
        lowerProcedure.contains('lscs')) return 'Gynaecology';
    if (lowerSurgeon.contains('uro') || lowerProcedure.contains('turp') ||
        lowerProcedure.contains('rirs') || lowerProcedure.contains('pcnl'))
      return 'Urology';
    if (lowerSurgeon.contains('ent') ||
        lowerProcedure.contains('septoplasty') ||
        lowerProcedure.contains('tonsil')) return 'ENT';
    if (lowerSurgeon.contains('eye') || lowerProcedure.contains('phaco') ||
        lowerProcedure.contains('cataract')) return 'Ophthalmology';
    if (lowerSurgeon.contains('plastic') || lowerProcedure.contains('flap') ||
        lowerProcedure.contains('graft')) return 'Plastic Surgery';
    if (lowerSurgeon.contains('onco') || lowerProcedure.contains('mastectomy'))
      return 'Oncology';
    if (lowerSurgeon.contains('neuro') ||
        lowerProcedure.contains('craniotomy') ||
        lowerProcedure.contains('spine')) return 'Neurosurgery';
    if (lowerSurgeon.contains('cardio') || lowerProcedure.contains('cabg') ||
        lowerProcedure.contains('valve')) return 'Cardiology';
    if (lowerSurgeon.contains('peds') || lowerSurgeon.contains('paed'))
      return 'Paediatrics';
    if (lowerSurgeon.contains('gastro') ||
        lowerProcedure.contains('cholecystectomy') ||
        lowerProcedure.contains('lap')) return 'Gastroenterology';

    return 'General Surgery'; // Default
  }

  String normalizeAge(String rawAge) {
      if (rawAge.isEmpty) return '';
      rawAge = rawAge.trim().toUpperCase();
      
      // Handle Months
      if (rawAge.contains('M') || rawAge.contains('MONTH')) {
         final numericPart = RegExp(r'(\d+[\.\d]*)').firstMatch(rawAge)?.group(1);
         if (numericPart != null) {
            double months = double.parse(numericPart);
            double years = months / 12.0;
            // Format to max 1 decimal place, remove .0 if integer
            String yearsStr = years.toStringAsFixed(1);
            if(yearsStr.endsWith('.0')) yearsStr = yearsStr.replaceAll('.0', '');
            return '${yearsStr}Y';
         }
      }
      
      // Handle Years (standardize format)
      if (rawAge.contains('Y') || RegExp(r'^\d+$').hasMatch(rawAge)) {
          final numericPart = RegExp(r'(\d+[\.\d]*)').firstMatch(rawAge)?.group(1);
          if (numericPart != null) {
              return '${numericPart}Y';
          }
      }
      
      return rawAge; // Return raw if parsing fails
  }

  String normalizeSex(String rawSex) {
      if (rawSex.isEmpty) return '';
      rawSex = rawSex.trim().toUpperCase();
      if (rawSex.startsWith('M')) return 'M';
      if (rawSex.startsWith('F')) return 'F';
      return rawSex;
  }

  Future<List<int>> generateSurgeryExcel(
      List<int> inputFileBytes, String inputFileName) async {
    try {
      // Parse input Excel file
      var excel = Excel.decodeBytes(inputFileBytes);
      // Assuming the first sheet is the one we want
      var sheet = excel.tables[excel.tables.keys.first]!;

      // Extract date from filename (assuming format: OT LIST 02-01-2026.xlsx)
      // Attempt to find a date pattern in DD-MM-YYYY or YYYY-MM-DD
      final dateMatch = RegExp(r'(\d{2}-\d{2}-\d{4})').firstMatch(inputFileName);
      String surgeryDate;
      if (dateMatch != null) {
         surgeryDate = dateMatch.group(1)!;
      } else {
         // Fallback: try to find date in the first few rows?
         // For now defaulting to today or a placeholder if not found, 
         // but ideally we should parse it from the file content if possible.
         // Let's try to find a date cell in the first 5 rows/cols
         DateTime now = DateTime.now();
         surgeryDate = DateFormat('dd-MM-yyyy').format(now); 
         for(var i=0; i<5; i++) {
            if(i >= sheet.rows.length) break;
            for(var cell in sheet.rows[i]) {
               if(cell?.value != null) {
                  String val = cell!.value.toString();
                   if(RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(val)) {
                      surgeryDate = RegExp(r'\d{2}-\d{2}-\d{4}').firstMatch(val)!.group(0)!;
                      break;
                   }
               }
            }
         }
      }

      List<SurgeryData> surgeries = [];

      // Process each row (skip header rows)
      // Starting from row 2 (index 2, so 3rd row) based on previous code view, 
      // but let's be safe and check where data starts.
      // The user says "Raw File inputs", usually headers are on row 1 (index 1) or row 0.
      // Based on previous code, it started at index 2.
      for (int rowIndex = 2; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];

        // Skip empty rows or rows with insufficient columns
        if (row.isEmpty || row.length < 10) continue; 
        
        // Sr No is usually column 0. If it's empty, might be a separator line.
        final srNo = row[0]?.value?.toString() ?? '';
        if (srNo.isEmpty) continue;

        // Check columns based on assumed indices:
        // 0: Sr
        // 1: Time?
        // 2: UHID
        // 3: Name
        // 4: Age
        // 5: Sex
        // 9: Procedure
        // 10: Surgeon
        // 16: Remarks
        
        final uhid = row[2]?.value?.toString() ?? '';
        final patientName = row[3]?.value?.toString() ?? '';
        final rawAge = row[4]?.value?.toString() ?? '';
        final rawSex = row[5]?.value?.toString() ?? '';
        final procedure = row[9]?.value?.toString() ?? '';
        final surgeon = row[10]?.value?.toString() ?? '';
        final specialRequest = row.length > 16 ? (row[16]?.value?.toString() ?? '') : '';

        // Skip rows that look like headers inside the list (e.g. "OT 2")
        if (patientName.toLowerCase().contains('patient') || procedure.toLowerCase().contains('surgery')) continue;

        // --- Data Cleaning & Validation ---
        
        // Normalize Age and Sex
        String normalizedAge = normalizeAge(rawAge);
        String normalizedSex = normalizeSex(rawSex);
        String ageSex = '$normalizedAge/$normalizedSex';

        // Strict Validation Rule: "aY/M" or "aY/F"
        // Regex: Number (int or float) + Y + / + M or F
        if (!RegExp(r'^[\d\.]+Y\/[MF]$').hasMatch(ageSex)) {
           // Skip Invalid Rows
           print('Skipping Invalid Row: $ageSex ($patientName)');
           continue;
        }

        //temp method for time-being till we get speciality in the raw file
        String speciality = determineSpecialty(surgeon, procedure);

        surgeries.add(SurgeryData(
          dateOfSurgery: surgeryDate,
          ageSex: ageSex,
          surgery: procedure,
          surgeon: surgeon,
          speciality: speciality,
          patientName: patientName,
          specialRequest: specialRequest,
          mrdNumber: uhid,
        ));
      }

      // Create new Excel file
      final newExcel = Excel.createExcel();
      // Rename default sheet
      final newSheet = newExcel['Sheet1'];
      newExcel.rename('Sheet1', 'Surgery Report');

      dynamic surgerySheet = newExcel['Surgery Report'];

      // Create headers
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
      for (int i = 0; i < surgeries.length; i++) {
        dynamic surgery = surgeries[i];
        final r = i + 2;
        surgerySheet
            .cell(CellIndex.indexByString('A$r'))
            .value = TextCellValue(surgery.dateOfSurgery);
        surgerySheet
            .cell(CellIndex.indexByString('B$r'))
            .value = TextCellValue(surgery.ageSex);
        surgerySheet
            .cell(CellIndex.indexByString('C$r'))
            .value = TextCellValue(surgery.surgery);
        surgerySheet
            .cell(CellIndex.indexByString('D$r'))
            .value = TextCellValue(surgery.surgeon);
        surgerySheet
            .cell(CellIndex.indexByString('E$r'))
            .value = TextCellValue(surgery.speciality);
        surgerySheet
            .cell(CellIndex.indexByString('F$r'))
            .value = TextCellValue(surgery.patientName);
        surgerySheet
            .cell(CellIndex.indexByString('G$r'))
            .value = TextCellValue(surgery.specialRequest);
        surgerySheet
            .cell(CellIndex.indexByString('H$r'))
            .value = TextCellValue(surgery.mrdNumber);
      }

      // Save and return the file bytes
      return newExcel.save()!;
    } catch (e) {
      print('Error generating Excel: $e');
      throw Exception('Uncaught Error generating Excel: $e');
    }
  }
}