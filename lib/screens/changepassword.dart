import 'package:attendance/screens/EventAttendance.dart';
import 'package:attendance/screens/admin_home_Screen.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/lists_data.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _auth = FirebaseAuth.instance;
  String current_password='';
  String new_password="";
  String confirm_password="";
  bool isFlag1 = false;
  bool isFlag2 = false;
  bool isFlag3 = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
                          "Change Password",
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
                      controller: _currentPasswordController,
                      obscureText: isFlag1?false:true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.security),
                        hintText: "Current Password",
                        hintStyle:TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0),),
                          borderSide: BorderSide.none,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        suffixIcon: IconButton(
                          icon: isFlag1?Icon(Icons.visibility_off):Icon(Icons.remove_red_eye),
                          onPressed: (){
                            if(isFlag1){
                              setState(() {
                                isFlag1=false;
                              });
                            }
                            else{
                              setState(() {
                                isFlag1=true;
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value){
                        current_password=value;
                      },
                    ),
                  ),
                  SizedBox(height: 30.0,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextField(
                      controller: _newPasswordController,
                      obscureText: isFlag2?false:true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.security),
                        hintText: "New Password",
                        hintStyle:TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0),),
                          borderSide: BorderSide.none,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        suffixIcon: IconButton(
                          icon: isFlag2?Icon(Icons.visibility_off):Icon(Icons.remove_red_eye),
                          onPressed: (){
                            if(isFlag2){
                              setState(() {
                                isFlag2=false;
                              });
                            }
                            else{
                              setState(() {
                                isFlag2=true;
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value){
                        new_password=value;
                      },
                    ),
                  ),
                  SizedBox(height: 30.0,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: isFlag3?false:true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.security),
                        hintText: "Confirm Password",
                        hintStyle:TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0),),
                          borderSide: BorderSide.none,
                        ),

                        filled: true,
                        fillColor: Colors.white,

                        suffixIcon: IconButton(
                          icon: isFlag3?Icon(Icons.visibility_off):Icon(Icons.remove_red_eye),
                          onPressed: (){
                            if(isFlag3){
                              setState(() {
                                isFlag3=false;
                              });
                            }
                            else{
                              setState(() {
                                isFlag3=true;
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value){
                        confirm_password=value;
                      },
                    ),
                  ),
                  SizedBox(height: 25.0,),
                  TextButton(onPressed:() async{
                    if (new_password == confirm_password){
                      try {
                        // Get current user
                        User? user = _auth.currentUser;

                        if (user != null) {
                          // Re-authenticate the user
                          AuthCredential credential = EmailAuthProvider.credential(
                            email: user.email!,
                            password: current_password,
                          );

                          await user.reauthenticateWithCredential(credential);

                          // Update the password
                          await user.updatePassword(new_password);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password changed successfully!')),
                          );

                          // Clear text fields after successful password change
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.message}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('New password and confirmation do not match!')),
                      );
                    }
                  } , child: Text(
                    "Change Password",
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
