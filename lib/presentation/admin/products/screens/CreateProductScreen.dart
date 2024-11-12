import 'dart:io';

import 'package:babyshophub/core/utils/toaster_utils.dart';
import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:babyshophub/presentation/admin/products/screens/ProductScreen.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  final ProductModel? product;
  final Function? fetchProductsCallback;

  const CreateProductScreen({super.key, this.product, this.fetchProductsCallback});

  @override
  ConsumerState<CreateProductScreen> createState() =>
      _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController stockQuantityController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // If product exists, populate the form with existing product data
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      descriptionController.text = widget.product!.description;
      priceController.text = widget.product!.price.toString();
      categoryController.text = widget.product!.category;
      stockQuantityController.text = widget.product!.stockQuantity.toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    stockQuantityController.dispose();
    super.dispose();
  }

  final List<String> categories = [
    'Clothes',
    'Health',
    'Feeding',
    'Diapers',
    'Toys',
    'Bath',
    'Skincare',
    'Learning'
  ];

  Future<void> _selectImages() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      if (_selectedImages.length + pickedImages.length > 5) {
        // Show a message or limit the images to only allow up to 5
        ToasterUtils.showCustomSnackBar(
            context, 'You can only select up to 5 images.');
      } else {
        setState(() {
          _selectedImages
              .addAll(pickedImages.map((image) => File(image.path)).toList());
        });
      }
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final firebaseService = ref.read(firebaseServiceProvider);
    String? errorMessage;

    if (widget.product == null) {
      // Creating a new product
      errorMessage = await firebaseService.createProduct(
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        images: _selectedImages,
        category: categoryController.text.trim(),
        stockQuantity: int.tryParse(stockQuantityController.text.trim()) ?? 0,
      );
    } else {
      // Editing an existing product
      errorMessage = await firebaseService.updateProduct(
        productId: widget.product!.productId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        images: _selectedImages,
        category: categoryController.text.trim(),
        stockQuantity: int.tryParse(stockQuantityController.text.trim()) ?? 0,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      ToasterUtils.showCustomSnackBar(context, widget.product == null
          ? 'Product created successfully!'
          : 'Product updated successfully!', isError: false);
      // fetchProductsCallback();
      // Navigator.pop(context);
    } else {
      ToasterUtils.showCustomSnackBar(context, errorMessage);
    }
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(categories[index]),
              onTap: () {
                setState(() {
                  categoryController.text = categories[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fetchProductsCallback = widget.fetchProductsCallback ?? ModalRoute.of(context)!.settings.arguments as Function?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Create Product' : 'Edit Product',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            fetchProductsCallback!();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProductScreen(),
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  placeholder: "Product Name",
                  label: "Product Name",
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.near_me_outlined,
                    color: Colors.grey,
                    size: 21,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  placeholder: "Description",
                  label: "Description",
                  controller: descriptionController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  placeholder: "Price",
                  label: "Price",
                  controller: priceController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    } else if (double.tryParse(value) == null) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.attach_money_outlined,
                    color: Colors.grey,
                    size: 21,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showCategorySelection,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      placeholder: "Category",
                      label: "Category",
                      controller: categoryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        color: Colors.grey,
                        size: 21,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  placeholder: "Stock Quantity",
                  label: "Stock Quantity",
                  controller: stockQuantityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stock quantity';
                    } else if (int.tryParse(value) == null) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.add,
                    color: Colors.grey,
                    size: 21,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text('Product Images',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._selectedImages.map((image) => Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(image,
                            width: 100, height: 100, fit: BoxFit.cover),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.remove(image);
                            });
                          },
                          child: const Icon(Icons.remove_circle,
                              color: Colors.red),
                        ),
                      ],
                    )),
                    if (_selectedImages.length < 5)
                      GestureDetector(
                        onTap: _selectImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () {
                    _saveProduct(context);
                  },
                  buttonText: "Create Product",
                  isLoading: _isLoading,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonSize: ButtonSize.full,
                  borderRadius: 25.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}