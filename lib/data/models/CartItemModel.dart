class CartItemModel {
  final String productId;
  int quantity;

  CartItemModel({
    required this.productId,
    this.quantity = 1,
  });

  // Convert CartItemModel to Map for Firebase or other storage
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }

  // Factory method to create CartItemModel from a Map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'],
      quantity: map['quantity'],
    );
  }
}
