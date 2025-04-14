class Skill {
  final String id;
  final String name;
  final double level;

  Skill({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id']?.toString() ?? "Unknown",
      name: json['name']?.toString() ?? "Unknown",
      level: json['level'] ?? 0.0,
    );
  }
}