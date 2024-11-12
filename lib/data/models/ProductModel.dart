import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final int stockQuantity;
  final int totalSold;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.stockQuantity,
    required this.totalSold,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert ProductModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'stockQuantity': stockQuantity,
      'totalSold': totalSold,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Factory method to create a ProductModel from a Map
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] is double ? map['price'] : (map['price'] as num).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      stockQuantity: map['stockQuantity'] ?? 0,
      totalSold: map['totalSold'] ?? 0,
      averageRating: map['averageRating'] is double ? map['averageRating'] : (map['averageRating'] as num).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
