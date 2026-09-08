import 'package:flutter/material.dart';
import 'package:my_flutter_app/login.dart';
import 'package:my_flutter_app/OTSchedule/SchedulerInput.dart';
import 'package:my_flutter_app/TimeMonitoring/PatientListScreen2.dart';
import 'package:my_flutter_app/Dashboards/Dashboard2.dart';
import 'package:my_flutter_app/services/session_manager.dart';

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
      home: const SessionGate(),
    );
  }
}

/// Decides what the app should show on launch (including after a browser
/// refresh): the login screen if there's no saved session, or the correct
/// landing screen for whichever role was last logged in on this browser.
///
/// Before this existed, `MaterialApp.home` pointed straight at `Login()`, so
/// every reload looked like an unexpected logout even though no logout ever
/// happened — nothing was ever saved to check against (see
/// docs/PRD.md Gap #2 and services/session_manager.dart).
class SessionGate extends StatefulWidget {
  const SessionGate({Key? key}) : super(key: key);

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  Session? _session;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await SessionManager.restore();
    if (!mounted) return;
    setState(() {
      _session = session;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = _session;
    if (session == null) {
      return const Scaffold(body: Login());
    }

    switch (session.userType) {
      case 'Nurse':
      case 'Technician':
        return PatientListScreen2();
      case 'OT Administration':
        return SchedulerInput();
      case 'Management':
        // Note: the counts/date-range normally pre-fetched by the login
        // screen aren't available on a restored session, so the dashboard
        // opens with its tiles at 0 until the user picks a date range —
        // an acceptable trade-off versus losing the session entirely.
        // Fetching them here too is a reasonable follow-up if this is
        // noticeable in practice.
        return Dashboard2(
          otCount: 0,
          doctorsCount: 0,
          departmentCount: 0,
          procedureCount: 0,
          patientCount: 0,
          otStaffCount: 0,
          dateRangeMap: const {},
        );
      default:
        return const Scaffold(body: Login());
    }
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
