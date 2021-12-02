import 'package:fetchdatafrommongo/appState/appState.dart';
import 'package:fetchdatafrommongo/screen/homePage.dart';
import 'package:fetchdatafrommongo/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingResource extends StatefulWidget {
  const LoadingResource({Key? key}) : super(key: key);

  @override
  _LoadingResourceState createState() => _LoadingResourceState();
}

class _LoadingResourceState extends State<LoadingResource> {
  @override
  Widget build(BuildContext context) {
    var student = context.watch<AppState>().studentmodel;
    // return student == null ? LoginPage() : HomePage();
    return HomePage();
  }
}
