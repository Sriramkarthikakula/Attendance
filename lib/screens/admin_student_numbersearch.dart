import 'package:attendance/Data/lists_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../Data/attendance.dart';

class Student_Overall_Attendance extends StatelessWidget {
  const Student_Overall_Attendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      appBar: AppBar(
        backgroundColor: Color(0xff8db4e7),
        title: Text('Attendance'),
      ),
      body:Student_AttendanceCal(),
    );
  }
}


class Student_AttendanceCal extends StatefulWidget {
  const Student_AttendanceCal({super.key});

  @override
  State<Student_AttendanceCal> createState() => _Student_AttendanceCalState();
}

class _Student_AttendanceCalState extends State<Student_AttendanceCal> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  String search ="" ;
  String searching = "";
  bool isFlag = false;
  String deptvalue = "";
  String yearvalue="";
  String fetched_Academic_year = "";
  String sectionvalue = "";
  List<dynamic> class_list = [];
  int counter = 0;
  double loader = 0.0;
  int percentageloader = 0;
  List<dynamic> Sections = ["Select"];
  List<dynamic> branches = ["Select"];
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
          Sections = ["Select"];
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
  late Future<List<Datawidget>> lis = Future.value([]);
  Future<List<Datawidget>> gettingClassList(String deptValue,String YearValue,String sectionvalue) async {
    List<int> classes_count = [];
    int claases_len=0;
    int count=0;
    int len=0;
    int totalclassesAttended=0;
    int attended=0;
    int total_classes_completed=0;
    double total_percentage = 0;
    final messages = await _firestore.collection('Full_Data').get();
    for (var message in messages.docs) {
      var data = message.data();
      if(data.containsKey(deptvalue) && data[deptvalue].containsKey(yearvalue)){
        setState(() {
          class_list = [];
          class_list = class_list+ data[deptvalue][yearvalue]['classes'];
        });
        break;
      }
      else{
        continue;
      }
    }
    for(var items in class_list){
      QuerySnapshot querySnapshot = await _firestore.collection('Absent_data').where('Department', isEqualTo: deptvalue).where('Year',isEqualTo: yearvalue).where('Section',isEqualTo: sectionvalue).where('Course_name',isEqualTo: items).where('Academic_year',isEqualTo:fetched_Academic_year).get();
      if(querySnapshot.docs.isNotEmpty){
        List<QueryDocumentSnapshot<Object?>> doc = querySnapshot.docs;
        claases_len = doc.length;
      }
      else{
        claases_len = 0;
      }
      classes_count.add(claases_len);
    }
    for(int i in classes_count){
      total_classes_completed = total_classes_completed+i;
    }
    List<Datawidget> messageWidgets = [];
    String AbyCpercentageString ='';
      List<String> AbyClist = [];
      List<String> Percentage = [];
      List<dynamic> StudentStat = [];
      List<String> AbyCwithPercentage = [];
      for(var j in class_list){
        QuerySnapshot querySnapshot = await _firestore.collection('Absent_data').where('Department', isEqualTo: deptvalue).where('Year',isEqualTo: yearvalue).where('Section',isEqualTo: sectionvalue).where('Course_name',isEqualTo: j).where('Academic_year',isEqualTo:fetched_Academic_year).where('Absentees', arrayContains: searching).get();
        if(querySnapshot.docs.isNotEmpty){
          List<QueryDocumentSnapshot<Object?>> doc = querySnapshot.docs;
          len = doc.length;
        }
        else{
          len=0;
        }
        attended = classes_count[count]-len;
        totalclassesAttended = totalclassesAttended+attended;
        int classcount = classes_count[count];
        String classesAttended = attended.toString();
        String classesStrcount = classcount.toString();
        String AbyC = classesAttended+"/"+classesStrcount;
        AbyClist.add(AbyC);
        if(attended==0 && classcount==0){
          String AbyCpercentage = '0.0';
          Percentage.add(AbyCpercentage);
          AbyCpercentageString = AbyC+" ("+AbyCpercentage+"%)";
        }
        else{
          double AbyCpercentage = (attended/classcount)*100;
          String result = AbyCpercentage.toStringAsFixed(2);
          Percentage.add(result);
          AbyCpercentageString = AbyC+" ("+result+"%)";
        }
        AbyCwithPercentage.add(AbyCpercentageString);
        count++;
        setState(() {
          loader = counter/(class_list.length);
          percentageloader = (loader*100).toInt();
        });
        counter = counter+1;
      }


      total_percentage = (totalclassesAttended/total_classes_completed)*100;
      String total_percentage_result = total_percentage.toStringAsFixed(2);
      StudentStat.add(searching);
      StudentStat=StudentStat+AbyCwithPercentage;
      StudentStat.add(totalclassesAttended);
      StudentStat.add(total_classes_completed);
      StudentStat.add(total_percentage_result);
      StudentsData.add(StudentStat);

      final studentdet = Datawidget(searching,class_list,AbyClist,Percentage,totalclassesAttended,total_classes_completed,total_percentage_result);
      messageWidgets.add(studentdet);
      totalclassesAttended=0;
      count=0;
      if(rollNumber.length == counter){
        print(counter);
        setState(() {
          isFlag = false;
        });
      }
      else{
        setState(() {
          isFlag = true;
        });
      }
    return messageWidgets;
  }
  @override
  void initState() {
    func();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 30.0),
          Column(
            children: [
              Row(
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
              SizedBox(height: 20.0),
              Row(
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
                ],
              ),
              SizedBox(height: 20.0,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
                child: TextField(
                  autofocus: true,
                  controller: searchController,
                  onEditingComplete: (){
                    setState(() {
                      searching = search;
                      FocusScope.of(context).unfocus();
                      loader = 0.0;
                      percentageloader = 0;
                      counter = 0;
                      StudentsData.clear();
                      lis = gettingClassList(deptvalue,yearvalue,sectionvalue);
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
            ],
          ),
          // Container(
          //   child: Row(
          //
          //     children: [
          //
          //
          //     ],
          //   ),
          // ),
          //
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
          //   child: Expanded(
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [

                  // Expanded(
                  //   child:
                  // ),
          //         // Padding(
          //         //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         //   child: TextButton(
          //         //     onPressed: (){
          //         //
          //         //     },
          //         //     child: Row(
          //         //         mainAxisAlignment: MainAxisAlignment.center,
          //         //         children: [
          //         //           isFlag?Icon(Icons.cancel):Icon(Icons.search),
          //         //           SizedBox(width: 10.0,),
          //         //           isFlag?Text("Cancel",):Text("Search",),
          //         //         ]
          //         //     ),
          //         //     style: ButtonStyle(
          //         //       backgroundColor: MaterialStateProperty.all(Color(0xff2D3250)),
          //         //       minimumSize: MaterialStateProperty.all(Size(150.0, 65.0)),
          //         //       foregroundColor: MaterialStateProperty.all(Colors.white),
          //         //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //         //         RoundedRectangleBorder(
          //         //           borderRadius: BorderRadius.circular(5.0),
          //         //         ),
          //         //       ),
          //         //     ),
          //         //   ),
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),
          SizedBox(height: 10.0,),
          Expanded(
            child: FutureBuilder<List<Datawidget>>(
              future: lis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loading indicator while waiting for the future
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator(
                        value: loader,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                        SizedBox(height: 10.0,),
                        Text('Fetched: $percentageloader%'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Return an error message if the future fails
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  // Return the ListView once the future completes
                  List<Datawidget>? data = snapshot.data;
                  if (data != null && data.isNotEmpty) {
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return data[index];
                      },
                    );
                  } else {
                    // Return a message if there's no data
                    return Center(
                      child: Text('No data available'),
                    );
                  }
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}

class Datawidget extends StatelessWidget {
  final String rolls;
  final List<dynamic> class_list;
  final List<String> AbyClist1; // Changed from AbyClist
  final List<String> Percentage1; // Changed from Percentage
  final int totalclassesAttended;
  final int total_classes_completed;
  final String total_percentage;
  Datawidget(this.rolls,this.class_list,this.AbyClist1,this.Percentage1,this.totalclassesAttended,this.total_classes_completed,this.total_percentage);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 23.0),
      padding: EdgeInsets.symmetric(vertical: 20.0,horizontal: 25.0),
      decoration: BoxDecoration(
        color: Color(0xffb9cdef),
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
                child: Text('Roll number: $rolls',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
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
              Column(
                children: class_list.map((classes) => Text(classes,style: TextStyle(
                  fontSize: 16.0,
                ),)).toList(),
              ),
              Column(
                children: AbyClist1.map((classes) => Text(classes,style: TextStyle(
                  fontSize: 16.0,
                ),)).toList(),
              ),
              Column(
                children: Percentage1.map((classes) => Text(classes.toString(),style: TextStyle(
                  fontSize: 16.0,
                ),)).toList(),
              ),
            ],
          ),
          SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attended"),
              Text("Conducted"),
              Text("Total Percentage"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),

                child: Text(totalclassesAttended.toString(),
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
                child: Text(total_classes_completed.toString(),style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0,horizontal: 5.0),
                child: Text(total_percentage.toString(),style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
