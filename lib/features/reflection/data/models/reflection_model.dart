class ReflectionModel {
  final String id;
  final String userId;
  final String userName;
  final int year;
  final String reflectionText;
  final String photoUrl;
  final DateTime createdAt;

  ReflectionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.year,
    required this.reflectionText,
    required this.photoUrl,
    required this.createdAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'year': year,
      'reflectionText': reflectionText,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore JSON
  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      year: json['year'] as int,
      reflectionText: json['reflectionText'] as String,
      photoUrl: json['photoUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}