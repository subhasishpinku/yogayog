import 'package:flutter/material.dart';
import 'package:yogayog/constants/app_colors.dart';
import 'package:yogayog/loginscreen/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      image: 'assets/images/bike.png',
      title: 'Deliver anything,\nanywhere in the city',
      description:
          "Bike pickups ready in 15 minutes. Documents, parcels, anything up to 20 kg — we've got you covered.",
    ),
    _OnboardingData(
      image: 'assets/images/truck.png',
      title: 'Pan-India shipping &\nglobal freight',
      description:
          'National door-to-door delivery and full-service international imports & exports with customs handled for you.',
    ),
    _OnboardingData(
      image: 'assets/images/tracking_pin.png',
      title: 'Track every shipment\nlive',
      description:
          'Real-time GPS tracking from pickup to door. Get notified at every milestone, every time.',
    ),
  ];

  static const Color blue = AppColors.primaryMain;
  static const Color yellow = AppColors.primaryButton;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _getStarted() {
    // Replace this with your navigation logic.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F8),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            return _buildPage(_pages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    final bool isLastPage = _currentPage == _pages.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double panelTop = constraints.maxHeight * 0.39;

        return Stack(
          children: [
            Container(
              color: blue,
              child: Stack(
                children: [
                  Positioned(top: -35, left: -35, child: _circle(125)),
                  Positioned(
                    top: constraints.maxHeight * 0.23,
                    right: -45,
                    child: _circle(190),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: constraints.maxHeight * 0.60,
                      ),
                      child: Image.asset(
                        page.image,
                        height: 115,
                        width: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 90,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: panelTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 26, 24, 18),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: _pageIndicator()),

                            const SizedBox(height: 24),

                            Text(
                              page.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 27,
                                height: 1.12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              page.description,
                              style: const TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),

                            const Spacer(),

                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: yellow,
                                  foregroundColor: blue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  isLastPage ? 'Get Started' : 'Next →',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: GestureDetector(
                                onTap: isLastPage ? null : _skip,
                                child: Text(
                                  isLastPage
                                      ? 'Already have an account? Log in'
                                      : 'Skip',
                                  style: TextStyle(
                                    color: isLastPage
                                        ? const Color(0xFF667085)
                                        : const Color(0xFF98A2B3),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF2F2F7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_pages.length, (index) {
        final bool selected = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: selected ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? blue : const Color(0xFFE1E4EA),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 14),
      ),
    );
  }
}

class _OnboardingData {
  final String image;
  final String title;
  final String description;

  const _OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
