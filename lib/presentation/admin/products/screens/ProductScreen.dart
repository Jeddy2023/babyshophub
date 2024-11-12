import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:babyshophub/presentation/admin/products/screens/AdminProductDetailsScreen.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = true;

  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  Future<void> _fetchProducts() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    setState(() => _isLoading = true);

    try {
      List<ProductModel> fetchedProducts =
      await firebaseService.getAllProducts();

      setState(() {
        products = fetchedProducts;
        filteredProducts = fetchedProducts; // Initially show all products
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final productName = product.name.toLowerCase();
        final productCategory = product.category.toLowerCase();
        final searchQuery = query.toLowerCase();

        return productName.contains(searchQuery) ||
            productCategory.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    searchController.addListener(() {
      _filterProducts(searchController.text); // Filter products when text changes
    });
  }

  @override
  void dispose() {
    searchController.removeListener(() {});
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/add-product',
                    arguments: _fetchProducts);
              },
              child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Icon(Icons.add)),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            children: [
              CustomTextField(
                placeholder: "Search",
                controller: searchController,
                validator: (value) {
                  return null;
                },
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 21,
                ),
              ),
              _isLoading
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,  // Prevent overflow and only take required space
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling on the list
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                    leading: product.images.isNotEmpty
                        ? Image.network(
                      product.images[0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const SizedBox(width: 50, height: 50),
                    title: Text(
                      product.name,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Price: \$${product.price}\nCategory: ${product.category}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Navigate to Product Details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminProductDetailsScreen(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
