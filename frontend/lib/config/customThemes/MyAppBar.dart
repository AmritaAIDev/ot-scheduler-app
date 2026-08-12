import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {

  static const int myToolbarHeight = 70;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      //toolbarHeight: myToolbarHeight.toDouble(),
      title: const Text('OT Tracker',style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),),
      //centerTitle: true,
      actions: [
        TextButton.icon(onPressed: () {}, icon: Icon(Icons.dashboard, color: Colors.blueGrey), label: Text("Dashboard", style: TextStyle(fontSize: 16, color: Colors.black))),
        TextButton.icon(onPressed: () {}, icon: Icon(Icons.list, color: Colors.blueGrey), label: Text("Patient List", style: TextStyle(fontSize: 16, color: Colors.black))),
        TextButton.icon(onPressed: () {}, icon: Icon(Icons.schedule_outlined, color: Colors.blueGrey), label: Text("Scheduler", style: TextStyle(fontSize: 16, color: Colors.black))),
        TextButton.icon(onPressed: () {}, icon: Icon(Icons.settings, color: Colors.blueGrey), label: Text("Settings", style: TextStyle(fontSize: 16, color: Colors.black))),

      ],
      backgroundColor: Colors.grey[100],
      // bottom:  PreferredSize(
      //   preferredSize: Size.fromHeight(1.0),
      //   // Set the height of the divider
      //   child: Divider(
      //     thickness: 2,
      //       color: Colors.blue.shade50), // Divider below the app bar title
      // ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(myToolbarHeight as double);

}