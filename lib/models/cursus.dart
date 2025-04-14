import 'package:swifty_companion/models/skill.dart';

class Cursus {
  final int id;
  final String name;
  final double level;
  final List<Skill> skills;

  Cursus({
    required this.id,
    required this.name,
    required this.level,
    required this.skills,
  });

  factory Cursus.fromJson(Map<String, dynamic> json) {
    return Cursus(
      id: json['id'],
      name: json['cursus']['name'],
      level: json['level'],
      skills:
          json['skills'] != null
              ? List<Skill>.from(
                json['skills'].map((skill) => Skill.fromJson(skill)),
              )
              : [],
    );
  }
}
