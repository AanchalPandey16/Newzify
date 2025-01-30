import 'package:flutter/material.dart';
import 'package:newzify/Models/news.dart';
import 'package:newzify/Services/api_service.dart';
import 'articlescreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<News> _breakingHeadlines = [];
  List<News> _recommendedNews = [];
  bool _isLoading = true;
  bool _hasError = false;
  final ApiService apiService = ApiService();
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final breakingNews = apiService.fetchTechCrunchNews();
      final recommendedNews = apiService.fetchBusinessNews();

      final newsData = await Future.wait([breakingNews, recommendedNews]);

      setState(() {
        _breakingHeadlines = newsData[0]
          ..sort((a, b) =>
              (b.urlToImage.isNotEmpty ? 1 : 0) - (a.urlToImage.isNotEmpty ? 1 : 0));
        _recommendedNews = newsData[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenWidth * 0.05;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(child: Text('Failed to load news. Please try again later.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Breaking Headlines', fontSize),
                      _buildBreakingNewsSection(screenWidth, screenHeight),
                      _buildSectionTitle('Recommended News', fontSize),
                      _buildRecommendedNewsList(screenWidth),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70),
      child: ClipRect(
        child: AppBar(
          backgroundColor: Colors.grey[900],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest News',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'Stay updated with the world',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
          elevation: 4,
          centerTitle: false,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildBreakingNewsSection(double screenWidth, double screenHeight) {
    return _breakingHeadlines.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              SizedBox(
                height: screenHeight * 0.3,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _breakingHeadlines.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final article = _breakingHeadlines[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArticleScreen(article: article)),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.7,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            article.urlToImage.isNotEmpty
                                ? FutureBuilder(
                                    future: precacheImage(NetworkImage(article.urlToImage), context),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          height: screenHeight * 0.2,
                                          color: Colors.grey[200],
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                        child: Image.network(
                                          article.urlToImage,
                                          width: double.infinity,
                                          height: screenHeight * 0.2,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    height: screenHeight * 0.2,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No Image Available',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                article.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildFlatDotIndicator(),
            ],
          );
  }

  Widget _buildFlatDotIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _breakingHeadlines.length,
          (index) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 5),
            height: 5,
            width: _currentIndex == index ? 20 : 10,
            decoration: BoxDecoration(
              color: _currentIndex == index ? Colors.black : Colors.grey,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedNewsList(double screenWidth) {
    return _recommendedNews.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _recommendedNews.length,
            itemBuilder: (context, index) {
              final article = _recommendedNews[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ArticleScreen(article: article)),
                  );
                },
                child: Container(
                  width: screenWidth * 0.9,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      article.urlToImage.isNotEmpty
                          ? FutureBuilder(
                              future: precacheImage(NetworkImage(article.urlToImage), context),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    article.urlToImage,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                            ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          article.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
