import 'package:attendance/screens/Submitted.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Data/lists_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class Topsection extends StatefulWidget {
  const Topsection({super.key});

  @override
  State<Topsection> createState() => _TopsectionState();
}
class _TopsectionState extends State<Topsection> {
  final _firestore = FirebaseFirestore.instance;
  String? Curr;
  String deptvalue = "";
  String yearvalue="";
  String fetched_Academic_year = "";
  String sectionvalue = "";
  String course_value = "";
  String Timeslot_value = "";
  String today_Date = "";
  bool checked = false;
  Map<String, dynamic> fulldata = {};
  List<dynamic> courses = ["Select"];
  List<dynamic> Sections = ["Select"];
  List<dynamic> branches = ["Select"];
  List<dynamic> register_no = [];
  List<Register_format> reg_with_check = [];
  void func() async {
    setState(() {
      final _auth = FirebaseAuth.instance;
      Curr = _auth.currentUser!.email;
      today_Date = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });
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
           courses = ["Select"];
           Sections = ["Select"];
           fulldata = data;
           courses = courses+ fulldata[deptvalue][yearvalue]['classes'];
           Sections = Sections+ fulldata[deptvalue][yearvalue]['section'];
           fetched_Academic_year = data[deptvalue][yearvalue]['Academic_year_begins'];
         });
         break;
       }
       else{
         continue;
       }
    }
  }
  void func2 (String deptvalue,String yearvalue,String sectionvalue) async {
      setState(() {
         register_no = fulldata[deptvalue][yearvalue][sectionvalue];
      });
  }
  void calling_numbers(){
    reg_with_check.clear();
    for(var i=0;i<register_no.length;i++){
      reg_with_check.add(Register_format(register_no[i]));
    }
  }
  @override
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
                Text("Date:- $today_Date",),
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
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                DropdownMenu<dynamic>(
                  initialSelection: Sections.first,
                  label: Text("Section"),
                  onSelected: (dynamic? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      sectionvalue = value!;

                      func2(deptvalue,yearvalue,sectionvalue);

                    });
                  },
                  dropdownMenuEntries: Sections.map<DropdownMenuEntry<String>>((dynamic value) {
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
                DropdownMenu <dynamic> (
                  initialSelection: Year.first,
                  label: Text("Courses"),
                  onSelected: (dynamic? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      course_value = value!;
                    });
                  },
                  dropdownMenuEntries: courses.map<DropdownMenuEntry<dynamic>>((dynamic value) {
                    return DropdownMenuEntry<String>(value: value, label: value);
                  }).toList(),
                ),
                DropdownMenu<String>(
                  initialSelection: Timeslots.first,
                  label: Text(
                    "Time-Slot"
                  ),
                  onSelected: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      Timeslot_value = value!;
                      calling_numbers();
                    });
                  },
                  dropdownMenuEntries: Timeslots.map<DropdownMenuEntry<String>>((String value) {
                    return DropdownMenuEntry<String>(value: value, label: value);
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 30.0,top: 10.0,right: 37.0,bottom: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0),topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: Register_numbers(reg_with_check),
            ),
          ),
          GestureDetector(
            onTap: ()=> showDialog(
              context: context,
              builder: (BuildContext context)=> AlertDialog(
                title: Text("Attendance"),
                content: Text("Are you sure you want to submit"),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  },
                      child: Text("Cancel")
                  ),
                  TextButton(onPressed: ()async{
                    absent_numbers.sort();
    await _firestore.collection("Absent_data").add({
      'Submission':FieldValue.serverTimestamp(),
      'Department': deptvalue,
      'Year':yearvalue,
      "Section":sectionvalue,
      'Date':today_Date,
      'Time_slot':Timeslot_value,
      'Faculty':'$Curr',
      'Course_name':course_value,
      'Absentees':absent_numbers,
      'checked':checked,
      'edited':false,
      'Academic_year':fetched_Academic_year,
    });
    setState(() {
      absent_numbers.clear();
    });
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return Aftersubmit();
    }));
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
        ],
      );
  }
}


class Register_numbers extends StatefulWidget {
  final List<Register_format> registers;
  Register_numbers(this.registers);

  @override
  State<Register_numbers> createState() => _Register_numbersState();
}

class _Register_numbersState extends State<Register_numbers> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context,index){
        return RegisterTile(widget.registers[index].rollno,widget.registers[index].isDone,(checkstate){
          // print();
          // print(checkstate);
          setState(() {
            widget.registers[index].toggleDone();
            if(checkstate==true){
              absent_numbers.add(widget.registers[index].rollno);
            }
            else{
              absent_numbers.remove(widget.registers[index].rollno);
            }

          });
        },
        );
      },
      itemCount: widget.registers.length,
    );
  }
}

class RegisterTile extends StatelessWidget {

  final String register_number;
  final bool isChecked;
  final void Function(bool?)? checkboxcallback;
  RegisterTile(this.register_number,this.isChecked,this.checkboxcallback);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(

        child: Text(
          register_number,
          style: TextStyle(
            decoration: isChecked? TextDecoration.lineThrough:null,
            fontSize: 18.0,
          ),
        ),
      ),
      trailing: Checkbox(
        activeColor: Colors.lightBlueAccent,
        value: isChecked,
        onChanged:checkboxcallback,
      ),

    );
  }
}






