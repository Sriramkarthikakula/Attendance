
import 'package:attendance/screens/editpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Faculty_History extends StatefulWidget {
  const Faculty_History({super.key});

  @override
  State<Faculty_History> createState() => _Faculty_HistoryState();
}

class _Faculty_HistoryState extends State<Faculty_History> {
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
                    StreamBuilder<QuerySnapshot>(
                          stream: searching == ""? _firestore.collection('Absent_data').where('Faculty', isEqualTo: curr).orderBy('Submission', descending: true).snapshots():_firestore.collection('Absent_data').where('Faculty', isEqualTo: curr).where('Date', isEqualTo: searching).orderBy('Submission', descending: true).snapshots(),
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
                              DateTime gettingDate = DateFormat('dd-MM-yyyy').parse(Date);
                              String day = getDayOfWeek(gettingDate);
                              final edited = message['edited'];
                              final messageContainer = Datawidget(Dept, Course, Section, year, time_slot, Absent_list, displayDate,edited,day);
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

Future<List<dynamic>?> presentList(String Date,String Dept,String year,String Section,String time_slot) async {
  try {
    DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(Date);
    String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
    final QuerySnapshot userDocs = await FirebaseFirestore.instance
        .collection('event_attendance').where('Date',isEqualTo:formattedDate)
        .where('Department', isEqualTo: Dept).where('Year', isEqualTo: year).where('Section', isEqualTo: Section).where('Time_slot', isEqualTo: time_slot)
        .get();

    if (userDocs.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = userDocs.docs[0];
      return List.from(userDoc['Present']);  // Directly return the value
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
 final String Course;
 final String year;
 final String time_slot;
 final String Section;
 final List<dynamic> Absent_list;
 final String Date;
 final bool edited;
 final String day;
 Datawidget(this.Dept,this.Course,this.Section,this.year,this.time_slot,this.Absent_list,this.Date,this.edited,this.day);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
        future: presentList(Date,Dept,year,Section,time_slot),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    // Show a loader while fetching event name
    }
    if (snapshot.hasError) {
    return Text('Error fetching event name');
    }
    final presentees = snapshot.data ?? [];
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
          SizedBox(height: 20.0,),
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
                Text('Course: $Course',style: TextStyle(
                      fontWeight: FontWeight.bold
                      ),),
                    ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0,),
          Padding(
            padding:presentees.isNotEmpty?EdgeInsets.all(0.0):EdgeInsets.only(left: 23.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: presentees.isNotEmpty
                  ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.start,
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
                    Text(presentees.isNotEmpty?"Event Members:":"",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(height: 10.0,),
                    Column(
                      children: presentees.map((present) => Column(
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
          ),
          SizedBox(height: 10.0,),
          Padding(
            padding: EdgeInsets.only(right: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return Edit_Page(Dept,Course,year,time_slot,Section,Absent_list,Date,presentees);
                      }));
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0,),
          Padding(
            padding: EdgeInsets.only(right: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(edited?"edited":"",style: TextStyle(
                  color: Color(0xff97979f),
                ),),
              ],
            ),
          ),
        ],

      ),
    );});
  }
}
