import 'package:attendance/screens/admin_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? curr;
  String? searching;
  final _firestore = FirebaseFirestore.instance;
  void fun1(){
    setState(() {
      searching = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });
  }
  void ChangeCheckedState(DocumentReference ref,bool checked) async{
    DocumentReference docref = ref;
    if(checked){
      await docref.update({'checked':false});
    }
    else{
      await docref.update({'checked':true});
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    fun1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffC4E4FF),
          title: Text("Admin Panel"),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Absent_data').where('Date', isEqualTo: searching).orderBy('Submission', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> Asyncsnapshots) {
                  if (Asyncsnapshots.hasData) {
                    final messages = Asyncsnapshots.data?.docs;
                    if (messages != null && messages.isNotEmpty) {
                      List<Datawidget> messageWidgets = [];
                      for (var message in messages) {
                        final ref = message.reference;
                        final Dept = message['Department'];
                        final Course = message['Course_name'];
                        final Section = message['Section'];
                        final year = message['Year'];
                        final time_slot = message['Time_slot'];
                        final Absent_list = message['Absentees'];
                        final Date = message['Date'];
                        final Faculty = message['Faculty'];
                        final checked = message['checked'];
                        final messageContainer = Datawidget(Dept, Course, Section, year, time_slot, Absent_list, Date,Faculty,ref,checked,ChangeCheckedState);
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
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context){
              return AdminProfile();
            }));
          },
          child: Icon(Icons.account_circle),
        ),
      ),
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
  final DocumentReference ref;
  final bool checked;
  final void Function(DocumentReference<Object?>,bool) ChangeCheckedState;
  Datawidget(this.Dept,this.Course,this.Section,this.year,this.time_slot,this.Absent_list,this.Date,this.Faculty,this.ref,this.checked,this.ChangeCheckedState);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress:()=> ChangeCheckedState!(ref,checked),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
        padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
        decoration: BoxDecoration(
          color: checked?Color(0xffE0FBE2):Color(0xffEEF5FF),
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
          ],
        ),
      ),
    );
  }
}