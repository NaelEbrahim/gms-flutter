import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/Models/ArticlesModel.dart';
import 'package:gms_flutter/Shared/Components.dart';

class ArticleDetail extends StatefulWidget {
  final Article article;

  const ArticleDetail({super.key, required this.article});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  final ValueNotifier<double> readProgress = ValueNotifier(0.0);
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    readProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Article Details",
          style: const TextStyle(
            fontSize: 22,
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.bookmark, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareNodes, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: ValueListenableBuilder<double>(
            valueListenable: readProgress,
            builder: (_, value, _) {
              return LinearProgressIndicator(
                value: value,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                backgroundColor: Colors.grey,
                minHeight: 6,
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.maxScrollExtent > 0) {
              readProgress.value =
                  (scrollNotification.metrics.pixels /
                          scrollNotification.metrics.maxScrollExtent)
                      .clamp(0.0, 1.0);
            }
            return false;
          },
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                controller: scrollController,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'images/article_image.jpg',
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.article.wikiType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.tealAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          FontAwesomeIcons.userTie,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Coach ${widget.article.admin.firstName} ${widget.article.admin.lastName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Created: ${ReusableComponents.formatDateTime(widget.article.createdAt.toString())}",
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      widget.article.lastModifiedAt != null
                          ? "Updated: ${ReusableComponents.formatDateTime(widget.article.lastModifiedAt.toString())}"
                          : 'N/A',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(127),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.tealAccent, width: 0.6),
                      ),
                      child: Text(
                        widget.article.content,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.7,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        "Keep pushing your limits 💪",
                        style: TextStyle(
                          color: Colors.tealAccent.shade100,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
