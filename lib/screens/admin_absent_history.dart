
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Admin_History extends StatefulWidget {
  const Admin_History({super.key});

  @override
  State<Admin_History> createState() => _Admin_HistoryState();
}

class _Admin_HistoryState extends State<Admin_History> {
  final TextEditingController searchController = TextEditingController();
  String? curr;
  String? search;
  String? searching;
  final _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    final _auth = FirebaseAuth.instance;
    curr = _auth.currentUser!.email;
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        search = DateFormat('yyyy-MM-dd').format(picked).toString(); // Set the selected date to the search string
      });
      searchController.text = DateFormat('dd-MM-yyyy').format(picked).toString();
    }

  }
  String formatDate(String inputDate) {
    // Parse the input date string in 'yyyy-MM-dd' format
    DateTime date = DateFormat('yyyy-MM-dd').parse(inputDate);

    // Format the parsed date to 'dd-MM-yyyy' format
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    return formattedDate;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffEEF5FF),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(50.0),topLeft: Radius.circular(50.0),),
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
                        child: Text("History",style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15.0,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 35.0),
                  child: TextField(
                    autofocus: true,
                    controller: searchController,
                    onEditingComplete: (){
                      setState(() {
                        searching = search;
                        FocusScope.of(context).unfocus();
                      });
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon:Icon(Icons.calendar_month),
                        onPressed:() => _selectDate(context),
                      ),
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                      hintStyle:TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0),),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.25),
                    ),

                    onChanged: (value){
                      search = value;
                    },
                  ),
                ),
                SizedBox(height: 20.0,),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      //search by dept, faculty,year,course
                      StreamBuilder<QuerySnapshot>(
                        stream: searching == ""? _firestore.collection('Absent_data').orderBy('Submission', descending: true).snapshots():_firestore.collection('Absent_data').where('Date', isEqualTo: searching).orderBy('Submission', descending: true).snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> Asyncsnapshots) {
                          if (Asyncsnapshots.hasData) {
                            final messages = Asyncsnapshots.data?.docs;
                            if (messages != null && messages.isNotEmpty) {
                              List<Datawidget> messageWidgets = [];
                              for (var message in messages) {

                                final Dept = message['Department'];
                                final Course = message['Course_name'];
                                final Section = message['Section'];
                                final year = message['Year'];
                                final time_slot = message['Time_slot'];
                                final Absent_list = message['Absentees'];
                                final Date = message['Date'];
                                String displayDate = formatDate(Date);
                                final Faculty = message['Faculty'];
                                final edited = message['edited'];

                                final messageContainer = Datawidget(Dept, Course, Section, year, time_slot, Absent_list, displayDate,Faculty,edited);
                                messageWidgets.add(messageContainer);
                              }
                              return Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.7, // Adjust the height as needed
                                  child: ListView(
                                    children: messageWidgets,
                                  ),
                                ),
                              );


                            } else {
                              return Center(
                                child: NoHistory(),
                              );
                            }
                          } else if (Asyncsnapshots.hasError) {
                            return Text('Error: ${Asyncsnapshots.error}');
                          } else {
                            return Center(
                              child: CircularProgressIndicator(), // Loading indicator while data is being fetched
                            );
                          }
                        },
                      )

                    ],
                  ),
                ),

              ],
            ),

          ),
        )
    );
  }
}


class NoHistory extends StatelessWidget {
  const NoHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_outlined),
        Text("You don't have any History"),
      ],
    );
  }
}


class Datawidget extends StatelessWidget {

  final String Dept;
  final String Course;
  final String year;
  final String time_slot;
  final String Section;
  final List<dynamic> Absent_list;
  final String Date;
  final String Faculty;
  final bool edited;
  Datawidget(this.Dept,this.Course,this.Section,this.year,this.time_slot,this.Absent_list,this.Date,this.Faculty,this.edited);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
      padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
      decoration: BoxDecoration(
        color: Color(0xffEEF5FF),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text('Date: $Date',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text('Time: $time_slot',style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),

            ],
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),

                child: Text('Dept: $Dept',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text('Year: $year',style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),

            ],
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),

                child: Text('Section: $Section',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text('Course: $Course',style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),

            ],
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text("Absentees:",style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(height: 10.0,),
                  Column(
                    children: Absent_list.map((absentee) => Text(absentee.toString(),style: TextStyle(
                      fontSize: 16.0,
                    ),)).toList(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(Faculty,style: TextStyle(
                  fontWeight: FontWeight.bold
              ),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(edited?"edited":"",style: TextStyle(
                color: Color(0xff97979f),
              ),),
            ],
          ),
        ],
      ),
    );
  }
}
