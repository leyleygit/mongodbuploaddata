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
  FocusNode focusproname = FocusNode();
  FocusNode focusproprice = FocusNode();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  BehaviorSubject<bool> subjectInsertbutton = BehaviorSubject<bool>();
  late mongo.Db db;
  BehaviorSubject<List<ProductModel>> subjectfetchproduct =
      BehaviorSubject<List<ProductModel>>();
  List<ProductModel> products = [];
  fetchDataProdutTomodel() async {
    await db.collection('product').find().forEach((element) {
      ProductModel product = ProductModel.fromJson(element);
      // products.add(product);
      if (!products.map((e) => e.id).contains(product.id)) {
        products.add(product);
      }
    });
    subjectfetchproduct.add(products);
  }

  //upload data to Table model in mogoDB
  postMongoDBdata() async {
    await db.collection('product').insert({
      "name": pronameController.text.toString(),
      "price": int.parse(propriceController.text)
    });
  }

  @override
  void dispose() {
    subjectInsertbutton.close();
    subjectfetchproduct.close();

    super.dispose();
  }

  @override
  void initState() {
    db = context.read<AppState>().db;
    fetchDataProdutTomodel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
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
                      subjectInsertbutton.add(isValidate);
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
                            focusNode: focusproname,
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
                              focusNode: focusproprice,
                              keyboardType: TextInputType.number,
                              controller: propriceController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "price is required";
                                } else {
                                  final numericRegex = RegExp(
                                      r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                  if (numericRegex.hasMatch(value)) {
                                  } else {
                                    return 'Price must be number';
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "price",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0)),
                              ),
                            )),
                        StreamBuilder(
                          stream: subjectInsertbutton,
                          initialData: false,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            bool isvalid = snapshot.data;
                            return ElevatedButton(
                                onPressed: isvalid
                                    ? () {
                                        postMongoDBdata();
                                        pronameController.clear();
                                        propriceController.clear();
                                        focusproname.unfocus();
                                        focusproprice.unfocus();
                                        fetchDataProdutTomodel();
                                      }
                                    : null,
                                child: Text('ADD PRODUCT NOW'));
                          },
                        )
                      ],
                    ),
                  )),
              Expanded(
                  child: StreamBuilder(
                      initialData: <ProductModel>[],
                      stream: subjectfetchproduct,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        List<ProductModel> productsSnapshot = snapshot.data;
                        return Container(
                          color: Colors.red,
                          child: ListView.builder(
                            itemCount: productsSnapshot.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (BuildContext context, int index) {
                              ProductModel product = productsSnapshot[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 60,
                                  color: Colors.white,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          product.name,
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        Text(
                                          "${product.price.toString()}\$",
                                          style: TextStyle(fontSize: 30),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }))
            ],
          ),
        ));
  }
}
