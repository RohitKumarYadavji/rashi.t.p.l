import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rashi_techologies/model/artical_model.dart';
class ArticleDetailScreen extends StatelessWidget {
  final Article article;
 const ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () {  Navigator.pop(context);},
      icon: Icon(Icons.arrow_back,color: Colors.white,)),title: Text(article.title,style: TextStyle(color: Colors.white),),backgroundColor: Colors.blueGrey,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  placeholder: (context, url) =>const  CircularProgressIndicator(color: Colors.blueGrey,),
                  errorWidget: (context, url, error) => const Icon(Icons.error,color: Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                 "Title:- ${article.title}",
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 4,
                ),
                const  SizedBox(height: 8),
                Text(
                  "Description:-${article.description}",
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
