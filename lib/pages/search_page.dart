import 'package:flutter/material.dart';
import 'package:swifty_companion/models/user.dart';
import 'package:swifty_companion/services/42_api_service.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/pages/profile_page.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  final oauth2.Client client;
  const SearchPage({
    super.key,
    required this.client,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final bool _isLoading = false;
  late List<User> _searchResults = [];
  late ApiService _apiService;
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

    // Annule le timer précédent s'il existe
    _debounceTimer?.cancel();

    // Crée un nouveau timer qui attendra 500ms avant d'exécuter la recherche
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchUsers();
    });
  }

  Future<void> _searchUsers() async {
    try {
      final result = await _apiService.fetchUsers(_searchController.text);
      setState(() {
        _searchResults = result;
      });
    } catch (e) {
      // Handle error
      print("Error searching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
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
                if (value.isNotEmpty) {
                  _searchUsers();
                } else {
                  setState(() {
                    _searchResults.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return InkWell(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePictureUrl),
                            ),
                            title: Text(user.username),
                            subtitle: Text(user.email),
                          ),
                          onTap: () {
                            // Handle user tap
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(client: widget.client, user: user),
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