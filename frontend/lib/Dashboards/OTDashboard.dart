import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../config/constants.dart';

class OTDashboard extends StatefulWidget {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  OTDashboard({required this.selectedFromDate, required this.selectedToDate});

  @override
  _OTDashboardState createState() => _OTDashboardState();
}

class _OTDashboardState extends State<OTDashboard> {
  Map<String, int> surgeryCountsMap = {};
  List<SurgeryData> chartData = [];
  List<UtilisationData> utilisationData = [];
  List<MonitoringStepsData> monitoringStepsData = [];
  List<AuxiliaryClass> chartData2 = [];
  List<AvgTimeDifferenceData> avgTimeDifferenceData = [];
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  // String selectedSpeciality = 'Ophthalmology';
  String selectedOT = '1';
  List<String> otList = Constants.otList;
  List<Map<String, String>> otSpecificData = [];

  String baseUrl = 'http://10.125.11.203:8091/api';

  @override
  void initState() {
    super.initState();

    selectedFromDate = widget.selectedFromDate!;
    selectedToDate = widget.selectedToDate!;
    print('initState()-selectedFromDate: $selectedFromDate');
    fromDateController =
        TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));

    _getSurgeryCount();
    _otUtilization();
    //_getSlotsUsageData();
    _getStepsAverage();
    _getAverageTimeDifference();
    //otList.add("1");
    //selectedOT = otList[0];
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _getSurgeryCount() async {
    String apiUrl = '$baseUrl/ot-surgery-count/';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

    String fromDate = '';
    String toDate = '';
    if (selectedFromDate != DateTime(2015) &&
        selectedToDate != DateTime(2015)) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
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
      print('Data Received from the backend successfully.-OTDashboard()');
      // Optionally, handle the response from the backend if needed
      print('Response body: ${response.body}');
      //Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      List<dynamic> surgeriesList = [];

      if (responseData.containsKey('Count of surgeries per OT on all dates')) {
        surgeriesList = responseData['Count of surgeries per OT on all dates'];
      } else if (responseData.containsKey(
          'Count of surgeries per OT from ${fromDate} to ${toDate}')) {
        surgeriesList = responseData[
            'Count of surgeries per OT from ${fromDate} to ${toDate}'];
      } else if (responseData
          .containsKey('Count of surgeries per OT from ${fromDate} onwards')) {
        surgeriesList =
            responseData['Count of surgeries per OT from ${fromDate} onwards'];
      } else if (responseData
          .containsKey('Count of surgeries per OT up to ${toDate}')) {
        surgeriesList =
            responseData['Count of surgeries per OT up to ${toDate}'];
      }

      print('SurgeryList - $surgeriesList');
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

  void _otUtilization() async {
    String apiUrl = '$baseUrl/percent-ot-utilization/';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

    String fromDate = '';
    String toDate = '';
    if (selectedFromDate != DateTime(2015) &&
        selectedToDate != DateTime(2015)) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
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
      print('Data Received from the backend successfully.-_getOtUtilization()');
      // Optionally, handle the response from the backend if needed
      print('Utilisation Response: ${response.body}');
      List<dynamic> utilisationList = jsonDecode(response.body);
      // print(utilisationList);
      // List<dynamic> utilisationList = responseData.entries.map((entry) => MapEntry(entry.key, entry.value)).toList();
      // print('utilisationList $utilisationList');
      setState(() {
        utilisationData.addAll(utilisationList
            .map((item) => UtilisationData.fromJson(item))
            .toList());
      });
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getAverageTimeDifference() async {
    String apiUrl = '$baseUrl/avg-time-difference/';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

    String fromDate = '';
    String toDate = '';
    if (selectedFromDate != DateTime(2015) &&
        selectedToDate != DateTime(2015)) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
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
      print('Data Received from the backend successfully.-_getOtUtilization()');
      // Optionally, handle the response from the backend if needed
      print('Utilisation Response: ${response.body}');
      List<dynamic> avgTimeDifferenceList = jsonDecode(response.body);

      print(avgTimeDifferenceList);
      for (var item in avgTimeDifferenceList) {
        print(item['ot_number'].runtimeType);
        print(item['avg_time_difference'].runtimeType);
        avgTimeDifferenceData.add(AvgTimeDifferenceData(
            otNumber: item['ot_number'],
            timeDifference: item['avg_time_difference']));
      }

      // setState(() {
      //   for(var item in avgTimeDifferenceList){
      //     print(item['ot_number']);
      //     print( item['avg_time_difference']);
      //     avgTimeDifferenceData.add(AvgTimeDifferenceData(otNumber: item['ot_number'], timeDifference: item['avg_time_difference']));
      //   }
      // });
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  // void _getSlotsUsageData() async {
  //
  //   String apiUrl = '$baseUrl/ot-time-slot-usage/';
  //   print('selectedFromDate:$selectedFromDate');
  //   print('selectedToDate:$selectedToDate');
  //
  //   String fromDate ='';
  //   String toDate = '';
  //   if (selectedFromDate != DateTime(2015) && selectedToDate != DateTime(2015)) {
  //     // Format the dates to include only the date part (yyyy-MM-dd)
  //     fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
  //     toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
  //     apiUrl += '?start_date=$fromDate&end_date=$toDate';
  //   }
  //   // Check if only fromDate is selected
  //   else if (selectedFromDate != DateTime(2015)) {
  //     fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
  //     apiUrl += '?start_date=$fromDate';
  //   }
  //   // Check if only toDate is selected
  //   else if (selectedToDate != DateTime(2015)) {
  //     // Format the date to include only the date part (yyyy-MM-dd)
  //     toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
  //     apiUrl += '?end_date=$toDate';
  //   }
  //
  //   print(apiUrl);
  //
  //   final response = await http.get(
  //     Uri.parse(apiUrl),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     print(
  //         '_getSlotsUsageData(): Data Received from the backend successfully');
  //     // Optionally, handle the response from the backend if needed
  //     print('_getSlotsUsageData():Response: ${response.body}');
  //     //List<dynamic> utilisationList = jsonDecode(response.body);
  //     // print(utilisationList);
  //     // List<dynamic> utilisationList = responseData.entries.map((entry) => MapEntry(entry.key, entry.value)).toList();
  //     // print('utilisationList $utilisationList');
  //     // setState(() {
  //     //   utilisationData.addAll(utilisationList.map((item) => UtilisationData.fromJson(item)).toList());
  //     // });
  //   } else {
  //     //print('Error sending data to the backend: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //   }
  // }

  void _getStepsAverage() async {
    String apiUrl = '$baseUrl/monitoring-steps-avg/';
    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

    String fromDate = '';
    String toDate = '';
    if (selectedFromDate != DateTime(2015) &&
        selectedToDate != DateTime(2015)) {
      // Format the dates to include only the date part (yyyy-MM-dd)
      fromDate = DateFormat('yyyy-MM-dd').format(selectedFromDate);
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?start_date=$fromDate&end_date=$toDate';
    }
    // Check if only fromDate is selected
    else if (selectedFromDate != DateTime(2015)) {
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
      print('_getStepsAverage(): Data Received from the backend successfully');
      // Optionally, handle the response from the backend if needed
      print('_getStepsAverage():Response: ${response.body}');
      List<dynamic> stepsList = jsonDecode(response.body);
      print(stepsList);
      setState(() {
        monitoringStepsData = stepsList
            .where((item) =>
                item['ot_number'] == '$selectedOT') // Filter based on ot_number
            .map((item) => MonitoringStepsData.fromJson(item))
            .toList();

        otSpecificData = stepsList
            .where((item) => item['ot_number'] == '$selectedOT')
            .map((item) => {
                  'avg_induction_duration':
                      item['avg_induction_duration'].toString(),
                  'avg_painting_and_draping_duration':
                      item['avg_painting_and_draping_duration'].toString(),
                  'avg_incision_duration':
                      item['avg_incision_duration'].toString(),
                  'avg_pre_op_to_ot': item['avg_pre_op_to_ot'].toString(),
                  'avg_extubation_duration':
                      item['avg_extubation_duration'].toString(),
                  'avg_incision_to_extubation':
                      item['avg_incision_to_extubation'].toString(),
                  'avg_wheeled_duration':
                      item['avg_wheeled_duration'].toString(),
                })
            .toList();

        chartData2.clear(); // Clear the chartData2 before adding new items
        for (var item in otSpecificData) {
          item.forEach((key, value) {
            chartData2.add(AuxiliaryClass(stepName: key, duration: value));
          });
        }
      });

      //print(otList);

      //print(monitoringStepsData);
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Widget _buildBarChart<T>(List<T> data, String xAxisTitle, String yAxisTitle) {
    Color barColor = Colors.teal; // Default color
    String legendItemText = 'Data';

    if (T == SurgeryData) {
      barColor = Colors.teal;
      legendItemText = 'Surgery Count';
    } else if (T == UtilisationData) {
      barColor = Colors.redAccent;
      legendItemText = 'Utilisation Percentage';
    } else if (T == AvgTimeDifferenceData) {
      barColor = Colors.amberAccent;
      legendItemText = 'Average Time Difference';
    }

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
      legend: Legend(isVisible: true, position: LegendPosition.top),
      series: <BarSeries<T, String>>[
        BarSeries<T, String>(
          dataSource: data,
          xValueMapper: (T data, _) {
            if (data is SurgeryData) {
              return data.otNumber; // Use otNumber for SurgeryData
            } else if (data is UtilisationData) {
              return data.otNumber; // Use otNumber for UtilisationData
            } else if (data is AvgTimeDifferenceData) {
              return data.otNumber;
            } else if (data is AuxiliaryClass) {
              return data.stepName;
            }
            return ''; // Default case
          },
          yValueMapper: (T data, _) {
            if (data is SurgeryData) {
              return double.parse(
                  data.surgeryCount); // Use surgeryCount for SurgeryData
            } else if (data is UtilisationData) {
              print('else-f ${data.utilisationPercentage.toDouble()}');
              return data
                  .utilisationPercentage; // Convert to double for UtilisationData
            } else if (data is AvgTimeDifferenceData) {
              return double.tryParse(data.timeDifference);
            } else if (data is AuxiliaryClass) {
              return double.tryParse(data.duration);
            }
            return 0; // Default case
          },
          width: 0.2,
          color: barColor,
          name: 'Data',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            color: barColor,
            textStyle: TextStyle(color: Colors.white, fontSize: 10),
          ),
          legendIconType: LegendIconType.circle,
          legendItemText: legendItemText,
        ),
      ],
    );
  }

  // Widget _buildMultipleBarChart(List<MonitoringStepsData> data, String xAxisTitle, String yAxisTitle) {
  //   return SfCartesianChart(
  //     isTransposed: true,
  //     backgroundColor: Colors.grey[200],
  //     primaryXAxis: CategoryAxis(
  //       title: AxisTitle(
  //           text: xAxisTitle,
  //           textStyle: TextStyle(fontWeight: FontWeight.bold)),
  //     ),
  //     primaryYAxis: NumericAxis(
  //       title: AxisTitle(
  //           text: yAxisTitle,
  //           textStyle: TextStyle(fontWeight: FontWeight.bold)),
  //     ),
  //     legend: Legend(isVisible: true, position: LegendPosition.top),
  //     series: <BarSeries<MonitoringStepsData, String>>[
  //       BarSeries<MonitoringStepsData, String>(
  //         dataSource: data,
  //         xValueMapper: (MonitoringStepsData stepsData, _) =>
  //             stepsData.otNumber,
  //         yValueMapper: (MonitoringStepsData stepsData, _) {
  //           double value =
  //               double.tryParse(stepsData.avgIncisionDuration) ?? 0.0;
  //           return double.parse(value.toStringAsFixed(
  //               1)); // Keep only two digits after the decimal point
  //         },
  //         width: 0.4,
  //         spacing: 0.4,
  //         color: Colors.lightBlueAccent,
  //         name: 'Data',
  //         dataLabelSettings: DataLabelSettings(
  //           isVisible: true,
  //           color: Colors.lightBlueAccent,
  //           textStyle: TextStyle(color: Colors.white, fontSize: 10),
  //         ),
  //         legendIconType: LegendIconType.circle,
  //         legendItemText: 'Incision Duration',
  //       ),
  //       BarSeries<MonitoringStepsData, String>(
  //         dataSource: data,
  //         xValueMapper: (MonitoringStepsData stepsData, _) =>
  //             stepsData.otNumber,
  //         yValueMapper: (MonitoringStepsData stepsData, _) {
  //           double value =
  //               double.tryParse(stepsData.avgInductionDuration) ?? 0.0;
  //           return double.parse(value.toStringAsFixed(
  //               1)); // Keep only two digits after the decimal point
  //         },
  //         width: 0.4,
  //         spacing: 0.4,
  //         color: Colors.amberAccent,
  //         name: 'Data',
  //         dataLabelSettings: DataLabelSettings(
  //           isVisible: true,
  //           color: Colors.amberAccent,
  //           textStyle: TextStyle(color: Colors.white, fontSize: 10),
  //         ),
  //         legendIconType: LegendIconType.circle,
  //         legendItemText: 'Induction Duration',
  //       ),
  //       BarSeries<MonitoringStepsData, String>(
  //         dataSource: data,
  //         xValueMapper: (MonitoringStepsData stepsData, _) =>
  //             stepsData.otNumber,
  //         yValueMapper: (MonitoringStepsData stepsData, _) {
  //           //double value = double.parse(stepsData.avgPaintingAndDrapingDuration) ?? 0.0;
  //           double value =
  //               double.tryParse(stepsData.avgPaintingAndDrapingDuration) ?? 0.0;
  //           return double.parse(value.toStringAsFixed(
  //               1)); // Keep only two digits after the decimal point
  //         },
  //         width: 0.4,
  //         spacing: 0.4,
  //         color: Colors.teal,
  //         name: 'Data',
  //         dataLabelSettings: DataLabelSettings(
  //           isVisible: true,
  //           color: Colors.teal,
  //           textStyle: TextStyle(color: Colors.white, fontSize: 10),
  //         ),
  //         legendIconType: LegendIconType.circle,
  //         legendItemText: 'Painting And Draping Duration',
  //       ),
  //       //
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> dropdownItems = [
      for (String item in otList)
        DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        )
    ];

    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            //mainAxisAlignment: MainAxisAlignment.center,
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
                          _getSurgeryCount();
                          _otUtilization();
                          _getStepsAverage();
                          _getAverageTimeDifference();
                        }),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 50,
                    child: Text("Surgery Count per OT",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              //SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    //width: 500,
                    child:
                        _buildBarChart(chartData, 'OT Number', 'Surgery Count'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 50,
                    child: Text("Percentage Utilisation of  OT's",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  //width: 500,
                  child: _buildBarChart(
                      utilisationData, 'OT Number', 'Utilization Percentage'),
                ),
              ]),
              SizedBox(height: 20),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 50,
                    child: Text("Average time taken per Step for OT",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                  Container(
                    width: 100,
                    child: DropdownButtonFormField(
                        items: dropdownItems,
                        decoration: InputDecoration(
                          labelText: 'Select OT',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        value: selectedOT,
                        //hint: Text('Select OT'),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOT = newValue!;
                            _getStepsAverage();
                          });
                        }),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(children: [
                Expanded(
                  //width: 500,
                  child: chartData2.isNotEmpty
                      ? _buildBarChart(chartData2, 'OT', 'Average Time')
                      : Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ]),
              SizedBox(height: 20),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 400,
                    height: 50,
                    child: Text("Average Time Difference",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  //width: 500,
                  child: _buildBarChart(avgTimeDifferenceData, 'OT Number',
                      'Average Time Difference'),
                ),
              ]),
              // Row(
              //   children: [
              //     Expanded(child: null)
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
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
  // Future<void> _selectFromDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedFromDate,
  //     firstDate: DateTime(2015),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (picked != null && picked != selectedFromDate) {
  //     setState(() {
  //       selectedFromDate = picked;
  //       String date = "${selectedFromDate.toLocal()}".split(' ')[0];
  //       fromDateController?.text = date;
  //     });
  //   } else if (picked == null) {
  //     setState(() {
  //       selectedFromDate = DateTime(2015); // Set selectedFromDate to an initial value
  //       fromDateController?.text = ''; // Set the text field to empty
  //     });
  //   }
  // }

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

  // Future<void> _selectToDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedToDate,
  //     firstDate: DateTime(2015),
  //     lastDate: DateTime.now(),
  //   );
  //
  //   if (picked != null && picked != selectedToDate) {
  //     setState(() {
  //       selectedToDate = picked;
  //       String date = "${selectedToDate.toLocal()}".split(' ')[0];
  //       toDateController?.text = date;
  //     });
  //   }else if (picked == null) {
  //     setState(() {
  //       selectedToDate = DateTime(2015); // Set selectedFromDate to an initial value
  //       toDateController?.text = ''; // Set the text field to empty
  //     });
  //   }
  //
  //   //_setValues(context);
  // }
}

class SurgeryData {
  final String otNumber;
  final String surgeryCount;

  SurgeryData({required this.otNumber, required this.surgeryCount});

  factory SurgeryData.fromJson(Map<String, dynamic> json) {
    return SurgeryData(
      otNumber: json.keys.first.toString(),
      surgeryCount: json.values.first.toString() ?? '',
    );
  }
}

class UtilisationData {
  final String otNumber;
  final double utilisationPercentage;

  UtilisationData(
      {required this.otNumber, required this.utilisationPercentage});

  factory UtilisationData.fromJson(Map<String, dynamic> json) {
    return UtilisationData(
      otNumber: json.keys.first.toString(),
      utilisationPercentage: ((json.values.first as double)),
    );
  }
}

class AvgTimeDifferenceData {
  final String otNumber;
  final String timeDifference;

  AvgTimeDifferenceData({required this.otNumber, required this.timeDifference});
}

class MonitoringStepsData {
  final String otNumber;
  final String avgInductionDuration;
  final String avgPaintingAndDrapingDuration;
  final String avgIncisionDuration;
  final String avg_pre_op_to_ot;
  final String avg_extubation_duration;
  final String avg_incision_to_extubation;
  final String avg_wheeled_duration;

  MonitoringStepsData({
    required this.otNumber,
    required this.avgInductionDuration,
    required this.avgPaintingAndDrapingDuration,
    required this.avgIncisionDuration,
    required this.avg_pre_op_to_ot,
    required this.avg_extubation_duration,
    required this.avg_incision_to_extubation,
    required this.avg_wheeled_duration,
  });

  factory MonitoringStepsData.fromJson(Map<String, dynamic> json) {
    return MonitoringStepsData(
      otNumber: json['ot_number'].toString(),
      avgInductionDuration: json['avg_induction_duration'].toString(),
      avgPaintingAndDrapingDuration:
          json['avg_painting_and_draping_duration'].toString(),
      avgIncisionDuration: json['avg_incision_duration'].toString(),
      avg_pre_op_to_ot: json['avg_pre_op_to_ot'].toString(),
      avg_extubation_duration: json['avg_extubation_duration'].toString(),
      avg_incision_to_extubation: json['avg_incision_to_extubation'].toString(),
      avg_wheeled_duration: json['avg_wheeled_duration'].toString(),
    );
  }
}

class AuxiliaryClass {
  String stepName;
  String duration;

  AuxiliaryClass({required this.stepName, required this.duration});
}
