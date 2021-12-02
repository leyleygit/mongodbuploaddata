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
    final String connectionString = ('mongodb://kerker:kerker@'
        'kerker-shard-00-02.wyfcw.mongodb.net:27017,'
        'kerker-shard-00-01.wyfcw.mongodb.net:27017,'
        'kerker-shard-00-00.wyfcw.mongodb.net:27017/'
        'stockmanagement?authSource=admin&compressors=disabled'
        '&gssapiServiceName=mongodb&replicaSet=atlas-stcn2i-shard-0'
        '&ssl=true');
    var db = mongo.Db(connectionString);
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
