import 'package:flutter/material.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gms_flutter/Modules/Login.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoarding> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "images/onBoarding_1.jpg",
      "title": "Elevate Your Performance",
      "desc":
          "Take control of your fitness operations with a smarter, streamlined system.",
    },
    {
      "image": "images/onBoarding_2.jpg",
      "title": "Manage With Confidence",
      "desc": "Monitor memberships, payments, and engagement effortlessly.",
    },
    {
      "image": "images/onBoarding_3.jpg",
      "title": "Built for Growth",
      "desc":
          "Scale your gym operations with tools designed for efficiency and impact.",
    },
  ];

  Future<void> _completeOnboarding(BuildContext context) async {
    await SharedPrefHelper.saveBool('onboarding_done', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              return SizedBox(
                width: Constant.screenWidth,
                height: Constant.screenHeight,
                child: Image.asset(_pages[index]["image"]!, fit: BoxFit.cover),
              );
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.black.withAlpha(102)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Shape",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 38,
                          ),
                        ),
                        TextSpan(
                          text: "Up",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _pages[currentIndex]["title"]!,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _pages[currentIndex]["desc"]!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _completeOnboarding(context),
                        child: const Text(
                          "Skip",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _pages.length,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white54,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_controller.hasClients) {
                            if (currentIndex == _pages.length - 1) {
                              _completeOnboarding(context);
                            } else {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        },
                        child: Text(
                          currentIndex == _pages.length - 1
                              ? "Get Started"
                              : "Next",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
