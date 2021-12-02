import 'dart:convert';

import 'package:fetchdatafrommongo/appState/appState.dart';
import 'package:fetchdatafrommongo/model/studentModel.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  TextEditingController userIDcontroller = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  //create variable string link API
  String uri = "https://www.schoolmgm.online";
  //create variable string phass link API
  String studentLogin = "/api/v1/school/students/student_token";
  //create Function Login
  handleLogin() {
    String id = userIDcontroller.value.text.trim();
    String pwd = userPasswordController.value.text.trim();
    final url = Uri.parse("$uri$studentLogin?s_token=$id&pwd=$pwd");
    //make http fetch server from internet
    http.get(url).then((http.Response response) {
      //convert data json to Map
      var _body = jsonDecode(response.body);
      if (_body['code'] == 201) {
        StudentModel student = StudentModel.fromJson(_body['data']);
        context.read<AppState>().setUser(student);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_body['message'])));
      }
      print(_body);
    });
  }

  //Create Stream Builder Subject
  var subjectUserValidate = BehaviorSubject<bool>();
  @override
  void dispose() {
    subjectUserValidate.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          //body
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill, image: AssetImage('assets/img/login.png')),
          ),
          child: Column(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 1,
                child: Form(
                  key: formstate,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: () {
                    bool isValidate = formstate.currentState!.validate();
                    subjectUserValidate.add(isValidate);
                  },
                  child: ListView(
                    children: [
                      //username
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 30),
                        child: TextFormField(
                          controller: userIDcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "require username or ID";
                            }
                          },
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: "login with ID or username",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0))),
                        ),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      //password
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 30, right: 30, top: 30),
                        child: TextFormField(
                          controller: userPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "require password";
                            } else if (value.isNotEmpty && value.length < 4) {
                              return "password must be more than 3";
                            }
                            return null;
                          },
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: "password",
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 2.0))),
                        ),
                      ),
                      StreamBuilder(
                        initialData: false,
                        stream: subjectUserValidate,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          bool isValid = snapshot.data;
                          return TextButton(
                              onPressed: isValid
                                  ? () {
                                      handleLogin();
                                    }
                                  : null,
                              child: Container(
                                  width: 100,
                                  height: 40,
                                  color: Colors.white,
                                  child: Center(
                                      child: Text(
                                    'Login now',
                                    style: TextStyle(color: Colors.black),
                                  ))));
                        },
                      )
                    ],
                  ),
                ),
              ),
              Expanded(flex: 1, child: Container())
            ],
          ),
        ));
  }
}
