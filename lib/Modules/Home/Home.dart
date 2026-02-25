import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/ClassesModel.dart';
import 'package:gms_flutter/Models/SessionsModel.dart';
import 'package:gms_flutter/Modules/Events.dart';
import 'package:gms_flutter/Modules/Info/ClassInfo.dart';
import 'package:gms_flutter/Modules/Info/SessionInfo.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page = 0;
  late Manager manager;
  bool isClasses = true;
  bool hasMore = true;
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getEvents(0).then((_) {
      _loadMore();
    });
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    manager.classes.items.clear();
    manager.sessions.items.clear();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);
    var before = 0;
    var after = 0;
    if (isClasses) {
      before = manager.classes.items.length;
      await manager.getClasses(page);
      after = manager.classes.items.length;
    } else {
      before = manager.sessions.items.length;
      await manager.getSessions(page);
      after = manager.sessions.items.length;
    }
    if (after == before) {
      hasMore = false;
    } else {
      page++;
    }
    setState(() => isLoading = false);
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
        return ConditionalBuilder(
          condition: state is! LoadingState,
          builder: (context) => Column(
            children: [
              SizedBox(
                height: Constant.screenHeight * 0.25,
                width: Constant.screenWidth,
                child: CarouselSlider.builder(
                  itemCount: manager.events.items.length,
                  itemBuilder: (context, index, _) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Events()),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              Constant.mediaURL +
                                  manager.events.items[index].imagePath
                                      .toString(),
                              width: Constant.screenWidth,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 140,
                                    width: 120,
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      FontAwesomeIcons.medal,
                                      color: Colors.greenAccent,
                                      size: 50,
                                    ),
                                  ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withAlpha(127),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Text(
                                "${manager.events.items[index].title} 💪",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      offset: Offset(1, 1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: double.infinity,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                    autoPlayInterval: Duration(seconds: 6),
                    autoPlayAnimationDuration: Duration(seconds: 2),
                    autoPlayCurve: Curves.easeInOut,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Available Sports",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.sports_gymnastics_outlined,
                      color: Colors.tealAccent,
                      size: 32.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            page = 0;
                            hasMore = true;
                            isLoading = false;
                            manager.sessions.items.clear();
                            if (!isClasses) isClasses = true;
                            _loadMore();
                          });
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isClasses
                                ? Colors.greenAccent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Classes",
                            style: TextStyle(
                              color: isClasses ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            page = 0;
                            hasMore = true;
                            isLoading = false;
                            manager.classes.items.clear();
                            if (isClasses) isClasses = false;
                            _loadMore();
                          });
                        },
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !isClasses
                                ? Colors.greenAccent
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Sessions",
                            style: TextStyle(
                              color: !isClasses ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    if (isClasses && index < manager.classes.items.length) {
                      return _buildCreativeCard(
                        context,
                        index,
                        cls: manager.classes.items[index],
                      );
                    } else if (!isClasses &&
                        index < manager.sessions.items.length) {
                      return _buildCreativeCard(
                        context,
                        index,
                        session: manager.sessions.items[index],
                      );
                    }
                    return isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5.0),
                  itemCount:
                      (isClasses
                          ? manager.classes.items.length
                          : manager.sessions.items.length) +
                      (isLoading ? 1 : 0),
                ),
              ),
            ],
          ),
          fallback: (context) =>
              Center(child: const CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildCreativeCard(
    BuildContext context,
    int index, {
    ClassesModel? cls,
    SessionsModel? session,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1),
      duration: Duration(milliseconds: 600 + (index * 150)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: () {
          if (isClasses) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassInfo(
                  classId: cls!.id.toString(),
                  title: cls.name.toString(),
                  coach: cls.coach,
                  description: cls.description.toString(),
                  image: cls.imagePath,
                  pricePerMonth: cls.price.toString(),
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SessionInfo(sessionsModel: session as SessionsModel),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Constant.scaffoldColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(76),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              (isClasses)
                  ? buildItemImage(cls!.imagePath)
                  : buildItemImage(session!.classImage),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      reusableText(
                        content: (isClasses)
                            ? cls!.name ?? 'none'
                            : session!.title ?? 'none',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 6),
                      reusableText(
                        content: (isClasses)
                            ? cls!.description ?? 'none'
                            : session!.description ?? 'none',
                        fontColor: Colors.white70,
                        fontSize: 13,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipOval(
                            child: (isClasses)
                                ? buildCoachAvatar(cls!.imagePath)
                                : buildCoachAvatar(session!.classImage),
                          ),
                          const SizedBox(width: 10),
                          reusableText(
                            content: (isClasses)
                                ? 'Coach ${cls!.coach.firstName} ${cls.coach.lastName}'
                                : 'Coach ${session!.coach.firstName} ${session.coach.lastName}',
                            fontColor: Colors.white70,
                            fontSize: 13,
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCoachAvatar(String? imagePath) {
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: (imagePath != null && imagePath.isNotEmpty)
            ? Image.network(
                Constant.mediaURL + imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  FontAwesomeIcons.circleUser,
                  color: Colors.greenAccent,
                  size: 30,
                ),
              )
            : const Icon(
                FontAwesomeIcons.circleUser,
                color: Colors.greenAccent,
                size: 30,
              ),
      ),
    );
  }

  Widget buildItemImage(String? imagePath) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      child: (imagePath != null)
          ? Image.network(
              Constant.mediaURL + imagePath.toString(),
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 140,
                width: 120,
                color: Colors.grey.shade300,
                child: Icon(
                  FontAwesomeIcons.dumbbell,
                  color: Colors.greenAccent,
                  size: 50,
                ),
              ),
            )
          : Container(
              color: Colors.grey.shade700,
              height: 140,
              width: 120,
              child: Icon(
                FontAwesomeIcons.dumbbell,
                color: Colors.greenAccent,
                size: 50,
              ),
            ),
    );
  }
}
