import 'package:babyshophub/data/models/CartItemModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String cartId;
  final String userId;
  final List<CartItemModel> products;
  final DateTime createdAt;
  DateTime updatedAt;

  CartModel({
    required this.cartId,
    required this.userId,
    this.products = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert CartModel to Map for Firebase or other storage
  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Factory method to create CartModel from a Map
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'],
      userId: map['userId'],
      products: List<CartItemModel>.from(
        map['products']?.map((product) => CartItemModel.fromMap(product)) ?? [],
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
