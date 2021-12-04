import 'package:fetchdatafrommongo/model/productModel.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ProductView extends StatefulWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  BehaviorSubject<List<ProductModel>> subjectFetchData =
      BehaviorSubject<List<ProductModel>>();
  @override
  void dispose() {
    subjectFetchData.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
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
                  decoration:
                      BoxDecoration(color: Colors.black.withOpacity(0.6),borderRadius: BorderRadius.circular(14.0)),
                      
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
