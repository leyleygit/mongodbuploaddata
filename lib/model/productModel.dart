import 'package:mongo_dart/mongo_dart.dart';

class ProductModel {
  final ObjectId id;
  final String name;
  final int price;
  final String? status;
  ProductModel({required this.id, required this.name, required this.price, this.status});
  factory ProductModel.fromJson(json) {
    return ProductModel(
        id: json['_id'], name: json['name'], price: json['price'],status: json['status']);
  }
}
