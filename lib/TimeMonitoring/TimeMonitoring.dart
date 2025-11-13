import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:my_flutter_app/config/customThemes/elevatedButtonTheme.dart';

class TimeMonitoring extends StatefulWidget {
  final String otNumber;
  final String patientName;
  final String doctorName;
  final String department;
  final String procedureName;
  final String technician;
  final String nurse;
  final String specialEquipment;
  final DateTime surgeryDate;
  final int surgeryId;
  final String caller;

  TimeMonitoring({required this.otNumber,
    required this.patientName,
    required this.surgeryId,
    required this.surgeryDate,
    required this.doctorName,
    required this.department,
    required this.procedureName,
    required this.technician,
    required this.caller,
    required this.nurse,
    required this.specialEquipment}) ;

  @override
  _TimeMonitoringState createState() => _TimeMonitoringState();
}

class _TimeMonitoringState extends State<TimeMonitoring> {

  List<Map<String, dynamic>> surgicalSteps = [];

  String preOPTime = '00:00';
  String prophylaxisTime = '00:00';
  String wheelInOT = '00:00';
  String inductionStartTime = '00:00';
  String inductionEndTime = '00:00';
  String paintAndDrapStartTime = '00:00';
  String paintAndDrapEndTime = '00:00';
  String incisionStartTime = '00:00';
  String incisionEndTime = '00:00';
  String extubationTime = '00:00';
  String wheeledOutToTime = '00:00';
  String wheeledOutFromTime = '00:00';

  bool preOPStartEnabled = true;
  bool prophylaxisStartEnabled = false;
  bool wheelInStartEnabled = false;
  bool inductionStartEnabled = false;
  bool inductionEndEnabled = false;
  bool paintAndDrapStartEnabled = false;
  bool paintAndDrapEndEnabled = false;
  bool incisionStartEnabled = false;
  bool incisionEndEnabled = false;
  bool extubationStartEnabled = false;
  bool wheeledOutToTimeEnabled = false;
  bool wheeledOutFromTimeEnabled = false;
  bool submitButtonEnabled = false;

  String baseUrl = 'http://10.125.11.203:8091/api';

  @override
  void initState() {

    _isSurgeryDone(widget.surgeryId);

    surgicalSteps = [
      {'step': 'Pre-OP', 'time': preOPTime},
      {'step': 'Prophylaxis', 'time': prophylaxisTime},
      {'step': 'Wheel-In', 'time': wheelInOT},
      {'step': 'Induction', 'time': '$inductionStartTime-$inductionEndTime'},
      {'step': 'Painting & Draping', 'time': '$paintAndDrapStartTime-$paintAndDrapEndTime'},
      {'step': 'Incision', 'time': '$incisionStartTime-$incisionEndTime'},
      {'step': 'Extubation', 'time': extubationTime},
      {'step': 'Wheeled Out to Post-Op', 'time': wheeledOutToTime},
      {'step': 'Wheeled Out From Post-Op', 'time': wheeledOutFromTime},
    ];
  }

  @override
  Widget build(BuildContext context) {
    //bool isOutButtonVisible = false;
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(150, 10, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operation Theatre #${widget.otNumber}', style: TextStyle (fontSize: 25, fontWeight: FontWeight.bold),),
            //Text('Patient: ${widget.patientName}', style: Theme.of(context).textTheme.subtitle1),
            Divider(color: Colors.blueGrey[50], thickness: 2, endIndent: 1000),
            SizedBox(height: 15),
            //Text('Surgical Steps', style: Theme.of(context).textTheme.headline6),
            ...surgicalSteps.map((step) => Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width : 30,
                        height: 60,
                        child: Icon(Icons.access_alarm_outlined,size: 35)
                      ),
                      SizedBox(width: 15,),
                      Container(
                        width : 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step['step'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(step['time'], style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        // child: Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(step['step'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        //     //Text(step['time'], style: TextStyle(fontSize: 18, color: Colors.grey)),
                        //     SizedBox(width:100),
                        //     Container(
                        //       width: 200,
                        //       child:Text(step['time'], style: TextStyle(fontSize: 18, color: Colors.grey)),
                        //     )
                        //   ],
                        // ),
                      ),
                      SizedBox(width: 600,),
                      Container(
                        //flex: 1,
                        child: Row(
                          //mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: isButtonEnabled(step['step']) ? () {
                                updateInTime(step['step']);
                                updateButtons(step['step']);
                              } : null,
                              style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                              child: Text('In Time',style: TextStyle(color: Colors.white),),
                            ),
                            SizedBox(width: 10,),
                            Visibility (
                              visible: isOutButtonVisible(step['step']),
                              child: ElevatedButton(
                                 onPressed: ()  {
                                   updateOutTime(step['step']);
                                   updateOutButtons(step['step']);
                                 } ,
                                // () {
                                //   switch(step['step']) {
                                //     case 'Induction':
                                //       updateOutTime('Induction');
                                //       updateButtons('Induction');
                                //     case 'Painting & Draping':
                                //       updateOutTime('Painting & Draping');
                                //       updateButtons('Painting & Draping');
                                //     case 'Incision':
                                //       updateOutTime('Incision');
                                //       updateButtons('Incision');
                                //   }
                                // },
                                style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                                child: Text('Out Time',style: TextStyle(color: Colors.white),),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(width: 10,),
                      // Container(
                      //   //flex: 1,
                      //   child: Row(
                      //     //mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  Divider(color: Colors.blueGrey[50], thickness: 2, endIndent: 275),
                ],
              ),
            )).toList(),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.fromLTRB(890, 0, 0, 0),
              child: ElevatedButton(
                onPressed: submitButtonEnabled ? () {
                  _submitForm(); // Call method to send POST request
                }
                : null,
                style: MyElevatedButtonTheme.elevatedButtonTheme1.style,
                child: Text('Save & Exit',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }



  String getCurrentTime() {
    // Get current time using DateTime class
    DateTime now = DateTime.now();
    // Format the time as desired
    String formattedTime =
        //"${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    return formattedTime;
  }

  void updateInTime(String step) {
    String currentTime = getCurrentTime();
    setState(() {
      switch (step) {
        case 'Pre-OP':
          preOPTime = currentTime;
          //preOPStartEnabled = false;
          surgicalSteps[0]['time']= preOPTime;
          break;
        case 'Prophylaxis':
          prophylaxisTime = currentTime;
          prophylaxisStartEnabled = false;
          surgicalSteps[1]['time']= prophylaxisTime;
          break;
        case 'Wheel-In':
          wheelInOT = currentTime;
          wheelInStartEnabled = false;
          surgicalSteps[2]['time']= wheelInOT;
          break;
        case 'Induction':
          inductionStartTime = currentTime;
          inductionStartEnabled = false;
          surgicalSteps[3]['time']= '$inductionStartTime-';
          break;
        case 'Painting & Draping':
          paintAndDrapStartTime = currentTime;
          paintAndDrapStartEnabled = false;
          surgicalSteps[4]['time']= '$paintAndDrapStartTime-';
          break;
        case 'Incision':
          incisionStartTime = currentTime;
          incisionStartEnabled = false;
          surgicalSteps[5]['time']= '$incisionStartTime-';
          break;
        case 'Extubation':
          extubationTime = currentTime;
          extubationStartEnabled = false;
          surgicalSteps[6]['time']= extubationTime;
          break;
        case 'Wheeled Out to Post-Op':
          wheeledOutToTime = currentTime;
          wheeledOutToTimeEnabled = false;
          surgicalSteps[7]['time']= wheeledOutToTime;
          break;
        case 'Wheeled Out From Post-Op':
          wheeledOutFromTime = currentTime;
          wheeledOutFromTimeEnabled = false;
          surgicalSteps[8]['time']= wheeledOutFromTime;
          break;
      }
    });
  }

  void updateOutTime(String step) {
    setState(() {
      if(step == 'Induction') {
      inductionEndTime = getCurrentTime();
      print("updateOutTime()-inductionEndTime:$inductionEndTime");
      surgicalSteps[3]['time']= '$inductionStartTime - $inductionEndTime';
      inductionEndEnabled = false;
      }

      else if(step == 'Painting & Draping') {
      paintAndDrapEndTime = getCurrentTime();
      print("updateOutTime()-paintAndDrapEndTime:$paintAndDrapEndTime");
      surgicalSteps[4]['time']= '$paintAndDrapStartTime - $paintAndDrapEndTime';
      }

      else if(step == 'Incision') {
      incisionEndTime = getCurrentTime();
      print("updateOutTime()-incisionEndTime:$incisionEndTime");
      surgicalSteps[5]['time']= '$incisionStartTime - $incisionEndTime';
      }
    });
  }

  bool isButtonEnabled(String step) {
    switch (step) {
      case 'Pre-OP':
        return (preOPStartEnabled && !(widget.caller =="pastSurgeries"));
        // extra condition added to disable all buttons for all except nurse/technician
      case 'Prophylaxis':
        return prophylaxisStartEnabled;
      case 'Wheel-In':
        return wheelInStartEnabled;
      case 'Induction':
        if(inductionStartEnabled && !inductionStartTime.startsWith('00'))
          return inductionEndEnabled;
        return inductionStartEnabled;
      case 'Painting & Draping':
        return paintAndDrapStartEnabled;
      case 'Incision':
        if(incisionStartEnabled)
          incisionEndEnabled;
        return incisionStartEnabled;
      case 'Extubation':
        return extubationStartEnabled;
      case 'Wheeled Out to Post-Op':
        return wheeledOutToTimeEnabled;
      case 'Wheeled Out From Post-Op':
        return wheeledOutFromTimeEnabled;
      default:
        return true; // Default to enabled if not specified
    }
  }

  bool isOutButtonVisible(String step) {

    // if(step == 'Induction' || step == 'Painting & Draping' || step == 'Incision')
    //   return true;

    if (step == 'Induction') {
      // if(!inductionStartTime.startsWith('00'))
      //   return true;
      // return false;
      return inductionEndEnabled;
    }

    else if (step == 'Painting & Draping') {
      // if(!paintAndDrapStartTime.startsWith('00'))
      //   return true;
      // return false;
      return paintAndDrapEndEnabled;
    }

    else if (step == 'Incision') {
      // if(!incisionStartTime.startsWith('00'))
      //   return true;
      // return false;
      return incisionEndEnabled;
    }

    return false;
  }

  void updateButtons(String step) {
    setState(() {
      switch (step) {
        case 'Pre-OP':
          print("disableButton-case 'Pre-OP'");
          preOPStartEnabled = false;
          prophylaxisStartEnabled = true;
          //checkIfButtonEnabled('Pre-OP');
          break;
        case 'Prophylaxis':
          print("disableButton-case 'Prophylaxis'");
          prophylaxisStartEnabled = false;
          wheelInStartEnabled = true;
          break;
        case 'Wheel-In':
          wheelInStartEnabled = false;
          inductionStartEnabled = true;
          break;
        case 'Induction':
          inductionEndEnabled = true;
          inductionStartEnabled = false;
          break;
        case 'Painting & Draping':
          paintAndDrapStartEnabled = false;
          paintAndDrapEndEnabled = true;
          break;
        case 'Incision':
          incisionEndEnabled = true;
          incisionStartEnabled = false;
          break;
        case 'Extubation':
          extubationStartEnabled = false;
          wheeledOutToTimeEnabled = true;
          break;
        case 'Wheeled Out to Post-Op':
          wheeledOutToTimeEnabled = false;
          wheeledOutFromTimeEnabled = true;
          break;
        case 'Wheeled Out From Post-Op':
          wheeledOutFromTimeEnabled = false;
          submitButtonEnabled = true;
          break;
      }
    });
  }

  void updateOutButtons(String step) {
    setState(() {
      switch (step) {
        case 'Induction':
          inductionEndEnabled = false;
          paintAndDrapStartEnabled = true;
          break;
        case 'Painting & Draping':
          paintAndDrapEndEnabled = false;
          incisionStartEnabled = true;
          break;
        case 'Incision':
          incisionEndEnabled = false;
          extubationStartEnabled = true;
          break;
      }
    });
  }

  void _submitForm() async {
    // Prepare your data for the POST request
    //String formattedDate = widget.surgeryDate.toIso8601String().split('T')[0];

    String formattedDate = DateFormat('MM/dd/yyyy').format(widget.surgeryDate);

    print(widget.doctorName);
    Map<String, dynamic> postData = {
      'scheduled_surgery_id': widget.surgeryId == 0
          ? null
          : widget.surgeryId == 1
          ? null
          : widget.surgeryId,
      'ot_number': widget.otNumber,
      'patient_received_in_pre_op_time': preOPTime,
      'antibiotic_prophylaxis_time': prophylaxisTime,
      'patient_wheel_in_OT': wheelInOT,
      'induction_start_time': inductionStartTime,
      'induction_end_time': inductionEndTime,
      'painting_and_draping_start_time': paintAndDrapStartTime,
      'painting_and_draping_end_time': paintAndDrapEndTime,
      'incision_in_time': incisionStartTime,
      'incision_close_time': incisionEndTime,
      'extubation_time_in_OT': extubationTime,
      'wheeled_out_time_to_Post_op_ICU': wheeledOutToTime,
      'wheeled_out_from_Post_OP': wheeledOutFromTime,
      //'surgery_date': '08/22/2023'
      'surgery_date': formattedDate,
      'doctor_name': widget.doctorName,
      'procedure_name': widget.procedureName,
      'technician_tl': widget.technician,
      'nurse_tl': widget.nurse,
      'special_equipment': widget.specialEquipment,
      'surgery_type': widget.surgeryId == 0
          ? 'Emergency'
          : widget.surgeryId == 1
          ? 'Add-on'
          : 'Pre-planned'
    };

    // Send POST request using http package
    try {
      Uri url = Uri.parse('$baseUrl/monitor/');
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful response
        print('POST request successful');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Confirmation.\nYour inputs have been recorded successfully'),
                //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      print(widget.surgeryId);
                      Navigator.of(context).pop('${widget.surgeryId} is done');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
        // Optionally, navigate to another screen or show a success message
      } else {
        // Handle other status codes if needed
        print('POST request failed with status: ${response.statusCode}');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'OOPS !!!.\nYour inputs have not been recorded.\nPlease check again'),
                //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Disable'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      }
    } catch (e) {
      // Handle any exceptions or errors
      print('Error sending POST request: $e');
    }
  }

  void _isSurgeryDone(int surgery_id) async {
    try {
      Uri url = Uri.parse('$baseUrl/monitor/');
      final headers = {'Content-Type': 'application/json'};
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle successful response
        print('GET request successful');
        //print(response.body);
        print(jsonDecode(response.body).runtimeType);
        List<dynamic> completedSurgeryList = jsonDecode(response.body);
        List<dynamic> currentSurgery = completedSurgeryList
            .where((object) => object['scheduled_surgery_id'] == surgery_id)
            .toList();
        print(completedSurgeryList
            .where((object) => object['scheduled_surgery_id'] == surgery_id)
            .toList());
        //for(int i =0;i<completedSurgeryList.length;i++){
        //  completedSurgeryList.where((object) => object['scheduled_surgery_id']==surgery_id).toList());
        //}

        if (currentSurgery.isNotEmpty) {
          setState(() {

            preOPStartEnabled = false;
            submitButtonEnabled = false;
            print(currentSurgery[0]['patient_received_in_pre_op_time']);
            preOPTime =
            currentSurgery[0]['patient_received_in_pre_op_time'];
            surgicalSteps[0]['time']= preOPTime;
            prophylaxisTime =
            currentSurgery[0]['antibiotic_prophylaxis_time'];
            surgicalSteps[1]['time']= prophylaxisTime;
            wheelInOT = currentSurgery[0]['patient_wheel_in_OT'];
            surgicalSteps[2]['time']= wheelInOT;
            inductionStartTime = currentSurgery[0]['induction_start_time'];
            inductionEndTime = currentSurgery[0]['induction_end_time'];
            surgicalSteps[3]['time']= '$inductionStartTime - $inductionEndTime';
            paintAndDrapStartTime =
            currentSurgery[0]['painting_and_draping_start_time'];
            paintAndDrapEndTime =
            currentSurgery[0]['painting_and_draping_end_time'];
            surgicalSteps[4]['time']= '$paintAndDrapStartTime - $paintAndDrapEndTime';
            incisionStartTime = currentSurgery[0]['incision_in_time'];
            incisionEndTime = currentSurgery[0]['incision_close_time'];
            surgicalSteps[5]['time']= '$incisionStartTime - $incisionEndTime';
            extubationTime = currentSurgery[0]['extubation_time_in_OT'];
            surgicalSteps[6]['time']= extubationTime;
            wheeledOutToTime =
            currentSurgery[0]['wheeled_out_time_to_Post_op_ICU'];
            surgicalSteps[7]['time']= wheeledOutToTime;
            wheeledOutFromTime = currentSurgery[0]['wheeled_out_from_Post_OP'];
            surgicalSteps[8]['time']= wheeledOutFromTime;

          });
        }
      } else {
        // Handle other status codes if needed
        print('GET request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions or errors
      print('Error sending GET request: $e');
    }

    //return false;
  }



}
