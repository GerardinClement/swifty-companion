import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:swifty_companion/models/user.dart';
import 'package:swifty_companion/models/project.dart';
import 'package:swifty_companion/models/cursus.dart';
import 'dart:convert';

class ApiService {
  final String baseUrl = "https://api.intra.42.fr/v2";
  late oauth2.Client _client;

  ApiService({required oauth2.Client client}) {
    _client = client;
  }

  Future<User> fetchUserInfo() async {
    final response = await _client.get(Uri.parse("$baseUrl/me"));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return User.fromJson(responseData);
    } else {
      throw Exception("Error fetching user info");
    }
  }

  Future<List<Project>> fetchProjects(User user) async {
    final response = await _client.get(Uri.parse("$baseUrl/users/${user.id}/projects_users?page[size]=100"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((project) => Project.fromJson(project)).toList();
    } else {
      throw Exception("Error fetching projects");
    }
  }

  Future<List<Cursus>> fetchUserCursus(User user) async {
    final response = await _client.get(Uri.parse("$baseUrl/users/${user.id}/cursus_users"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((cursus) => Cursus.fromJson(cursus)).toList();
    } else {
      throw Exception("Error fetching cursus");
    }
  }

  Future<List<User>> fetchUsers(String query) async {
    final response = await _client.get(Uri.parse("$baseUrl/users?filter[login]=$query"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception("Error fetching users");
    }
  }
}