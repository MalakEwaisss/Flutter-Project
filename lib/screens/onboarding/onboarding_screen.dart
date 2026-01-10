import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.explore,
      title: 'Discover Amazing Places',
      description:
          'Explore destinations around the world and find your perfect trip',
      imagePath: 'assets/images/1.jpeg',
    ),
    OnboardingPage(
      icon: Icons.calendar_month,
      title: 'Plan Your Journey',
      description:
          'Easily schedule your trips with flexible dates and customizable options',
      imagePath: 'assets/images/2.jpeg',
    ),
    OnboardingPage(
      icon: Icons.card_travel,
      title: 'Travel with Confidence',
      description:
          'Book your dream vacation with secure payments and trusted partners',
      imagePath: 'assets/images/3.jpeg',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToSearch() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _skipToSearch() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToSearch,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageWidget(page: _pages[index]);
                },
              ),
            ),

            _PageIndicator(currentPage: _currentPage, pageCount: _pages.length),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _navigateToSearch
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.75;
    final contentHeight = screenHeight * 0.25;

    return Stack(
      children: [
        // Background Image (top 2/3)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: imageHeight,
          child: Image.asset(page.imagePath, fit: BoxFit.cover),
        ),
        // Rounded Content Section (bottom 1/3)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: contentHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    page.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const _PageIndicator({required this.currentPage, required this.pageCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? const Color(0xFF1E3A8A)
                : const Color(0xFF1E3A8A).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String imagePath;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
