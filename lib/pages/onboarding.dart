// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lakbay/authentication/login.dart';
import 'package:lakbay/global-styling/colors.dart';
import 'package:lakbay/global-styling/global_style.dart';

OnboardingPage buildOnboardingPage() {
  return OnboardingPage(
    pages: [
      OnboardingPageModel(
        title: 'Welcome to Lak-bay!',
        description:
            'Enjoy the best of the Luzon, Philippines in the palm of your hands.',
        image: 'assets/images/onboard/onboard1.png',
        bgColor: AppColors.accentWhiteColor,
      ),
      OnboardingPageModel(
        title: "It's time to hit the road!",
        description:
            'Discover hidden gems, embrace new cultures, and create stories that resonate.',
        image: 'assets/images/onboard/onboard2.png',
        bgColor: AppColors.accentWhiteColor,
      ),
      OnboardingPageModel(
        title: 'Bookmark your favourites',
        description: 'Gain insights on navigating new places with ease.',
        image: 'assets/images/onboard/onboard3.png',
        bgColor: AppColors.accentWhiteColor,
      ),
      OnboardingPageModel(
        title: 'Ease of travel',
        description: "From essentials to travel hacks, we've got you covered.",
        image: 'assets/images/onboard/onboard1.png',
        bgColor: AppColors.accentWhiteColor,
      ),
    ],
  );
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String image;
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel(
      {required this.title,
      required this.description,
      required this.image,
      this.bgColor = Colors.blue,
      this.textColor = AppColors.accentBlackColor});
}

class OnboardingPage extends StatefulWidget {
  final List<OnboardingPageModel> pages;

  const OnboardingPage({Key? key, required this.pages}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Store the currently visible page
  int _currentPage = 0;
  // Define a controller for the pageview
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: widget.pages[_currentPage].bgColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                // Pageview to render each page
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
                    // Change current page when pageview changes
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Image.asset(
                              item.image,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: HeaderText(item.title),
                              ),
                              Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: AppColors.accentBlackColor,
                                  ),
                                ),
                              )
                            ]))
                      ],
                    );
                  },
                ),
              ),

              // Current page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages
                    .map((item) => AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: _currentPage == widget.pages.indexOf(item)
                              ? 20
                              : 4,
                          height: 4,
                          margin: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                              color: AppColors.accentLightGreenColor,
                              borderRadius: BorderRadius.circular(10.0)),
                        ))
                    .toList(),
              ),

              // Bottom buttons
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        } else {
                          _pageController.animateToPage(_currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _currentPage == widget.pages.length - 1
                              ? "Finish"
                              : "Next",
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              color: AppColors.accentDarkGreenColor),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
