import 'package:babyshophub/data/firebase_providers/firebase_provider.dart';
import 'package:babyshophub/presentation/shared_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  // Method to fetch all users
  Future<void> _fetchUsers() async {
    final firebaseService = ref.read(firebaseServiceProvider);
    setState(() => _isLoading = true);

    try {
      List<Map<String, dynamic>> fetchedUsers = await firebaseService.getAllUsers();

      setState(() {
        users = fetchedUsers;
        filteredUsers = fetchedUsers; // Initially show all users
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching all users: $e');
      setState(() => _isLoading = false);
    }
  }

  // Method to filter users based on search query
  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final userName = user['name']?.toLowerCase() ?? '';
        final userEmail = user['email']?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return userName.contains(searchQuery) || userEmail.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    searchController.addListener(() {
      _filterUsers(searchController.text);
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
          'Users',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
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
            const SizedBox(height: 10), // Add some spacing
            _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : Expanded(
              child: filteredUsers.isEmpty
                  ? const Center(
                child: Text("No users found."),
              )
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        user['name']?[0]?.toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user['name'] ?? 'No Name'),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Navigate to a user detail screen if needed
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
