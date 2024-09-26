import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:excel/excel.dart';
import 'dart:io';


class CreateUserPage extends StatefulWidget {
  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _passwordController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _fileName;
  String username='';
  String ph_number='';
  String event_name="";
  String email="";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _eventnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submit() async {

    if (email.isEmpty || _startDate == null || _endDate == null || _fileName == null || ph_number == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill in all fields and upload a file.")));
      return;
    }

    try {
      await createUserAndStoreData(email, ph_number, _startDate!, _endDate!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User created and data stored successfully.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.path;
      });
    }
  }
  Future<void> createUserAndStoreData(String email, String ph_number, DateTime startDate, DateTime endDate) async {
    // Create user in Firebase Authentication
    FirebaseApp secondaryApp = await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: Firebase.app().options,
    );
    try {
      final userCredential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
        email: email,
        password: ph_number,
      );

      if (userCredential.user != null) {
        var bytes = File(_fileName!).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        Map<String, List<String>> categorizedData = {};

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          for (var row in sheet!.rows) {
            var rollNumber = row[0]?.value.toString();
            var branch = row[1]?.value.toString();
            var year = row[2]?.value.toString();
            var section = row[3]?.value.toString();

            String key = "${branch}-${year}-${section}";

            if (!categorizedData.containsKey(key)) {
              categorizedData[key] = [];
            }

            categorizedData[key]!.add(rollNumber as String);
          }
        }

        // Prepare the data to be stored
        Map<String, dynamic> eventData = {
          'username':username,
          'ph_number':ph_number,
          'email': email,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'studentsData': categorizedData,
          'role_status':'event',
          'Event_name':event_name,
        };

        // Store event details in Firestore
        await FirebaseFirestore.instance.collection('events').add(eventData);
        _usernameController.clear();
        _phonenumberController.clear();
        _eventnameController.clear();
        _emailController.clear();
      }
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
    } catch (e) {
      print("Error creating user or storing data: $e");
    } finally {
      // Ensure that the secondary app instance is deleted after use
      await secondaryApp.delete();
    }
  }

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
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    elevation: WidgetStateProperty.all(5.0),
                    shape: WidgetStateProperty.all<CircleBorder>(
                      CircleBorder(),
                    ),
                    shadowColor: WidgetStateProperty.all(Colors.black),
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
                    Text("Event Registration",style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 30.0,),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 35.0),
                            child: TextField(
                              controller: _usernameController,
                              keyboardType: TextInputType.text,
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
                              controller: _eventnameController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.emoji_events_rounded),
                                hintText: "Event Name",
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
                                event_name=value;
                              },
                            ),
                          ),
                          SizedBox(height: 30.0,),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 35.0),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_rounded),
                                hintText: "Email",
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
                                email=value;
                              },
                            ),
                          ),
                          SizedBox(height: 30.0,),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 35.0),
                            child: TextField(
                              controller: _phonenumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.call),
                                hintText: "Phone number",
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
                                ph_number=value;
                              },
                            ),
                          ),
                          SizedBox(height: 30.0,),
                          Container(
padding: EdgeInsets.symmetric(horizontal: 40.0),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                            Text("Select Start Date:"),
                          Row(
                            children: [
                              Expanded(
                                child: Text(_startDate == null ? 'No date selected' : DateFormat('yyyy-MM-dd').format(_startDate!)),
                              ),
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null && pickedDate != _startDate) {
                                    setState(() {
                                      _startDate = pickedDate;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text("Select End Date:"),
                          Row(
                            children: [
                              Expanded(
                                child: Text(_endDate == null ? 'No date selected' : DateFormat('yyyy-MM-dd').format(_endDate!)),
                              ),
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null && pickedDate != _endDate) {
                                    setState(() {
                                      _endDate = pickedDate;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),]
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[
                                ElevatedButton(
                                  onPressed: _pickFile,
                                  child: Text(_fileName == null ? 'Pick Excel File' : _fileName!),
                                ),
                                SizedBox(height: 16),
                                TextButton(onPressed:_submit, child: Text(
                                  "Register",
                                ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Color(0xff2D3250)),
                                    minimumSize: WidgetStateProperty.all(Size(150.0, 50.0),),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0), // Adjust the border radius as needed
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 26.0),
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                )



              ),
              ],
          ),
        ),
      ),
    );
  }
}
