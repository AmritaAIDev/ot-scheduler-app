//import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/TimeMonitoring/TimeMonitoring.dart';
import 'package:my_flutter_app/config/constants.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:my_flutter_app/config/customThemes/elevatedButtonTheme.dart';
import 'package:my_flutter_app/main.dart';

class DetailsConfirmation extends StatefulWidget {
  final String patientName;
  //final String gender;
  final String otNumber;
  final String doctorName;
  final String department;
  final String procedureName;
  final String technician;
  final String nurse;
  final String mrd;
  final String specialEquipment;
  final DateTime surgeryDate;
  final int surgeryId;

  DetailsConfirmation({
    required this.patientName,
    //required this.gender,
    required this.surgeryId,
    required this.otNumber,
    required this.surgeryDate,
    required this.doctorName,
    required this.department,
    required this.procedureName,
    required this.technician,
    required this.nurse,
    required this.mrd,
    required this.specialEquipment,
  });

  DetailsConfirmation.emergency(
      {required this.patientName,
      required this.otNumber,
      required this.surgeryDate,
      required this.doctorName,
      required this.mrd,
      required this.procedureName,
      required this.surgeryId})
      : nurse = '',
        specialEquipment = '',
        department = '',
        technician = '';

  @override
  _DetailsConfirmationState createState() => _DetailsConfirmationState();
}

class _DetailsConfirmationState extends State<DetailsConfirmation> {
  late TextEditingController _nameController;
  //late TextEditingController _ageController;
  late TextEditingController _mrdController;
  late TextEditingController _surgeryNameController;
  late TextEditingController _otNumberController;
  late TextEditingController _surgeonController;
  late TextEditingController _nurseController;
  late TextEditingController _departmentController;
  late TextEditingController _technicianController;
  late TextEditingController _genderController;

  String selectedAnesthesiaType = Constants.anesthesiaTypes[0];

  String selectedDepartment = Constants.departmentList[0];

  String selectedSurgery = '';

  List<String> dropdownItemsSurgery = [];

  Color subtitle = Colors.blueGrey;

  double subtitleFontSize = 16;

  static const double gap = 20;

  static const double gap2 = 15;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patientName);
    //_genderController = TextEditingController(text: widget.gender);
    //_ageController = TextEditingController(text: widget.surgeryId);
    _mrdController = TextEditingController(text: widget.mrd);
    _surgeryNameController = TextEditingController(text: widget.procedureName);
    _otNumberController = TextEditingController(text: widget.otNumber);
    _surgeonController = TextEditingController(text: widget.doctorName);
    _nurseController = TextEditingController(text: widget.nurse);
    _departmentController = TextEditingController(text: widget.department);
    _technicianController = TextEditingController(text: widget.technician);

    selectedDepartment = widget.department.isNotEmpty ? widget.department : Constants.departmentList[0];
    dropdownItemsSurgery = Constants.surgeryMap[selectedDepartment] ?? [];
    selectedSurgery = dropdownItemsSurgery.isNotEmpty ? dropdownItemsSurgery.first : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    //_ageController.dispose();
    _mrdController.dispose();
    _surgeryNameController.dispose();
    _otNumberController.dispose();
    _surgeonController.dispose();
    _nurseController.dispose();
    _departmentController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showDropdown1 = false;
    bool showDropdown2 = false;
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(120, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSection('Patient Details', [
              Divider(color: Colors.blueGrey[50], thickness: 2, endIndent: 150),
              SizedBox(
                height: gap,
              ),
              _buildDetailRow(
                  'Name', _nameController, false, 'MRD', _mrdController),
              //Divider(color: Colors.blueGrey[50],thickness: 2, endIndent: 150,),
              //_buildDetailRow('Sex', _genderController, 'MRD', _mrnController),
            ]),
            SizedBox(height: 25),
            _buildSection('Surgery Details', [
              Divider(color: Colors.blueGrey[50], thickness: 2, endIndent: 150),
              SizedBox(
                height: gap2,
              ),
              _buildDetailRow('Department', _departmentController, true,
                  'OT Number', _otNumberController),
              Divider(
                color: Colors.blueGrey[50],
                thickness: 2,
                endIndent: 400,
              ),
              SizedBox(
                height: gap2,
              ),
              _buildDetailRow('Surgery Name', _surgeryNameController, true,
                  'Technician', _technicianController),
              Divider(
                color: Colors.blueGrey[50],
                thickness: 2,
                endIndent: 400,
              ),
              SizedBox(
                height: gap2,
              ),
              _buildDetailRow('Surgeon', _surgeonController, false, 'Nurse',
                  _nurseController),
              Divider(
                color: Colors.blueGrey[50],
                thickness: 2,
                endIndent: 400,
              ),
              SizedBox(
                height: gap2,
              ),
              _buildLastRow('Anaesthesia Type', _surgeonController),
            ]),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(0, 0, 350, 10),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimeMonitoring(
                                  otNumber: _otNumberController.text,
                                  patientName: _nameController.text,
                                  surgeryId: widget.surgeryId,
                                  surgeryDate: widget.surgeryDate,
                                  // Pass DateTime value
                                  doctorName: _surgeonController.text,
                                  department: _departmentController.text,
                                  procedureName: _surgeryNameController.text,
                                  technician: _technicianController.text,
                                  nurse: _nurseController.text,
                                  specialEquipment: widget.specialEquipment,
                                  caller: "DetailsConfimation",
                                )));
                  },
                  child: Text('Confirm', style: TextStyle(color: Colors.white)),
                  style: MyElevatedButtonTheme.elevatedButtonTheme1.style),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...children,
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDetailRow(String label1, TextEditingController controller1,
      bool showDropdown, String label2, TextEditingController controller2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SizedBox(height: 10,),
              Text(label1,
                  style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: subtitle)),
              //SizedBox(height: 2,),
              showDropdown
                  ? DropdownMenu(
                      controller: label1 == 'Department'
                          ? _departmentController
                          : _surgeryNameController,
                      hintText: "Select $label1",
                      menuHeight: 250,
                      //width: null,
                      enableSearch: true,
                      expandedInsets: label1 == 'Department'
                          ? null
                          : EdgeInsets.fromLTRB(0, 0, 180, 0),
                      inputDecorationTheme:
                          InputDecorationTheme(border: InputBorder.none),
                      onSelected: (String? value) {
                        setState(() {
                          switch (label1) {
                            case 'Department':
                              selectedDepartment = value!;
                              _updateSurgeryDropdown(value);
                            // if (_departmentController == null || _departmentController.text.isEmpty) {
                            //   // If department is cleared, clear Surgery Name and reset its items
                            //   _surgeryNameController.clear();
                            //   dropdownItemsSurgery = []; // Assuming you have a way to reset this list
                            // } else {
                            //   // Update Surgery dropdown based on selected department
                            //   _updateSurgeryDropdown(value);
                            // }
                            //break;
                            case 'Surgery Name':
                              selectedSurgery = value!;
                            //break;
                          }
                        });
                      },
                      dropdownMenuEntries: label1 == 'Department'
                          ? Constants.departmentList.map((item) {
                              return DropdownMenuEntry(
                                  value: item, label: item);
                            }).toList()
                          : dropdownItemsSurgery.isNotEmpty
                              ? dropdownItemsSurgery.map((item) {
                                  return DropdownMenuEntry(
                                      value: item, label: item);
                                }).toList()
                              : [
                                  const DropdownMenuEntry(
                                      value: '',
                                      label: 'No surgeries available')
                                ],
                    )
                  : TextFormField(
                      controller: controller1,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label2,
                  style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: subtitle)),
              TextFormField(
                controller: controller2,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildLastRow(String label, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //SizedBox(height: 10,),
              Text(label,
                  style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: subtitle)),
              DropdownMenu(
                  //label: const Text('Select Anesthesia'),
                  hintText: 'Select Anesthesia',
                  inputDecorationTheme:
                      InputDecorationTheme(border: InputBorder.none),
                  onSelected: (String? anesthesia) {
                    setState(() {
                      selectedAnesthesiaType = anesthesia!;
                    });
                  },
                  dropdownMenuEntries:
                      Constants.anesthesiaTypes.map((anesthesia) {
                    return DropdownMenuEntry(
                        value: anesthesia, label: anesthesia);
                  }).toList())
            ],
          ),
        ),
      ],
    );
  }

  void _updateSurgeryDropdown(String department) {
    setState(() {
      dropdownItemsSurgery = Constants.surgeryMap[department] ?? [];
      print("_departmentController::$_departmentController");
      print("dropdownItemsSurgery $dropdownItemsSurgery");
      selectedSurgery =
          (dropdownItemsSurgery.isNotEmpty ? dropdownItemsSurgery.first : '')!;
      print("selectedSurgery $selectedSurgery");
      //menuController_surgery = selectedSurgery.toString() as TextEditingController;
    });
  }
}
