import 'package:attendance/screens/admin_home_Screen.dart';
import 'package:attendance/screens/admin_profile.dart';
import 'package:attendance/screens/faculty_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String username='';
  String password='';
  String searching = "";
  String? FacStatus;
  String UniqueName="";
  String imageurl = "";
  List<String> Status = ["Select","Professor","Assoc Professor","Asst Professor"];
  Future<void> loginfun(String username) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('Username', username);
    await prefs.setBool('isLoggedIn', true);
  }
  void PickImage() async{
    ImagePicker imagepicker = ImagePicker();
    XFile? file = await imagepicker.pickImage(source: ImageSource.gallery);
    UniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instanceFor(app:Firebase.app(),bucket:'gs://attendance-e35d5.appspot.com');
    Reference referenceDir = storage.ref().child('images');
    Reference referenceImage = referenceDir.child(UniqueName);
    File imageFile = File(file!.path);
    try{
      await referenceImage.putFile(imageFile);
      imageurl = await referenceImage.getDownloadURL();
      setState(() {
        searching = imageurl;
      });
  }
  catch(e){
      print(e);
    }

  }
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 35.0,left: 15.0),
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
              Container(
                padding: EdgeInsets.only(top: 30.0),
                child: Column(
                  children: [
                    Center(
                      child: CircleAvatar(
                        backgroundImage: AssetImage('assets/images.jpeg'),
                        radius: 40.0,
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Text("Faculty Registration",style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 30.0,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 35.0),
                      child: TextField(
                        controller: _usernameController,
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
                        controller: _passwordController,
                        obscureText: true,
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
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: null,
                          ),
                        ),
                        onChanged: (value){
                          password=value;
                        },
                      ),
                    ),
                    SizedBox(height: 30.0,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 35.0),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 100.0,
                            height: 100.0,
                            child:CircleAvatar(
                              backgroundImage: NetworkImage(searching==""?'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_640.png':searching),
                              radius: 40.0,
                            ),
                          ),
                          // Button
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextButton(
                                onPressed: (){
                                  PickImage();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.perm_media),
                                    SizedBox(width: 10.0,),
                                    Text(
                                    "Upload Image",
                                  ),
                                  ]
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color(0xff2D3250)),
                                  minimumSize: MaterialStateProperty.all(Size(150.0, 50.0)),
                                  foregroundColor: MaterialStateProperty.all(Colors.white),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25.0,),
                    Container(

                      child: DropdownMenu <String> (
                        width:MediaQuery.of(context).size.width * 0.8,
                        initialSelection: Status.first,
                        label: Text("Faculty Status"),
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            FacStatus = value!;
                          });
                        },
                        dropdownMenuEntries: Status.map<DropdownMenuEntry<String>>((String value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 25.0,),
                    TextButton(onPressed:() async{
                      try{
                        final newUserCredential = await _auth.createUserWithEmailAndPassword(
                          email: username,
                          password: password,
                        );
                        if (newUserCredential.user != null) {
                          _firestore.collection('Faculty_Data').add({
                            'email': username,
                            'display_image': searching,
                            'faculty_status':FacStatus,
                          });
                          // User registered successfully
                          setState(() {
                            searching="";
                          });
                          _usernameController.clear();
                          _passwordController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User registered successfully!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to register user.'),
                            ),
                          );
                        }
                      }
                      catch (e) {
                        print("Error: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } , child: Text(
                      "Register",
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
      ),
    );
  }
}
