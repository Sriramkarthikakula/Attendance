
import 'package:attendance/screens/Profile.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:flutter/material.dart';
class Aftersubmit extends StatelessWidget {
  const Aftersubmit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb6d3f5),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.done_outlined,size: 50.0,),
            Text("Your Attendance Successfully Submitted"),
            TextButton(onPressed:(){ Navigator.push(context, MaterialPageRoute(builder: (context){return Faculty_main();}));}, child: Text("Back"),),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context){
              return Profile();
            }));
          },
          child: Icon(Icons.account_circle),
        ),
      ),
    );
  }
}
