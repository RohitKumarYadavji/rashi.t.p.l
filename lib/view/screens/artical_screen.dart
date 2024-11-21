import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:rashi_techologies/controller/artical_provider_controller.dart';
import 'package:rashi_techologies/model/artical_model.dart';
import 'artical_details_page.dart';

class ArticleListScreen extends StatefulWidget {
  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ArticleProvider>(context, listen: false).fetchArticles();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_outlined,color: Colors.white,),
        title: Text("News Articles",style: TextStyle(color: Colors.white),),backgroundColor: Colors.blueGrey,),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueGrey,),);
          }
          if (articleProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    articleProvider.errorMessage,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      articleProvider.getDataFromSharedPreferences();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (articleProvider.articles.isEmpty) {
            return Center(
              child: Container(
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueGrey
                  ), child: Center(child: Text("You are first time open \n app  without  network \n so open the network \n then open the app",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))),
            );
          }
          return ListView.builder(
            itemCount: articleProvider.articles.length,
            itemBuilder: (context, index) {
              Article article = articleProvider.articles[index];
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article),));
                  },
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          article.cachedImagePath != null
                              ? Image.file(File(article.cachedImagePath!))
                              : CachedNetworkImage(
                            imageUrl: article.imageUrl,
                            placeholder: (context, url) => CircularProgressIndicator(color: Colors.blueGrey,),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Title:- ${article.title}",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Description:- ${article.description}",
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
