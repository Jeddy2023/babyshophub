import 'package:babyshophub/presentation/admin/products/screens/ProductScreen.dart';
import 'package:babyshophub/presentation/admin/users/screens/UserScreen.dart';
import 'package:babyshophub/presentation/home/pages/HomeScreen.dart';
import 'package:flutter/material.dart';

class AdminmainScreen extends StatefulWidget {
  const AdminmainScreen({super.key});

  @override
  State<AdminmainScreen> createState() => _AdminmainScreenState();
}

class _AdminmainScreenState extends State<AdminmainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    UserScreen(),
    ProductScreen(),
    UserScreen(),
    UserScreen(),
    UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          enableFeedback: false,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          iconSize: 23,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_shopping_cart_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent),
              label: 'Support',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
