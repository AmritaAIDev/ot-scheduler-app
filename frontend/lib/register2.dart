import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:my_flutter_app/MenuPage.dart';
// import 'package:my_flutter_app/TimeMonitoring/PatientListScreen.dart';
// import 'package:my_flutter_app/OTSchedule/OTScheduleScreen.dart';
// import 'package:my_flutter_app/register.dart';


class Register2 extends StatefulWidget {
  const Register2({Key? key}) : super(key: key);

  @override
  _Register2State createState() => _Register2State();
}

class _Register2State extends State<Register2> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[

            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(150, 10, 150, 0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.jpeg', // Path to your logo image asset
                    width: 180, // Adjust the width as needed
                    height: 180, // Adjust the height as needed
                  ),
                  const SizedBox(height: 10), // Add spacing between logo and text
                  const Text(
                    'AMRITA  OT-SCHEDULER',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(150, 10, 150, 0),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.fromLTRB(150, 60, 150, 0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(150, 30, 150, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(150, 10, 150, 10),
              child: TextButton(
                onPressed: () {
                  //forgot password screen
                },
                child: const Text('Forgot Password',
                  style: TextStyle(
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            Container(
                height: 50,
                //width: 25,
                padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent,
                      textStyle: TextStyle(color: Colors.white)),
                  child: const Text('Register',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),),
                  onPressed: () {
                    // // print(nameController.text);
                    // // print(passwordController.text);
                    //
                    // String username = nameController.text.trim();
                    //
                    // // Check for specific usernames
                    // if (username == 'abcd' || username == 'doctor') {
                    //   // Navigate to OTScheduleScreen if the username matches
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => MenuPage()),
                    //   );
                    // } else {
                    //   // Navigate to PatientListScreen for other usernames
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => PatientListScreen()),
                    //   );
                    // }

                  },
                )
            ),
            // Row(
            //   children: <Widget>[
            //     const Text('Does not have account?'),
            //     TextButton(
            //       child: const Text(
            //         'Register',
            //         style: TextStyle(fontSize: 20,decoration: TextDecoration.underline),
            //       ),
            //       onPressed: () {
            //         // Navigator.push(
            //         //   context,
            //         //   MaterialPageRoute(
            //         //     builder: (context) =>
            //         //         Register(),
            //         //   ),
            //         // );
            //       },
            //     )
            //   ],
            //   mainAxisAlignment: MainAxisAlignment.center,
            // ),
          ],
        ));
  }
}
