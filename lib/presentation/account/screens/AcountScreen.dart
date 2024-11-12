import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/account/widgets/profile_info.dart';
import 'package:babyshophub/presentation/account/widgets/profile_listtile.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_button.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_confirmationdialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> with WidgetsBindingObserver {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchUserData();
    }
  }

  void _fetchUserData() {
    final authService = ref.read(firebaseServiceProvider);
    print('This is the data that was returned please ${authService.getCurrentUser()}');
    setState(() {
      _userDataFuture = authService.getCurrentUser();
    });
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Log Out',
        content: 'Are you sure you want to log out?',
        onConfirm: onConfirm,
        onCancel: () {
          Navigator.of(context).pop(); // Close the dialog if user cancels
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(firebaseServiceProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile', arguments: _fetchUserData,);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: _userDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                          child: Center(child: CircularProgressIndicator())
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                          child: Text('Error fetching profile data.'));
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final userData = snapshot.data!;

                      // Create the preferenceItems after userData is available
                      final List<Map<String, dynamic>> preferenceItems = [
                        {
                          'icon': Icons.person_outline,
                          'title': userData['name'] ?? '',
                          'subtitle': 'Personal Profile Info',
                          'onTap': () {
                            Navigator.pushNamed(context, '/edit-profile', arguments: _fetchUserData);
                          },
                        },
                        {
                          'icon': Icons.location_on_outlined,
                          'title': 'Delivery Address',
                          'subtitle': 'Delivery Address Info',
                          'onTap': () {
                            Navigator.pushNamed(context, '/delivery-address');
                          },
                        },
                      ];

                      return Column(
                        children: [
                          Center(
                            child: ProfileInfo(
                              email: userData['email'] ?? '',
                              fullName: userData['name'] ?? '',
                              profilePicture: userData['photoURL'] ??
                                  'https://res.cloudinary.com/dn7xnr4ll/image/upload/v1722866767/notionistsNeutral-1722866616198_iu61hw.png',
                            ),
                          ),
                          ...preferenceItems.map((item) => CustomListTile(
                            icon: item['icon'],
                            title: item['title'],
                            subtitle: item['subtitle'] ?? '',
                            onTap: item['onTap'],
                          )),
                          const SizedBox(height: 20),
                          CustomButton(
                            onPressed: () {
                              _showLogoutConfirmationDialog(context, () async {
                                await authService.signOut();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              });
                            },
                            buttonText: 'Logout',
                            backgroundColor: Colors.redAccent,
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                          child: Text('No profile data available.'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
