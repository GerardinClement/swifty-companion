class Project {
  final String id;
  final String name;
  final String status;
  final String finalMark;
  final bool isValidated;
  final List<double> cursusIds;

  Project({
    required this.id,
    required this.name,
    required this.status,
    required this.finalMark,
    required this.isValidated,
    required this.cursusIds,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    String status = json['status']?.toString() ?? "Unknown";
    status = status.replaceAll("_", " ");
    return Project(
      id: json['id']?.toString() ?? "Unknown",
      name: json['project']['name']?.toString() ?? "Unknown",
      status: status,
      finalMark: json['final_mark']?.toString() ?? "Unknown",
      isValidated: json['validated?'] ?? false,
      cursusIds: json['cursus_ids'] != null
          ? List<double>.from(json['cursus_ids'].map((id) => id.toDouble()))
          : [],
    );
  }
}