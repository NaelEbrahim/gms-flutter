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

class KnowledgeHubHome extends StatefulWidget {
  const KnowledgeHubHome({super.key});

  @override
  State<KnowledgeHubHome> createState() => _KnowledgeHubHomeState();
}

class _KnowledgeHubHomeState extends State<KnowledgeHubHome> {
  int page = 0;
  late Manager manager;
  String currentSort = 'Newest';
  String selectedCategory = 'All';

  bool hasMore = true;
  bool _isLoading = false;
  List<Article> displayedArticles = [];
  final ScrollController scrollController = ScrollController();

  static final List<String> articleCategories = [
    'All',
    'Health',
    'Sport',
    'Food',
    'Fitness',
    'Supplements',
  ];

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.articles.articles.clear();
    _loadMore();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !hasMore) return;
    setState(() => _isLoading = true);
    final before = manager.articles.articles.length;
    await manager.getArticles(page, selectedCategory);
    final after = manager.articles.articles.length;
    if (after == before) {
      hasMore = false;
    } else {
      final newArticles = manager.articles.articles.sublist(before);
      if (page == 0) {
        // Filter only first batch
        displayedArticles = _filterArticles(manager.articles.articles);
      } else {
        displayedArticles.addAll(newArticles);
      }
      page++;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 15),
                _buildCategorySelector(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Available Articles',
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
                      onChanged: (String? newValue) async {
                        if (newValue == null) return;
                        setState(() {
                          currentSort = newValue;
                          displayedArticles = _filterArticles(
                            displayedArticles,
                          );
                        });
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
                Expanded(
                  child: ConditionalBuilder(
                    condition: state is! LoadingState,
                    builder: (context) {
                      if (state is SuccessState) {
                        return ListView.separated(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: displayedArticles.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < displayedArticles.length) {
                              return _buildCompactArticleCard(
                                context,
                                displayedArticles[index],
                              );
                            }
                            return _isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox();
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20.0),
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              reusableText(
                                content: 'Connection error!',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  manager.getArticles(page, selectedCategory);
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
                        );
                      }
                    },
                    fallback: (context) =>
                        Center(child: const CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articleCategories.length,
        itemBuilder: (context, index) {
          final category = articleCategories[index];
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () async {
                if (!isSelected) {
                  setState(() {
                    page = 0;
                    hasMore = true;
                    selectedCategory = category;
                    manager.articles.articles.clear();
                    displayedArticles.clear();
                  });
                  await _loadMore();
                }
              },
              child: Chip(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF003366),
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
              color: Colors.teal.withAlpha(102),
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
                  'images/article_logo.jpg',
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
                      'images/article_logo.jpg',
                      width: 80,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
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
                  const SizedBox(width: 5.0),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
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
    List<Article> articles = list
        .where(
          (a) => selectedCategory == 'All' || a.wikiType == selectedCategory,
        )
        .toList();
    if (currentSort == 'Newest') {
      articles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (currentSort == 'Oldest') {
      articles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (currentSort == 'Longest') {
      articles.sort((a, b) => b.minReadTime! - a.minReadTime!);
    }
    return articles;
  }
}
