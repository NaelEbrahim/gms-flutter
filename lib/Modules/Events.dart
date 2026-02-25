import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/EventModel.dart';
import 'package:gms_flutter/Modules/Info/EventInfo.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<Events> {
  late Manager manager;
  final scrollController = ScrollController();

  int page = 0;
  bool hasMore = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getUserEvents().then(
      (_) => scrollController.addListener(_onScroll),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    manager.userEvents.clear();
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
    final before = manager.events.items.length;
    await manager.getEvents(page);
    final after = manager.events.items.length;
    if (after == before) {
      hasMore = false;
    } else {
      page++;
    }
    setState(() => isLoading = false);
  }

  bool _isSubscribed(EventModel event) {
    return manager.userEvents.any((e) => e.id == event.id);
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
      builder: (context, state) => Scaffold(
        backgroundColor: Constant.scaffoldColor,
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: reusableText(
            content: 'Events',
            fontSize: 22.0,
            fontColor: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: ConditionalBuilder(
          condition: state is! LoadingState,
          builder: (context) => ListView.builder(
            padding: EdgeInsets.all(10),
            controller: scrollController,
            itemCount: manager.events.items.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < manager.events.items.length) {
                return buildEventCardAnimated(
                  context,
                  index,
                  manager.events.items[index],
                );
              }
              return isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            },
          ),
          fallback: (context) =>
              Center(child: const CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget buildEventCardAnimated(
    BuildContext context,
    int index,
    EventModel event,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventInfo(event: event,isSubscribed: _isSubscribed(event))),
        );
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1),
        duration: Duration(milliseconds: 600 + (index * 150)),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
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
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
                child: (event.imagePath != null)
                    ? Image.network(
                        Constant.mediaURL + event.imagePath.toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 120,
                          width: 100,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            FontAwesomeIcons.medal,
                            color: Colors.greenAccent,
                            size: 30,
                          ),
                        ),
                      )
                    : Container(
                        height: 120,
                        width: 100,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          FontAwesomeIcons.medal,
                          color: Colors.greenAccent,
                          size: 30,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child:Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSubscriptionBadge(event),
                      const SizedBox(height: 10),
                      Text(
                        'start: ${event.startedAt} -> end: ${event.endedAt}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
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

  Widget _buildSubscriptionBadge(EventModel event) {
    final subscribed = _isSubscribed(event);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: subscribed ? Colors.green : Colors.redAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        subscribed ? "Subscribed" : "Unsubscribed",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
