import 'dart:io';

import 'package:babyshophub/core/utils/image_utils.dart';
import 'package:babyshophub/core/utils/toaster_utils.dart';
import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/account/widgets/custom_avatar.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  late Future<Map<String, dynamic>?> _userDataFuture;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _userData;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();

    // Fetch the current user data when the screen initializes
    final authService = ref.read(firebaseServiceProvider);
    _userDataFuture = authService.getCurrentUser();

    _userDataFuture.then((userData) {
      if (userData != null) {
        setState(() {
          _userData = userData;
          firstNameController.text = userData['name'].split(' ').first ?? '';
          lastNameController.text = userData['name'].split(' ').sublist(1).join(' ') ?? '';
          emailController.text = userData['email'] ?? '';
        });
      }
    });
  }

  Future<void> _updateProfileImage() async {
    if (_selectedImage == null) {
      ToasterUtils.showCustomSnackBar(context, 'Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(firebaseServiceProvider);
    final errorMessage = await authService.updateProfilePicture(
      _selectedImage!
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // Show success message and/or navigate to another screen if needed
      ToasterUtils.showCustomSnackBar(context, 'Profile Image updated successfully', isError: false);
    } else {
      // Show an error message using ScaffoldMessenger
      ToasterUtils.showCustomSnackBar(context, errorMessage);
    }
  }

  /// Method to handle image selection
  Future<void> _handleImageSelection() async {
    await ImageUtils.showOptions(context, (File image) {
      setState(() {
        _selectedImage = image;
      });

      _updateProfileImage();
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = ref.read(firebaseServiceProvider);
    final errorMessage = await authService.updateUserInfo(
      name: '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      email: emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // Show success message and/or navigate to another screen if needed
      ToasterUtils.showCustomSnackBar(context, 'Profile updated successfully', isError: false);
    } else {
      // Show an error message using ScaffoldMessenger
      ToasterUtils.showCustomSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchUserDataCallback = ModalRoute.of(context)!.settings.arguments as Function;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            fetchUserDataCallback(); // Call the fetchUserDataCallback
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomAvatar(
                    profileImageUrl: _userData?['photoURL'] ??
                        'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png',
                    imagePickerHandler: _handleImageSelection,
                    selectedImageUrl: _selectedImage?.path,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    placeholder: "First name",
                    label: "First name",
                    controller: firstNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    placeholder: "Last name",
                    label: "Last name",
                    controller: lastNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: 21,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    placeholder: "Email",
                    label: "Email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(
                      Icons.alternate_email,
                      color: Colors.grey,
                      size: 21,
                    ),
                    disabled: true,
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    onPressed: _updateProfile,
                    buttonText: "Save Changes",
                    isLoading: _isLoading,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
