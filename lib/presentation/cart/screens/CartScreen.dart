// import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
// import 'package:babyshophub/data/models/CartModel.dart';
// import 'package:babyshophub/data/models/ProductModel.dart';
// import 'package:babyshophub/presentation/cart/widgets/CartItemCard.dart';
// import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
// import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class CartScreen extends ConsumerStatefulWidget {
//   const CartScreen({super.key});
//
//   @override
//   ConsumerState<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends ConsumerState<CartScreen> {
//   final TextEditingController searchController = TextEditingController();
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _cartItems = [];
//   double _totalPrice = 0.0;
//
//   Future<void> _fetchCartData() async {
//     final firebaseService = ref.read(firebaseServiceProvider);
//     setState(() => _isLoading = true);
//
//     try {
//       CartModel cartData = await firebaseService.getCartItems();
//       List<Map<String, dynamic>> fetchedCartItems = [];
//       double totalPrice = 0.0;
//
//       for (var productInfo in cartData.products) {
//         String productId = productInfo.productId;
//         int quantity = productInfo.quantity;
//
//         // Fetch product details using productId
//         ProductModel? product = await firebaseService.getProduct(productId);
//
//         // Calculate total price of this product based on its quantity
//         double productTotalPrice = product!.price * quantity;
//         totalPrice += productTotalPrice;
//
//         // Add the product details, quantity, and product ID to the cart items list
//         fetchedCartItems.add({
//           'productId': productId,
//           'product': product,
//           'quantity': quantity,
//         });
//       }
//
//       setState(() {
//         _cartItems = fetchedCartItems;
//         _totalPrice = totalPrice;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching products: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _updateCartItem(String productId, int quantity) async {
//     final firebaseService = ref.read(firebaseServiceProvider);
//     await firebaseService.updateCartItem(productId, quantity);
//     _fetchCartData(); // Refresh the cart data after update
//   }
//
//   Future<void> _removeFromCart(String productId) async {
//     final firebaseService = ref.read(firebaseServiceProvider);
//     await firebaseService.removeFromCart(productId);
//     _fetchCartData(); // Refresh the cart data after removal
//   }
//
//   void _onIncreaseQuantity(int index) {
//     final item = _cartItems[index];
//     int newQuantity = item['quantity'] + 1;
//     _updateCartItem(item['productId'], newQuantity);
//   }
//
//   void _onDecreaseQuantity(int index) {
//     final item = _cartItems[index];
//     int newQuantity = item['quantity'] - 1;
//     if (newQuantity > 0) {
//       _updateCartItem(item['productId'], newQuantity);
//     } else {
//       _removeFromCart(item['productId']);
//     }
//   }
//
//   void _onRemove(int index) {
//     final item = _cartItems[index];
//     _removeFromCart(item['productId']);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchCartData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Cart',
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//           child: Column(
//             children: [
//               CustomTextField(
//                 placeholder: "Search",
//                 controller: searchController,
//                 validator: (value) {
//                   return null;
//                 },
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: Colors.grey,
//                   size: 21,
//                 ),
//               ),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = _cartItems[index];
//                   return CartItemCard(
//                     product: item['product'],
//                     quantity: item['quantity'],
//                     onRemove: () => _onRemove(index),
//                     onIncreaseQuantity: () => _onIncreaseQuantity(index),
//                     onDecreaseQuantity: () => _onDecreaseQuantity(index),
//                   );
//                 },
//               ),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.secondary,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Total price',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 18),
//                         ),
//                         Text(
//                           '\$${_totalPrice.toStringAsFixed(2)}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 18),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     CustomButton(
//                       onPressed: () {},
//                       buttonText: "Checkout",
//                       isLoading: _isLoading,
//                       backgroundColor: Theme.of(context).primaryColor,
//                       buttonSize: ButtonSize.full,
//                       borderRadius: 10.0,
//                       leadingIcon: const Icon(Icons.shopping_cart),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/data/models/CartModel.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:babyshophub/presentation/cart/widgets/CartItemCard.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _filteredCartItems = [];
  double _totalPrice = 0.0;

  Future<void> _fetchCartData() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    setState(() => _isLoading = true);

    try {
      CartModel cartData = await firebaseService.getCartItems();
      List<Map<String, dynamic>> fetchedCartItems = [];
      double totalPrice = 0.0;

      for (var productInfo in cartData.products) {
        String productId = productInfo.productId;
        int quantity = productInfo.quantity;

        ProductModel? product = await firebaseService.getProduct(productId);
        double productTotalPrice = product!.price * quantity;
        totalPrice += productTotalPrice;

        fetchedCartItems.add({
          'productId': productId,
          'product': product,
          'quantity': quantity,
        });
      }

      setState(() {
        _cartItems = fetchedCartItems;
        _filteredCartItems = fetchedCartItems;
        _totalPrice = totalPrice;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterCartItems(String query) {
    setState(() {
      _filteredCartItems = _cartItems.where((item) {
        final productName = item['product'].name.toLowerCase();
        return productName.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _updateCartItem(String productId, int quantity) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    await firebaseService.updateCartItem(productId, quantity);
    _fetchCartData();
  }

  Future<void> _removeFromCart(String productId) async {
    final firebaseService = ref.read(firebaseServiceProvider);
    await firebaseService.removeFromCart(productId);
    _fetchCartData();
  }

  void _onIncreaseQuantity(int index) {
    final item = _filteredCartItems[index];
    int newQuantity = item['quantity'] + 1;
    _updateCartItem(item['productId'], newQuantity);
  }

  void _onDecreaseQuantity(int index) {
    final item = _filteredCartItems[index];
    int newQuantity = item['quantity'] - 1;
    if (newQuantity > 0) {
      _updateCartItem(item['productId'], newQuantity);
    } else {
      _removeFromCart(item['productId']);
    }
  }

  void _onRemove(int index) {
    final item = _filteredCartItems[index];
    _removeFromCart(item['productId']);
  }

  @override
  void initState() {
    super.initState();
    _fetchCartData();
    searchController.addListener(() {
      _filterCartItems(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cart',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: Column(
              children: [
                CustomTextField(
                  placeholder: "Search",
                  controller: searchController,
                  validator: (value) => null,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              itemCount: _filteredCartItems.length,
              itemBuilder: (context, index) {
                final item = _filteredCartItems[index];
                return CartItemCard(
                  product: item['product'],
                  quantity: item['quantity'],
                  onRemove: () => _onRemove(index),
                  onIncreaseQuantity: () => _onIncreaseQuantity(index),
                  onDecreaseQuantity: () => _onDecreaseQuantity(index),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total price',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      '\$${_totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onPressed: () {},
                  buttonText: "Checkout",
                  isLoading: _isLoading,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonSize: ButtonSize.full,
                  borderRadius: 10.0,
                  leadingIcon: const Icon(Icons.shopping_cart),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
