import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ArticlesModel.dart';
import 'package:gms_flutter/Shared/Components.dart';

class ArticleDetail extends StatelessWidget {
  double _progress = 0.0;
  final Article article;
  final ScrollController _scrollController = ScrollController();

  ArticleDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) {
        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
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
                icon: const Icon(
                  FontAwesomeIcons.bookmark,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.shareNodes,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: _progress,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                backgroundColor: Colors.grey.shade200,
                minHeight: 6.0,
              ),
            ),
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.maxScrollExtent > 0) {
                final newProgress =
                    scrollNotification.metrics.pixels /
                    scrollNotification.metrics.maxScrollExtent;
                context.read<Manager>().UpdateProgressEvent(newProgress);
              }
              return true;
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
                // Article content
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'images/1.png',
                          height: 230,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Wiki type + coach
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.tealAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article.wikiType.toUpperCase(),
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
                            'Coach ${article.admin.firstName} ${article.admin.lastName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Dates
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.clock,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Created: ${ReusableComponents.formatDateTime(article.createdAt.toString())}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            FontAwesomeIcons.penToSquare,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            article.lastModifiedAt != null
                                ? "Updated: ${ReusableComponents.formatDateTime(article.lastModifiedAt.toString())}"
                                : 'N/A',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Content Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.tealAccent,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          article.content,
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
                      // Motivational Footer
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
                      const SizedBox(height: 60),
                    ],
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
