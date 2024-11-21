import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rashi_techologies/model/artical_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ArticleProvider with ChangeNotifier {
  List<Article> _articles = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = "";

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> fetchArticles() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = "";
    notifyListeners();
    try {
      if (!await _isInternetAvailable()) {
        await getDataFromSharedPreferences();
      } else {
        await _fetchArticlesFromFirebase();
      }
    } catch (e) {
      print("Error fetching articles: $e");
      _hasError = true;
      _errorMessage = "Failed to load articles. Please check your internet connection.";
      notifyListeners();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchArticlesFromFirebase() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('articles').get();
      _articles = snapshot.docs.map((doc) => Article.fromFirestore(doc)).toList();
      await storeDataToSharedPreferences(_articles);
      notifyListeners();
    } catch (e) {
      print("Error fetching articles from Firebase: $e");
      _hasError = true;
      _errorMessage = "Failed to load articles from Firebase.";
      notifyListeners();
    }
  }

  Future<void> storeDataToSharedPreferences(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> serializedArticles = articles.map((article) {
      return jsonEncode(article.toJson());
    }).toList();
    await prefs.setStringList('saveArticles', serializedArticles);

    for (Article article in articles) {
      await _cacheImage(article.imageUrl);
    }
  }

  Future<void> _cacheImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${Uri.parse(imageUrl).pathSegments.last}';
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<void> getDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedData = prefs.getStringList('saveArticles');
    if (savedData != null) {
      _articles = savedData.map((itemString) {
        Map<String, dynamic> articleMap = _parseMapString(itemString);
        return Article.fromjson(articleMap);
      }).toList();
      for (Article article in _articles) {
        article.cachedImagePath = await _getCachedImagePath(article.imageUrl);
      }
      notifyListeners();
    }
  }

  Map<String, dynamic> _parseMapString(String mapString) {
    return Map<String, dynamic>.from(jsonDecode(mapString));
  }

  Future<String?> _getCachedImagePath(String imageUrl) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${Uri.parse(imageUrl).pathSegments.last}';
    final file = File(filePath);
    return file.existsSync() ? filePath : null;
  }
  Future<bool> _isInternetAvailable() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com'));
      return result.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
