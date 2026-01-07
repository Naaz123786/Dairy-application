import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Your Private\nSanctuary',
      description:
          'A secure space for your thoughts, encrypted and protected with biometric lock.',
      icon: Icons.security_outlined,
    ),
    OnboardingContent(
      title: 'Organize Your\nVision',
      description:
          'Plan your days efficiently with our integrated calendar and smart planner.',
      icon: Icons.calendar_today_outlined,
    ),
    OnboardingContent(
      title: 'Capture Every\nMoment',
      description:
          'Write daily entries, track your mood, and never forget a special memory.',
      icon: Icons.edit_note_outlined,
    ),
    OnboardingContent(
      title: 'Stay on\nTrack',
      description:
          'Set reminders for important events and never miss a beat in your busy life.',
      icon: Icons.notifications_active_outlined,
    ),
    OnboardingContent(
      title: 'Your Personal\nJourney',
      description:
          'Track your mood and growth over time with insightful analytics and reflections.',
      icon: Icons.auto_graph_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final localDb = GetIt.I<LocalDatabase>();
    await localDb.setOnboardingComplete();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.white : AppTheme.black;
    final secondaryColor = isDark ? AppTheme.black : AppTheme.white;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final bool isVisible = _currentPage == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                _contents[index].icon,
                                size: 120,
                                color: Colors.cyan,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 60),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 600),
                          opacity: isVisible ? 1.0 : 0.0,
                          curve: Curves.easeIn,
                          child: AnimatedPadding(
                            duration: const Duration(milliseconds: 600),
                            padding: EdgeInsets.only(top: isVisible ? 0 : 20),
                            child: Text(
                              _contents[index].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                letterSpacing: -1,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: isVisible ? 0.7 : 0.0,
                          curve: Curves.easeIn,
                          child: Text(
                            _contents[index].description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              color: primaryColor,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        margin: const EdgeInsets.only(right: 10),
                        height: 6,
                        width: _currentPage == index ? 32 : 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryColor
                              : primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: secondaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _currentPage == _contents.length - 1
                              ? 'GET STARTED'
                              : 'NEXT',
                          key: ValueKey(_currentPage == _contents.length - 1),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage < _contents.length - 1 ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _currentPage == _contents.length - 1,
                      child: TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.4),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.privacy),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.3),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}
