
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  String curr="";
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String username='';
  String email='';
  String ph_number='';
  String password='';
  String searching = "";
  String? FacStatus;
  String UniqueName="";
  String imageurl = "";
  String deptvalue="";
  String deptback = "";
  List<dynamic> branches = ["Select"];
  List<String> Status = ["Select"];
  bool isLoading = true; // To track loading state
  String? role;
  void func() async {
    try {
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('Faculty_Data')
          .where('email', isEqualTo: curr)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final DocumentSnapshot userDoc = userDocs.docs[0];
        setState(() {
          role = userDoc['faculty_status']; // Example field name
          if(role=='admin'){
            Status=Status+["HOD","Professor","Assoc Professor","Asst Professor"];
          }
          else{
            deptback = userDoc['department'];
            Status=Status+["Professor","Assoc Professor","Asst Professor"];
          }
          isLoading = false; // Stop loading after role is fetched
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if no user found
        });
      }
    } catch (error) {
      // Handle any errors here
      setState(() {
        isLoading = false;
      });
    }
    final messages = await _firestore.collection('Dept_data').get();
    for (var message in messages.docs){
      final data = message.data();
      setState(() {
        role=="admin"?branches =  branches + data['Branches']:branches.add(deptback);
      });
    }
  }

  void PickImage() async{
    ImagePicker imagepicker = ImagePicker();
    XFile? file = await imagepicker.pickImage(source: ImageSource.gallery);
    if (file == null) return; // If no image is selected, return

    // Step 1: Crop the image
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
            // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ],
    );


    if (croppedFile == null) return;
    UniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instanceFor(app:Firebase.app(),bucket:'gs://attendance-e35d5.appspot.com');
    Reference referenceDir = storage.ref().child('images');
    Reference referenceImage = referenceDir.child(UniqueName);
    File imageFile = File(croppedFile!.path);
    try{
      await referenceImage.putFile(imageFile);
      imageurl = await referenceImage.getDownloadURL();
      setState(() {
        searching = imageurl;
      });
  }
  catch(e){
      print(e);
    }

  }
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();


  @override
  void initState() {
    curr = _auth.currentUser!.email!;
    func();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF5FF),
      body: Stack(
        children: [
          SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 35.0,left: 15.0),
                  child: TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_rounded, size: 18.0,),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      elevation: WidgetStateProperty.all(5.0),
                      shape: WidgetStateProperty.all<CircleBorder>(
                        CircleBorder(),
                      ),
                      shadowColor: WidgetStateProperty.all(Colors.black),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/images.jpeg'),
                          radius: 40.0,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                      Text("Faculty Registration",style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),),
                      SizedBox(height: 30.0,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            hintText: "Username",
                            hintStyle:TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0),),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
        
                          ),
                          onChanged: (value){
                            username=value;
                          },
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            hintText: "Email",
                            hintStyle:TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0),),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
            
                          ),
                          onChanged: (value){
                            email=value;
                          },
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.security),
                            hintText: "Password",
                            hintStyle:TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0),),
                              borderSide: BorderSide.none,
                            ),
            
                            filled: true,
                            fillColor: Colors.white,
            
                            suffixIcon: IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              onPressed: null,
                            ),
                          ),
                          onChanged: (value){
                            password=value;
                          },
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: TextField(
                          controller: _phonenumberController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.account_circle),
                            hintText: "Phone number",
                            hintStyle:TextStyle(
                              color: Colors.grey.withOpacity(0.8),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15.0),),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
        
                          ),
                          onChanged: (value){
                            ph_number=value;
                          },
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      Container(
        
                        child: DropdownMenu<dynamic>(
                          width:MediaQuery.of(context).size.width * 0.8,
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
                      ),
                      SizedBox(height: 30.0,),
        
                      Container(
        
                        child: DropdownMenu <String> (
                          width:MediaQuery.of(context).size.width * 0.8,
                          initialSelection: Status.first,
                          label: Text("Faculty Status"),
                          onSelected: (String? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              FacStatus = value!;
                            });
                          },
                          dropdownMenuEntries: Status.map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(value: value, label: value);
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 25.0,),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 100.0,
                              height: 100.0,
                              child:CircleAvatar(
                                backgroundImage: NetworkImage(searching==""?'https://cdn.pixabay.com/photo/2018/11/13/21/43/avatar-3814049_640.png':searching),
                                radius: 40.0,
                              ),
                            ),
                            // Button
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextButton(
                                  onPressed: (){
                                    PickImage();
                                  },
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.perm_media),
                                        SizedBox(width: 10.0,),
                                        Text(
                                          "Upload Image",
                                        ),
                                      ]
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(Color(0xff2D3250)),
                                    minimumSize: WidgetStateProperty.all(Size(150.0, 50.0)),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      SizedBox(height: 25.0,),
                      TextButton(onPressed:() async{
                        FirebaseApp secondaryApp = await Firebase.initializeApp(
                          name: 'SecondaryApp',
                          options: Firebase.app().options,
                        );
                        try{
                          final newUserCredential = await FirebaseAuth.instanceFor(app: secondaryApp).createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (newUserCredential.user != null) {
                            _firestore.collection('Faculty_Data').add({
                              'Username':username,
                              'department':deptvalue,
                              'ph_number': ph_number,
                              'email': email,
                              'display_image': searching,
                              'faculty_status':FacStatus,
                            });
                            // User registered successfully
                            setState(() {
                              searching="";
                            });
                            _usernameController.clear();
                            _passwordController.clear();
                            _emailController.clear();
                            _phonenumberController.clear();
        
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User registered successfully!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to register user.'),
                              ),
                            );
                          }
                          await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
                        }
                        catch (e) {
                          print("Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          // Ensure that the secondary app instance is deleted after use
                          await secondaryApp.delete();
                        }
                      } , child: Text(
                        "Register",
                      ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Color(0xff2D3250)),
                          minimumSize: WidgetStateProperty.all(Size(150.0, 50.0),),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0), // Adjust the border radius as needed
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          if (isLoading) ...[
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.5),
            ),
            Center(
              child: SpinKitDoubleBounce(
                color: Colors.white,
                size: 50.0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3';
}