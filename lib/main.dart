import 'package:babyshophub/firebase_options.dart';
import 'package:babyshophub/presentation/account/widgets/delivery_address.dart';
import 'package:babyshophub/presentation/account/widgets/edit_profile.dart';
import 'package:babyshophub/presentation/admin/adminmain_screen.dart';
import 'package:babyshophub/presentation/admin/products/screens/AdminProductDetailsScreen.dart';
import 'package:babyshophub/presentation/admin/products/screens/CreateProductScreen.dart';
import 'package:babyshophub/presentation/authentication/screens/login_screen.dart';
import 'package:babyshophub/presentation/authentication/screens/sign_up_screen.dart';
import 'package:babyshophub/presentation/main_screen.dart';
import 'package:babyshophub/presentation/splash-screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:babyshophub/core/constants/theme_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: GetMaterialApp(
        initialRoute: '/main',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        getPages: [
          GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/signup',
            page: () => const SignUpScreen(),
            transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/login',
            page: () => const LoginScreen(),
            transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/main',
            page: () => const MainScreen(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/admin-main',
            page: () => const AdminmainScreen(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/add-product',
            page: () => const CreateProductScreen(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/edit-profile',
            page: () => const EditProfile(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
          GetPage(
            name: '/delivery-address',
            page: () => const DeliveryAddress(),
            transition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    ),
  );
}
