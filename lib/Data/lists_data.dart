class Register_format{
  final String rollno;
  bool isDone;
  Register_format(this.rollno,{this.isDone=false});

  void toggleDone(){
    isDone=!isDone;
  }
}

List<String> absent_numbers = [];
const List<String> Year = [
  'Select',
  '1st_year',
  '2nd_year',
  '3rd_year',
  '4th_year'
];

const List<String> Timeslots = [
  'Select',
  '9:00 - 10:30',
  '10:30 - 12:00',
  '1:30 - 3:00',
  '3:00 - 4:30',
  '9:00 - 12:00',
  '1:30 - 4:30'
];
List<dynamic> PdfHeader=[];

List<List<dynamic>> StudentsData = [];

List<dynamic> rollNumber=[];

String displayimageURL = "";