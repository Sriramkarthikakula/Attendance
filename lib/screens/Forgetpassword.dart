import 'package:attendance/screens/EventAttendance.dart';
import 'package:attendance/screens/admin_home_Screen.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/lists_data.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final _auth = FirebaseAuth.instance;
  String username='';
  String password='';
  bool isFlag = false;
  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Column(

                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images.jpeg'),
                      radius: 40.0,
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Forget Password",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.account_circle),
                        hintText: "Username",
                        hintStyle:TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0),),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,

                      ),
                      onChanged: (value){
                        username=value;
                      },
                    ),
                  ),
                  SizedBox(height: 30.0,),
                  TextButton(onPressed:() async{
                    try{
                      if(username!=""){
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                            .collection('Faculty_Data')
                            .where('email', isEqualTo: username)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          _resetPassword(username); // Call reset password method

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User not exsist')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter your email')),
                        );
                      }
                    } catch (e) {
                      print("Error: $e");
                    }
                  } , child: Text(
                    "Reset Password",
                  ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xff2D3250)),
                      minimumSize: MaterialStateProperty.all(Size(150.0, 50.0),),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Adjust the border radius as needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
