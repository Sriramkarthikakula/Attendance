import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DisplayMembers extends StatefulWidget {
  const DisplayMembers({super.key});

  @override
  State<DisplayMembers> createState() => _DisplayMembersState();
}

class _DisplayMembersState extends State<DisplayMembers> {
  List<dynamic> branches = [];
  String role = "";
  String deptback = "";
  String curr = "";
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isLoading = true;

  Future<void> fetchUserRole() async {
    try {
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Faculty_Data')
          .where('email', isEqualTo: curr)
          .get();
      final messages = await _firestore.collection('Dept_data').get();
      if (userDocs.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = userDocs.docs[0];
        setState(() {
          role = userDoc['faculty_status'];
          if (role != "admin") {
            deptback = userDoc['department'];
          }
        });
      }
      if(role !=""){
        for (var message in messages.docs) {
          final data = message.data();
          setState(() {
            branches = role == "admin" ? branches + data['Branches'] : [deptback];
          });
        }
        setState(() {
          isLoading = false; // Set loading to false after fetching branches
        });
      }

    } catch (error) {
      setState(() {
        isLoading = false; // Set loading to false after fetching branches
      });
    }
  }

  Future<List<Map<String, dynamic>>> getFacultyDetails(String branch) async {
    List<Map<String, dynamic>> facultyList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Faculty_Data')
        .where('department', isEqualTo: branch)
        .get();
    for (var doc in querySnapshot.docs) {
      facultyList.add(doc.data() as Map<String, dynamic>);
    }
    print(facultyList);
    return facultyList;
  }

  @override
  void initState() {
    curr = _auth.currentUser!.email!;
    fetchUserRole();
    super.initState();
  }

  List<Widget> buildFacultyList() {
    List<Widget> facultyWidgets = [];
    for (String branch in branches) {
      facultyWidgets.add(FutureBuilder<List<Map<String, dynamic>>>(
        future: getFacultyDetails(branch),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(); // Return an empty widget to avoid multiple loaders
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> facultyList = snapshot.data!;
            if (facultyList.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.0),
                    Text(
                      "Branch: $branch",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 0.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text("No Faculty Found"),
                      ),
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.0),
                  Text(
                    "Branch: $branch",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    children: facultyList.map((faculty) {
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xffEEF5FF),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(faculty['display_image']),
                                      radius: 45.0,
                                    ),
                                    SizedBox(width: 10.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(faculty['Username']),
                                          Text(faculty['email']),
                                          Text("Ph No: ${faculty['ph_number']}"),
                                          Container(
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            child: Text(faculty['faculty_status']),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,size: 32.0,),
                                      onPressed: () {
                                        // Handle delete action here
                                        // _deleteFaculty(faculty['id']); // Assuming you have an 'id' field
                                      },
                                    ),
                                  ],
                                ),]
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          } else {
            return Text('No data available');
          }
        },
      ));
    }
    return facultyWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50.0),
                  topLeft: Radius.circular(50.0),
                ),
              ),
              margin: EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 22.0,top: 27.0),
                    child: Row(
                      children: [
                        TextButton(
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
                        Center(
                          child: Text("Faculty Members",style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  Expanded(
                    child: ListView(
                    children: buildFacultyList(),
                                    ),
                  ),]
              ),
            ),
            if (isLoading) ...[
              ModalBarrier(
                dismissible: false,
                color: Colors.black.withOpacity(0.5),
              ),
              Center(
                child: SpinKitDoubleBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


