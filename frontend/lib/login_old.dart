import 'package:flutter/material.dart';
import 'package:my_flutter_app/MenuPage.dart';
import 'package:my_flutter_app/TimeMonitoring/PatientListScreen.dart';
import 'package:my_flutter_app/OTSchedule/OTScheduleScreen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Get the entered username
                  String username = _usernameController.text.trim();

                  // Check for specific usernames
                  if (username == 'abcd' || username == 'doctor') {
                    // Navigate to OTScheduleScreen if the username matches
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage()),
                    );
                  } else {
                    // Navigate to PatientListScreen for other usernames
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PatientListScreen()),
                    );
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
