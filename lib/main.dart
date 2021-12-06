import 'package:fetchdatafrommongo/appState/appState.dart';

import 'package:fetchdatafrommongo/screen/loadingResource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void main() {
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => AppState())],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoadingConnection = true;
  connectMongo() async {
    final String connectionString = ('mongodb+srv://kerker:kerker@kerker.wyfcw.mongodb.net/stockmanagement');
    var db =await mongo.Db.create(connectionString);
    await db.open();
    context.read<AppState>().db = db;
    setState(() {
      isLoadingConnection = false;
    });
  }

  @override
  void initState() {
    connectMongo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isLoadingConnection
            ? Center(
                child: CircularProgressIndicator(),
              )
            : LoadingResource());
  }
}
