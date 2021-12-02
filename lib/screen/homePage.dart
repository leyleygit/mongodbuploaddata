import 'package:fetchdatafrommongo/appState/appState.dart';
import 'package:fetchdatafrommongo/model/productModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController pronameController = TextEditingController();
  TextEditingController propriceController = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  BehaviorSubject subjectAddProduct = BehaviorSubject();
  late mongo.Db db;
  List<ProductModel> products = [];
  BehaviorSubject<List<ProductModel>> subjectProducts =
      BehaviorSubject<List<ProductModel>>();
  fetchDataProdutTomodel() async {
    await db.collection('product').find().forEach((element) {
      ProductModel product = ProductModel.fromJson(element);
      products.add(product);
    });
    subjectAddProduct.add(products);
  }

  //upload data to Table model in mogoDB
  postMongoDBdata() {
    db.collection('product').insertOne({
      "name": pronameController.value.toString(),
      "price": propriceController.value
    });
  }

  @override
  void initState() {
    db = context.read<AppState>().db;
    super.initState();
  }

  @override
  void dispose() {
    subjectAddProduct.close(); //subject for validate button add product!!
    subjectProducts.close(); //subject for query to show data IN UI from mongodb
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     context.read<AppState>().studentmodel = null;
        //     Navigator.pushReplacement(
        //         context, CupertinoPageRoute(builder: (_) => LoadingResource()));
        //   },
        // ),

        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: size.width,
                height: 300,
                child: Form(
                  key: formstate,
                  onChanged: () {
                    bool isValidate = formstate.currentState!.validate();
                    subjectAddProduct.add(isValidate);
                  },
                  child: ListView(
                    children: [
                      Text(
                        'Product',
                        style: TextStyle(color: Colors.orange, fontSize: 30),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: pronameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "product name required";
                            }
                          },
                          decoration: InputDecoration(
                              hintText: "product name",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green),
                                  borderRadius: BorderRadius.circular(12.0))),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: propriceController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "price is required";
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "price",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                            ),
                          )),
                      StreamBuilder(
                        initialData: false,
                        stream: subjectAddProduct,
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          bool _isValidfrom = snapshot.data;
                          return ElevatedButton(
                              onPressed: _isValidfrom
                                  ? () {
                                      postMongoDBdata();
                                    }
                                  : null,
                              child: Text('ADD PRODUCT'));
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
