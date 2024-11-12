class OrderItemModel {
  final String productId;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  // Convert OrderItemModel to Map for Firebase or other storage
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  // Factory method to create OrderItemModel from a Map
  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'],
      quantity: map['quantity'],
      price: map['price'].toDouble(),
    );
  }
}
