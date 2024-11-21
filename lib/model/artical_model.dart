import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp timestamp;
  String? cachedImagePath;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    this.cachedImagePath
  });

  factory Article.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Article(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  factory Article.fromjson(Map<dynamic, dynamic> data) {
    Timestamp timestamp;
    if (data['timestamp'] is Timestamp) {
      timestamp = data['timestamp'];
    } else if (data['timestamp'] is String) {
      try {
        timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(data['timestamp']) * 1000);
      } catch (e) {
        timestamp = Timestamp.now();
      }
    } else {
      timestamp = Timestamp.now();
    }
    return Article(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      timestamp: timestamp,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl.toString(),
      'timestamp': timestamp.seconds,
    };
  }
}
