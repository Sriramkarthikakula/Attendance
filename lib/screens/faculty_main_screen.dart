import 'package:flutter/material.dart';
import 'package:attendance/screens/faculty_attendance_screen.dart';
import 'package:attendance/screens/Profile.dart';

import 'admin_profile.dart';
class Faculty_main extends StatelessWidget {
  const Faculty_main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb6d3f5),
      // appBar: AppBar(
      //   backgroundColor: Color(0xff8db4e7),
      //   title: Text('Attendance'),
      // ),
      body: Topsection(),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context){
              return AdminProfile();
            }));
          },
          child: Icon(Icons.account_circle),
        ),
      ),
    );
  }
}
