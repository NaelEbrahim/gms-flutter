import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';

import '../../../BLoC/Manager.dart';
import '../../../Models/ArticlesModel.dart';
import '../../../Shared/Constant.dart';
import 'ArticleDetail.dart';

const Color gmsPrimaryDark = Color(0xFF003366); // Deep Navy
const Color gmsTeal700 = Colors.teal; // Main Accent
const Color gmsBackgroundLight = Color(0xFFF7F7F7); // Soft background

class KnowledgeHubHome extends StatelessWidget {
  String selectedCategory = 'All';
  String currentSort = 'Newest';

  @override
  Widget build(BuildContext context) {
    Manager _manager = Manager.get(context);
    _manager.getArticles(data: {'wiki': selectedCategory});
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          ReusableComponents.showToast(
            state.error.toString(),
            background: Colors.red,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            title: reusableText(
              content: 'Knowledge Hub',
              fontSize: 22.0,
              fontColor: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Colors.black,
            centerTitle: true,
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  // Implement Search functionality
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                // --- Category Selector ---
                _buildCategorySelector(_manager),
                const SizedBox(height: 20),
                // --- Filter Results
                Row(
                  children: [
                    Text(
                      'Latest Articles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal,
                      ),
                    ),
                    Spacer(),
                    DropdownButton<String>(
                      value: currentSort,
                      icon: FaIcon(
                        FontAwesomeIcons.sort,
                        size: 14,
                        color: Colors.teal,
                      ),
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          currentSort = newValue;
                          _manager.updateState();
                        }
                      },
                      items: <String>['Newest', 'Oldest', 'Longest']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                'Sort by: $value',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
                ConditionalBuilder(
                  condition: state is! LoadingState,
                  builder: (context) {
                    if (state is SuccessState || state is UpdateNewState) {
                      if (_manager.articles!.articles.isNotEmpty) {
                        var resultList = _filterArticles(
                          _manager.articles!.articles,
                        );
                        return Expanded(
                          child: ListView.separated(
                            itemBuilder: (context, index) =>
                                _buildCompactArticleCard(
                                  context,
                                  resultList.elementAt(index),
                                ),
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 20.0),
                            itemCount: resultList.length,
                          ),
                        );
                      } else {
                        return Expanded(
                          child: const Center(
                            child: Text(
                              "no Articles found.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    } else {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              reusableText(
                                content: 'Connection error!',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  _manager.getArticles(
                                    data: {'wiki': selectedCategory},
                                  );
                                },
                                child: Container(
                                  height: 50,
                                  width: Constant.screenWidth / 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.teal.shade700,
                                        Constant.scaffoldColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade700,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Retry",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  fallback: (context) => Expanded(
                    child: Center(child: const CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(Manager _manager) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ArticlesModel.articleCategories.length,
        itemBuilder: (context, index) {
          final category = ArticlesModel.articleCategories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                selectedCategory = category;
                _manager.getArticles(data: {'wiki': selectedCategory});
              },
              child: Chip(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : gmsPrimaryDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                backgroundColor: isSelected
                    ? Colors.teal.shade700
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactArticleCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleDetail(article: article),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade600, Colors.teal.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.4),
              blurRadius: 5,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'images/1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      'images/1.png',
                      width: 80,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  // --- Text content ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WikiType Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.wikiType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${article.minReadTime} min read',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // --- Arrow icon ---
                  const SizedBox(width: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Article> _filterArticles(List<Article> list) {
    List<Article> articles = list.where((article) {
      return selectedCategory == 'All' || article.wikiType == selectedCategory;
    }).toList();
    if (currentSort == 'Newest') {
      articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (currentSort == 'Oldest') {
      articles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (currentSort == 'Longest') {
      articles.sort(
        (a, b) => b.minReadTime! - a.minReadTime!,
      );
    }
    return articles;
  }
}
