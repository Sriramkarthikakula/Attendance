import 'package:attendance/Data/lists_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../Data/Uploadexcel.dart';

class EditRollnumbers extends StatefulWidget {
  const EditRollnumbers({super.key});

  @override
  State<EditRollnumbers> createState() => _EditRollnumbersState();
}

class _EditRollnumbersState extends State<EditRollnumbers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Attendance'),
      ),
      body:Rollnumbers(),
      floatingActionButton:Padding(
        padding: EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(onPressed: () async{
          backgroundColor: Color(0xff8db4e7);
          List curr = await Excelupload.pickExcelFile();
          setState(() {
            rollNumber = [];
            rollNumber = curr;
          });

        },
          child: Icon(Icons.file_copy_outlined),

        ),
      ),
    );
  }
}

class Rollnumbers extends StatefulWidget {
  const Rollnumbers({super.key});

  @override
  State<Rollnumbers> createState() => _RollnumbersState();
}

class _RollnumbersState extends State<Rollnumbers> {
  final _firestore = FirebaseFirestore.instance;
  String deptvalue = "";
  String yearvalue="";
  String sectionvalue = "";
  bool isFlag = false;
  bool light=false;
  String today_Date="";
  String storing_academic_year = "";
  String fetched_Academic_year = "";
  List<dynamic> Sections = ["Select"];
  List<dynamic> branches = ["Select"];
  late DocumentReference ref;
  void func() async {
    today_Date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        branches =  branches + data['Branches'];
      });
    }
  }
  void func1(String deptvalue, String yearvalue) async {
    setState(() {
      Sections = ["Select"];
    });
    final messages = await _firestore.collection('Full_Data').get();
    for (var message in messages.docs) {
      var data = message.data();
      if(data.containsKey(deptvalue) && data[deptvalue].containsKey(yearvalue)){
        setState(() {
          Sections = Sections+ data[deptvalue][yearvalue]['section'];

          fetched_Academic_year = data[deptvalue][yearvalue]['Academic_year_begins'];
        });
        break;
      }
      else{
        continue;
      }
    }
  }
  void getRollList(String deptValue,String YearValue,String sectionvalue) async {
    rollNumber = [];
    final messages = await _firestore.collection('Full_Data').get();
    for (var message in messages.docs) {
      var data = message.data();
      if(data.containsKey(deptvalue) && data[deptvalue].containsKey(yearvalue)){
        ref = message.reference;
        rollNumber = rollNumber+ data[deptvalue][yearvalue][sectionvalue];
        break;
      }
    }
    setState(() {
      isFlag=true;
    });
  }
  void initState() {
    func();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.0),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownMenu<dynamic>(
                label: Text("Department"),
                onSelected: (dynamic? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    deptvalue = value!;
                  });
                },
                dropdownMenuEntries: branches.map<DropdownMenuEntry<String>>((dynamic value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
                initialSelection: branches.first,
              ),
              DropdownMenu<String>(
                initialSelection: Year.first,
                label: Text("Year"),
                onSelected: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    yearvalue = value!;
                    func1(deptvalue,yearvalue);
                  });
                },
                dropdownMenuEntries: Year.map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),

            ],
          ),
        ),
        SizedBox(height: 20.0),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownMenu<dynamic>(
                initialSelection: Sections.first,
                label: Text("Section"),
                onSelected: (dynamic? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    sectionvalue = value!;
                  });
                },
                dropdownMenuEntries: Sections.map<DropdownMenuEntry<String>>((dynamic value) {
                  return DropdownMenuEntry<String>(value: value, label: value);
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                  onPressed: (){
                    getRollList(deptvalue,yearvalue,sectionvalue);
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 10.0,),
                        Text("Search",),
                      ]
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xff2D3250)),
                    minimumSize: MaterialStateProperty.all(Size(150.0, 65.0)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0,),
        Expanded(
          child: isFlag?(rollNumber.isEmpty)?Container(
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
                    child: Text("Section is Empty",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  Center(
                    child: Text("Please add the Roll Numbers",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ],
              ),
            ),
          ):Column(
            children: [
              SizedBox(height: 10.0,),
              Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05,),

                decoration: BoxDecoration(
                  color:Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4), // Shadow color
                      spreadRadius: 5, // Spread radius
                      blurRadius: 4, // Blur radius
                      offset: Offset(0, 3), // Offset in x and y direction
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text("Change Academic Year? "),
                  trailing: Switch(
                    value: light,
                    activeColor: Colors.red,
                    onChanged: (value){
                      setState(() {
                        light = value;
                        if(light){
                          storing_academic_year = today_Date;
                        }
                        else{
                          storing_academic_year = fetched_Academic_year;
                        }
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.0,),
              Container(
              height: MediaQuery.of(context).size.height * 0.5, // Adjust the height as needed
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
                        Text("Roll Numbers:",style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),),
                        SizedBox(height: 10.0,),
                        Column(
                          children: rollNumber!.map((absentee) =>Row(
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
                                            rollNumber.remove(absentee);
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
                  ),
                ],
              ),
            ),
            ]
          ):NoHistory(),
        ),
        GestureDetector(
          onTap: ()=> showDialog(
              context: context,
              builder: (BuildContext context)=> AlertDialog(
                title: Text("Update Roll Numbers"),
                content: Text("Are you sure you want to Update"),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text("Cancel")
                  ),
                  TextButton(onPressed: () async {
                    if (ref!=null) {
                      if(light){
                        await ref.update({'$deptvalue.$yearvalue.$sectionvalue': rollNumber});
                        await ref.update({'$deptvalue.$yearvalue.Academic_year_begins': storing_academic_year});
                      }
                      else{
                        await ref.update({'$deptvalue.$yearvalue.$sectionvalue': rollNumber});
                      }

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
            width: double.infinity,
            color:Color(0xff8db4e7),
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text("Update Rollnumbers",
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
        Icon(Icons.history_outlined),
        Text("No Roll Numbers Found"),
      ],
    );
  }
}

