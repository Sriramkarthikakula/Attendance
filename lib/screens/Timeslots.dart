import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';



class EditTimeSlots extends StatelessWidget {
  const EditTimeSlots({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Attendance'),
      ),
      body:EditingTimeSlots(),
    );
  }
}

class EditingTimeSlots extends StatefulWidget {
  const EditingTimeSlots({super.key});

  @override
  State<EditingTimeSlots> createState() => _EditingTimeSlotsState();
}

class _EditingTimeSlotsState extends State<EditingTimeSlots> {
  TextEditingController _textController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  bool isFlag = false;
  List<dynamic> timeslots = [];
  List<dynamic> adding = [];
  List<dynamic> removing = [];
  int? dup_parse_time;
  late DocumentReference ref;
  int? parsing_time;
  String today_Date="";
  void func() async {
    today_Date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        ref = message.reference;
        isFlag =true;
        parsing_time = data['parsing_time'];
        dup_parse_time = parsing_time;
        _textController.text = parsing_time.toString();
        timeslots =  timeslots + data['Time-Slots'];
      });
    }
  }
  void initState() {
    func();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0,vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Text("Parsing Time in Minutes:"),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 35.0),
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0),),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,

                    ),
                    onChanged: (value){
                      dup_parse_time= int.tryParse(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: isFlag?(timeslots.isEmpty)?Container(
            height: MediaQuery.of(context).size.height, // Adjust the height as needed
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
              padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Text("Classes are Empty",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  Center(
                    child: Text("Please add the Classes",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
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
                            child:AddTaskCont((newtask) async{
                              setState(() {
                                if(!timeslots.contains(newtask)) {
                                  if (removing.contains(newtask)) {
                                    removing.remove(newtask);
                                    adding.add(newtask);
                                  }
                                  else {
                                    adding.add(newtask);
                                  }
                                  timeslots?.add(newtask);
                                }
                              });
                              Navigator.pop(context);
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
            ),
          ):Container(
            height: MediaQuery.of(context).size.height * 0.7, // Adjust the height as needed
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
                  padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: [
                      Text("Time Slots:",style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                      SizedBox(height: 10.0,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: timeslots!.map((oneBranch) =>Row(
                                children: [
                                  Text(oneBranch.toString(),style: TextStyle(
                                    fontSize: 16.0,
                                  ),),
                                  GestureDetector(
                                    onTap: ()=> showDialog(
                                        context: context,
                                        builder: (BuildContext context)=> AlertDialog(
                                          title: Text("Delete!"),
                                          content: Text("Are you sure you want to Remove $oneBranch from the list"),
                                          actions: [
                                            TextButton(onPressed: (){
                                              Navigator.pop(context);
                                            }, child: Text("Cancel")
                                            ),
                                            TextButton(onPressed: (){
                                              setState(() {
                                                if(adding.contains(oneBranch)){
                                                  adding.remove(oneBranch);
                                                }
                                                else{
                                                  removing.add(oneBranch);
                                                }
                                                timeslots.remove(oneBranch);
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
                                      child:AddTaskCont((newtask) async{
                                        setState(() {
                                          if(!timeslots.contains(newtask)){
                                            if(removing.contains(newtask)){
                                              removing.remove(newtask);
                                              adding.add(newtask);
                                            }
                                            else{
                                              adding.add(newtask);
                                            }
                                            timeslots?.add(newtask);
                                          }
                                        });
                                        Navigator.pop(context);
                                      }),
                                    ),
                                  ),
                                  );
                                },
                                icon: Icon(Icons.add),
                              ),
                            ),
                          ]
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ):NoHistory(),
        ),
        GestureDetector(
          onTap: ()=> showDialog(
              context: context,
              builder: (BuildContext context)=> AlertDialog(
                title: Text("Updated Time Slots!"),
                content: Text("Are you sure you want to Update"),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text("Cancel")
                  ),
                  TextButton(onPressed: () async {

                    try {
                      if (ref!=null) {
                        if(parsing_time!=dup_parse_time){
                          print(dup_parse_time);
                          await ref.update({'parsing_time': dup_parse_time});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Parsing Updated Successfully'),
                            ),
                          );
                        }
                        await ref.update({'Time-Slots': timeslots});
                      }
                      else{
                        print("error");
                      }
                      if(adding.isNotEmpty || removing.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Time Slots Updated Successfully'),
                          ),
                        );
                      }
                    }catch (error) {
                      print("Error creating document: $error");
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },  child: Text("Submit")),
                ],
              )
          ),
          child: Container(
            width: double.infinity,
            color:Color(0xff8db4e7),
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text("Submit Time Slots",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),),
            ),
          ),
        ),
      ],
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
        CircularProgressIndicator(),
        Text("Fetching Data"),
      ],
    );
  }
}

class AddTaskCont extends StatelessWidget {
  final Function(String) addingTask1;// Function now accepts two values
  AddTaskCont(this.addingTask1);

  @override
  Widget build(BuildContext context) {
    String tasktext1 = '';
    String tasktext2 = '';

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Add Time Slot',
              style: TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 25.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Input Box
              Expanded(
                child: TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onChanged: (newvalue) {
                    tasktext1 = newvalue;
                  },
                  decoration: InputDecoration(
                    hintText: 'Start Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Text(
                '-', // Hyphen
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10.0),
              // Second Input Box
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (newvalue) {
                    tasktext2 = newvalue;
                  },
                  decoration: InputDecoration(
                    hintText: 'End Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
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
            onPressed: () {
              String newTask = "$tasktext1 - $tasktext2";
              addingTask1(newTask); // Pass both inputs
            },
            child: Text('Add'),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}