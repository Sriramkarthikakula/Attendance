
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Faculty_History_Number extends StatefulWidget {
  const Faculty_History_Number({super.key});

  @override
  State<Faculty_History_Number> createState() => _Faculty_History_NumberState();
}

class _Faculty_History_NumberState extends State<Faculty_History_Number> {
  final TextEditingController searchController = TextEditingController();
  String? curr;
  String search ="" ;
  String searching = "";
  final _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    final _auth = FirebaseAuth.instance;
    curr = _auth.currentUser!.email;
    super.initState();
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
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search By Number",
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
                  child: FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('Absent_data').where('Faculty', isEqualTo: curr).where('Absentees', arrayContains: searching).orderBy('Submission', descending: true).get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        return Center(child: NoHistory());
                      } else {
                        final messages = snapshot.data!.docs;
                        List<Datawidget> messageWidgets = [];
                        for (var message in messages) {
                          final Dept = message['Department'];
                          final Course = message['Course_name'];
                          final Section = message['Section'];
                          final year = message['Year'];
                          final time_slot = message['Time_slot'];
                          final Date = message['Date'];
                          final messageContainer =
                          Datawidget(
                              Dept,
                              Course,
                              Section,
                              year,
                              time_slot,
                              Date,
                              searching) ;
                          messageWidgets.add(messageContainer);
                        }
                        return Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.7, // Adjust the height as needed
                          child: ListView.builder(itemBuilder: (contex,index) {
                            return messageWidgets[index];
                          },
                            itemCount: messageWidgets.length,
                          ),
                        );
                      }
                    },
                  )

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
        Text("Search a Number to get History"),
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
  final String searching_number;
  final String Date;
  Datawidget(this.Dept,this.Course,this.Section,this.year,this.time_slot,this.searching_number,this.Date);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
      padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
      decoration: BoxDecoration(
        color: Color(0xffEEF5FF),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Date,
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text('Date: $searching_number',
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
        ],
      ),
    );
  }
}
