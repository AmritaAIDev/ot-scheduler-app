import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_app/login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Map userData = {};
  List<String> dropdownItems = [
    'Nurse',
    'Technician',
    'Management',
    'OT Administration'
  ];
  late String selectedDropdownItem;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool _passwordVisible = false;
  String baseUrl = 'http://10.125.11.203:8091/api';

  final _formkey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    selectedDropdownItem =
        dropdownItems[0]; // Initialize selectedDropdownItem here
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration Page', style: TextStyle(fontSize: 24)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            // Set the height of the divider
            child:
                Divider(color: Colors.grey), // Divider below the app bar title
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 150,
                          //decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(40),
                          //border: Border.all(color: Colors.blueGrey)),
                          child: Image.asset('assets/images/logo.jpeg'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(180, 15, 180, 0),
                      child: TextFormField(
                        controller: _nameController,
                        // validator: ((value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'please enter some text';
                        //   } else if (value.length < 5) {
                        //     return 'Enter atleast 5 Charecter';
                        //   }
                        //
                        //   return null;
                        // }),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter your name'),
                          MinLengthValidator(3,
                              errorText: 'Minimum 3 character filled name'),
                        ]),

                        decoration: InputDecoration(
                            hintText: 'Enter Your Name',
                            labelText: 'Name',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.green,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(180, 15, 180, 0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter the password'),
                          MinLengthValidator(4,
                              errorText:
                                  'password should be atleast 4 charater'),
                        ]),
                        decoration: InputDecoration(
                            hintText: 'Enter Your password',
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.password_rounded,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(180, 15, 180, 0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Enter email address'),
                          EmailValidator(
                              errorText: 'Please correct email filled'),
                        ]),
                        decoration: InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.lightBlue,
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(180, 15, 180, 0),
                      child: DropdownButtonFormField<String>(
                        value: selectedDropdownItem,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDropdownItem = newValue!;
                          });
                        },
                        items: dropdownItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          hintText: 'Select Role',
                          labelText: 'Select Role',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(9.0)),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: TextFormField(
                    //     validator: MultiValidator([
                    //       RequiredValidator(errorText: 'Enter mobile number'),
                    //       PatternValidator(r'(^[0,9]{10}$)',
                    //           errorText: 'enter vaid mobile number'),
                    //     ]),
                    //     decoration: InputDecoration(
                    //         hintText: 'Mobile',
                    //         labelText: 'Mobile',
                    //         prefixIcon: Icon(
                    //           Icons.phone,
                    //           color: Colors.grey,
                    //         ),
                    //         border: OutlineInputBorder(
                    //             borderSide: BorderSide(color: Colors.red),
                    //             borderRadius:
                    //             BorderRadius.all(Radius.circular(9)))),
                    //   ),
                    // ),
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(180, 15, 180, 0),
                      child: Container(
                        // margin: EdgeInsets.fromLTRB(200, 20, 50, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              textStyle: TextStyle(color: Colors.white)),
                          child: Text(
                            'Register',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              print('form submiitted');
                              // userData ={
                              //   'name': _nameController.text,
                              //   'password': _passwordController.text,
                              //   'email': _emailController.text,
                              //   'user_type': selectedDropdownItem,
                              // };
                              _registerUser();
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                            }
                          },
                        ),

                        width: MediaQuery.of(context).size.width,

                        height: 50,
                      ),
                    )),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => Login()),
                          // );
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Already Have account? SIGN IN',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ));
  }

  Future<void> _registerUser() async {
    String apiUrl = '$baseUrl/register/';
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'user_type': selectedDropdownItem
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful
        print('Registration successful!');
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                    'Confirmation.\nYou have been successfully registered'),
                //content: const Text('Thank you!!!Your inputs have been recorded successfully'),
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => Login()),
                      // );
                    },
                  ),
                ],
              );
            });
      } else {
        // Registration failed
        print('Registration failed. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }
}
