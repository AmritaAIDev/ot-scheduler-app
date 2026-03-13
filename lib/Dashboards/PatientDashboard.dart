import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../config/constants.dart';

class PatientDashboard extends StatefulWidget {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  PatientDashboard(
      {required this.selectedFromDate, required this.selectedToDate});

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  late TextEditingController fromDateController;
  late TextEditingController toDateController;
  late DateTime selectedFromDate;
  late DateTime selectedToDate;
  List<AgeDistributionData> chartData = [];

  //List<SurgeryData> chartData = [];
  Map<String, double> dataMap = {};
  final colorList = <Color>[
    Colors.greenAccent,
  ];

  // List<AverageSurgeryDuration> avgSurgeryDurationData = [];

  String baseUrl = Constants.baseURL;

  @override
  void initState() {
    super.initState();
    selectedFromDate = widget.selectedFromDate!;
    selectedToDate = widget.selectedToDate!;
    _getGenderDistribution();
    _getAgeDistribution();
    // _getAverageSurgeryDuration();

    print('initState()-selectedFromDate: $selectedFromDate');
    fromDateController =
        TextEditingController(text: _formatDate(selectedFromDate));
    toDateController = TextEditingController(text: _formatDate(selectedToDate));
    //_otUtilization();
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
    //return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _getGenderDistribution() async {
    String apiUrl = '$baseUrl/gender-distribution/';

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
      print(
          '_getGenderDistribution(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      List<dynamic> genderDistributionList = responseData['message'];
      double totalPercentage = 0.0;
      dataMap.clear(); // Clear previous data

      // Calculate total percentage and update dataMap
      for (var item in genderDistributionList) {
        Map<String, dynamic> genderData = item;
        if (genderData.containsKey('Female')) {
          double femalePercentage = genderData['Female'];
          dataMap['Female'] = femalePercentage;
          totalPercentage += femalePercentage;
        } else if (genderData.containsKey('Male')) {
          double malePercentage = genderData['Male'];
          dataMap['Male'] = malePercentage;
          totalPercentage += malePercentage;
        }
      }

      // Check if total percentage is less than 100 and add blank entry if needed
      if (totalPercentage < 100.0) {
        dataMap['Not Specified'] = 100.0 - totalPercentage;
      }

      setState(() {
        // Update the state to trigger a rebuild with the new dataMap
      });
    } else {
      // Handle error cases
      print('Error receiving data from the backend: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  void _getAgeDistribution() async {
    String apiUrl = '$baseUrl/age-distribution/';

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
      print(
          '_getAgeDistribution(): Data Received from the backend successfully.');

      // Parse the JSON response
      Map<String, dynamic> responseData = jsonDecode(response.body);

      print(responseData);

      List<dynamic> ageDistributionList = responseData['age_distribution'];

      for(var item in ageDistributionList){
        print(item.runtimeType);//_JsonMap
        print(item['age_group']);
      }

      print('ageDistributionList:$ageDistributionList');
      setState(() {
        for(var item in ageDistributionList){
          chartData.add(AgeDistributionData(ageRange: item['age_group'], value: item['count']));
        }
      });

      print('chartData:$chartData');
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

  Widget _buildBarChart<T>(List<AgeDistributionData> data, String xAxisTitle, String yAxisTitle) {
    Color barColor = Colors.teal; // Default color
    String legendItemText = 'Data';

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
      series: <BarSeries<AgeDistributionData, String>>[
        BarSeries<AgeDistributionData, String>(
          dataSource: data,
          xValueMapper: (AgeDistributionData data, _) => data.ageRange,
          yValueMapper: (AgeDistributionData data, _) => data.value,
          width: 0.2,
          color: barColor,
          name: 'Data',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            color: Colors.redAccent,
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
          title: Text('Patient Dashboard'),
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
                          _getGenderDistribution();
                          _getAgeDistribution();
                        }),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //color: Color(0xFF381460),
                    width: 400,
                    height: 40,
                    child: Text("Gender distribution of Patients",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              Container(
                width: 550,
                height: 550,
                child: dataMap.isNotEmpty
                    ? PieChart(
                        dataMap: dataMap,
                        chartType: ChartType.disc,
                        centerText: "Gender Distribution of Patients",
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
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //color: Color(0xFF381460),
                    width: 400,
                    height: 40,
                    child: Text("Age distribution of Patients",
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 25, color: Colors.blueAccent)),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    //height: 400,
                    child: _buildBarChart(chartData, 'age-range', 'value'),
                  ),
                ],
              ),
              // SizedBox(height: 30),
              // Row(children: [
              //   Expanded(
              //     //width: 500,
              //     child: _buildBarChart(avgSurgeryDurationData, 'Doctor',
              //         'Average Surgery Time (hours)'),
              //   ),
              // ]),
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
}

class AgeDistributionData {
  String ageRange;
  int value;
  //double percentage;

  AgeDistributionData({required this.ageRange, required this.value});

}
