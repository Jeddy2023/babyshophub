import 'package:babyshophub/data/models/OrderItemModel.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItemModel> products;
  final double totalAmount;
  final String status; // e.g., 'pending', 'shipped', 'delivered'
  final DateTime createdAt;
  DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    this.products = const [],
    required this.totalAmount,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert OrderModel to Map for Firebase or other storage
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Factory method to create OrderModel from a Map
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'],
      userId: map['userId'],
      products: List<OrderItemModel>.from(
        map['products']?.map((product) => OrderItemModel.fromMap(product)) ?? [],
      ),
      totalAmount: map['totalAmount'].toDouble(),
      status: map['status'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
