import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/admin/products/screens/CreateProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminProductDetailsScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const AdminProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<AdminProductDetailsScreen> createState() =>
      _AdminProductDetailsScreenState();
}

class _AdminProductDetailsScreenState
    extends ConsumerState<AdminProductDetailsScreen> {
  bool _isLoading = true;
  List<ProductModel> products = [];

  Future<void> _fetchProducts() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    setState(() => _isLoading = true);

    try {
      List<ProductModel> fetchedProducts =
          await firebaseService.getAllProducts();

      setState(() {
        products = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Handle product deletion logic here
              // You can implement the deletion logic here if needed
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateProductScreen(
                    product: widget.product,
                    fetchProductsCallback: _fetchProducts,
                  ), // Replace with your Edit page
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Carousel
              if (widget.product.images.isNotEmpty)
                CarouselSlider(
                  items: widget.product.images
                      .map((imageUrl) => ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1.0,
                  ),
                ),

              // Product Details Section
              const SizedBox(height: 20),
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoBox('Category', widget.product.category),
                  const SizedBox(width: 8),
                  _buildInfoBox('Sold', '${widget.product.totalSold} sold'),
                ],
              ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).colorScheme.surface),
              const SizedBox(height: 5),

              // Description Section
              Text(
                'Description',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text(widget.product.description),
              const SizedBox(height: 20),

              // Additional Details
              _buildInfoBox(
                  'Price', '\$${widget.product.price.toStringAsFixed(2)}'),
              _buildInfoBox(
                  'Stock Quantity', widget.product.stockQuantity.toString()),
              _buildInfoBox('Average Rating',
                  widget.product.averageRating.toStringAsFixed(1)),
              _buildInfoBox(
                  'Total Reviews', widget.product.totalReviews.toString()),
              _buildInfoBox(
                  'Created At', _formatDate(widget.product.createdAt)),
              _buildInfoBox(
                  'Updated At', _formatDate(widget.product.updatedAt)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build info boxes
  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  // Helper method to format DateTime into a string
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
