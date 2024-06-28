import 'package:attendance/screens/Faculty_History.dart';
import 'package:attendance/screens/Overall_attendance.dart';
import 'package:attendance/screens/loginpage.dart';
import 'package:attendance/screens/search_by_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/lists_data.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? curr;
  final _auth = FirebaseAuth.instance;
@override
  void initState() {

    curr = _auth.currentUser!.email;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF5FF),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(50.0),topLeft: Radius.circular(50.0),),
        ),
        width: double.infinity,
        margin: EdgeInsets.only(top: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 35.0,left: 25.0),
              child: TextButton(
                onPressed: (){
                Navigator.pop(context);
              },
                child: Icon(Icons.arrow_back_ios_rounded, size: 18.0,),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  elevation: MaterialStateProperty.all(5.0),
                  shape: MaterialStateProperty.all<CircleBorder>(
                    CircleBorder(),
                  ),
                  shadowColor: MaterialStateProperty.all(Colors.black),
                ),
              ),
            ),
           SizedBox(height: 30.0,),
           Center(
             child: Column(
               children: [
                 ClipRRect(
                     borderRadius: BorderRadius.circular(26.0), // Set your desired border radius
                     child: Image.network(displayimageURL==""?
                       'https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8cHJvZmlsZXxlbnwwfHwwfHx8MA%3D%3D':displayimageURL,
                       width: 140.0,
                       height: 140.0,
                       fit: BoxFit.cover,
                     ),
             ),
                 SizedBox(height: 20.0,),
                 Text(curr!,
                 style: TextStyle(
                   fontSize: 20.0,
                   fontWeight: FontWeight.bold,
                 ),),
                 SizedBox(height: 8.0,),
                 Text("Asst Professor"),
                 SizedBox(height: 40.0,),
                 Container(
                   margin: EdgeInsets.symmetric(horizontal: 25.0),
                   padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 15.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.all(Radius.circular(25.0)),
                     color: Colors.white,
                     boxShadow: [BoxShadow(
                       color: Colors.grey.withOpacity(0.3), // Set the shadow color
                       spreadRadius: 2, // Set the spread radius of the shadow
                       blurRadius: 4, // Set the blur radius of the shadow
                       offset: Offset(0, 3), // Set the offset of the shadow
                     ),]
                   ),
                   child: Column(
                     children: [
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context){
                             return Overall_Attendance();
                           }));
                         },
                         child: ListTile(
                           leading: Icon(Icons.login_rounded),
                           title: Text("OverAll Attendance"),
                           trailing: Icon(Icons.arrow_forward_ios_sharp),
                         ),
                       ),
                       Container(
                         height: 1, // Adjust the height of the line
                         color: Colors.black.withOpacity(0.2), // Set the color of the line
                         margin: EdgeInsets.symmetric(vertical: 20), // Adjust the margin if needed
                       ),
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context){
                             return Faculty_History_Number();
                           }));
                         },
                         child: ListTile(
                           leading: Icon(Icons.login_rounded),
                           title: Text("Search By Number"),
                           trailing: Icon(Icons.arrow_forward_ios_sharp),
                         ),
                       ),
                       Container(
                         height: 1, // Adjust the height of the line
                         color: Colors.black.withOpacity(0.2), // Set the color of the line
                         margin: EdgeInsets.symmetric(vertical: 20), // Adjust the margin if needed
                       ),
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context){
                             return Faculty_History();
                           }));
                         },
                         child: ListTile(
                           leading: Icon(Icons.search),
                           title: Text("Attendance History"),
                           trailing: Icon(Icons.arrow_forward_ios_sharp),
                         ),
                       ),
                       Container(
                         height: 1, // Adjust the height of the line
                         color: Colors.black.withOpacity(0.2), // Set the color of the line
                         margin: EdgeInsets.symmetric(vertical: 20), // Adjust the margin if needed
                       ),
                       GestureDetector(
                         onTap: () async{
                           SharedPreferences prefs = await SharedPreferences.getInstance();
                           await prefs.setBool('isLoggedIn', false);
                           _auth.signOut();
                           Navigator.of(context).pushAndRemoveUntil(
                             MaterialPageRoute(builder: (context) => LoginPage()),
                                 (Route<dynamic> route) => false,
                           );
                         },
                         child: ListTile(
                           leading: Icon(Icons.logout_outlined),
                           title: Text("Logout"),
                           trailing: Icon(Icons.arrow_forward_ios_sharp),
                         ),
                       ),
                     ],
                   )
                 ),
               ]
             ),
           ),
          ],
        ),
      ),
    );
  }
}
