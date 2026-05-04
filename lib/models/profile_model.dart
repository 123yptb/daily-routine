import 'dart:convert';

class UserProfile {
  final String id;
  String name;
  String avatarUrl;
  String? localImagePath; // Local JPG picked from gallery
  DateTime dateOfBirth;
  String designation;
  int level;
  int currentXP;
  int lifetimePoints;
  DateTime joinedAt;
  bool isSetup;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.localImagePath,
    required this.dateOfBirth,
    this.designation = '',
    this.level = 1,
    this.currentXP = 0,
    this.lifetimePoints = 0,
    required this.joinedAt,
    this.isSetup = false,
  });

  int get xpForNextLevel => level * 1000;
  double get xpProgress => currentXP / xpForNextLevel;
  
  int get currentAge {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'localImagePath': localImagePath,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'designation': designation,
        'level': level,
        'currentXP': currentXP,
        'lifetimePoints': lifetimePoints,
        'joinedAt': joinedAt.toIso8601String(),
        'isSetup': isSetup,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'],
        name: map['name'],
        avatarUrl: map['avatarUrl'] ?? '',
        localImagePath: map['localImagePath'] as String?,
        dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : DateTime.now(),
        designation: map['designation'] ?? '',
        level: map['level'] ?? 1,
        currentXP: map['currentXP'] ?? 0,
        lifetimePoints: map['lifetimePoints'] ?? 0,
        joinedAt: DateTime.parse(map['joinedAt']),
        isSetup: map['isSetup'] ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String j) =>
      UserProfile.fromMap(jsonDecode(j));
}
