import 'package:flutter/material.dart';
import 'package:swifty_companion/models/user.dart';
import 'package:swifty_companion/services/42_api_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/pages/profile_page.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  final oauth2.Client client;

  const SearchPage({super.key, required this.client});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  late List<User> _searchResults = [];
  late ApiService _apiService;
  int queryId = 0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(client: widget.client);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      queryId++;
      _searchUsers(queryId);
    });
  }

  Future<void> _searchUsers(int searchQueryId) async {
    try {
      final result = await _apiService.fetchUsers(_searchController.text);
      setState(() {
        if (queryId == searchQueryId) _searchResults = result;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching users: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _onSearchChanged();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _searchResults.isEmpty
                      ? const Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return InkWell(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.profilePictureUrl,
                                ),
                              ),
                              title: Text(user.username),
                              subtitle: Text(user.email),
                            ),
                            onTap: () {
                              // Handle user tap
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProfilePage(
                                        client: widget.client,
                                        user: user,
                                      ),
                                ),
                              );
                            },
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
