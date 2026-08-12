import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'package:my_flutter_app/TimeMonitoring/CapturedRecord.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:my_flutter_app/config/customThemes/utilities/Utilities.dart';

import '../config/constants.dart';
import '../config/customThemes/elevatedButtonTheme.dart';
import 'DetailsConfirmation.dart';

class PatientListScreen2 extends StatefulWidget {
  @override
  _PatientListScreenState2 createState() => _PatientListScreenState2();
}

class _PatientListScreenState2 extends State<PatientListScreen2> {
  DateTime? selectedDate;
  List<String> patientList = [];
  List<String> doctorList = [];
  List<String> procedureList = [];
  List<String> departmentList = [];
  List<String> techniciansList = [];
  List<String> nursesList = [];
  List<String> specialEquipmentList = [];
  List<String> mrdList = [];
  List<int> surgery_id = [];
  List<String> ot_numbers = [];
  List<DateTime> surgery_date = [];
  bool isSubmitted = false;
  bool isSurgeryDone = false;

  static const double leftMargin = 180;
  //String displayMessage =

  //String baseUrl = 'https://9c79-2409-40d0-b5-dafe-c4cf-904e-59b2-3fd4.ngrok-free.app/api';
  String baseUrl = Constants.baseURL;

  String displayText1 = 'Surgery List';
  String displayText2 =
      'View all scheduled surgeries across all operation theatres';

  String? selectedSurgeryType;

  @override
  void initState() {
    _fetchPatientList(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        body: Padding(
          padding: const EdgeInsets.only(
            left: leftMargin,
            right: 320,
            top: 10,
          ),
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  Divider(color: Colors.blueGrey[50], thickness: 2),
                ],
              )),
              SizedBox(height: 20),
              //Text('OT NUMBER', style: TextStyle (fontSize: 16, fontWeight: FontWeight.w400),),
              Text(
                'OT NUMBER',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey),
              ),
              SizedBox(height: 4),
              SizedBox(
                width: 260,
                height: 45,
                child: TextField(
                  decoration: Utilities.otSearchBoxDecoration,
                  // decoration: InputDecoration(
                  //   hintText: 'Filter by OT number',
                  //   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  //   filled: true,
                  //   //constraints: BoxConstraints.tightFor(),
                  //   fillColor: Colors.grey[50],
                  // ),
                ),
              ),
              SizedBox(height: 25),
              Flexible(
                  // width:MediaQuery.sizeOf(context).width/1.5,
                  // height:800,
                  fit: FlexFit.tight,
                  child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                            color: Colors.blue.shade50,
                            thickness: 2,
                          ),
                      itemCount: patientList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientList[index],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                width: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Procedure: ${procedureList[index]}'),
                                    // Text(
                                    //     'Surgery ID: ${surgery_id[index]}'),
                                    Text('Surgeon: ${doctorList[index]}'),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 500,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsConfirmation(
                                                patientName: patientList[index],
                                                surgeryId: surgery_id[index],
                                                otNumber: ot_numbers[index],
                                                surgeryDate:
                                                    surgery_date[index],
                                                // Pass DateTime value
                                                doctorName: doctorList[index],
                                                department:
                                                    departmentList[index],
                                                procedureName:
                                                    procedureList[index],
                                                technician:
                                                    techniciansList[index],
                                                nurse: nursesList[index],
                                                specialEquipment:
                                                    specialEquipmentList[index],
                                                mrd: mrdList[index],
                                              )));
                                },
                                style: MyElevatedButtonTheme
                                    .elevatedButtonTheme2.style,
                                child: Text(
                                  'View/Update Details',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                            // child: Column(
                            //   crossAxisAlignment:
                            //   CrossAxisAlignment.start,
                            //   children: [
                            //     Text('Procedure: ${procedureList[index]}'),
                            //     // Text(
                            //     //     'Surgery ID: ${surgery_id[index]}'),
                            //     Text('Surgeon: ${doctorList[index]}'),
                            //   ],
                            // ),
                          ),
                          titleTextStyle: TextStyle(color: Colors.blueGrey),
                        );
                      })),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      // height: 50,
                      // width: 180,
                      child: ElevatedButton(
                          style:
                              MyElevatedButtonTheme.elevatedButtonTheme2.style,
                          onPressed: () {
                            _showDialogForm(0);
                          },
                          child: Text(
                            'Emergency/Add-on Surgery',
                            //'           Add\nEmergency/Add-on Surgery',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          )),
                    ),
                    //SizedBox(width: 600),
                    // Container(
                    //   height: 50,
                    //   width: 180,
                    //   child: ElevatedButton(
                    //     //style: ElevatedButton.styleFrom( disabledForegroundColor: Colors.red.withOpacity(0.38), disabledBackgroundColor: Colors.red.withOpacity(0.12)),
                    //       style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
                    //       onPressed: () {
                    //         _showDialogForm(1);
                    //       },
                    //       child: Text(
                    //         '        Add\nAdd-on Surgery',
                    //         style: TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 15),
                    //       )),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _fetchPatientList(DateTime date) async {
    try {
      //String formattedDate = "(${date.year},${date.month},${date.day})";
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      print('Date - $date');
      print('Formatted date - $formattedDate');
      Uri url = Uri.parse('$baseUrl/schedule/?surgery_date=$formattedDate');

      final headers = {'Accept': 'application/json'};

      print(url);
      final response = await http.get(
        url,
        headers: headers,
      );
      print('2');

      print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        print("patientListScreen_fetchPatientList(): ${response.body}");
        final List<Map<String, dynamic>> patients = data
            .where((element) =>
                element['surgery_date'] ==
                DateFormat('MM/dd/yyyy').format(date))
            .map<Map<String, dynamic>>((e) => {
                  'patientName': e['patient_name'] as String,
                  'scheduledSurgeryId': e['scheduled_surgery_id'] as int,
                  'otNumber': e['ot_number'] as String,
                  'surgery_date': DateFormat('MM/dd/yyyy')
                      .parse(e['surgery_date'] as String),
                  'doctor_name': e['doctor_name'] as String,
                  'department': e['department'] as String,
                  'procedure_name': e['procedure_name'] as String,
                  'technician': e['technician_tl'] as String,
                  'nurse': e['nurse_tl'] as String,
                  'specialEquipment': e['special_equipment'] as String,
                  'mrd': e['mrd'] as String,
                })
            .toList();

        if (data.isEmpty) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content:
          //     Text('No data Available. Please select correct date.'),
          //   ),
          // );
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                      'No data available.\nPlease select correct date'),
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

        setState(() {
          patientList =
              patients.map<String>((e) => e['patientName'] as String).toList();
          surgery_id =
              patients.map<int>((e) => e['scheduledSurgeryId'] as int).toList();
          ot_numbers =
              patients.map<String>((e) => e['otNumber'] as String).toList();
          surgery_date = patients
              .map<DateTime>((e) => e['surgery_date'] as DateTime)
              .toList(); // Store as DateTime
          doctorList =
              patients.map<String>((e) => e['doctor_name'] as String).toList();
          departmentList =
              patients.map<String>((e) => e['department'] as String).toList();
          procedureList = patients
              .map<String>((e) => e['procedure_name'] as String)
              .toList();
          techniciansList =
              patients.map<String>((e) => e['technician'] as String).toList();
          nursesList =
              patients.map<String>((e) => e['nurse'] as String).toList();
          specialEquipmentList = patients
              .map<String>((e) => e['specialEquipment'] as String)
              .toList();

          mrdList = patients.map<String>((e) => e['mrd'] as String).toList();
          isSubmitted = true;
        });

        // Check if any surgery is done
        // for (int id in surgery_id) {
        //   bool isDone = await _isSurgeryDone(id);
        //   if (isDone) {
        //     print('Surgery $id is done');
        //     // Handle the case when surgery is done
        //   } else {
        //     print('Surgery $id is not done');
        //   }
        // }
      } else {
        throw Exception('Failed to load patient list');
      }
    } catch (e) {
      print('Error fetching patient list: $e');
      print(techniciansList);
      print(nursesList);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to fetch patient list. Please try again later.'),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _fetchPatientList(selectedDate!);
      //_isSurgeryDone(surgery_id[index]);
      //   if (selectedDate != null) {
      //      // Call function to fetch patient list
      //   // } else {
      //   //   ScaffoldMessenger.of(context).showSnackBar(
      //   //     SnackBar(
      //   //       content: Text('Please select a date first.'),
      //   //     ),
      //   //   );
      //   // }
      // } else {}
    }
  }

  void _showDialogForm(int id) {
    final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var nameController = TextEditingController();
          var mrdController = TextEditingController();
          var surgeonName = TextEditingController();
          var department = TextEditingController();
          var otNumber = TextEditingController();
          var surgeryName = TextEditingController();
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2.0))),
            scrollable: true,
            title: const Text('Please Enter the Patient details'),
            //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
            content: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        //icon: Icon(Icons.account_box)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter patient name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: mrdController,
                      decoration: InputDecoration(labelText: 'MRD Number'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter MRD number';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: surgeonName,
                      decoration: InputDecoration(
                        labelText: 'Surgeon Name',
                        //icon: Icon(Icons.account_box)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter surgeon name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                        controller: department,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          //icon: Icon(Icons.account_box)
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter department';
                          }
                          return null;
                        }),
                    TextFormField(
                      controller: otNumber,
                      decoration: InputDecoration(labelText: 'OT Number'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter OT number';
                        }
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: surgeryName,
                      decoration: InputDecoration(
                        labelText: 'Surgery Name',
                        //icon: Icon(Icons.account_box)
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter surgery name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          //labelText: 'Select Surgery Type',
                          // Only show an underline border
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors
                                    .grey), // Custom color for the underline
                          ),
                          // focusedBorder: UnderlineInputBorder(
                          //   borderSide: BorderSide(color: Colors.blue), // Custom color when focused
                          // ),
                        ),
                        hint: Text("Select Surgery Type"),
                        value: selectedSurgeryType,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a surgery type';
                          }
                          return null;
                        },
                        onChanged: (String? surgeryType) {
                          setState(() {
                            selectedSurgeryType = surgeryType!;
                          });
                        },
                        items: Constants.surgeryTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList()),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)))),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          // MaterialPageRoute(
                          //     builder: (context) => CapturedRecord.emergency(
                          //       patientName: nameController.text,
                          //       otNumber: otNumber.text,
                          //       //surgeryDate: DateTime(DateTime.now().year-DateTime.now().month-DateTime.now().day),
                          //       surgeryDate: selectedDate!,
                          //       surgeryId: id,
                          //       doctorName: surgeonName.text,
                          //       procedureName: surgeryName.text,
                          //     ))
                          MaterialPageRoute(
                              builder: (context) => DetailsConfirmation.emergency(
                                    patientName: nameController.text,
                                    otNumber: otNumber.text,
                                    //surgeryDate: DateTime(DateTime.now().year-DateTime.now().month-DateTime.now().day),
                                    surgeryDate: DateTime.now(),
                                    surgeryId: id,
                                    doctorName: surgeonName.text,
                                    procedureName: surgeryName.text,
                                    mrd: mrdController.text,
                                  )));
                    }
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ))
              // TextButton(
              //   style: TextButton.styleFrom(
              //     textStyle: Theme.of(context).textTheme.labelLarge,
              //   ),
              //   child: const Text('OK'),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //     //Navigator.of(context).pop();
              //     // Navigator.push(
              //     //   context,
              //     //   MaterialPageRoute(builder: (context) => Login()),
              //     // );
              //   },
              // ),
            ],
          );
        });
  }
}
