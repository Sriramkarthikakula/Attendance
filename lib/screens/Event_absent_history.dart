
import 'package:attendance/screens/editpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventAttendance extends StatefulWidget {
  const EventAttendance({super.key});

  @override
  State<EventAttendance> createState() => _EventAttendanceState();
}

class _EventAttendanceState extends State<EventAttendance> {
  final TextEditingController searchController = TextEditingController();
  String? curr;
  String? search;
  String? searching;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isLoading = true; // To track loading state
  String? role;
  String deptback = "";
  Future<void> fetchUserRole() async {
    try {
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Faculty_Data')
          .where('email', isEqualTo: curr)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = userDocs.docs[0];
        setState(() {
          role = userDoc['faculty_status'];
          if(role!="admin"){
            deptback = userDoc['department'];
          }
          // Example field name
          isLoading = false; // Stop loading after role is fetched
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if no user found
        });
      }
    } catch (error) {
      // Handle any errors here
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  void initState() {
    curr = _auth.currentUser!.email;
    fetchUserRole();
    super.initState();
  }
  String getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
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
        body: Stack(
          children: [SafeArea(
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
                        StreamBuilder<QuerySnapshot>(
                          stream: role=="admin" ?(searching == ""? _firestore.collection('event_attendance').orderBy('Submission', descending: true).snapshots():_firestore.collection('event_attendance').where('Date', isEqualTo: searching).orderBy('Submission', descending: true).snapshots()):(searching == ""? _firestore.collection('event_attendance').where('Department', isEqualTo: deptback).orderBy('Submission', descending: true).snapshots():_firestore.collection('event_attendance').where('Department', isEqualTo: deptback).where('Date', isEqualTo: searching).orderBy('Submission', descending: true).snapshots()),
                          builder: (context, AsyncSnapshot<QuerySnapshot> Asyncsnapshots) {
                            if (Asyncsnapshots.hasData) {
                              final messages = Asyncsnapshots.data?.docs;
                              if (messages != null && messages.isNotEmpty) {
                                List<Datawidget> messageWidgets = [];
                                for (var message in messages) {
                                  final Dept = message['Department'];
                                  final Section = message['Section'];
                                  final year = message['Year'];
                                  final time_slot = message['Time_slot'];
                                  final Absent_list = message['Absentees'];
                                  final Date = message['Date'];
                                  final presentlis = message['Present'];
                                  String displayDate = formatDate(Date);
                                  DateTime gettingDate = DateFormat('dd-MM-yyyy').parse(Date);
                                  String day = getDayOfWeek(gettingDate);
                                  final mail = message['Faculty'];
                                  final messageContainer = Datawidget(Dept,Section, year, time_slot, Absent_list, displayDate,day,mail,presentlis);
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

Future<String?> eventname(String mail) async {
  try {
    final QuerySnapshot userDocs = await FirebaseFirestore.instance
        .collection('events')
        .where('email', isEqualTo: mail)
        .get();

    if (userDocs.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = userDocs.docs[0];
      return userDoc['Event_name'];  // Directly return the value
    } else {
      return null; // No document found
    }
  } catch (e) {
    print("Error fetching event name: $e");
    return null;  // Return null on error
  }
}
class Datawidget extends StatelessWidget {

  final String Dept;
  final String year;
  final String time_slot;
  final String Section;
  final List<dynamic> Absent_list;
  final String Date;
  final String day;
  final String mail;
  final List<dynamic> presentlis;
  Datawidget(this.Dept,this.Section,this.year,this.time_slot,this.Absent_list,this.Date,this.day,this.mail,this.presentlis);

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String?>(
        future: eventname(mail),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
     // Show a loader while fetching event name
    }
    if (snapshot.hasError) {
    return Text('Error fetching event name');
    }
    final eventName = snapshot.data ?? 'Unknown Event';
    final lislen = presentlis.length;
        return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),

      decoration: BoxDecoration(
        color: Color(0xffEEF5FF),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0,vertical:15.0),
            decoration: BoxDecoration(
              color: Color(0xffB1AFFF),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 20.0,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 3.0,),
                        Text("Session Date",style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 13.0,
                        ),),],
                    ),
                    Text(day,style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26.0,
                    ),),
                    Text(Date,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 20.0,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 3.0,),
                        Text("Time",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 13.0,
                          ),
                        ),],
                    ),
                    SizedBox(height: 7.0,),
                    Text(time_slot,style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width*0.045,
                    ),),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            padding:EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("Event Name: $eventName",style:TextStyle(
                fontWeight: FontWeight.bold,
              ))),
          Container(padding:EdgeInsets.symmetric(horizontal: 20.0),child: Text("Co-ordinator: $mail",style:TextStyle(
            fontWeight: FontWeight.bold,
          ))),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dept: $Dept',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Text('Year: $year',style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Section: $Section',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Text('Present Count: $lislen',
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
              children: [
                Text("Absentees:",style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
                SizedBox(height: 10.0,),
                Column(
                  children: Absent_list.map((absentee) => Column(
                    children: [
                      Row(
                          children: [
                            FaIcon(FontAwesomeIcons.user, color: Colors.blueAccent,size: 18.0,),
                            SizedBox(width: 10.0), // Add some space between the icon and the text
                            Text(
                              absentee.toString(),
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),]),SizedBox(height: 5.0,)],
                  ),).toList(),
                ),
              ],
            ),
              Column(
                children: [
                  Text("Present:",style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                  SizedBox(height: 10.0,),
                  Column(
                    children: presentlis.map((present) => Column(
                      children: [
                        Row(
                            children: [
                              FaIcon(FontAwesomeIcons.user, color: Colors.blueAccent,size: 18.0,),
                              SizedBox(width: 10.0), // Add some space between the icon and the text
                              Text(
                                present.toString(),
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),]),SizedBox(height: 5.0,)],
                    ),).toList(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5.0,),
          Padding(
            padding: EdgeInsets.only(right: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin:EdgeInsets.only(bottom: 11.0),
                  child: Text(mail,style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),),
                ),

              ],
            ),
          ),
        ],

      ),
    );}
    );
  }
}
