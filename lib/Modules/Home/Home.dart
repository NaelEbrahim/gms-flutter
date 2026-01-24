import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/Manager.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/Constant.dart';

class Home extends StatelessWidget {
  Home({super.key});

  bool isClasses = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Manager, BLoCStates>(
      listener: (context, state) {},
      builder: (context, state) => Column(
        children: [
          SizedBox(
            height: Constant.screenHeight * 0.25,
            width: Constant.screenWidth,
            child: CarouselSlider.builder(
              itemCount: 3,
              itemBuilder: (context, index, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'images/1.png',
                        width: Constant.screenWidth,
                        fit: BoxFit.fill,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.5),
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
                          "Stay Strong 💪",
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
                      if (!isClasses) isClasses = true;
                      Manager.get(context).updateState();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
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
                      if (isClasses) isClasses = false;
                      Manager.get(context).updateState();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
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
              itemBuilder: (context, index) =>
                  _buildCreativeCard(context, index),
              separatorBuilder: (context, index) => const SizedBox(height: 5.0),
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeCard(BuildContext context, int index) {
    return TweenAnimationBuilder<double>(
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
              color: Colors.black.withOpacity(0.3),
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
              child: Image.asset(
                'images/1.png',
                width: 120,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    reusableText(
                      content: 'Kick Boxing',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 6),
                    reusableText(
                      content:
                          'Powerful class combining boxing & fighting skills',
                      fontColor: Colors.white70,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 600),
                          turns: 0.05,
                          child: const CircleAvatar(
                            backgroundImage: AssetImage('images/coach.jpg'),
                            radius: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        reusableText(
                          content: 'Coach Ahmed Hallak',
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
    );
  }
}
