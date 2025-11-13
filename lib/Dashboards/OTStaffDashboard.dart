import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OTStaffDashboard extends StatefulWidget {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  OTStaffDashboard({required this.selectedFromDate, required this.selectedToDate});

  @override
  _OTStaffDashboardState createState() => _OTStaffDashboardState();
}

class _OTStaffDashboardState extends State<OTStaffDashboard> {

  Map<String, int> surgeryCountsMap = {};
  List<SurgeryData> chartData = [];
  List<AverageSurgeryDurationData> chartData2 = [];
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate;
  late DateTime selectedToDate;

  String baseUrl = 'http://10.125.11.203:8091/api';

  @override
  void initState() {
    super.initState();

    selectedFromDate = widget.selectedFromDate!;
    selectedToDate = widget.selectedToDate!;
    print('initState()-selectedFromDate: $selectedFromDate');
    fromDateController = TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));


    _getSurgeryCount();
    _getAverageSurgeryDuration();

  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _getSurgeryCount() async {
    String apiUrl = '$baseUrl/otstaff-surgery-count/';

    print('selectedFromDate:$selectedFromDate');
    print('selectedToDate:$selectedToDate');

    String fromDate ='';
    String toDate = '';
    if (selectedFromDate != DateTime(2015) && selectedToDate != DateTime(2015)) {
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
      print('Response body:runtime Type: ${response.body.runtimeType}');
      //Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print('from Date: ${fromDate}');
      List<dynamic> surgeriesList =[];

      if(responseData.containsKey('Count of surgeries per staff on all dates')){
        surgeriesList = responseData['Count of surgeries per staff on all dates'];
      }else if (responseData.containsKey('Count of surgeries per staff from ${fromDate} to ${toDate}')) {
        surgeriesList = responseData['Count of surgeries per staff from ${fromDate} to ${toDate}'];
      }
      else if(responseData.containsKey('Count of surgeries per staff from ${fromDate} onwards')){
        surgeriesList = responseData['Count of surgeries per staff from ${fromDate} onwards'];
      }
      else if (responseData.containsKey('Count of surgeries per staff up to ${toDate}')){
        surgeriesList = responseData['Count of surgeries per staff up to ${toDate}'];
      }

      print('SurgeryList - $surgeriesList');
      setState(() {
        for(var item in surgeriesList){
          chartData.add(SurgeryData(staffName: item['staff_name'], surgeryCount: item['count']));
        }
      });
      // print('Chart Data - ${chartData[0].otNumber} | ${chartData[0].surgeryCount}');
    } else {
      //print('Error sending data to the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getAverageSurgeryDuration() async {

    String apiUrl = '$baseUrl/otstaff-avg-time/';

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

    print('_getAverageSurgeryDuration URL :$apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('_getAverageSurgeryDuration(): Data Received from the backend successfully.');
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
          for(var item in avgDurationList){
            chartData2.add(AverageSurgeryDurationData(staffName: item['staff_name'], avgDuration: item['duration']));
          }
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

    if (T == SurgeryData) {
      barColor = Colors.teal;
      legendItemText = 'Surgery Count';
    } else if (T == AverageSurgeryDurationData) {
      barColor = Colors.redAccent;
      legendItemText = 'Utilisation Percentage';
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
              return data.staffName; // Use otNumber for SurgeryData
            } else if (data is AverageSurgeryDurationData) {
              return data.staffName; // Use otNumber for UtilisationData
            }
            return ''; // Default case
          },
          yValueMapper: (T data, _) {
            if (data is SurgeryData) {
              return data.surgeryCount; // Use surgeryCount for SurgeryData
            } else if (data is AverageSurgeryDurationData) {
              // print('else-f ${data.avgDuration
              //     .toDouble()}');
              return data.getDuration() ;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OT Staff Dashboard'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Set the height of the divider
          child: Divider(color: Colors.grey), // Divider below the app bar title
        ),
      ),
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
                          // _otUtilization();
                          // _getStepsAverage();
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
                    Text("Surgery Count per OT Staff",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              //SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    //width: 500,
                    child:
                    _buildBarChart(chartData, 'Staff', 'Surgery Count'),
                  ),
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
                  child: _buildBarChart(
                      chartData2, 'Staff', 'Duration'),
                ),
              ]),
              SizedBox(height:20),
              Divider(
                color: Colors.black,
                thickness: 2,
              ),

              //SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 400,
              //       height: 50,
              //       child:
              //       Text("Average time taken per Step for OT",
              //           textAlign: TextAlign.center,
              //           style: TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //     ),
              //   ],
              // ),
              // Row(children: [
              //   Expanded(
              //     //width: 500,
              //     child: _buildMultipleBarChart(
              //         monitoringStepsData, 'OT Number', 'Average Time'),
              //   ),
              // ]),
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
  final String staffName;
  final int surgeryCount;

  SurgeryData({required this.staffName, required this.surgeryCount});

}

class AverageSurgeryDurationData {
  final String staffName;
  final String avgDuration;

  AverageSurgeryDurationData({required this.staffName, required this.avgDuration});

  // factory AverageSurgeryDuration.fromJson(Map<String, dynamic> json) {
  //   String name = json.keys.first.toString();
  //   name = name.replaceAll(RegExp(r'^\s*Dr\s*'), '');
  //   return AverageSurgeryDuration(
  //     doctorName: name.trim(),
  //     avgDuration: json.values.first.toString() ?? '',
  //   );
  // }

  double getDuration() {
    List<String> parts = avgDuration.split(':');
    if (parts.length == 3) {
      double? hours = double.tryParse(parts[0]);
      double? minutes = double.tryParse(parts[1]);
      double? seconds = double.tryParse(parts[2]);

      print('hours $hours');
      print('minutes $minutes');
      print('seconds $seconds');

      if (hours != null && minutes != null && seconds !=null) {
        //double totalHours = hours + (minutes / 100);
        double totalMinutes = minutes + (seconds/100);
        return double.parse(totalMinutes.toStringAsFixed(2));
      } else {
        throw FormatException("Invalid duration format-2");
      }
    } else {
      throw FormatException("Invalid duration format");
    }
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

// class MonitoringStepsData {
//   final String otNumber;
//   final String avgInductionDuration;
//   final String avgPaintingAndDrapingDuration;
//   final String avgIncisionDuration;
//
//   MonitoringStepsData({
//     required this.otNumber,
//     required this.avgInductionDuration,
//     required this.avgPaintingAndDrapingDuration,
//     required this.avgIncisionDuration,
//   });
//
//   factory MonitoringStepsData.fromJson(Map<String, dynamic> json) {
//     return MonitoringStepsData(
//       otNumber: json['ot_number'].toString(),
//       avgInductionDuration: json['avg_induction_duration'].toString(),
//       avgPaintingAndDrapingDuration: json['avg_painting_and_draping_duration'].toString(),
//       avgIncisionDuration: json['avg_incision_duration'].toString(),
//     );
//   }
// }
