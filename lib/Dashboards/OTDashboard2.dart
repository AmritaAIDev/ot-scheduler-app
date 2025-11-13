import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_flutter_app/config/customThemes/MyAppBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../config/constants.dart';
import '../config/customThemes/elevatedButtonTheme.dart';

class OTDashboard2 extends StatefulWidget {
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  OTDashboard2({required this.selectedFromDate, required this.selectedToDate});

  @override
  _OTDashboardState createState() => _OTDashboardState();
}

class _OTDashboardState extends State<OTDashboard2> {
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

  static const double leftMargin = 220;
  static const double rightMargin = 120;
  static const double gap_for_calender = 15;
  String displayText1 = 'OT Dashboard';
  String displayText2 = 'Comprehensive Overview of OT Metrics';
  String calenderHintText = 'Select the Date';

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

    chartData.clear();
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
            timeDifference: '${double.parse(item['avg_time_difference'])*3600}'));
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
                  'induction':
                      item['avg_induction_duration'].toString(),
                  'painting&draping':
                      item['avg_painting_and_draping_duration'].toString(),
                  'incision':
                      item['avg_incision_duration'].toString(),
                  'pre_op_to_ot': item['avg_pre_op_to_ot'].toString(),
                  'extubation':
                      item['avg_extubation_duration'].toString(),
                  'incision_to_extubation':
                      item['avg_incision_to_extubation'].toString(),
                  'wheeling':
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

  Widget _buildLineChart<T>(
      List<T> data, String xAxisTitle, String yAxisTitle) {

    Color? barColor = Colors.blueGrey[100]; // Default color
    String legendItemText = 'Data';
    String chartTitleText = 'Chart Title';
    if (T == SurgeryData) {
      barColor = Colors.blueGrey;
      legendItemText = 'Surgery Count';
      chartTitleText = 'Surgery Count';
    } else if (T == UtilisationData) {
      barColor = Colors.cyan.shade200;
      legendItemText = 'Utilisation Percentage';
      chartTitleText = 'Utilisation Percentage';
    } else if (T == AvgTimeDifferenceData) {
      barColor = Colors.cyan[50];
      legendItemText = 'Average Time Difference';
      chartTitleText = 'Average Time Difference';
    }

    else if (T == AuxiliaryClass) {
      barColor = Colors.cyan.shade200;
      legendItemText = 'Average Time per Step';
      chartTitleText = 'Average Time per Step';
    }

    return SfCartesianChart(
      //isTransposed: true,
      //backgroundColor: Colors.grey[200],

      title: ChartTitle(
          text: chartTitleText,
          //backgroundColor: Colors.grey,
          //borderColor: Colors.blue,
          borderWidth: 2,
          // Aligns the chart title to left
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            color: Colors.blueGrey,
            fontFamily: 'Roboto',
            //fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
            text: xAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold)),
        //majorGridLines: const MajorGridLines(width: 0)
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
            text: yAxisTitle,
            textStyle: TextStyle(fontWeight: FontWeight.bold)),

        //majorGridLines: const MajorGridLines(width: 0),
      ),
      legend: Legend(isVisible: false, position: LegendPosition.top),

      series: <LineSeries<T, String>>[
        LineSeries<T, String>(
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
              return (data
                  .utilisationPercentage); // Convert to double for UtilisationData
            } else if (data is AvgTimeDifferenceData) {
              return double.tryParse(data.timeDifference);
            } else if (data is AuxiliaryClass) {
              return double.tryParse(data.duration);
            }
            return 0; // Default case
          },
          width: 0.6,
          //color: barColor,
          //name:  ' ',
          markerSettings: MarkerSettings(
            isVisible: true, // Set to true to show markers
            shape: DataMarkerType.circle, // Marker shape
            borderColor: Colors.blue, // Border color of the marker
            borderWidth: 2, // Border width of the marker
          ),

          // Show data labels at data points
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            // Set to true to show data labels
            textStyle: TextStyle(
              color: Colors.black, // Text color for data labels
              fontSize: 12, // Font size for data labels
            ),
            labelAlignment: ChartDataLabelAlignment.middle,
            // Customize the shape of the data label to be circular
            useSeriesColor: true,
            borderRadius: 10, // Border radius for circular effect
            labelPosition: ChartDataLabelPosition.inside,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaChart<T>(List<T> data, String xAxisTitle, String yAxisTitle) {
    Color? barColor = Colors.blueGrey[100]; // Default color
    String legendItemText = 'Data';
    String chartTitleText = 'Chart Title';
    if (T == SurgeryData) {
      barColor = Colors.blueGrey;
      legendItemText = 'Surgery Count';
      chartTitleText = 'Surgery Count';
    } else if (T == UtilisationData) {
      barColor = Colors.cyan.shade200;
      legendItemText = 'Utilisation Percentage';
      chartTitleText = 'Utilisation Percentage';
    } else if (T == AvgTimeDifferenceData) {
      barColor = Colors.cyan[50];
      legendItemText = 'Average Time Difference';
      chartTitleText = 'Average Time Difference';
    }

    else if (T == AuxiliaryClass) {
      barColor = Colors.cyan.shade200;
      legendItemText = 'Average Time per Step';
      chartTitleText = 'Average Time per Step';
    }

    // final List<Color> color = <Color>[];
    // color.add(Colors.deepOrange[50]!);
    // color.add(Colors.deepOrange[200]!);
    // color.add(Colors.deepOrange);
    //
    // final List<double> stops = <double>[];
    // stops.add(0.0);
    // stops.add(0.5);
    // stops.add(1.0);
    //
    // final LinearGradient gradientColors =
    // LinearGradient(colors: color, stops: stops);

    return SfCartesianChart(
      //isTransposed: true,
      //backgroundColor: Colors.grey[200],
      title: ChartTitle(
          text: chartTitleText,
          //backgroundColor: Colors.grey,
          //borderColor: Colors.blue,
          borderWidth: 2,
          // Aligns the chart title to left
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            color: Colors.blueGrey,
            fontFamily: 'Roboto',
            //fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),

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
      legend: Legend(isVisible: false, position: LegendPosition.top),

      series: <AreaSeries<T, String>>[
        AreaSeries<T, String>(
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
          //width: 0.2,
          color: barColor,
          //color: Colors.deepOrange[300],
          borderDrawMode: BorderDrawMode.top,
          borderColor: Colors.green,
          name: 'Data',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            color: barColor,
            textStyle: TextStyle(color: Colors.black, fontSize: 10),
          ),
          legendIconType: LegendIconType.circle,
          legendItemText: legendItemText,
          //gradient: gradientColors

        ),
      ],
    );
  }


  Widget _buildBarChart<T>(List<T> data, String xAxisTitle, String yAxisTitle) {
    Color? barColor = Colors.blueGrey[100]; // Default color
    String legendItemText = 'Data';
    String chartTitleText = 'Chart Title';
    if (T == SurgeryData) {
      barColor = Colors.blueGrey;
      legendItemText = 'Surgery Count';
      chartTitleText = 'Surgery Count';
    } else if (T == UtilisationData) {
      barColor = Colors.blueGrey;
      legendItemText = 'Utilisation Percentage';
      chartTitleText = 'Utilisation Percentage';
    } else if (T == AvgTimeDifferenceData) {
      barColor = Colors.redAccent[200];
      legendItemText = 'Average Time Difference';
      chartTitleText = 'Average Time Difference';
    }

    else if (T == AuxiliaryClass) {
      barColor = Colors.cyan.shade200;
      legendItemText = 'Average Time per Step';
      chartTitleText = 'Average Time per Step';
    }

    return SfCartesianChart(
      isTransposed: true,
      //backgroundColor: Colors.grey[200],
      title: ChartTitle(
          text: chartTitleText,
          //backgroundColor: Colors.grey,
          //borderColor: Colors.blue,
          borderWidth: 2,
          // Aligns the chart title to left
          alignment: ChartAlignment.center,
          textStyle: TextStyle(
            color: Colors.blueGrey,
            fontFamily: 'Roboto',
            //fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )),

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
      legend: Legend(isVisible: false, position: LegendPosition.top),
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
        padding: const EdgeInsets.only(
          left: leftMargin,
          right: 20,
          top: 10,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('OT Dashboard',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              //SizedBox(height: 1),
              // Text(displayText2,
              //     style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              //Text(displayText2, style: Theme.of(context).textTheme.subtitle1),
              Divider(
                color: Colors.blueGrey[50],
                thickness: 2,
                endIndent: 500,
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                //crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  Text(
                    'From Date',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  SizedBox(width: gap_for_calender),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: TextField(
                      textAlign: TextAlign.center,
                      // textAlignVertical: TextAlignVertical.center,
                      controller: fromDateController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: calenderHintText,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        //constraints: BoxConstraints.tightFor(),
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  SizedBox(width: gap_for_calender),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Circular shape
                      color: Colors.blueGrey, // Lavender background color
                    ),
                    child: IconButton(
                      onPressed: () => _selectFromDate(context),
                      icon: Icon(Icons.calendar_month_outlined),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 205),
                  Text(
                    'To Date',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  SizedBox(width: gap_for_calender),
                  SizedBox(
                    width: 180,
                    height: 40,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: toDateController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: calenderHintText,
                        //hintStyle: TextStyle(decorationStyle: text),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        //constraints: BoxConstraints.tightFor(),
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                  SizedBox(width: gap_for_calender),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Circular shape
                      color: Colors.blueGrey, // Lavender background color
                    ),
                    child: IconButton(
                      onPressed: () => _selectToDate(context),
                      icon: Icon(Icons.calendar_month_outlined),
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 50),
                  Container(
                    width: 150,
                    child: ElevatedButton(
                        style: MyElevatedButtonTheme.elevatedButtonTheme2.style,
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
              SizedBox(
                height: 50,
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   width: 200,
                        //   height: 40,
                        //   child: Text("Surgeries",
                        //       //textAlign: TextAlign.center,
                        //       style: TextStyle(
                        //           fontSize: 25, color: Colors.blueGrey)),
                        // ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.blueGrey.shade50,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 1000,
                          height: 400,
                          child: _buildLineChart(
                              chartData, 'OT Number', 'Surgery Count'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 75),
                  Container(
                    // width: 400,
                    // height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text("Utilisation",
                        //     //textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //         fontSize: 25, color: Colors.blueAccent)),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.blueGrey.shade50,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 1000,
                          height: 400,
                          child: _buildBarChart(utilisationData, 'OT Number',
                              'Utilization Percentage'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 75),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   width: 200,
                        //   height: 40,
                        //   // child: Text("Time Difference",
                        //   //     //textAlign: TextAlign.center,
                        //   //     style:
                        //   //     TextStyle(fontSize: 25, color: Colors.blueGrey)),
                        // ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.blueGrey.shade50,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 1000,
                          height: 400,
                          child: _buildLineChart(avgTimeDifferenceData,
                              'OT Number', 'Average Time Difference'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 75),
                  Container(
                    // width: 400,
                    // height: 50,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text("Utilisation",
                        //     //textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //         fontSize: 25, color: Colors.blueAccent)),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.blueGrey.shade50,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 1000,
                          height: 480,
                          child: Column(
                            children: [
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'SELECT  OT',
                                    //textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey),
                                  ),
                                  SizedBox(width: 20),
                                  SizedBox(
                                    width: 100,
                                    height: 35,
                                    child: DropdownButtonFormField(
                                        items: dropdownItems,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.fromLTRB(35, 0, 15, 0),
                                          //hintText: 'Select OT Number',
                                          //hintStyle: TextStyle(decorationStyle: text),
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                          filled: true,
                                          //constraints: BoxConstraints.tightFor(),
                                          fillColor: Colors.grey[50],
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
                                  SizedBox(height: 30),
                                  // Container(
                                  //   width: 100,
                                  //   child: DropdownButtonFormField(
                                  //       items: dropdownItems,
                                  //       decoration: InputDecoration(
                                  //         labelText: 'Select OT',
                                  //         border: OutlineInputBorder(
                                  //             borderRadius: BorderRadius.circular(10)),
                                  //       ),
                                  //       value: selectedOT,
                                  //       //hint: Text('Select OT'),
                                  //       onChanged: (String? newValue) {
                                  //         setState(() {
                                  //           selectedOT = newValue!;
                                  //           _getStepsAverage();
                                  //         });
                                  //       }),
                                  // ),
                                ],
                              ),
                              Container(
                                // width: 1000,
                                height: 400,
                                child: chartData2.isNotEmpty
                                    ? _buildAreaChart(chartData2, 'OT', 'Average Time')
                                    : Center(
                                  child: Text(
                                    'No data available',
                                    style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),



              // Row(
              // children: [
              //   Text(
              //     'OT NUMBER',
              //     style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.blueGrey),
              //   ),
              //   SizedBox(width: 20),
              //   SizedBox(
              //     width: 180,
              //     height: 50,
              //     child: DropdownButtonFormField(
              //         items: dropdownItems,
              //         decoration: InputDecoration(
              //           labelText: 'Select OT',
              //           border: OutlineInputBorder(
              //               borderRadius: BorderRadius.circular(10)),
              //         ),
              //         value: selectedOT,
              //         //hint: Text('Select OT'),
              //         onChanged: (String? newValue) {
              //           setState(() {
              //             selectedOT = newValue!;
              //             _getStepsAverage();
              //           });
              //         }),
              //   ),
              //   SizedBox(height: 25),
              //   // Container(
              //   //   width: 100,
              //   //   child: DropdownButtonFormField(
              //   //       items: dropdownItems,
              //   //       decoration: InputDecoration(
              //   //         labelText: 'Select OT',
              //   //         border: OutlineInputBorder(
              //   //             borderRadius: BorderRadius.circular(10)),
              //   //       ),
              //   //       value: selectedOT,
              //   //       //hint: Text('Select OT'),
              //   //       onChanged: (String? newValue) {
              //   //         setState(() {
              //   //           selectedOT = newValue!;
              //   //           _getStepsAverage();
              //   //         });
              //   //       }),
              //   // ),
              // ],
              //                   ),
              // Row(children: [
              //   Container(
              //     width: 1000,
              //     height: 400,
              //     child: chartData2.isNotEmpty
              //         ? _buildBarChart(chartData2, 'OT', 'Average Time')
              //         : Center(
              //       child: Text(
              //         'No data available',
              //         style: TextStyle(
              //             fontSize: 20, fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),
              // ]),
              //SizedBox(height: 40),
              // Divider(
              //   color: Colors.black,
              //   thickness: 2,
              // ),

              //SizedBox(height: 30),
              //SizedBox(height: 20),

              //SizedBox(height: 20),
              // Divider(
              //   color: Colors.black,
              //   thickness: 2,
              // ),
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 400,
              //       height: 50,
              //       child: Text("Utilisation",
              //           textAlign: TextAlign.center,
              //           style:
              //           TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //     ),
              //   ],
              // ),
              // Row(children: [
              //   Expanded(
              //     //width: 500,
              //     child: _buildBarChart(
              //         utilisationData, 'OT Number', 'Utilization Percentage'),
              //   ),
              // ]),
              // SizedBox(height: 20),
              // Divider(
              //   color: Colors.black,
              //   thickness: 2,
              // ),
              // SizedBox(height: 20),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 400,
              //       height: 50,
              //       child: Text("Average time taken per Step for OT",
              //           textAlign: TextAlign.center,
              //           style:
              //           TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //     ),

              // Container(
              //   // width: 400,
              //   // height: 50,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     children: [
              //       // Text("Utilisation",
              //       //     textAlign: TextAlign.center,
              //       //     style:
              //       //     TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //       Container(
              //         decoration: BoxDecoration(
              //           border: Border.all(
              //             width: 2,
              //             color: Colors.blueGrey.shade50,
              //           ),
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //         width: 1000,
              //         height: 400,
              //         child:
              //         _buildBarChart(utilisationData, 'OT Number', 'Utilization Percentage'),
              //       ),
              //
              //
              //     ],
              //   ),
              // ),
              //   ],
              // ),
              // SizedBox(height: 20),
              // Row(children: [
              //   Expanded(
              //     //width: 500,
              //     child: chartData2.isNotEmpty
              //         ? _buildBarChart(chartData2, 'OT', 'Average Time')
              //         : Center(
              //       child: Text(
              //         'No data available',
              //         style: TextStyle(
              //             fontSize: 20, fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ),
              // ]),
              // SizedBox(height: 20),
              // Divider(
              //   color: Colors.black,
              //   thickness: 2,
              // ),
              // SizedBox(height: 20),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 400,
              //       height: 50,
              //       child: Text("Average Time Difference",
              //           textAlign: TextAlign.center,
              //           style:
              //           TextStyle(fontSize: 25, color: Colors.blueAccent)),
              //     ),
              //   ],
              // ),
              // Row(children: [
              //   Expanded(
              //     //width: 500,
              //     child: _buildBarChart(avgTimeDifferenceData, 'OT Number',
              //         'Average Time Difference'),
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
