import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DepartmentDashboard extends StatefulWidget {

  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  DepartmentDashboard({required this.selectedFromDate, required this.selectedToDate});
  @override
  _DepartmentDashboardState createState() => _DepartmentDashboardState();
}

class _DepartmentDashboardState extends State<DepartmentDashboard> {

  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  String selectedSpeciality = 'Ophthalmology';
  //String selectedSurgery = '';
  List<SurgeryData> chartData = [];
  List<UniqueSurgeryData> chartData2 = [];
  // List<AverageSurgeryDuration> avgSurgeryDurationData = [];

  String baseUrl = 'http://10.125.11.203:8091/api';

  List<String> specialityList = [];
  //Map<String, List<String>> surgeryMap = {};

  @override
  void initState() {
    super.initState();

    selectedFromDate = widget.selectedFromDate!;

    selectedToDate = widget.selectedToDate!;


    print('initState()-selectedFromDate: $selectedFromDate');

    fromDateController = TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));
     _getSurgeryCount();
     _getUniqueSurgeryCount();
    // _getAverageSurgeryDuration();
    //_otUtilization();
    specialityList = [
      'Ophthalmology',
      'Dentistry',
      'ORTHO',
      'ENT',
      'OBG',
      'Plastic Surgery',
      'Neuro Surgery',
      'HBP Surgery/Organ Transplant'
    ];

    // surgeryMap = {
    //   'Opthalmology': ['Cataract Left Eye', 'MICS+PCIOL Left Eye','MICS+PCIOL Right Eye','SICS+IOL'],
    //   'Dentistry': ['Root Canal', 'Teeth Cleaning'],
    //   'ORTHO': [
    //     'Knee Replacement',
    //     'Hip Replacement',
    //     'Spinal Injection Epidural'
    //   ],
    //   'ENT': ['Oral Cavity Lesion Excisional Biopsy - Major', 'Septoplasty'],
    //   'OBG': ['C-Section', 'Hysterectomy','Hysteroscopic Resection of Uterin Septum'],
    //   'Plastic Surgery': [
    //     'Rhinoplasty',
    //     'Liposuction',
    //     'Debridement',
    //     'Secondary Suturing'
    //   ],
    //   'Neuro Surgery': ['Brain Tumor Removal', 'Spinal Fusion','Bifrontal Carinotomy'],
    // };
    //
    // selectedSurgery =
    //     surgeryMap[selectedSpeciality]!.first;
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _getSurgeryCount() async {
    String apiUrl = '$baseUrl/surgery-department-count/';
    String fromDate ='';
    String toDate = '';
    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(1947)) {
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

    print(apiUrl);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getSurgeryCount(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      List<dynamic> surgeriesList = responseData['message'];
      print(surgeriesList);

      setState(() {
        chartData.addAll(
            surgeriesList.map((item) => SurgeryData.fromJson(item)).toList());
      });
      // print('Chart Data - ${chartData[0].otNumber} | ${chartData[0].surgeryCount}');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getUniqueSurgeryCount() async {
    String apiUrl = '$baseUrl/unique-department-surgery-count/';

    String fromDate ='';
    String toDate = '';
    if (selectedFromDate != null && selectedToDate != null) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(1947)) {
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      apiUrl += '?start_date=$fromDate';
    }
    // Check if only toDate is selected
    else if (selectedToDate != DateTime(2015)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

    print(apiUrl);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getUniqueSurgeryCount(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      //print(response.body.runtimeType);
      List<dynamic> uniqueSurgeryList = [];


      chartData2.clear();
      if(responseData.containsKey('$selectedSpeciality')){
        print(responseData.containsKey('$selectedSpeciality'));
        uniqueSurgeryList = responseData['$selectedSpeciality'];
      }


      //print(chartData2.toString());
      print('uniqueSurgeryList$uniqueSurgeryList');
      setState(() {

        for(var item in uniqueSurgeryList){
          //print('${item['procedure_name']} + ${item['count']}');
          chartData2.add(UniqueSurgeryData(procedureName: item['procedure_name'], count: item['count']));
        }
      });
      // print('Chart Data - ${chartData[0].otNumber} | ${chartData[0].surgeryCount}');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }



  Widget _buildBarChart<T>(List<T> data, String xAxisTitle, String yAxisTitle) {

    Color barColor = Colors.teal; // Default color
    String legendItemText = 'Data';
    Color labelColor = Colors.red;

    if (T == SurgeryData) {
      barColor = Colors.teal;
      legendItemText = 'Surgery Count';
      labelColor = Colors.red;
    }
    else if (T == UniqueSurgeryData) {
      barColor = Colors.amberAccent;
      //legendItemText = 'Avg Surgery DurationData';
      labelColor = Colors.lightBlueAccent;
    }
    return SfCartesianChart(
      //title: ChartTitle(text: 'Surgery Count Per Doctor'),
        isTransposed: true, // Change X and Y axis data
        backgroundColor: Colors.grey[200],
        primaryXAxis: CategoryAxis(
          //labelRotation: -45,
          title: AxisTitle(
              text: xAxisTitle,
              textStyle: TextStyle(fontWeight: FontWeight.bold)),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
              text: yAxisTitle,
              textStyle: TextStyle(fontWeight: FontWeight.bold)),
        ),
        legend: Legend(isVisible: true, position: LegendPosition.top),
        series: <BarSeries<T, String>>[
          BarSeries<T, String>(
            dataSource: data,
            // xValueMapper: (SurgeryData surgeryData, _) => surgeryData.doctorName,
            xValueMapper: (T data, _) {
              if (data is SurgeryData) {
                return data.departmentName; // Use otNumber for SurgeryData
              }
              else if (data is UniqueSurgeryData) {
                return data.procedureName; // Use otNumber for UtilisationData
              }
              return ''; // Default case
            },
            yValueMapper: (T data, _) {
              if (data is SurgeryData) {
                return double.parse(data.surgeryCount);
              }
              else if (data is UniqueSurgeryData) {
                return data.count ;
              }
              return 0; // Default case
            },
            width: 0.2,
            color: barColor,
            //name: 'Total Marks',
            // gradient: LinearGradient(colors: Colors.primaries, tileMode: TileMode.clamp/*, transform: GradientRotation(10)*/),
            dataLabelSettings: DataLabelSettings(
                isVisible: true,
                color: labelColor,
                textStyle: TextStyle(color: Colors.white, fontSize: 10)),
            legendIconType: LegendIconType.circle,
            legendItemText: legendItemText,
            enableTooltip: true,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {

    // List<DropdownMenuItem<String>> dropdownItemsSurgery = [
    //   for (String item in surgeryMap['$selectedSpeciality']!)
    //     DropdownMenuItem<String>(
    //       value: item,
    //       child: Text(item),
    //     )
    // ];

    List<DropdownMenuItem<String>> dropdownItemsSpeciality = [
      for (String item in specialityList)
        DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        )
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text('Department Dashboard'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize:
            Size.fromHeight(1.0), // Set the height of the divider
            child:
            Divider(color: Colors.grey), // Divider below the app bar title
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Padding()
                      Container(
                        width: 200,
                        child: TextField(
                          controller: fromDateController,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.calendar_today, size: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.indigoAccent,
                        ),
                        child: IconButton(
                          onPressed: () => _selectFromDate(context),
                          icon: Icon(Icons.calendar_today_outlined),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 50),
                      Container(
                        width: 200,
                        child: TextField(
                          controller: toDateController,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.calendar_today, size: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.indigoAccent,
                        ),
                        child: IconButton(
                          onPressed: () => _selectToDate(context),
                          icon: Icon(Icons.calendar_today_outlined),
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
                              _getSurgeryCount();
                              _getUniqueSurgeryCount();
                              //_getAverageSurgeryDuration();
                            }

                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //color: Color(0xFF381460),
                        width: 400,
                        height: 40,
                        child: Text("Surgery Count:Speciality wise",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBarChart(chartData, 'Department', 'Surgery Count'),
                      ),
                      SizedBox(width: 30)
                    ],
                  ),
                 SizedBox(height: 30),
                  Divider(
                    color: Colors.black54,
                    thickness: 2,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        //color: Color(0xFF381460),
                        width: 450,
                        height: 40,
                        child: Text("Unique Surgery Count:Speciality wise",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 275,
                          child: DropdownButtonFormField(
                              items: dropdownItemsSpeciality,
                              decoration: InputDecoration(
                                labelText: 'Select Speciality',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              hint: Text('Select Item'),
                              value: selectedSpeciality,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedSpeciality = newValue!;
                                  _getUniqueSurgeryCount();
                                  //selectedSurgery = surgeryMap[newValue]!.first;
                                  //_filterDoctorData(selectedSurgery);
                                });
                              }),
                        ),
                        //SizedBox(width: 50),
                  ]),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: _buildBarChart(chartData2, 'Surgery Name', 'Count'))
                    ],
                  ),
                ],)),
        ));
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedFromDate!,
      firstDate: widget.selectedFromDate!,
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedFromDate) {
      setState(() {
        selectedFromDate = picked;
        String date = "${selectedFromDate.toLocal()}".split(' ')[0];
        fromDateController?.text = date;
      });
    }
    else if (picked == null) {
      setState(() {
        //selectedFromDate = selectedFromDate;
        String date = "${selectedFromDate.toLocal()}".split(' ')[0];
        fromDateController?.text = date;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedToDate!,
      firstDate: widget.selectedFromDate!,
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
        //selectedToDate = selectedToDate;
        toDateController?.text = "${selectedToDate.toLocal()}".split(' ')[0];
      });
    }
  }
}

class SurgeryData {
  final String departmentName;
  final String surgeryCount;

  SurgeryData({required this.departmentName, required this.surgeryCount});

  factory SurgeryData.fromJson(Map<String, dynamic> json) {
    return SurgeryData(
      departmentName: json.keys.first.toString(),
      surgeryCount: json.values.first.toString() ?? '',
    );
  }
}

class UniqueSurgeryData {
  final String procedureName;
  final int count;

  UniqueSurgeryData({required this.procedureName, required this.count});
  // factory SurgeryData.fromJson(Map<String, dynamic> json) {
  //   return SurgeryData(
  //     departmentName: json.keys.first.toString(),
  //     surgeryCount: json.values.first.toString() ?? '',
  //   );
  // }
}

