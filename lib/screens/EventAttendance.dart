import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Data/lists_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:attendance/screens/faculty_attendance_screen.dart';
import 'package:attendance/screens/Profile.dart';

class Event_main extends StatelessWidget {
  const Event_main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffb6d3f5),
      body: Eventattendance(),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return EventProfile();
            }));
          },
          child: Icon(Icons.account_circle),
        ),
      ),
    );
  }
}

class Eventattendance extends StatefulWidget {
  const Eventattendance({super.key});

  @override
  State<Eventattendance> createState() => _EventattendanceState();
}

class _EventattendanceState extends State<Eventattendance> {
  final _firestore = FirebaseFirestore.instance;
  String? Curr;
  String Timeslot_value = "";
  String today_Date = "";
  bool checked = false;
  Map<String, dynamic> fulldata = {};
  List<dynamic> courses = ["Select"];
  List<dynamic> Sections = ["Select"];
  List<dynamic> branches = ["Select"];
  List<dynamic> Timeslots = ["Select"];
  Map<String, List<dynamic>> studentsData = {};
  Map<String, List<String>> selectedRollNumbers = {};
  String greeting = '';
  String username = '';

  void func() async {
    setState(() {
      final _auth = FirebaseAuth.instance;
      Curr = _auth.currentUser!.email;
      today_Date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      int hour = DateTime.now().hour;
      if (hour < 12) {
        greeting = 'Good Morning...';
      } else if (hour < 17) {
        greeting = 'Good Afternoon...';
      } else {
        greeting = 'Good Evening...';
      }
    });

    if (Curr != null) {
      setState(() {
        username = Curr ?? 'No Username';
      });
    }
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        Timeslots = ['Select'];
        Timeslots =  Timeslots + data['Time-Slots'];
      });
    }
  }

  void calling_numbers() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('email', isEqualTo: Curr)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      setState(() {
        studentsData = Map<String, List<dynamic>>.from(data['studentsData']);
        for (var key in studentsData.keys) {
          selectedRollNumbers[key] = [];
        }
      });
    } else {
      print('No data found for the user.');
    }
  }
  List<String> checkOverlappingSlots(List<dynamic> timeSlots, String selectedSlot) {
    List<String> selectedTimes = selectedSlot.split(' - ');
    DateTime selectedStartTime = _parseTime(selectedTimes[0]);
    DateTime selectedEndTime = _parseTime(selectedTimes[1]);

    List<String> overlappingSlots = [];

    for (String slot in timeSlots) {
      List<String> times = slot.split(' - ');
      DateTime startTime = _parseTime(times[0]);
      DateTime endTime = _parseTime(times[1]);

      // Check if the slot is within the selected time range
      // Check if the slot is within the selected time range
      if (startTime.isAfter(selectedStartTime) && endTime.isBefore(selectedEndTime) ||
          startTime.isAtSameMomentAs(selectedStartTime) && endTime.isBefore(selectedEndTime) ||
          startTime.isAfter(selectedStartTime) && endTime.isAtSameMomentAs(selectedEndTime) ||
          startTime.isAtSameMomentAs(selectedStartTime) && endTime.isAtSameMomentAs(selectedEndTime)) {
        overlappingSlots.add(slot);
      }

      // Check if the selected slot is within the current slot (encompassing case)
      if (startTime.isBefore(selectedStartTime) && endTime.isAfter(selectedEndTime) ||
          startTime.isAtSameMomentAs(selectedStartTime) && endTime.isAfter(selectedEndTime) ||
          startTime.isBefore(selectedStartTime) && endTime.isAtSameMomentAs(selectedEndTime)) {
        overlappingSlots.add(slot);
      }
    }
    return overlappingSlots;
  }

  DateTime _parseTime(String time) {
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    int currentYear = DateTime.now().year;
    return DateTime(currentYear, 1, 1, hour, minute); // You can ignore the date, it's just a placeholder.
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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 25.0, 0.0, 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xffffffff),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Color(0xffffffff),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Date: $today_Date"),
                DropdownMenu<dynamic>(
                  initialSelection: Timeslots.first,
                  label: Text("Time-Slot"),
                  onSelected: (dynamic? value) {
                    setState(() {
                      Timeslot_value = value!;
                      calling_numbers();
                    });
                  },
                  dropdownMenuEntries: Timeslots.map<DropdownMenuEntry<dynamic>>((dynamic value) {
                    return DropdownMenuEntry<String>(value: value, label: value);
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 30.0, top: 10.0, right: 37.0, bottom: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: studentsData.isNotEmpty
                  ? ListView(
                children: studentsData.keys.map((key) {
                  return ExpansionTile(
                    title: Text(key),
                    children: studentsData[key]!.map<Widget>((rollNumber) {
                      bool isSelected = selectedRollNumbers[key]?.contains(rollNumber) ?? false;

                      return CheckboxListTile(
                        title: Text(
                          rollNumber,
                          style: TextStyle(
                            decoration: isSelected ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedRollNumbers.putIfAbsent(key, () => []).add(rollNumber);
                            } else {
                              selectedRollNumbers[key]?.remove(rollNumber);
                              if (selectedRollNumbers[key]?.isEmpty ?? true) {
                                selectedRollNumbers.remove(key);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                }).toList(),
              )
                  : Center(child: Text("No Data available")),
            ),
          ),
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text("Attendance"),
                content: Text("Are you sure you want to submit?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      List<String> overlappingSlots = checkOverlappingSlots(Timeslots.sublist(1),Timeslot_value);
                      print(overlappingSlots);
                      DateTime date = DateFormat('dd-MM-yyyy').parse(today_Date);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                      for (var key in selectedRollNumbers.keys) {
                        var splitKey = key.split('-'); // Change from '-' to '_'
                        var department = splitKey[0];
                        print(department);
                        var year = splitKey[1];
                        print(year);
                        var section = splitKey[2];
                        print(section);
                        List<dynamic> presentRollNumbers = studentsData[key]!.where((rollNumber) => !selectedRollNumbers[key]!.contains(rollNumber)).toList();

                        for (var i in overlappingSlots){
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('Absent_data')
                              .where('Date', isEqualTo: formattedDate)
                              .where('Department', isEqualTo: department)
                              .where('Year', isEqualTo: year)
                              .where('Section', isEqualTo: section)
                              .where('Time_slot', isEqualTo: i)
                              .get();
                          if (querySnapshot.docs.isNotEmpty){
                            final document = querySnapshot.docs.first;
                            final data = document.data();

                            List<dynamic> absentees = List<dynamic>.from(data['Absentees']);

                            // Remove roll numbers in the Present list from the Absentees list
                            absentees.removeWhere((rollNumber) => presentRollNumbers.contains(rollNumber));
                            absentees.sort();
                            // Update the document with the modified Absentees list
                            await document.reference.update({'Absentees': absentees});

                            print('Updated Absentees list: $absentees');
                          }
                        }
                        Map<String, dynamic> attendanceData = {
                          'Submission': FieldValue.serverTimestamp(),
                          'Department': department,
                          'Year': year,
                          'Section': section,
                          'Date': formattedDate,
                          'Time_slot': Timeslot_value,
                          'Faculty': Curr,
                          'Absentees': selectedRollNumbers[key],
                          'Present': presentRollNumbers,
                        };

                        await FirebaseFirestore.instance.collection('event_attendance').add(attendanceData);
                      }

                      setState(() {
                        selectedRollNumbers.clear();
                      });

                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        text: 'Attendance Submitted Successfully!',
                        onConfirmBtnTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return Event_main();
                          }));
                        },
                      );
                    },
                    child: Text("Submit"),
                  ),
                ],
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                "Submit Attendance",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
