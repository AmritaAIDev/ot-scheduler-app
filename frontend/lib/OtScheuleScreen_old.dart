import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_flutter_app/TimeMonitoring/PatientListScreen.dart'; // Import PatientListScreen.dart

class OTScheduleScreen extends StatefulWidget {
  @override
  _OTScheduleScreenState createState() => _OTScheduleScreenState();
}

class _OTScheduleScreenState extends State<OTScheduleScreen> {
  File? _file;
  String _notificationMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'OT Schedule',
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
              // File upload section
              GestureDetector(
                onTap: () {
                  _pickFile();
                },
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 50), // Icon indicating upload
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _pickFile();
                      },
                      child: Text('Upload'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(_notificationMessage), // Notification message
              SizedBox(height: 20),
              // Schedule button
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        // File picked successfully
        setState(() {
          _file = File(result.files.single.path!);
          _notificationMessage = 'File selected: ${_file!.path}';
        });
      } else {
        // User canceled the file picking
        setState(() {
          _notificationMessage = 'No file selected';
        });
      }
    } catch (e) {
      // Error picking file
      print('Error picking file: $e');
      setState(() {
        _notificationMessage = 'Error picking file: $e';
      });
    }
  }
}
