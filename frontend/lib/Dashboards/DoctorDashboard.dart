import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../config/constants.dart';

class DoctorDashboard extends StatefulWidget {

  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  DoctorDashboard({required this.selectedFromDate, required this.selectedToDate});

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {

  late TextEditingController fromDateController;
  late TextEditingController toDateController;

  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  List<SurgeryData> chartData = [];
  List<AverageSurgeryDuration> avgSurgeryDurationData = [];

  String baseUrl = Constants.baseURL;

  @override
  void initState() {
    super.initState();

    //print('selectedDate_doctordashboard:${DateFormat('yyyy-MM-dd').format(widget.selectedFromDate)}');
    selectedFromDate = widget.selectedFromDate!;

    selectedToDate = widget.selectedToDate!;


    print('initState()-selectedFromDate: $selectedFromDate');

    fromDateController = TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));
    _getSurgeryCount();
    _getAverageSurgeryDuration();
    // selectedFromDate = widget.selectedFromDate!;
    // selectedToDate = widget.selectedToDate!;

    //_otUtilization();
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }


  void _getSurgeryCount() async {
    String apiUrl = '$baseUrl/doctor-surgery-count/';

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
      print('_getSurgeryCount(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData.keys);

      List<dynamic> surgeriesList =[];

      // List<dynamic> surgeriesList =
      //     responseData['Count of surgeries per doctor across all dates'];
      if(responseData.containsKey('Count of surgeries per doctor across all dates')){
        surgeriesList = responseData['Count of surgeries per doctor across all dates'];
      }
      else if(responseData.containsKey('Count of surgeries per doctor from ${fromDate} to ${toDate}')){
        surgeriesList = responseData['Count of surgeries per doctor from ${fromDate} to ${toDate}'];
      }
      else if(responseData.containsKey('Count of surgeries per doctor from ${fromDate} onwards')) {
        surgeriesList = responseData['Count of surgeries per doctor from ${fromDate} onwards'];
      }
      else if (responseData.containsKey('Count of surgeries per doctor up to ${toDate}')){
        surgeriesList = responseData['Count of surgeries per doctor up to ${toDate}'];
      }

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

  void _getAverageSurgeryDuration() async {

    String apiUrl = '$baseUrl/doctor-average-time/';

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
    else if (selectedToDate != DateTime(1947)) {
      // Format the date to include only the date part (yyyy-MM-dd)
      toDate = DateFormat('yyyy-MM-dd').format(selectedToDate);
      apiUrl += '?end_date=$toDate';
    }

    print('_getAverageSurgeryDuration-API URL :$apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(
          '_getAverageSurgeryDuration(): Data Received from the backend successfully.');
      // Optionally, handle the response from the backend if needed
      //print('Response body: ${response.body}');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);
      print('_getAverageSurgeryDuration()-responseData: ${responseData}');
      // Ensure responseData is not null
      //List<dynamic> avgDurationList = [];
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            '_getAverageSurgeryDuration(): Data Received from the backend successfully.');

        // Parse the JSON response
        Map<String, dynamic> responseData = jsonDecode(response.body);

        print(responseData);
        List<dynamic> avgDurationList = responseData['message'];
        print('avgDurationData:${avgDurationList}');

        // setState(() {
        //   avgSurgeryDurationData.addAll(
        //       avgDurationList.map((item) => AverageSurgeryDuration.fromJson(item)).toList());
        // });
        setState(() {
          avgSurgeryDurationData.addAll(
            avgDurationList
                .map((item) => AverageSurgeryDuration.fromJson(item))
                .toList(),
          );
        });
      } else {
        // Handle the error case
        print('Error sending data to the backend: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      // Handle the error case
      print('Error sending data to the backend: ${response.statusCode}');
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
    } else if (T == AverageSurgeryDuration) {
      barColor = Colors.redAccent;
      legendItemText = 'Avg Surgery DurationData';
      labelColor = Colors.lightBlueAccent;
    }

    return SfCartesianChart(
      //title: ChartTitle(text: 'Surgery Count Per Doctor'),
      isTransposed: true, // Change X and Y axis data
      backgroundColor: Colors.grey[200],
      primaryXAxis: CategoryAxis(
        labelRotation: 270,
        title: AxisTitle(
          text: xAxisTitle,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),

      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: yAxisTitle,
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      legend: Legend(isVisible: true, position: LegendPosition.top),
      series: <BarSeries<T, String>>[
        BarSeries<T, String>(
          dataSource: data,
          xValueMapper: (T data, _) {

            // Use truncated name for SurgeryData
            if (data is SurgeryData) {
              String truncatedName = data.doctorName.length > 10
                  //? '${data.doctorName.substring(0, 10)}\n${data.doctorName.substring(10)}'
                  ? '${data.doctorName.substring(0, 10)}'
                  : data.doctorName;
              return truncatedName;
              //return data.doctorName;
            } else if (data is AverageSurgeryDuration) {
              String truncatedName = data.doctorName.length > 10
                  ? '${data.doctorName.substring(0, 10)}'
                  : data.doctorName;
              return truncatedName;
              //return data.doctorName;
            }
            return ''; // Default case
          },
          yValueMapper: (T data, _) {
            if (data is SurgeryData) {
              return double.parse(data.surgeryCount);
            } else if (data is AverageSurgeryDuration) {
              return data.getHoursDuration();
            }
            return 0; // Default case
          },
          width: 0.6,
          color: barColor,
          name: 'Total Marks',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            color: labelColor,
            textStyle: TextStyle(color: Colors.white, fontSize: 10),
          ),
          legendIconType: LegendIconType.circle,
          legendItemText: legendItemText,
          enableTooltip: true,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: false,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
          String doctorName = data.doctorName;
          // if (data is SurgeryData) {
          //   doctorName =
          // } else if (data is AverageSurgeryDuration) {
          //   doctorName = data.doctorName;
          // }
          return Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Doctor Name: $doctorName',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Doctor Dashboard'),
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
                          _getAverageSurgeryDuration();
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
                    width: 400,
                    height: 50,
                    child:
                    Text("Surgery Count per Doctor",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildBarChart(chartData, 'Doctor', 'Surgery Count'),
                  ),
                  //SizedBox(width: 30)
                ],
              ),
              SizedBox(height:20),
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
                    child:
                    Text("Average Surgery Duration",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              Row(children: [
                Expanded(
                  //width: 500,
                  child: _buildBarChart(avgSurgeryDurationData, 'Doctor',
                      'Average Surgery Time (Min)'),
                ),
              ]),
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

// class SurgeryData {
//   final String doctorName;
//   final String surgeryCount;
//
//   SurgeryData({required this.doctorName, required this.surgeryCount});
//
//   factory SurgeryData.fromJson(Map<String, dynamic> json) {
//     return SurgeryData(
//       doctorName: json.keys.first.toString(),
//       surgeryCount: json.values.first.toString() ?? '',
//     );
//   }
// }

class SurgeryData {
  final String doctorName;
  final String surgeryCount;

  SurgeryData({required this.doctorName, required this.surgeryCount});

  factory SurgeryData.fromJson(Map<String, dynamic> json) {
    String name = json.keys.first.toString();
    name = name.replaceAll(RegExp(r'^\s*Dr\s*'), ''); // Remove "Dr" prefix and any spaces after it
    return SurgeryData(
      doctorName: name.trim(), // Trim any leading or trailing spaces
      surgeryCount: json.values.first.toString() ?? '',
    );
  }
}

class AverageSurgeryDuration {
  final String doctorName;
  final String avgDuration;

  AverageSurgeryDuration({required this.doctorName, required this.avgDuration});

  factory AverageSurgeryDuration.fromJson(Map<String, dynamic> json) {
    String name = json.keys.first.toString();
    name = name.replaceAll(RegExp(r'^\s*Dr\s*'), '');
    return AverageSurgeryDuration(
      doctorName: name.trim(),
      avgDuration: json.values.first.toString() ?? '',
    );
  }

  double getHoursDuration() {
    List<String> parts = avgDuration.split(':');
    if (parts.length == 3) {
      double? hours = double.tryParse(parts[0]);
      double? minutes = double.tryParse(parts[1]);
      double? seconds = double.tryParse(parts[2]);

      // print('hours $hours');
      // print('minutes $minutes');
      // print('seconds $seconds');

      if (hours != null && minutes != null && seconds!=null) {
        //double totalHours = hours + (minutes / 100);
        //double totalMinutes = minutes + (seconds / 10);
        double totalMinutes = minutes + (seconds);
        return double.parse(totalMinutes.toStringAsFixed(2));
      } else {
        throw FormatException("Invalid duration format-2");
      }
    } else {
      throw FormatException("Invalid duration format");
    }
  }
}
