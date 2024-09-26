import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';



class EditBranches extends StatelessWidget {
  const EditBranches({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Attendance'),
      ),
      body:Editingbranches(),
    );
  }
}

class Editingbranches extends StatefulWidget {
  const Editingbranches({super.key});

  @override
  State<Editingbranches> createState() => _EditingbranchesState();
}

class _EditingbranchesState extends State<Editingbranches> {
  final _firestore = FirebaseFirestore.instance;
  bool isFlag = false;
  List<dynamic> branches = [];
  List<dynamic> adding = [];
  List<dynamic> removing = [];
  late DocumentReference ref;
  String today_Date="";
  void func() async {
    today_Date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        ref = message.reference;
        isFlag =true;
        branches =  branches + data['Branches'];
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
        SizedBox(height: 20.0),
        Expanded(
          child: isFlag?(branches.isEmpty)?Container(
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
                                if(!branches.contains(newtask)) {
                                    if (removing.contains(newtask)) {
                                        removing.remove(newtask);
                                        adding.add(newtask);
                                      }
                                    else {
                                        adding.add(newtask);
                                        }
                                      branches?.add(newtask);
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
                      Text("Courses:",style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                      SizedBox(height: 10.0,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: branches!.map((oneBranch) =>Row(
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
                                                branches.remove(oneBranch);
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
                                          if(!branches.contains(newtask)){
                                            if(removing.contains(newtask)){
                                              removing.remove(newtask);
                                              adding.add(newtask);
                                            }
                                            else{
                                              adding.add(newtask);
                                            }
                                            branches?.add(newtask);
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
                title: Text("Updated Classes "),
                content: Text("Are you sure you want to Update"),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: Text("Cancel")
                  ),
                  TextButton(onPressed: () async {
                    if (ref!=null) {
                      await ref.update({'Branches': branches});
                    }
                    else{
                      print("error");
                    }
                    try {
                      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(today_Date);

                      // Format it into "yyyy-MM-dd" format
                      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                      for(dynamic i in adding){

                        // Create a new document in the "Full_Data" collection with a random ID
                        DocumentReference fullDataRef = _firestore.collection('Full_Data').doc();
                        // Create the data for the document
                        Map<String, dynamic> documentData = {
                          i: {
                            '1st_year': {'classes': [], 'section': [],'Academic_year_begins':formattedDate},
                            '2nd_year': {'classes': [], 'section': [],'Academic_year_begins':formattedDate},
                            '3rd_year': {'classes': [], 'section': [],'Academic_year_begins':formattedDate},
                            '4th_year': {'classes': [], 'section': [],'Academic_year_begins':formattedDate},
                          }
                        };

                        // Set the data for the document
                        await fullDataRef.set(documentData);
                      }
                    final messages = await _firestore.collection('Full_Data').get();
                    for(dynamic i in removing){
                      for (var message in messages.docs) {
                        var data = message.data();
                        if(data.containsKey(i)){
                            ref = message.reference;
                            await ref.delete();
                          break;
                        }
                      }
                    }
                    if(adding.isNotEmpty || removing.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
          content: Text('Branches Updated Successfully'),
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
            color:Colors.red,
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text("Submit Attendance",
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