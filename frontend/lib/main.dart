import 'package:flutter/material.dart';
import 'package:my_flutter_app/login.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static const String _title = 'Sample App';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OT Scheduler',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      home: Scaffold(
        //appBar: AppBar(title: const Text(_title)),
        body: Login(),
      ),
    );
  }
}


// class PatientDetailsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Patient Details'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Add patient details segments and buttons here
//           ],
//         ),
//       ),
//     );
//   }
//}
