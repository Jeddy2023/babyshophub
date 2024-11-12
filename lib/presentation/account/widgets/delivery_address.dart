import 'package:babyshophub/core/utils/toaster_utils.dart';
import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryAddress extends ConsumerStatefulWidget {
  const DeliveryAddress({super.key});

  @override
  ConsumerState<DeliveryAddress> createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends ConsumerState<DeliveryAddress> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipCodeController;
  late TextEditingController countryController;

  bool _isLoading = false;
  Map<String, dynamic>? _deliveryAddressData;

  @override
  void initState() {
    super.initState();

    addressLine1Controller = TextEditingController();
    addressLine2Controller = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    zipCodeController = TextEditingController();
    countryController = TextEditingController();

    // Fetch the user's existing delivery address when the screen initializes
    final authService = ref.read(firebaseServiceProvider);
    authService.getCurrentUser().then((userData) {
      if (userData != null && userData['deliveryAddress'] != null) {
        setState(() {
          _deliveryAddressData = userData['deliveryAddress'];
          addressLine1Controller.text =
              _deliveryAddressData!['addressLine1'] ?? '';
          addressLine2Controller.text =
              _deliveryAddressData!['addressLine2'] ?? '';
          cityController.text = _deliveryAddressData!['city'] ?? '';
          stateController.text = _deliveryAddressData!['state'] ?? '';
          zipCodeController.text = _deliveryAddressData!['zipCode'] ?? '';
          countryController.text = _deliveryAddressData!['country'] ?? '';
        });
      }
    });
  }

  Future<void> _updateDeliveryAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(firebaseServiceProvider);
    final newAddress = {
      'addressLine1': addressLine1Controller.text.trim(),
      'addressLine2': addressLine2Controller.text.trim(),
      'city': cityController.text.trim(),
      'state': stateController.text.trim(),
      'zipCode': zipCodeController.text.trim(),
      'country': countryController.text.trim(),
    };

    final errorMessage =
        await authService.updateDeliveryAddress(newAddress: newAddress);

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      ToasterUtils.showCustomSnackBar(
          context, 'Delivery Address updated successfully',
          isError: false);
    } else {
      ToasterUtils.showCustomSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Address',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  placeholder: "Address Line 1",
                  label: "Address Line 1",
                  controller: addressLine1Controller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  placeholder: "Address Line 2",
                  label: "Address Line 2",
                  controller: addressLine2Controller,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  placeholder: "City",
                  label: "City",
                  controller: cityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  placeholder: "State",
                  label: "State",
                  controller: stateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  placeholder: "Zip Code",
                  label: "Zip Code",
                  controller: zipCodeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your zip code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  placeholder: "Country",
                  label: "Country",
                  controller: countryController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: _updateDeliveryAddress,
                  buttonText: "Save Address",
                  isLoading: _isLoading,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
