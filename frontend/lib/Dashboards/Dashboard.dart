import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
//import 'package:my_flutter_app/OTScheduleScreen.dart';
//import 'package:my_flutter_app/TimeMonitoringScreen.dart';
import 'package:my_flutter_app/Dashboards/OTDashboard.dart';
import 'package:my_flutter_app/Dashboards/DoctorDashboard.dart';
import 'package:my_flutter_app/Dashboards/DepartmentDashboard.dart';
import 'package:my_flutter_app/Dashboards/OTStaffDashboard.dart';
import 'package:my_flutter_app/Dashboards/ProcedureDashboard.dart';
import 'package:my_flutter_app/Dashboards/PatientDashboard.dart';

class Dashboard extends StatefulWidget {

  int otCount;
  int doctorsCount;
  int departmentCount;
  int procedureCount;
  int patientCount;
  int otStaffCount;
  Map<String, String> dateRangeMap;
  //Date earliestDate;
  //Date
  Dashboard({required this.otCount, required this.doctorsCount, required this.departmentCount,
    required this.patientCount,
    required this.procedureCount, required this.otStaffCount, required this.dateRangeMap});



  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  String baseUrl = 'http://127.0.0.1:8000/api';
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate ;
  late DateTime selectedToDate;

  late int otCount;
  late int doctorsCount;
  late int departmentCount;
  late int procedureCount;
  late int patientCount;
  late int otStaffCount;

  @override
  void initState() {

    otCount = widget.otCount;
    doctorsCount = widget.doctorsCount;
    departmentCount = widget.departmentCount;
    procedureCount = widget.procedureCount;
    patientCount = widget.patientCount;
    otStaffCount = widget.otStaffCount;
    print('daterange:${widget.dateRangeMap.values}');
    fromDateController = TextEditingController(text: '${widget.dateRangeMap['earliest date']}');
    toDateController = TextEditingController(text: '${widget.dateRangeMap['latest date']}');
    // fromDateController = TextEditingController(text: '');
    // toDateController = TextEditingController(text: '');
    selectedFromDate = DateTime.parse(widget.dateRangeMap['earliest date']!);
    selectedToDate = DateTime.parse(widget.dateRangeMap['latest date']!);

    //_getDateRange();
    super.initState();

    print('otCount-${widget.otCount}' + 'doctorsClount: ${widget.doctorsCount}' + 'departmentCount:${widget.departmentCount}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.only(top: 16), // Add margin only to the top of the text
          child: Text('DASHBOARD'),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Set the height of the divider
          child: Divider(color: Colors.grey), // Divider below the app bar title
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /** From Date*/
                      Container(
                        width: 250,
                        child: TextField(
                          controller: fromDateController,
                          canRequestFocus: false,
                          decoration: InputDecoration(labelText: 'From Date', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          onPressed: () => _selectFromDate(context),
                          icon: Icon(Icons.calendar_month_outlined),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 100),
                      /** To Date */
                      Container(
                        width: 250,
                        child: TextField(
                          controller: toDateController,
                          canRequestFocus: false,
                          decoration: InputDecoration(labelText: 'To Date', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                          onPressed: () => _selectToDate(context),
                          icon: Icon(Icons.calendar_month_outlined),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 30),
                      Container(
                        width: 150,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent,
                                textStyle: TextStyle(color: Colors.white),
                              padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24), ),
                            child: const Text('Apply',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),),
                            onPressed: (){
                              _getOTCount(selectedFromDate, selectedToDate);
                              _getDoctorCount(selectedFromDate,selectedToDate);
                              _getDepartmentCount(selectedFromDate,selectedToDate);
                              _getProcedureCount(selectedFromDate,selectedToDate);
                              _getPatientCount(selectedFromDate,selectedToDate);
                              _getOTStaffCount(selectedFromDate,selectedToDate);

                            }

                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleButton(
                title: "${otCount}",
                label: 'OT',
                circleColor: '#97E7E1',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OTDashboard(selectedFromDate :selectedFromDate, selectedToDate:selectedToDate)));
                },
              ),
              CircleButton(
                title: "${doctorsCount}",
                label: 'Doctors',
                circleColor: '#FFC55A',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      DoctorDashboard(selectedFromDate :selectedFromDate, selectedToDate:selectedToDate)));
                },
              ),
              CircleButton(
                title: "${departmentCount}",
                label: 'Departments',
                circleColor: '#7AA2E3',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      DepartmentDashboard(selectedFromDate :selectedFromDate, selectedToDate:selectedToDate)));
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleButton(
                title: '${procedureCount}',
                label: 'Procedures',
                circleColor: '#FC4100',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      ProcedureDashboard(selectedFromDate :selectedFromDate, selectedToDate:selectedToDate)));
                },
              ),
              CircleButton(
                title: '${patientCount}',
                label: 'Patients',
                circleColor: '#90D26D',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      PatientDashboard(selectedFromDate :selectedFromDate, selectedToDate:selectedToDate)));
                },
              ),
              CircleButton(
                title: '${otStaffCount}',
                label: 'OT Staff',
                circleColor: '#93B1A6',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      OTStaffDashboard(selectedFromDate: selectedFromDate, selectedToDate: selectedToDate)));

                  // Implement onTap for Option 6
                },
              ),

            ],
          ),
        ],
      ),
    );
  }


  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.dateRangeMap['earliest date']!),
      firstDate: DateTime.parse(widget.dateRangeMap['earliest date']!), // Adjust the first and last date according to your needs1
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedFromDate) {
      setState(() {
        selectedFromDate = picked;
        String date = "${selectedFromDate.toLocal()}".split(' ')[0];
        fromDateController?.text = date;
      });
    }else if (picked == null) {
      setState(() {
        selectedFromDate = DateTime.parse(widget.dateRangeMap['earliest date']!); // Set selectedFromDate to an initial value
        fromDateController?.text = '${widget.dateRangeMap['earliest date']}'; // Set the text field to empty
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.parse(widget.dateRangeMap['earliest date']!),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedToDate) {
      setState(() {
        selectedToDate = picked;
        String date = "${selectedToDate.toLocal()}".split(' ')[0];
        toDateController?.text = date;
      });
    }else if (picked == null) {
      setState(() {
        selectedToDate = DateTime.parse(widget.dateRangeMap['latest date']!);
        toDateController?.text = '${widget.dateRangeMap['latest date']}';
      });
    }

    //_setValues(context);
  }

  void _getOTCount(DateTime selectedFromDate, DateTime selectedToDate) async {
    String apiUrl = '$baseUrl/ot-count/';

    print('selectedFromDate $selectedFromDate');
    print('selectedToDate $selectedToDate');


    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

    print('_getOTCount():$apiUrl');


    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle the response data here
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String message = responseData['message'];
      //widget.otCount = int.parse(message.split(':').last.trim());
      print(int.parse(message.split(':').last.trim()));
      // Update the widget's data based on the response
      setState(() {
        //widget.doctorsCount = responseData['doctorsCount'];
        otCount = int.parse(message.split(':').last.trim());
        // Update other counts similarly
      });
    } else {
      // Handle API error
      print('Error fetching data from API: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getDepartmentCount(DateTime selectedFromDate, DateTime selectedToDate) async{

    String apiUrl = '$baseUrl/department-count/';

    print('selectedFromDate $selectedFromDate');
    print('selectedToDate $selectedToDate');

    // Check if both fromDate and toDate are selected
    // Check if both fromDate and toDate are selected
    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }


    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getDepartmentCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      print('_getDepartmentCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      String message = responseData['message'];
      print(int.parse(message.split(':').last.trim()));
      setState(() {
        //widget.doctorsCount = responseData['doctorsCount'];
        departmentCount = int.parse(message.split(':').last.trim());
        // Update other counts similarly
      });

    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }


  void _getDoctorCount(DateTime selectedFromDate, DateTime selectedToDate) async{

    print('selectedFromDate $selectedFromDate');
    print('selectedToDate $selectedToDate');
    String apiUrl = '$baseUrl/doctor-count/';

    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != null) {
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != null) {
      // Format the date to include only the date part (yyyy-MM-dd)
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

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
      print('doctors Count: ${int.parse(message.split(':').last.trim())}');
      setState(() {
        //widget.doctorsCount = responseData['doctorsCount'];
        //widget.doctorsCount = int.parse(message.split(':').last.trim());
        // Update other counts similarly
        doctorsCount = int.parse(message.split(':').last.trim());
      });

    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

  }

  void _getPatientCount(DateTime selectedFromDate, DateTime selectedToDate) async {
    //String apiUrl = '$baseUrl/procedure-count/';
    String apiUrl = '$baseUrl/patient-count/';

    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

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
          if (item is Map<String, dynamic> && item.containsKey('total_patients')) {
            setState(() {
              //widget.doctorsCount = responseData['doctorsCount'];
              //widget.patientCount = item['total_patients'];
              patientCount = item['total_patients'];
              print('patientCount $widget.patientCount');
              // Update other counts similarly
            });
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


  void _getOTStaffCount(DateTime selectedFromDate, DateTime selectedToDate) async {
    String apiUrl = '$baseUrl/ot_staff_count/';
    //String apiUrl = '$baseUrl/patient-count/';

    String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
    String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
    apiUrl += '?start_date=$fromDate&end_date=$toDate';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getOTStaffCount(): Data Received from the backend successfully.');

      print(jsonDecode(response.body).runtimeType);

      Map<String,dynamic> responseData = jsonDecode(response.body);
      print(responseData['message']);
      // Extract the count value from the message
      //List<dynamic> message = responseData['message'];
      otStaffCount = int.parse(responseData['message'].toString().split(':').last.trim());
      print('otstaffCount:$otStaffCount');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getProcedureCount(DateTime selectedFromDate, DateTime selectedToDate) async{

    String apiUrl = '$baseUrl/procedure-count/';
    //String apiUrl = '$baseUrl/patient-count/';

    print('selectedFromDate $selectedFromDate');
    print('selectedToDate $selectedToDate');


    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
      String fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      String toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

    print('dashboard_getProcedureCount:$apiUrl');
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getProcedureCount(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      //print('_getProcedureCount()-Response body: ${response.body}');
      //Parse the JSON response
      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      // Extract the count value from the message
      List<dynamic> message = responseData['message'];
      if (message.isNotEmpty) {
        String countString = message[0].values.first.toString(); // Extract the string with the count
        String numberString = countString.replaceAll(RegExp(r'[^0-9]'), ''); // Remove non-numeric characters
        print('procedureCount: ${int.tryParse(numberString) ?? 0}');
        setState(() {
          //widget.doctorsCount = responseData['doctorsCount'];
          procedureCount = int.tryParse(numberString) ?? 0;
          // Update other counts similarly
        });
         // Parse the number, default to 0 if parsing fails

        print('Procedure Count: $widget.procedureCount');
      } else {
        print('No data found in the message.');
      }
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }


  }


// void _setValues(BuildContext context) async{
  //
  //   String apiUrl = '$baseUrl/ot-count/';
  //
  //   final response = await http.get(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     print('Data Received from the backend successfully.');
  //     // Optionally, handle the response from the backend if needed
  //     print('Response body: ${response.body}');
  //     final List<dynamic> data = json.decode(response.body);
  //     print('Response body: ${data}');
  //
  //   } else {
  //     //print('Error sending data to the backend: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //   }
  // }

}

class CircleButton extends StatelessWidget {
  final String title;
  final String label;
  final VoidCallback? onTap; // Make onTap nullable
  final String circleColor; // Add the circleColor parameter

  const CircleButton({Key? key, required this.title, required this.label, this.onTap, required this.circleColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Use onTap as provided
      child: Column(
        children: [
          Container(
            width: 175,
            height: 175,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(int.parse(circleColor.replaceAll('#', '0xFF'))), // Use the provided circleColor
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
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
