import 'package:attendance/Data/lists_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../Data/Uploadexcel.dart';


class EditSection extends StatelessWidget {
  const EditSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Edit Sections'),
      ),
      body:EditingSection(),
    );
  }
}

class EditingSection extends StatefulWidget {
  const EditingSection({super.key});

  @override
  State<EditingSection> createState() => _EditingSectionState();
}

class _EditingSectionState extends State<EditingSection> {
  final _firestore = FirebaseFirestore.instance;
  String deptvalue = "";
  String yearvalue="";
  bool isFlag = false;
  List<dynamic> adding =[];
  List<dynamic> removing = [];
  List<dynamic> Sections = [];
  List<dynamic> branches = ["Select"];
  late DocumentReference ref;
  void func() async {
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        branches =  branches + data['Branches'];
      });
    }
  }
  void func1(String deptvalue, String yearvalue) async {

    final messages = await _firestore.collection('Full_Data').get();
    for (var message in messages.docs) {
      var data = message.data();
      if(data.containsKey(deptvalue) && data[deptvalue].containsKey(yearvalue)){
        setState(() {
          Sections = [];
        });
        setState(() {
          isFlag = true;
          ref = message.reference;
          Sections = Sections+ data[deptvalue][yearvalue]['section'];
        });
        break;
      }
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
        Expanded(
          child: isFlag?(Sections.isEmpty)?Container(
            height: MediaQuery.of(context).size.height * 0.7, // Adjust the height as needed
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
                    child: Text("Sections are Empty",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                  Center(
                    child: Text("Please add the sections",style: TextStyle(
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
                                if(!Sections.contains(newtask)){
                                    if(removing.contains(newtask)){
                                          removing.remove(newtask);
                                          adding.add(newtask);
                                          }
                                        else{
                                            adding.add(newtask);
                                        }
                                        Sections?.add(newtask);
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
                      Text("Sections:",style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                      SizedBox(height: 10.0,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:CrossAxisAlignment.end,
                        children: [
                          Column(
                          children: Sections!.map((oneSection) =>Row(
                            children: [
                              Text(oneSection.toString(),style: TextStyle(
                                fontSize: 16.0,
                              ),),
                              GestureDetector(
                                onTap: ()=> showDialog(
                                    context: context,
                                    builder: (BuildContext context)=> AlertDialog(
                                      title: Text("Delete!"),
                                      content: Text("Are you sure you want to Remove $oneSection from the list"),
                                      actions: [
                                        TextButton(onPressed: (){
                                          Navigator.pop(context);
                                        }, child: Text("Cancel")
                                        ),
                                        TextButton(onPressed: () async{
                                          setState(() {
                                            if(adding.contains(oneSection)){
                                              adding.remove(oneSection);
                                            }
                                            else{
                                              removing.add(oneSection);
                                            }
                                            Sections.remove(oneSection);
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
                                        if(!Sections.contains(newtask)){
                                            if(removing.contains(newtask)){
                                                removing.remove(newtask);
                                                adding.add(newtask);
                                                  }
                                                  else{
                                                      adding.add(newtask);
                                                    }
                                              Sections?.add(newtask);
                                             }
                                      });
                                      Navigator.pop(context);
                                      // FieldPath nestedFieldPath = FieldPath.fromString('$deptvalue.$yearvalue.$newtask');
                                      // await ref.update({
                                      //   nestedFieldPath: [],
                                      // });
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
                title: Text("Update Sections"),
                content: Text("Are you sure you want to Update"),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text("Cancel")
                  ),
                  TextButton(onPressed: () async {
                    if (ref!=null) {
                      await ref.update({'$deptvalue.$yearvalue.section': Sections});
                    }
                    else{
                      print("error");
                    }
                    try {
                      for(dynamic i in adding){
                        FieldPath nestedFieldPath = FieldPath.fromString('$deptvalue.$yearvalue.$i');
                        await ref.update({
                          nestedFieldPath: {
                            'roll_numbers':[],
                            'courses_count':{},
                          },
                        });
                      }
                      for(dynamic i in removing){
                        FieldPath nestedFieldPath = FieldPath.fromString('$deptvalue.$yearvalue.$i');
                        await ref.update({
                          nestedFieldPath: FieldValue.delete(),
                        });
                      }
                      if(adding.isNotEmpty || removing.isNotEmpty){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Section`s Updated Successfully!'),
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
              child: Text("Update Sections",
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
        Text("Select Dropdowns to get History"),
      ],
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
              'Add Section',
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