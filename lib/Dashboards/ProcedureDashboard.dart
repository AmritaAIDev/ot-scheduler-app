import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:syncfusion_flutter_charts/charts.dart';

class ProcedureDashboard extends StatefulWidget {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  ProcedureDashboard(
      {required this.selectedFromDate, required this.selectedToDate});

  @override
  _ProcedureDashboardState createState() => _ProcedureDashboardState();
}

class _ProcedureDashboardState extends State<ProcedureDashboard> {
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  String selectedSpeciality = 'Plastic Surgery';
  String selectedSurgery = '';

  // List of items in our dropdown menu
  List<String> specialityList = [
    'Ophthalmology',
    'Dentistry',
    'ORTHO',
    'ENT',
    'OBG',
    'Plastic Surgery',
    'Neuro Surgery'
  ];

  Map<String, List<String>> surgeryMap = {
    'Ophthalmology': ['Cataract Left Eye', 'MICS+PCIOL Left Eye'],
    'Dentistry': ['Root Canal', 'Teeth Cleaning','cavity'],
    'ORTHO': [
      'Knee Replacement',
      'Hip Replacement',
      'Spinal Injection Epidural'
    ],
    'ENT': ['Tonsillectomy', 'Sinus Surgery'],
    'OBG': ['C-Section', 'Hysterectomy'],
    'Plastic Surgery': [
      'Secondary Suturing',
      'Rhinoplasty',
      'Liposuction',
      'Debridement',
    ],
    'Neuro Surgery': ['Brain Tumor Removal', 'Spinal Fusion','Bifrontal Carinotomy'],
    'HBP Surgery/Organ Transplant' : [],
  };

  List<DoctorData> doctorDataList = [];
  List<DoctorData> allDoctorData = [];

  final List<Color> doctorColorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.pink,
    Colors.teal,
    Colors.brown,
    // Add more colors if needed
  ];

// Function to get a color based on the index
  Color getColor(int index) {
    return doctorColorList[index % colorList.length];
  }

  Map<String, double> dataMap = {};
  Map<String, double> TimingdataMap = {};
  final colorList = <Color>[
    Colors.greenAccent,
  ];

  // List<AverageSurgeryDuration> avgSurgeryDurationData = [];

  String baseUrl = 'http://10.125.11.203:8091/api';

  @override
  void initState() {
    super.initState();
    selectedFromDate = widget.selectedFromDate!;
    selectedToDate = widget.selectedToDate!;
    _getSurgeryType();
    _getSurgeryTimings();
    _getProcedureTimeComparison();
    // _getAverageSurgeryDuration();

    print('initState()-selectedFromDate: $selectedFromDate');
    fromDateController =
        TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));
    //_otUtilization();
    selectedSurgery =
        surgeryMap[selectedSpeciality]!.first; // Initialize selectedSurgery
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _getSurgeryType() async {
    String apiUrl = '$baseUrl/surgery-type-percentage/';
    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

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
      print('_getSurgeryType(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      List<dynamic> surgeryTypeList = responseData['message'];
      for (var item in surgeryTypeList) {
        item.forEach((key, value) {
          dataMap[key] = value;
        });
      }
      dataMap.remove('total_surgeries');
      print(dataMap);
      setState(() {
        // Update the state to trigger a rebuild with the new dataMap
      });
      //
      // setState(() {
      //   chartData.addAll(
      //       surgeriesList.map((item) => SurgeryData.fromJson(item)).toList());
      // });
      // print('Chart Data - ${chartData[0].otNumber} | ${chartData[0].surgeryCount}');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getSurgeryTimings() async {
    String apiUrl = '$baseUrl/surgery-timing-percentage/';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

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
      print('_getSurgeryTimings(): Data Received from the backend successfully.');
      print(response.body);
      // Parse the JSON response
      // Map<String, dynamic> responseData = jsonDecode(response.body);
      //
      // print(responseData);
      //
      // List<dynamic> surgeryTypeList = responseData['message'];
      // for (var item in surgeryTypeList) {
      //   item.forEach((key, value) {
      //     dataMap[key] = value;
      //   });
      // }
      // dataMap.remove('total_surgeries');
      // print(dataMap);
      // setState(() {
      //   // Update the state to trigger a rebuild with the new dataMap
      // });
      //
      // setState(() {
      //   chartData.addAll(
      //       surgeriesList.map((item) => SurgeryData.fromJson(item)).toList());
      // });
      // print('Chart Data - ${chartData[0].otNumber} | ${chartData[0].surgeryCount}');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  // Widget _buildBarChart<T>(List<T> data, String xAxisTitle, String yAxisTitle) {
  //   Color barColor = Colors.teal; // Default color
  //   String legendItemText = 'Data';
  //   Color labelColor = Colors.red;
  //
  //   if (T == SurgeryData) {
  //     barColor = Colors.teal;
  //     legendItemText = 'Surgery Count';
  //     labelColor = Colors.red;
  //   }
  //   // else if (T == AverageSurgeryDuration) {
  //   //   barColor = Colors.redAccent;
  //   //   legendItemText = 'Avg Surgery DurationData';
  //   //   labelColor = Colors.lightBlueAccent;
  //   // }
  //   return SfCartesianChart(
  //     //title: ChartTitle(text: 'Surgery Count Per Doctor'),
  //       isTransposed: true, // Change X and Y axis data
  //       backgroundColor: Colors.grey[200],
  //       primaryXAxis: CategoryAxis(
  //         title: AxisTitle(
  //             text: xAxisTitle,
  //             textStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       primaryYAxis: NumericAxis(
  //         title: AxisTitle(
  //             text: yAxisTitle,
  //             textStyle: TextStyle(fontWeight: FontWeight.bold)),
  //       ),
  //       legend: Legend(isVisible: true, position: LegendPosition.top),
  //       series: <BarSeries<T, String>>[
  //         BarSeries<T, String>(
  //           dataSource: data,
  //           // xValueMapper: (SurgeryData surgeryData, _) => surgeryData.doctorName,
  //           xValueMapper: (T data, _) {
  //             if (data is SurgeryData) {
  //               return data.departmentName; // Use otNumber for SurgeryData
  //             }
  //             // else if (data is AverageSurgeryDuration) {
  //             //   return data.doctorName; // Use otNumber for UtilisationData
  //             // }
  //             return ''; // Default case
  //           },
  //           yValueMapper: (T data, _) {
  //             if (data is SurgeryData) {
  //               return double.parse(data.surgeryCount);
  //             }
  //             // else if (data is AverageSurgeryDuration) {
  //             //   return data.getHoursDuration() ;
  //             // }
  //             return 0; // Default case
  //           },
  //           width: 0.2,
  //           color: barColor,
  //           name: 'Total Marks',
  //           // gradient: LinearGradient(colors: Colors.primaries, tileMode: TileMode.clamp/*, transform: GradientRotation(10)*/),
  //           dataLabelSettings: DataLabelSettings(
  //               isVisible: true,
  //               color: labelColor,
  //               textStyle: TextStyle(color: Colors.white, fontSize: 10)),
  //           legendIconType: LegendIconType.circle,
  //           legendItemText: legendItemText,
  //           enableTooltip: true,
  //         ),
  //       ]);
  // }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItemsSurgery = [
      for (String item in surgeryMap['$selectedSpeciality']!)
        DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        )
    ];

    List<DropdownMenuItem<String>> dropdownItemsSpeciality = [
      for (String item in specialityList)
        DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        )
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text('Procedure Dashboard'),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          textStyle: TextStyle(color: Colors.white),
                          padding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: 24),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        onPressed: () {
                          _getSurgeryType();
                          _getSurgeryTimings();
                          _getProcedureTimeComparison();
                        }),
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
                    child: Text("Surgery Type Percentage",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              //SizedBox(height: 20),
              Container(
                width: 550,
                height: 450,
                child: dataMap.isNotEmpty
                    ? pie.PieChart(
                        dataMap: dataMap,
                        chartType: pie.ChartType.disc,
                        centerText: "Surgery Type Percentage",
                        baseChartColor: Colors.grey[300]!,
                      )
                    : Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                  //color: Color(0xFF381460),
                  width: 400,
                  height: 40,
                  child: Text("Timing Comparision Surgery wise",
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
                  width: 200,
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
                          selectedSurgery = surgeryMap[newValue]!.first;
                          _filterDoctorData(selectedSurgery);
                        });
                      }),
                ),
                SizedBox(width: 50),
                Container(
                  width: 250,
                  child: DropdownButtonFormField(
                      items: dropdownItemsSurgery,
                      decoration: InputDecoration(
                        labelText: 'Select Surgery',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      hint: Text('Select Item'),
                      value: selectedSurgery,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSurgery = newValue!;
                          _filterDoctorData(selectedSurgery);
                        });
                      }),
                ),
              ]),
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  //width: 500,
                  child: doctorDataList.isNotEmpty
                      ? _buildMultipleBarChart(doctorDataList, 'Doctor Name',
                          'Average Duration(sec)')
                      : Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ]),
              SizedBox(height: 50),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              SizedBox(height: 20),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       //color: Color(0xFF381460),
              //       width: 400,
              //       height: 40,
              //       child: Text("Surgery Timings Percentage",
              //           textAlign: TextAlign.center,
              //           style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 550,
              //       height: 450,
              //       child: dataMap.isNotEmpty
              //           ? pie.PieChart(
              //         dataMap: dataMap,
              //         chartType: pie.ChartType.disc,
              //         centerText: "Surgery Timings Percentage",
              //         baseChartColor: Colors.grey[300]!,
              //       )
              //           : Center(
              //         child: Text(
              //           'No data available',
              //           style: TextStyle(
              //               fontSize: 20, fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          )),
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
    } else if (picked == null) {
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
    } else if (picked == null) {
      setState(() {
        //selectedToDate = selectedToDate;
        toDateController?.text = "${selectedToDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void _getProcedureTimeComparison() async {
    String apiUrl = '$baseUrl/procedure-time-comparison';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

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

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('_getProcedureTimeComparison(): Data Received from the backend successfully.');

        // Parse the JSON response
        List<dynamic> responseList = jsonDecode(response.body);
        print('_getProcedureTimeComparison()-responseList: $responseList');
        List<DoctorData> fetchedDoctorDataList = [];
        if (responseList is List) {
          for (var procedure in responseList) {
            String procedureName =
                procedure['procedure_name'] ?? 'Unknown Procedure';
            List<dynamic> doctors = procedure['doctors'];
            if (doctors is List) {
              for (var doctor in doctors) {
                String doctorName = doctor['doctor_name'] ?? 'Unknown Doctor';
                String averageDuration =
                    doctor['average_duration'] ?? '0:00:00';
                Duration duration = _parseDuration(averageDuration);
                fetchedDoctorDataList.add(DoctorData(
                    doctorName, duration.inSeconds.toDouble(), procedureName));
              }
            }
          }
        }

        setState(() {
          allDoctorData = fetchedDoctorDataList;
          _filterDoctorData(selectedSurgery);
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filterDoctorData(String surgery) {
    setState(() {
      doctorDataList =
          allDoctorData.where((data) => data.procedureName == surgery).toList();
    });

    // Print the values of the filtered data
    for (var data in doctorDataList) {
      print(data); // This will use the toString() method of DoctorData
    }
  }

  Duration _parseDuration(String duration) {
    try {
      List<String> parts = duration.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      double seconds = double.parse(parts[2]);
      return Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds.toInt(),
      );
    } catch (e) {
      // If there's an error parsing, return a zero duration
      print('Error parsing duration: $e');
      return Duration.zero;
    }
  }

  Widget _buildMultipleBarChart(
      List<DoctorData> data, String xAxisTitle, String yAxisTitle) {
    //String legendItemText = data.pr ;
    return SfCartesianChart(
      isTransposed: true,
      backgroundColor: Colors.grey[200],
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
            text: xAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold)),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
            text: yAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold)),
      ),
      //legend: Legend(isVisible: true, position: LegendPosition.top),
      series: <BarSeries<DoctorData, String>>[
        // BarSeries<DoctorData, String>(
        //   dataSource: data,
        //   xValueMapper: (DoctorData stepsData , _) => stepsData.otNumber,
        //   yValueMapper: (DoctorData stepsData, _) {
        //     double value = double.tryParse(stepsData.avgIncisionDuration) ?? 0.0;
        //     return double.parse(value.toStringAsFixed(1)); // Keep only two digits after the decimal point
        //   },
        //   width: 0.2,
        //   spacing: 0.1,
        //   color: Colors.lightBlueAccent,
        //   name: 'Data',
        //   dataLabelSettings: DataLabelSettings(
        //     isVisible: true,
        //     color: Colors.lightBlueAccent,
        //     textStyle: TextStyle(color: Colors.white, fontSize: 10),
        //   ),
        //   legendIconType: LegendIconType.circle,
        //   legendItemText: 'Incision Duration',
        // ),
        BarSeries<DoctorData, String>(
          dataSource: data,
          xValueMapper: (DoctorData doctorData, _) => doctorData.doctorName,
          yValueMapper: (DoctorData doctorData, _) {
            //double value = double.tryParse(doctorData.averageDuration) ?? 0.0;
            return doctorData.averageDuration
                .toDouble(); // Keep only two digits after the decimal point
          },
          width: 0.2,
          spacing: 0.1,
          //color: Colors.amberAccent,
          pointColorMapper: (DoctorData doctorData, int index) {
            // Assign colors based on index in doctorColorList
            return doctorColorList[index % doctorColorList.length];
          },
          //name: 'Average Duration',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            color: Colors.amberAccent,
            textStyle: TextStyle(color: Colors.white, fontSize: 10),
          ),
          // legendIconType: LegendIconType.circle,
          // legendItemText: '${doctorDataList}',
        ),
        // BarSeries<MonitoringStepsData, String>(
        //   dataSource: data,
        //   xValueMapper: (MonitoringStepsData stepsData , _) => stepsData.otNumber,
        //   yValueMapper: (MonitoringStepsData stepsData, _) {
        //     //double value = double.parse(stepsData.avgPaintingAndDrapingDuration) ?? 0.0;
        //     double value = double.tryParse(stepsData.avgPaintingAndDrapingDuration) ?? 0.0;
        //     return double.parse(value.toStringAsFixed(1)); // Keep only two digits after the decimal point
        //   },
        //   width: 0.2,
        //   spacing: 0.2,
        //   color: Colors.teal,
        //   name: 'Data',
        //   dataLabelSettings: DataLabelSettings(
        //     isVisible: true,
        //     color: Colors.teal,
        //     textStyle: TextStyle(color: Colors.white, fontSize: 10),
        //   ),
        //   legendIconType: LegendIconType.circle,
        //   legendItemText: 'Painting And Draping Duration',
        // ),
      ],
    );
  }
}

class DoctorData {
  final String doctorName;
  final double averageDuration;
  final String procedureName;

  DoctorData(this.doctorName, this.averageDuration, this.procedureName);

  String toString() {
    return 'DoctorData(procedureName: $procedureName, doctorName: $doctorName, averageDuration: $averageDuration)';
  }
}
