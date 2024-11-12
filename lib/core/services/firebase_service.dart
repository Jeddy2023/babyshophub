import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:babyshophub/data/models/CartItemModel.dart';
import 'package:babyshophub/data/models/CartModel.dart';
import 'package:babyshophub/data/models/OrderItemModel.dart';
import 'package:babyshophub/data/models/OrderModel.dart';
import 'package:babyshophub/data/models/ProductModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  // Private constructor for Singleton pattern
  FirebaseService._privateConstructor();

  // Static instance of FirebaseService
  static final FirebaseService _instance =
      FirebaseService._privateConstructor();

  // Factory constructor to return the same instance
  factory FirebaseService() {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Helper function to hash passwords using SHA256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Hash the password
        String passwordHash = _hashPassword(password);

        // Save user data in Firestore 'Users' collection
        await _firestore.collection('Users').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'email': email,
          'password': passwordHash,
          'admin': false,
          'signInMethod': 'email-pass',
          'profilePicture':
              'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png',
          'deliveryAddress': {
            'addressLine1': '',
            'addressLine2': '',
            'city': '',
            'state': '',
            'zipCode': '',
            'country': ''
          },
          'paymentMethods': [
            {
              'cardNumber': '', // Store encrypted card number here
              'cardHolderName': '',
              'expirationDate': '', // Format as MM/YY
              'cvv': '' // Store encrypted CVV here
            }
          ],
        });

        // Update display name
        await user.updateDisplayName(name);
        await user.updatePhotoURL(
            'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png');
        await user.reload();

        // Send email verification
        await user.sendEmailVerification();
        return null; // No error, sign-up was successful
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'network-request-failed':
          return 'Network error occurred. Please check your connection.';
        default:
          return 'An unknown error occurred. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
    return 'Sign up failed. Please try again.';
  }

  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          // Check if the user is an admin
          bool isAdmin = userDoc.get('admin') ?? false;
          return {
            'isAdmin': isAdmin,
            'message': null, // Sign-in was successful
          };
        } else {
          return {
            'isAdmin': false,
            'message': 'User data not found.',
          };
        }
      } else {
        return {
          'isAdmin': false,
          'message': 'Login failed. Please try again.',
        };
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          return {'isAdmin': false, 'message': 'Invalid email or password.'};
        case 'user-disabled':
          return {'isAdmin': false, 'message': 'This user has been disabled.'};
        case 'user-not-found':
          return {
            'isAdmin': false,
            'message': 'No user found with this email.'
          };
        case 'wrong-password':
          return {
            'isAdmin': false,
            'message': 'The password is incorrect. Please try again.'
          };
        default:
          return {
            'isAdmin': false,
            'message': 'An error occurred. Please try again.'
          };
      }
    } catch (e) {
      return {
        'isAdmin': false,
        'message': 'An unexpected error occurred. Please try again.'
      };
    }
  }

  // Google Sign-In method
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Google sign-in aborted.';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('Users').doc(user.uid).set({
            'userId': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'password': '',
            'admin': false,
            'signInMethod': 'email-pass',
            'profilePicture': user.photoURL ??
                'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png',
            'deliveryAddress': {
              'addressLine1': '',
              'addressLine2': '',
              'city': '',
              'state': '',
              'zipCode': '',
              'country': ''
            },
            'paymentMethods': [
              {
                'cardNumber': '', // Store encrypted card number here
                'cardHolderName': '',
                'expirationDate': '', // Format as MM/YY
                'cvv': '' // Store encrypted CVV here
              }
            ],
          });
        }
      }

      return user != null ? null : 'Google sign-in failed. Please try again.';
    } catch (e) {
      print('Error during Google sign-in: $e');
      return 'An error occurred during Google sign-in. Please try again.';
    }
  }

  // Method to update user email, first name, and last name
  Future<String?> updateUserInfo({
    required String name,
    required String email,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Update email in Firebase Authentication
        await user.verifyBeforeUpdateEmail(email);

        // Update display name (full name)
        String displayName = name;
        await user.updateDisplayName(displayName);

        // Update the user info in Firestore
        await _firestore.collection('Users').doc(user.uid).update({
          'name': name,
          'email': email,
        });

        await user.reload();

        return null; // Update successful
      } else {
        return 'No user is currently logged in.';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already in use by another account.';
        case 'requires-recent-login':
          return 'Please reauthenticate and try again.';
        case 'invalid-email':
          return 'The provided email is invalid.';
        default:
          return 'An error occurred. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> updateDeliveryAddress({
    required Map<String, String> newAddress,
  }) async {
    User? user = _auth.currentUser;

    if (user == null) {
      return 'User not logged in.';
    }

    try {
      await _firestore.collection('Users').doc(user.uid).update({
        'deliveryAddress': newAddress,
      });
      return null;
    } catch (e) {
      return 'Failed to update delivery address: $e';
    }
  }

  Future<String?> updateProfilePicture(File imageFile) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return 'No user is currently logged in.';
      }

      // Default profile image URL
      String defaultPhotoUrl =
          'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png';

      // Retrieve the current profile picture URL
      String? oldPhotoUrl = user.photoURL;

      // Delete the old profile picture from Cloudinary if it's not the default image
      if (oldPhotoUrl != null &&
          oldPhotoUrl.isNotEmpty &&
          oldPhotoUrl != defaultPhotoUrl) {
        try {
          // Parse the Cloudinary public ID from the old URL
          final publicId = oldPhotoUrl.split('/').last.split('.').first;

          // Send delete request to Cloudinary
          await http.delete(Uri.parse(
              'https://api.cloudinary.com/v1_1/do6nmsymn/image/destroy?public_id=$publicId'));

          print('Old profile picture deleted successfully.');
        } catch (e) {
          print('Error deleting old profile picture: $e');
          // You can choose whether to continue or return an error here
        }
      }

      // Upload the new image to Cloudinary
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/do6nmsymn/image/upload'),
      );
      request.fields['upload_preset'] = 'jjhhkpbb';
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = json.decode(responseData);
        String downloadUrl = jsonData['secure_url'];

        // Update the profile picture URL in Firebase Authentication
        await user.updatePhotoURL(downloadUrl);

        // Update the profile picture URL in Firestore
        await _firestore.collection('Users').doc(user.uid).update({
          'profilePicture': downloadUrl,
        });

        // Reload the user to apply changes
        await user.reload();
        print('Profile picture updated successfully.');
        return null;
      } else {
        return 'Failed to upload image to Cloudinary';
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      return 'An error occurred while updating the profile picture. Please try again.';
    }
  }

  // Method to get the current logged-in user and their Firestore data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // Get the current user from Firebase Authentication
      User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user data from Firestore based on the user ID
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();

        if (userDoc.exists) {
          // Combine both FirebaseAuth user data and Firestore user data
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Add FirebaseAuth-specific data (if needed)
          userData['emailVerified'] = user.emailVerified;
          userData['displayName'] = user.displayName;
          userData['photoURL'] = user.photoURL;
          userData['creationTime'] =
              user.metadata.creationTime?.toIso8601String();
          userData['lastSignInTime'] =
              user.metadata.lastSignInTime?.toIso8601String();

          return userData;
        } else {
          return null; // No user data found in Firestore
        }
      } else {
        return null; // No user is currently logged in
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null; // Handle error appropriately in your app
    }
  }

  // Method to fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Users').get();
      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        userData['userId'] = doc.id; // Add document ID if needed
        return userData;
      }).toList();
      return users;
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  // Sign Out method
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Password Reset method
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> createProduct({
    required String name,
    required String description,
    required double price,
    required List<File> images,
    required String category,
    required int stockQuantity,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return 'User not logged in.';
      }

      // Check if the user is an admin
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();
      bool isAdmin = userDoc.get('admin') ?? false;

      if (!isAdmin) {
        return 'Only admins can create products.';
      }

      // Upload each image and store its URL
      // List<String> imageUrls = [];
      // for (File image in images) {
      //   String fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.uid}';
      //   Reference storageRef = _firebaseStorage.ref().child('product_images/$fileName');
      //   UploadTask uploadTask = storageRef.putFile(image);
      //   TaskSnapshot snapshot = await uploadTask;
      //   String downloadUrl = await snapshot.ref.getDownloadURL();
      //   imageUrls.add(downloadUrl);
      // }
      List<String> imageUrls = [];
      for (File image in images) {
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(
                'https://api.cloudinary.com/v1_1/do6nmsymn/image/upload'));
        request.fields['upload_preset'] = 'jjhhkpbb';
        request.files
            .add(await http.MultipartFile.fromPath('file', image.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonData = json.decode(responseData);
          imageUrls.add(jsonData['secure_url']);
        } else {
          return 'Failed to upload image to Cloudinary';
        }
      }

      // Create a unique product ID
      String productId = _firestore.collection('Products').doc().id;

      // Create the product in Firestore
      await _firestore.collection('Products').doc(productId).set({
        'productId': productId,
        'name': name,
        'description': description,
        'price': price,
        'images': imageUrls,
        'category': category,
        'stockQuantity': stockQuantity,
        'totalSold': 0,
        'averageRating': 0.0,
        'totalReviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // Product created successfully
    } catch (e) {
      print('Error creating product: $e');
      return 'An error occurred while creating the product. Please try again.';
    }
  }

  // Method to retrieve a single product by productId
  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot productDoc =
          await _firestore.collection('Products').doc(productId).get();

      if (productDoc.exists) {
        return ProductModel.fromMap(productDoc.data() as Map<String, dynamic>);
      } else {
        return null; // Product not found
      }
    } catch (e) {
      return null;
    }
  }

  // Method to retrieve all products
  Future<List<ProductModel>> getAllProducts() async {
    try {
      QuerySnapshot productsSnapshot =
          await _firestore.collection('Products').get();
      return productsSnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching all products: $e');
      return [];
    }
  }

  Future<String?> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<File>? images,
    String? category,
    int? stockQuantity,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return 'User not logged in.';
      }

      // Check if the user is an admin
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();
      bool isAdmin = userDoc.get('admin') ?? false;

      if (!isAdmin) {
        return 'Only admins can update products.';
      }

      // Retrieve the current product document
      DocumentSnapshot productDoc =
          await _firestore.collection('Products').doc(productId).get();
      if (!productDoc.exists) {
        return 'Product not found.';
      }

      Map<String, dynamic> productData =
          productDoc.data() as Map<String, dynamic>;
      List<String> oldImageUrls =
          List<String>.from(productData['images'] ?? []);

      // If new images are provided, delete old images and upload new ones
      List<String>? imageUrls;
      if (images != null && images.isNotEmpty) {
        // Delete old images from Firebase Storage (if any)
        for (String oldImageUrl in oldImageUrls) {
          if (oldImageUrl.isNotEmpty) {
            try {
              Reference oldImageRef = _firebaseStorage.refFromURL(oldImageUrl);
              await oldImageRef.delete();
              print('Old image deleted successfully: $oldImageUrl');
            } catch (e) {
              print('Error deleting old image: $e');
            }
          }
        }

        // Upload new images and store their URLs using Cloudinary (similar to createProduct method)
        imageUrls = [];
        for (File image in images) {
          var request = http.MultipartRequest(
              'POST',
              Uri.parse(
                  'https://api.cloudinary.com/v1_1/do6nmsymn/image/upload'));
          request.fields['upload_preset'] = 'jjhhkpbb';
          request.files
              .add(await http.MultipartFile.fromPath('file', image.path));
          var response = await request.send();
          if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonData = json.decode(responseData);
            imageUrls.add(jsonData['secure_url']);
          } else {
            return 'Failed to upload image to Cloudinary';
          }
        }
      }

      // Prepare data for updating the product
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (imageUrls != null && imageUrls.isNotEmpty)
        updateData['images'] = imageUrls;
      if (category != null) updateData['category'] = category;
      if (stockQuantity != null) updateData['stockQuantity'] = stockQuantity;

      // Set the updatedAt field to the current server timestamp
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Update the product document in Firestore
      await _firestore.collection('Products').doc(productId).update(updateData);

      return null; // Update successful
    } catch (e) {
      print('Error updating product: $e');
      return 'An error occurred while updating the product. Please try again.';
    }
  }

  // Method to delete a product by productId
  Future<String?> deleteProduct(String productId) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return 'User not logged in.';
      }

      // Check if the user is an admin
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user.uid).get();
      bool isAdmin = userDoc.get('admin') ?? false;

      if (!isAdmin) {
        return 'Only admins can delete products.';
      }

      // Retrieve the product document to get image URLs
      DocumentSnapshot productDoc =
          await _firestore.collection('Products').doc(productId).get();

      if (!productDoc.exists) {
        return 'Product not found.';
      }

      // Get image URLs from the product document
      List<String> imageUrls = List<String>.from(productDoc.get('images'));

      // Delete each image from Firebase Storage
      for (String imageUrl in imageUrls) {
        try {
          Reference imageRef = _firebaseStorage.refFromURL(imageUrl);
          await imageRef.delete();
          print('Deleted image: $imageUrl');
        } catch (e) {
          print('Error deleting image $imageUrl: $e');
          // Continue deleting other images even if one fails
        }
      }

      // Delete the product document from Firestore
      await _firestore.collection('Products').doc(productId).delete();
      print('Product deleted successfully.');

      return null; // Deletion successful
    } catch (e) {
      print('Error deleting product: $e');
      return 'An error occurred while deleting the product. Please try again.';
    }
  }

  // Adds an item to the cart for the specified user
  Future<void> addToCart(CartItemModel cartItem) async {
    User? user = _auth.currentUser;

    final cartRef = _firestore.collection('carts').doc(user?.uid);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      // Update existing cart with new item or increment quantity
      CartModel cart = CartModel.fromMap(cartDoc.data()!);
      int existingIndex = cart.products
          .indexWhere((item) => item.productId == cartItem.productId);

      if (existingIndex != -1) {
        cart.products[existingIndex].quantity += cartItem.quantity;
      } else {
        cart.products.add(cartItem);
      }

      cart.updatedAt = DateTime.now();
      await cartRef.set(cart.toMap());
    } else {
      // Create new cart document for the user
      CartModel cart = CartModel(
        cartId: cartRef.id,
        userId: user!.uid,
        products: [cartItem],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await cartRef.set(cart.toMap());
    }
  }

  // Retrieves all items in the user's cart
  Future<CartModel> getCartItems() async {
    User? user = _auth.currentUser;

    final cartRef = _firestore.collection('carts').doc(user?.uid);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      return CartModel.fromMap(cartDoc.data()!);
    } else {
      // Return empty cart if no cart document exists
      return CartModel(
        cartId: cartRef.id,
        userId: user!.uid,
        products: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Updates the quantity of a specific item in the cart
  Future<void> updateCartItem(String productId, int quantity) async {
    User? user = _auth.currentUser;

    final cartRef = _firestore.collection('carts').doc(user?.uid);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      CartModel cart = CartModel.fromMap(cartDoc.data()!);
      int existingIndex =
          cart.products.indexWhere((item) => item.productId == productId);

      if (existingIndex != -1) {
        if (quantity > 0) {
          cart.products[existingIndex].quantity = quantity;
        } else {
          cart.products.removeAt(existingIndex);
        }

        cart.updatedAt = DateTime.now();
        await cartRef.set(cart.toMap());
      }
    }
  }

  // Removes a specific item from the cart
  Future<void> removeFromCart(String productId) async {
    User? user = _auth.currentUser;

    final cartRef = _firestore.collection('carts').doc(user?.uid);
    final cartDoc = await cartRef.get();

    if (cartDoc.exists) {
      CartModel cart = CartModel.fromMap(cartDoc.data()!);
      cart.products.removeWhere((item) => item.productId == productId);

      cart.updatedAt = DateTime.now();
      await cartRef.set(cart.toMap());
    }
  }

  // Simulate payment process (returns true if successful)
  Future<bool> simulatePayment(double amount) async {
    // Simulating a delay as if processing payment
    await Future.delayed(const Duration(seconds: 2));
    // Assume payment is always successful for simulation purposes
    return true;
  }

  // Method to generate order summary for the user
  Future<Map<String, dynamic>> generateOrderSummary() async {
    try {
      User? user = _auth.currentUser;
      // Fetch the user's cart
      final cartRef = _firestore.collection('carts').doc(user?.uid);
      final cartDoc = await cartRef.get();

      if (!cartDoc.exists) {
        throw Exception("Cart not found for user.");
      }

      CartModel cart = CartModel.fromMap(cartDoc.data()!);

      // Initialize the order details
      double totalAmount = 0.0;
      List<Map<String, dynamic>> orderItems = [];

      // Calculate the total amount for the items in the cart
      for (var item in cart.products) {
        ProductModel? product = await getProduct(item.productId);
        if (product != null) {
          double itemTotal = item.quantity * product.price;
          totalAmount += itemTotal;

          // Add the item details to the order summary
          orderItems.add({
            'productId': product.productId,
            'productName': product.name,
            'quantity': item.quantity,
            'price': product.price,
            'itemTotal': itemTotal
          });
        } else {
          throw Exception("Product not found: ${item.productId}");
        }
      }

      // Add shipping cost
      double shippingCost = 10.0; // Fixed shipping cost

      // Calculate the final total (items total + shipping cost)
      double finalTotal = totalAmount + shippingCost;

      // Return the order summary
      return {
        'orderItems': orderItems,
        'totalAmount': totalAmount,
        'shippingCost': shippingCost,
        'finalTotal': finalTotal,
      };
    } catch (e) {
      throw Exception("Error generating order summary: $e");
    }
  }

  // Place an order after successful payment
  Future<void> checkoutCart() async {
    User? user = _auth.currentUser;
    // Get the user's cart
    final cartRef = _firestore.collection('carts').doc(user?.uid);
    final cartDoc = await cartRef.get();

    if (!cartDoc.exists) {
      throw Exception("Cart not found for user.");
    }

    CartModel cart = CartModel.fromMap(cartDoc.data()!);

    // Calculate the total amount for the order
    double totalAmount = 0.0;

    for (var item in cart.products) {
      ProductModel? product = await getProduct(item.productId);
      if (product != null) {
        totalAmount += item.quantity * product.price;
      } else {
        throw Exception("Product not found: ${item.productId}");
      }
    }

    // Simulate payment process
    bool paymentSuccessful = await simulatePayment(totalAmount);
    if (!paymentSuccessful) {
      throw Exception("Payment failed.");
    }

    // Prepare the order items
    List<OrderItemModel> orderItems = cart.products
        .map((item) async {
          ProductModel? product = await getProduct(item.productId);
          if (product != null) {
            return OrderItemModel(
              productId: item.productId,
              quantity: item.quantity,
              price: product.price,
            );
          } else {
            throw Exception("Product not found: ${item.productId}");
          }
        })
        .cast<OrderItemModel>()
        .toList();

    // Create a new order
    OrderModel order = OrderModel(
      orderId: _firestore.collection('orders').doc().id,
      userId: user!.uid,
      products: orderItems,
      totalAmount: totalAmount,
      status: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the order to Firestore
    await _firestore.collection('orders').doc(order.orderId).set(order.toMap());

    // Clear the user's cart after successful checkout
    await cartRef.delete();
  }

  // get all order
  // change order status
  // get single order
}
