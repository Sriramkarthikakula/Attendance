
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Edit_Page extends StatefulWidget {
  Edit_Page(this.Dept,this.Course,this.year,this.time_slot,this.Section,this.Absent_list,this.Date,this.presentees);
  final String Dept;
  final String Course;
  final String Section;
  final String year;
  final String time_slot;
  final List<dynamic> Absent_list;
  final String Date;
  final List<dynamic> presentees;
  @override
  State<Edit_Page> createState() => _Edit_PageState();
}

class _Edit_PageState extends State<Edit_Page> {
  final TextEditingController searchController = TextEditingController();
  String? curr;
  String? Dept;
  String? Course;
  String? year;
  String? time_slot;
  String? Section;
  List<dynamic>? Absent_list1;
  List<dynamic> roll_no = [];
  String? Date;
  List<dynamic> presentees = [];
  void SetValues() async{
    Dept=widget.Dept;
    Course=widget.Course;
    year=widget.year;
    time_slot=widget.time_slot;
    Section=widget.Section;
    Absent_list1 = widget.Absent_list;
    Date = widget.Date;
    presentees = widget.presentees;

      final messages = await _firestore.collection('Full_Data').get();
      for (var message in messages.docs) {
        var data = message.data();
        if(data.containsKey(widget.Dept) && data[widget.Dept].containsKey(widget.year)){
          setState(() {
            roll_no = [];
            roll_no = data[widget.Dept][widget.year][widget.Section];
          });

            break;
        }
        else{
          continue;
        }
      }
  }
  final _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    final _auth = FirebaseAuth.instance;
    curr = _auth.currentUser!.email;
    SetValues();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffEEF5FF),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child:Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(50.0),topLeft: Radius.circular(50.0),),
              ),

              margin: EdgeInsets.only(top: 30.0,),
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
                          child: Text("Edit Here",style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.74,
                    child: ListView(
                      children: [Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
                        padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:CrossAxisAlignment.end,
                              children: [
                                Column(
                                  children: [
                                    Text("Absentees:",style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),),
                                    SizedBox(height: 10.0,),
                                    Column(
                                      children: Absent_list1!.map((absentee) =>Row(
                                        children: [
                                          Text(absentee.toString(),style: TextStyle(
                                            fontSize: 16.0,
                                          ),),
                                          GestureDetector(
                                            onTap: ()=> showDialog(
                                                context: context,
                                                builder: (BuildContext context)=> AlertDialog(
                                                  title: Text("Delete!"),
                                                  content: Text("Are you sure you want to Remove $absentee from the list"),
                                                  actions: [
                                                    TextButton(onPressed: (){
                                                      Navigator.pop(context);
                                                    }, child: Text("Cancel")
                                                    ),
                                                    TextButton(onPressed: (){
                                                      setState(() {
                                                        Absent_list1!.remove(absentee);
                                                      });
                                                      Navigator.pop(context);
                                                    },  child: Text("Yes")),
                                                  ],
                                                )
                                            ),
                                            child: IconButton(
                                              onPressed: null,
                                              icon: Icon(Icons.remove_circle_outline), // Adjust icon as needed
                                            ),
                                          ),
                    
                                        ],
                                      ),).toList(),
                                    ),
                    
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: IconButton(
                                    onPressed: (){
                                      showModalBottomSheet(context: context,isScrollControlled: true,builder:(context)=> SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 80.0,right: 80.0,top: 30.0,bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child:AddTaskCont((newtask){
                                            if (roll_no.contains(newtask) && !presentees.contains(newtask)){
                                              setState(() {
                                                Absent_list1?.add(newtask);
                                              });
                                              Navigator.pop(context);
                                            }
                                            else{
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Couldn`t add the roll number',style: TextStyle(
                                                  color: Colors.red,
                                                ),)),
                                              );

                                            }

                                          }),
                                        ),
                                      ),
                                      );
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),],
                    ),
                  ),

                ],
              ),

              )),
              GestureDetector(
                onTap: ()=> showDialog(
                    context: context,
                    builder: (BuildContext context)=> AlertDialog(
                      title: Text("Attendance"),
                      content: Text("Are you sure you want to Update"),
                      actions: [
                        TextButton(onPressed: (){
                          Navigator.pop(context);
                        }, child: Text("Cancel")
                        ),
                        TextButton(onPressed: () async {
                          DateTime parsedDate = DateFormat("dd-MM-yyyy").parse(Date!);
                          String formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
                          QuerySnapshot UserquerySnapshot = await _firestore.collection('Absent_data')
                              .where('Faculty', isEqualTo: curr).where('Date',isEqualTo: formattedDate).where('Time_slot', isEqualTo: time_slot)
                              .get();
                          if (UserquerySnapshot.docs.isNotEmpty) {
                            DocumentSnapshot doc = UserquerySnapshot.docs.first;
                            DocumentReference docRef = doc.reference;
                            await docRef.update({'Absentees': Absent_list1,'edited':true});
                          }
                          else{
                            print("error");
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },  child: Text("Submit")),
                      ],
                    )
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text("Submit Attendance",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),),
                ),
              ),
            ]
          ),
        )
    );
  }
}
class AddTaskCont extends StatelessWidget {
  final Function(String) addingTask1;
  AddTaskCont(this.addingTask1);
  @override
  Widget build(BuildContext context) {
    String tasktext = '';
    return  Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Add Roll Number',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 25.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            autofocus: true,
            textAlign: TextAlign.center,
            onChanged: (newvalue){
              tasktext = newvalue;
            },
          ),
          SizedBox(height: 10.0,),
          TextButton(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              foregroundColor: Colors.white,
              padding: EdgeInsets.only(
                  left: 110.0, right: 110.0, top: 15.0, bottom: 15.0),
              backgroundColor: Colors.lightBlueAccent,
            ),
            onPressed: (){
              addingTask1(tasktext);
            },
            child: Text('Add'),
          ),
          SizedBox(height: 10.0,),
        ],
      ),);
  }
}
