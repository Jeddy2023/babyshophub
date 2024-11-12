import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/home/widgets/HomeCategoryCircle.dart';
import 'package:babyshophub/presentation/home/widgets/ProductCard.dart';
import 'package:flutter/material.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ProductModel> products = [];
  Map<String, dynamic> userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchUserDetails();
  }

  Future<void> fetchProducts() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    setState(() => _isLoading = true);

    try {
      List<ProductModel> fetchedProducts = await firebaseService.getAllProducts();
      setState(() {
        products = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> fetchUserDetails() async {
    final firebaseService = ref.read(firebaseServiceProvider);

    try {
      Map<String, dynamic>? user = await firebaseService.getCurrentUser();

      setState(() {
        userData = user!;
      });
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            backgroundImage: NetworkImage(
              userData['profilePicture'] ?? 'https://res.cloudinary.com/dyktnfgye/image/upload/v1722173585/8_hyx9vy.png',
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back 👋',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              userData['displayName'] ?? '',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 13, 0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 30),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  HomeCategoryCircle(label: 'Clothes', icon: Icons.checkroom),
                  HomeCategoryCircle(label: 'Diapers', icon: Icons.vertical_align_bottom),
                  HomeCategoryCircle(label: 'Feeding', icon: Icons.fastfood),
                  HomeCategoryCircle(label: 'Health', icon: Icons.health_and_safety_outlined),
                  HomeCategoryCircle(label: 'Toys', icon: Icons.toys),
                  HomeCategoryCircle(label: 'Bath', icon: Icons.bathroom_outlined),
                  HomeCategoryCircle(label: 'Skincare', icon: Icons.ac_unit_sharp),
                  HomeCategoryCircle(label: 'Learning', icon: Icons.library_books),
                ],
              ),
            ),
            // Product Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                  ? const Center(child: Text('No products available.'))
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.63,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
