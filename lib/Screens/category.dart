// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:newzify/Models/news.dart';
import 'package:newzify/Screens/articlescreen.dart';
import 'package:newzify/Services/api_service.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  String selectedCategory = "All";

  final List<String> categories = ["All", "Sports", "Technology", "Bollywood"];

  final Map<String, List<News>> cachedArticles = {};

  late Future<List<News>> fetchedArticles;

  @override
  void initState() {
    super.initState();
    fetchedArticles = fetchArticles(selectedCategory);
  }

  Future<List<News>> fetchArticles(String category) async {
    if (cachedArticles.containsKey(category)) {
      return cachedArticles[category]!;
    }

    List<News> fetchedArticles = [];

    try {
      if (category == "Sports") {
        fetchedArticles = await ApiService().fetchSportsNews();
      } else if (category == "Technology") {
        fetchedArticles = await ApiService().fetchTechnologyNews();
      } else if (category == "Bollywood") {
        fetchedArticles = await ApiService().fetchBollywoodNews();
      } else if (category == "All") {
        List<News> sportsNews = await ApiService().fetchSportsNews();
        List<News> technologyNews = await ApiService().fetchTechnologyNews();
        List<News> bollywoodNews = await ApiService().fetchBollywoodNews();
        fetchedArticles.addAll(sportsNews);
        fetchedArticles.addAll(technologyNews);
        fetchedArticles.addAll(bollywoodNews);
      }

      cachedArticles[category] = fetchedArticles;
    } catch (e) {
      print("Error fetching news: $e");
    }

    return fetchedArticles;
  }

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      fetchedArticles = fetchArticles(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: PreferredSize(
         preferredSize: Size.fromHeight(70),
        child: AppBar(
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Discover\n",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "Browse More!",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.grey[900],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return GestureDetector(
                    onTap: () => onCategorySelected(category),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 15,
                      ),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: selectedCategory == category
                              ? Colors.grey[900]
                              : Colors.grey[500],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric( horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<News>>(
              future: fetchedArticles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No articles available"));
                }

                final articles = snapshot.data!;

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleScreen(
                              article: article,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          children: [
                            article.urlToImage.isNotEmpty
                                ? Image.network(
                                    article.urlToImage,
                                    width: double.infinity,
                                    height: isSmallScreen ? 150 : 200,
                                    fit: BoxFit.cover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "No Image Available",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                article.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}  