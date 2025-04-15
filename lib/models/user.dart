import 'package:swifty_companion/models/project.dart';
import 'package:swifty_companion/models/cursus.dart';

class User {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePictureUrl;
  final String location;
  final double wallet;
  final double correction_points;
  final String kind;
  List<Project> projects;
  List<Cursus> cursusUsers;


  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePictureUrl,
    required this.projects,
    required this.cursusUsers,
    required this.location,
    required this.wallet,
    required this.correction_points,
    required this.kind,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? "Unknown",
      username: json['login']?.toString() ?? "Unknown",
      firstName: json['first_name']?.toString() ?? "Unknown",
      lastName: json['last_name']?.toString() ?? "Unknown",
      email: json['email']?.toString() ?? "Unknown",
      profilePictureUrl: json['image']['link']?.toString() ?? "",
      projects: json['projects_users'] != null
          ? List<Project>.from(
              json['projects_users'].map((project) => Project.fromJson(project)),
            )
          : [],
      cursusUsers: json['cursus_users'] != null
          ? List<Cursus>.from(
              json['cursus_users'].map((cursus) => Cursus.fromJson(cursus)),
            )
          : [],
      location: json['location']?.toString() ?? "Unavailable",
      wallet: json['wallet'] != null ? json['wallet'].toDouble() : 0.0,
      correction_points: json['correction_point'] != null
          ? json['correction_point'].toDouble()
          : 0.0,
      kind: json['kind']?.toString() ?? "Unknown",
    );
  }
}