import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/EventModel.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class EventInfo extends StatefulWidget {
  final bool isSubscribed;
  final EventModel event;

  const EventInfo({super.key, required this.event, required this.isSubscribed});

  @override
  State<EventInfo> createState() => _EventInfoState();
}

class _EventInfoState extends State<EventInfo> {
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
          iconTheme: IconThemeData(color: Colors.white),
          title: reusableText(
            content: 'Event Info',
            fontSize: 22.0,
            fontColor: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
        bottomNavigationBar: (state is! LoadingState)
            ? _buildBottomAction(context)
            : const SizedBox.shrink(),
        body: (state is LoadingState)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.event.imagePath != null
                          ? Image.network(
                              Constant.mediaURL + widget.event.imagePath!,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            )
                          : Container(
                              height: 200,
                              color: Colors.black26,
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.medal,
                                  size: 80,
                                  color: Colors.greenAccent,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "startDate: ${widget.event.startedAt}\nendDate: ${widget.event.endedAt}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text(
                      "Prizes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.event.prizes.isEmpty)
                      const Text(
                        "No prizes available.",
                        style: TextStyle(color: Colors.white54),
                      )
                    else
                      Column(
                        children: widget.event.prizes.map((prize) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.card_giftcard,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prize.prize,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Condition: ${prize.condition}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text(
                      "Participants",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.event.participants.isEmpty)
                      const Text(
                        "No participants yet.",
                        style: TextStyle(color: Colors.white54),
                      )
                    else
                      Column(
                        children: widget.event.participants.map((user) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.black26,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${user.firstName} ${user.lastName}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Text(
                                  "${user.score} pts",
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _buildSubscribeButton(context, widget.event),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context, EventModel event) {
    final manager = Manager.get(context);
    return SizedBox(
      height: 36,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isSubscribed
              ? Colors.redAccent
              : Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          if (widget.isSubscribed) {
            await manager.unSubscribeFromEvent(event.id);
            Navigator.pop(context);
          } else {
            await manager.subscribeToEvent(event.id);
            Navigator.pop(context);
          }
        },
        icon: Icon(
          widget.isSubscribed ? Icons.event_busy : Icons.event_available,
          size: 18,
        ),
        label: Text(
          widget.isSubscribed ? "Unsubscribe" : "Subscribe",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
