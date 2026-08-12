import 'dart:convert';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/Dashboards/Dashboard2.dart';
import 'package:my_flutter_app/OTSchedule/OTScheduleScreen.dart';
import 'package:my_flutter_app/Dashboards/Dashboard.dart';
//import 'package:my_flutter_app/TimeMonitoringScreen.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/OTSchedule/SchedulerInput.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String baseUrl = 'http://127.0.0.1:8000/api';
  int otCount = 0;
  int doctorsCount = 0;
  int departmentCount = 0;
  int procedureCount = 0;
  int patientCount = 0;
  int otstaffCount = 0;
  Map<String, String> dateRangeMap = {};

  //const MenuPage({Key? key}) : super(key: key);

  @override
  void initState() {
    super.initState();
    _getDateRange();
    _getOTCount();
    _getDoctorsCount();
    _getDepartmentCount();
    _getProcedureCount();
    _getPatientCount();
    _getOTStaffCount();

    // Initialization code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      //backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          children: <Widget>[
            // Image banner section
            // Container(
            //   margin: EdgeInsets.only(bottom: 20.0),
            //   child: Image.network(
            //     'https://via.placeholder.com/400x150', // Replace with your image URL
            //     fit: BoxFit.cover,
            //   ),
            // ),
            // Container(
            //   margin: EdgeInsets.only(bottom: 20.0),
            //   child: Image.network(
            //     'https://via.placeholder.com/400x150', // Replace with your image URL
            //     fit: BoxFit.cover,
            //   ),
            // ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CircleButton(
                    title: 'OT Schedule',
                    myColor: '#97E7E1',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              //builder: (context) => OTScheduleScreen()));
                              builder: (context) => SchedulerInput()));
                    },
                  ),
                  SizedBox(height: 20),
                  CircleButton(
                    title: 'Time Monitor',
                    myColor: '#FFC55A',
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => TimeMonitoringScreen()));
                    },
                  ),
                  SizedBox(height: 20),
                  CircleButton(
                    title: 'Dashboard',
                    myColor: '#7AA2E3',
                    onTap: () {
                      //Navigator.push(
                          //context,
                          // MaterialPageRoute(
                          //     builder: (context) => Dashboard(
                          //         otCount: otCount,
                          //         doctorsCount: doctorsCount,
                          //         departmentCount: departmentCount,
                          //         procedureCount: procedureCount,
                          //         patientCount: patientCount,
                          //         otStaffCount: otstaffCount,
                          //         dateRangeMap: dateRangeMap))
                                  
                      //MaterialPageRoute(builder: (context)=> Dashboard2())
                      //);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getOTCount() async {
    String apiUrl = '$baseUrl/ot-count/';

    String selectedFromDate = dateRangeMap['earliest date'] ?? '';
    print('selectedFromDate:$selectedFromDate');

    // String fromDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateRangeMap['earliest date']!));
    // String toDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateRangeMap['latest date']!));
    // apiUrl += '?start_date=$fromDate&end_date=$toDate';

    print('Menu-page():$apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      String message = responseData['message'];
      otCount = int.parse(message.split(':').last.trim());
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getDoctorsCount() async {
    String apiUrl = '$baseUrl/doctor-count/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getDoctorsCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('_getDoctorsCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      String message = responseData['message'];
      doctorsCount = int.parse(message.split(':').last.trim());
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getDepartmentCount() async {
    String apiUrl = '$baseUrl/department-count/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          '_getDepartmentCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('_getDepartmentCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      String message = responseData['message'];
      departmentCount = int.parse(message.split(':').last.trim());
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getProcedureCount() async {
    String apiUrl = '$baseUrl/procedure-count/';
    //String apiUrl = '$baseUrl/patient-count/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          '_getProcedureCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      //print('_getProcedureCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      List<dynamic> message = responseData['message'];
      if (message.isNotEmpty) {
        String countString = message[0]
            .values
            .first
            .toString(); // Extract the string with the count
        String numberString = countString.replaceAll(
            RegExp(r'[^0-9]'), ''); // Remove non-numeric characters
        procedureCount = int.tryParse(numberString) ??
            0; // Parse the number, default to 0 if parsing fails

        print('Procedure Count: $procedureCount');
      } else {
        print('No data found in the message.');
      }
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getOTStaffCount() async {
    String apiUrl = '$baseUrl/ot_staff_count/';
    //String apiUrl = '$baseUrl/patient-count/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getProcedureCount(): Data Received from the backend successfully.');

      print(jsonDecode(response.body).runtimeType);

      Map<String,dynamic> responseData = jsonDecode(response.body);
      print(responseData['message']);
      // Extract the count value from the message
      //List<dynamic> message = responseData['message'];
      otstaffCount = int.parse(responseData['message'].toString().split(':').last.trim());
      print('otstaffCount:$otstaffCount');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getPatientCount() async {
    //String apiUrl = '$baseUrl/procedure-count/';
    String apiUrl =
        '$baseUrl/patient-count/?start_date=2023-08-15&end_date=2024-04-26';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getPatientCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('_getPatientCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      List<dynamic> messageList = responseData['message'];
      print(messageList);

      if (messageList.isNotEmpty) {
        // Iterate through the message list to find the "total_patients" value
        //int? totalPatients;
        for (dynamic item in messageList) {
          if (item is Map<String, dynamic> &&
              item.containsKey('total_patients')) {
            patientCount = item['total_patients'];
            break; // Exit the loop once "total_patients" is found
          }
        }
      } else {
        print('No data found in the message list.');
      }
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getDateRange() async {
    String apiUrl = '$baseUrl/date-range/';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getDateRange(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('_getDateRange()-Response body: ${response.body}');

      List<dynamic> responseData = jsonDecode(response.body);

      // Create a Map to store the date range

      // Iterate through the response data and extract values
      responseData.forEach((dynamic item) {
        if (item is Map<String, dynamic>) {
          item.forEach((key, value) {
            // handled edge case if earliest date and latest date is null
            // as for null values error screen was being shown
            if (value == null) {
              if (key == 'earliest date') {
                dateRangeMap[key] = "2023-01-01";
              } else if (key == 'latest date') {
                dateRangeMap[key] = "2024-01-01";
              }
            } else {
              dateRangeMap[key] =
                  value.toString(); // Convert value to String if needed
            }
          });
        }
      });

      print(dateRangeMap.values);

      // if (messageList.isNotEmpty) {
      //   // Iterate through the message list to find the "total_patients" value
      //   //int? totalPatients;
      //   for (dynamic item in messageList) {
      //     if (item is Map<String, dynamic> && item.containsKey('total_patients')) {
      //       patientCount = item['total_patients'];
      //       break; // Exit the loop once "total_patients" is found
      //     }
      //   }
      //
      // } else {
      //   print('No data found in the message list.');
      // }
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}

class CircleButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String myColor;

  const CircleButton(
      {Key? key,
      required this.title,
      required this.onTap,
      required this.myColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(int.parse(myColor.replaceAll('#', '0xFF'))),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
