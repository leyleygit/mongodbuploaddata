import 'package:fetchdatafrommongo/model/studentModel.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  var db;

  StudentModel? studentmodel;
  setUser(StudentModel val) {
    studentmodel = val;
    notifyListeners();
  }
}
