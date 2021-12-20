import 'package:fetchdatafrommongo/appState/appState.dart';
import 'package:fetchdatafrommongo/model/productModel.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:provider/provider.dart';

class ProductView extends StatefulWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  //TextField Add Product
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  BehaviorSubject<bool> subjectButtonInsertProduct = BehaviorSubject<bool>();

  //create stream subject fetch Data
  BehaviorSubject<List<ProductModel>> subjectFetchData =
      BehaviorSubject<List<ProductModel>>();
  List<ProductModel> products = [];
  late mongo.Db db;
  fetchDataFromMongoDB() async {
    await db
        .collection('product')
        .find(mongo.SelectorBuilder().eq('status', 'enable'))
        .forEach((element) {
      ProductModel product = ProductModel.fromJson(element);
      if (!products.map((e) => e.id).contains(product.id)) {
        products.add(product);
      }
    });
    print(products.map((e) => e.name));
    subjectFetchData.add(products);
  }

  deleteProduct() async {
 await   db.collection('product').updateMany(mongo.SelectorBuilder().oneFrom('_id', selectedProducts.map((e) => e.id).toList()), mongo.ModifierBuilder().set('status', 'disable')).then((value){
      products.removeWhere((element) =>selectedProducts.map((e) => e.id).contains(element.id));
    
      fetchDataFromMongoDB();
    });
  }

  funInsertData() async {
    await db.collection('product').insert({
      'name': productNameController.text.toString(),
      'price': int.parse(productPriceController.text),
      'status': _dropdownItem
    });
  }

  @override
  void initState() {
    db = context.read<AppState>().db;
    fetchDataFromMongoDB();
    super.initState();
  }

  @override
  void dispose() {
    subjectFetchData.close();
    subjectButtonInsertProduct.close();
    super.dispose();
  }

  List _dropDownItems = ['enable', 'disable'];
  String _dropdownItem = "";
  BehaviorSubject<String> _subjectDropDownItem = BehaviorSubject<String>();
  //create variable to check disable

  List<ProductModel> selectedProducts = [];
  BehaviorSubject<List<ProductModel>> subjectSelectedProducts = BehaviorSubject<List<ProductModel>>();
  BehaviorSubject<bool> subjectShowSelectText = BehaviorSubject<bool>();
  bool _isShowSelectText = true;
  bool _isShowDelete = false;
  BehaviorSubject<bool> subjectShowDelete = BehaviorSubject<bool>();
  // BehaviorSubject<bool> subjectShowCircle=BehaviorSubject<bool>();
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: StreamBuilder(
          initialData: false,
          stream: subjectShowDelete,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {  
            print(snapshot.data);
           return snapshot.data? IconButton(onPressed: (){
             deleteProduct();
           }, icon: Icon(Icons.delete)):Container();
         },),
        actions: [
          StreamBuilder(
            initialData: true,
            stream: subjectShowSelectText,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                    child: snapshot.data
                        //true
                        ? InkWell(
                            onTap: () {
                              _isShowSelectText = false;
                             
                              subjectShowSelectText.add(_isShowSelectText);
                                                      
                            },
                            child: Text(
                              'select',
                              style: TextStyle(fontSize: 25),
                            ),
                          )
                        //false
                        : IconButton(
                            onPressed: () {
                               _isShowDelete = false;
                                 subjectShowDelete.add(_isShowDelete);    
                              _isShowSelectText = true;
                              subjectShowSelectText.add(_isShowSelectText);
                              selectedProducts.clear();
                            },
                            icon: Icon(Icons.close))),
              );
            },
          )
        ],
        backgroundColor: Colors.red[300],
      ),
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage('assets/img/bg.png'))),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                //body test field
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(14.0)),
                  child: Form(
                    key: formState,
                    onChanged: () {
                      bool _isValidateFromState =
                          formState.currentState!.validate();
                      subjectButtonInsertProduct.add(_isValidateFromState);
                    },
                    child: ListView(
                      children: [
                        //product textfield
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextFormField(
                            controller: productNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "please insert product name";
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.white),
                                hintText: "Porduct Name",
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    )),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(14.0))),
                          ),
                        ),
                        //textfield price
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "price product is require";
                              } else {
                                final numericRegex = RegExp(
                                    r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
                                if (numericRegex.hasMatch(value)) {
                                } else {
                                  return 'Price must be number';
                                }
                              }
                            },
                            keyboardType: TextInputType.number,
                            controller: productPriceController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                hintStyle: TextStyle(color: Colors.white),
                                hintText: " Price",
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    )),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(14.0))),
                          ),
                        ),

                        StreamBuilder(
                            initialData: "",
                            stream: _subjectDropDownItem,
                            builder: (context, AsyncSnapshot snapshot) {
                              String _dropdownItemSnap = snapshot.data;
                              return DropdownButton(
                                hint: _dropdownItemSnap == ""
                                    ? Text(
                                        'Dropdown',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text(
                                        _dropdownItemSnap,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                items: _dropDownItems.map((e) {
                                  return DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  _dropdownItem = val.toString();
                                  _subjectDropDownItem.add(_dropdownItem);
                                },
                              );
                            }),
                        StreamBuilder(
                          initialData: false,
                          stream: subjectButtonInsertProduct,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            bool _isValidButton = snapshot.data;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: ElevatedButton(
                                  onPressed: _isValidButton
                                      ? () {
                                          funInsertData();
                                          productNameController.clear();
                                          productPriceController.clear();
                                          fetchDataFromMongoDB();
                                        }
                                      : null,
                                  child: Text('Add product')),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: StreamBuilder(
                    initialData: <ProductModel>[],
                    stream: subjectSelectedProducts,
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      List<ProductModel> _selectedProducts = snapshot.data;
                      return StreamBuilder(
                initialData: <ProductModel>[],
                stream: subjectFetchData,
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  List<ProductModel> productSnapshot = snapshot.data;
                  return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: productSnapshot.length,//10
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                  ProductModel product = productSnapshot[index];
              
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: (){
                           
                            print(product.name);
                            if(selectedProducts.contains(product)){
                              selectedProducts.remove(product);
                              if(selectedProducts.isEmpty){
                                _isShowDelete=false;
                                subjectShowDelete.add(_isShowDelete);
                                
                              }else{
                                _isShowDelete=true;
                                 subjectShowDelete.add(_isShowDelete);
                              }
                            }else{
                              _isShowDelete=true;
                                 subjectShowDelete.add(_isShowDelete);
                              selectedProducts.add(product);
                            }
                            subjectSelectedProducts.add(selectedProducts);
                         
                          },
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: Colors.black.withOpacity(0.7)),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                                Text(
                                  product.status == null
                                      ? ""
                                      : product.status!,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ],
                            ),
                          ),
                        ),
                        StreamBuilder(
                          initialData:  true,
                          stream: subjectShowSelectText,
                          builder: (context,AsyncSnapshot snapshot) {
                            return snapshot.data?Container():_selectedProducts.contains(product)? Icon( Icons.check_circle,color: Colors.green,size: 35,):Icon( Icons.circle_outlined,color: Colors.white,size: 35,);
                          }
                        )
                      ],
                    ),
                  );
                    },
                  );
                },
              );
                      },)
              
              
              
              )
            ],
          ),
        ),
      ),
    );
  }
}
