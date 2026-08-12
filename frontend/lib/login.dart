import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/Dashboards/Dashboard.dart';
import 'package:my_flutter_app/Dashboards/Dashboard2.dart';
import 'package:my_flutter_app/MenuPage.dart';
import 'package:my_flutter_app/OTSchedule/SchedulerInput.dart';
import 'package:my_flutter_app/TimeMonitoring/PatientListScreen.dart';
import 'package:my_flutter_app/OTSchedule/OTScheduleScreen.dart';
import 'package:my_flutter_app/config/constants.dart';
import 'package:my_flutter_app/register.dart';
import 'package:http/http.dart' as http;

import 'TimeMonitoring/PatientListScreen2.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //static const String _title = 'Sample App';
  //String baseUrl = 'http://127.0.0.1:8000/api';
  int otCount = 0;
  int doctorsCount = 0;
  int departmentCount = 0;
  int procedureCount = 0;
  int patientCount = 0;
  int otstaffCount = 0;
  Map<String, String> dateRangeMap = {};
  String baseUrl = Constants.baseURL;

  bool _passwordVisible = false;


  @override
  void initState() {
    super.initState();
    _passwordVisible = false;

    _getDateRange();
    _getOTCount();
    _getDoctorsCount();
    _getDepartmentCount();
    _getProcedureCount();
    _getPatientCount();
    _getOTStaffCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[

            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(150, 10, 150, 0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg', // Path to your logo image asset
                    width: 180, // Adjust the width as needed
                    height: 180, // Adjust the height as needed
                  ),
                  const SizedBox(height: 10), // Add spacing between logo and text
                  const Text(
                    'AMRITA  OT-SCHEDULER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(150, 10, 150, 0),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(150, 60, 150, 0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(150, 30, 150, 0),
              child: TextField(
                obscureText: !_passwordVisible,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height:25),
            Container(
                height: 50,
                //width: 25,
                padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent,
                  textStyle: TextStyle(color: Colors.white)),
                  child: const Text('Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),),
                  onPressed: () async {

                    String user_type = await _validateuser(nameController.text, passwordController.text);
                    // String username = nameController.text.trim();
                    //
                    // // Check for specific usernames
                    print(user_type);
                    if (user_type == 'Nurse' || user_type == 'Technician') {
                      nameController.clear();
                      passwordController.clear();
                      // Navigate to OTScheduleScreen if the username matches
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PatientListScreen2()),
                      );

                    } else if (user_type == 'OT Administration') {
                      nameController.clear();
                      passwordController.clear();
                      // Navigate to PatientListScreen for other usernames
                      Navigator.push(
                        context,
                         //MaterialPageRoute(builder: (context) => MenuPage()),
                        MaterialPageRoute(builder: (context) => SchedulerInput()),
                        //MaterialPageRoute(builder: (context) => Dashboard2()),
                      );
                    }

                    else if (user_type == 'Management') {
                      nameController.clear();
                      passwordController.clear();
                      // Navigate to PatientListScreen for other usernames
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Dashboard2(
                                otCount: otCount,
                                doctorsCount: doctorsCount,
                                departmentCount: departmentCount,
                                procedureCount: procedureCount,
                                patientCount: patientCount,
                                otStaffCount: otstaffCount,
                                dateRangeMap: dateRangeMap))
                        //MaterialPageRoute(builder: (context) => Dashboard(otCount: otCount, doctorsCount: doctorsCount, departmentCount: departmentCount, patientCount: patientCount, procedureCount: procedureCount, otStaffCount: otStaffCount, dateRangeMap: dateRangeMap)),
                      );
                    }

                  },
                )
            ),
            Row(
              children: <Widget>[
                const Text('Does not have account?'),
                TextButton(
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 20,decoration: TextDecoration.underline),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Register(),
                      ),
                    );
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
        ));
  }

  Future<String> _validateuser(String email, String password) async {
    String apiUrl = '$baseUrl/login/';
    String user_type ='';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('login successful!');
        print('response_login(): ${response.body}');
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('jsonResponse(): ${jsonResponse}');
        if(jsonResponse.containsKey('user')){
          print(jsonResponse['user'].runtimeType);
          user_type = jsonResponse['user']['user_type'];
        }
      }
      else{
        print('login failed. Status code: ${response.statusCode}');
        showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please enter valid credentials'),
            //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
            actions: <Widget>[TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),],
          );
        });
      }
      //return user_type;
    }
    catch (e){
      print('Error sending request: $e');
    }
    return user_type;
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

  void _getOTCount() async {
    String apiUrl = '$baseUrl/ot-count/';

    String selectedFromDate = dateRangeMap['earliest date'] ?? '';
    print('selectedFromDate:$selectedFromDate');

    // String fromDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateRangeMap['earliest date']!));
    // String toDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(dateRangeMap['latest date']!));
    // apiUrl += '?start_date=$fromDate&end_date=$toDate';

    print('Login-page():$apiUrl');

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
}
