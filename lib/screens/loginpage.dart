import 'package:attendance/screens/admin_home_Screen.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/lists_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String username='';
  String password='';
  bool isFlag = false;
  Future<void> loginfun(String username,String role,profileimage) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Username', username);
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('role', role);
    await prefs.setString('display_image', profileimage);
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
                          "Login To ",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "SRKR",
                          style: TextStyle(
                            fontSize: 20.0,
                            letterSpacing: 3.0,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Text(
                    "Online Attendance",
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextField(
                      obscureText: isFlag?false:true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.security),
                        hintText: "Password",
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
                          icon: isFlag?Icon(Icons.visibility_off):Icon(Icons.remove_red_eye),
                          onPressed: (){
                            if(isFlag){
                              setState(() {
                                isFlag=false;
                              });
                            }
                            else{
                              setState(() {
                                isFlag=true;
                              });
                            }
                          },
                        ),
                      ),
                      onChanged: (value){
                        password=value;
                      },
                    ),
                  ),
                  SizedBox(height: 25.0,),
                  TextButton(onPressed:() async{
                    try{
                      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: username, password: password);
                      final User? user = userCredential.user;
                      if(user!=null){
                        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                            .collection('Faculty_Data')
                            .where('email', isEqualTo: user.email)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          DocumentSnapshot userDoc = querySnapshot.docs.first;
                          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
                          String role = data['faculty_status'];
                          String email = data['email'];
                          displayimageURL = data['display_image'];
                          if (role == "admin") {
                            await loginfun(email, role,displayimageURL);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return AdminPage();
                              }),
                            );
                          } else {
                            await loginfun(email, role,displayimageURL);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return Faculty_main();
                              }),
                            );
                          }
                        } else {
                          print("User document does not exist");
                        }
                      } else {
                        print("User not found");
                      }
                    } catch (e) {
                      print("Error: $e");
                    }
                  } , child: Text(
                    "Login",
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
