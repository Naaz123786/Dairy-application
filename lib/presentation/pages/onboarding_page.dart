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

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _finishOnboarding() async {
    final localDb = GetIt.I<LocalDatabase>();
    await localDb.setOnboardingComplete();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  BoxDecoration _slideCardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF161616) : Colors.white,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: Colors.cyan.withValues(alpha: isDark ? 0.06 : 0.05),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  Widget _buildTopBar(bool isDark, Color primaryColor) {
    final isLast = _currentPage == _contents.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Text(
            'Diary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: primaryColor.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Text(
              '${_currentPage + 1} / ${_contents.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: primaryColor.withValues(alpha: 0.70),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isLast ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: isLast,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor.withValues(alpha: 0.55),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                  ),
                ),
                child: const Text('SKIP'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _contents.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          margin: const EdgeInsets.only(right: 10),
          height: 6,
          width: _currentPage == index ? 32 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.cyan
                : primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryCtaButton({
    required bool isDark,
    required VoidCallback onPressed,
    required String label,
    required bool isLast,
  }) {
    final gradient = LinearGradient(
      colors: isDark
          ? const [Color(0xFF00E5FF), Color(0xFF2979FF)]
          : [Colors.cyan, Colors.lightBlueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withValues(alpha: isDark ? 0.35 : 0.22),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.10),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.16),
            highlightColor: Colors.white.withValues(alpha: 0.06),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Row(
                  key: ValueKey(label),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      isLast
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.white : AppTheme.black;
    final secondaryColor = isDark ? AppTheme.black : AppTheme.white;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: Stack(
        children: [
          // Background gradient wash
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF000000),
                          const Color(0xFF001A1C),
                          const Color(0xFF000000),
                        ]
                      : [
                          const Color(0xFFF7FEFF),
                          Colors.cyan.withValues(alpha: 0.08),
                          Colors.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isDark, primaryColor),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                            decoration: _slideCardDecoration(isDark),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(
                                      begin: 0.0, end: isVisible ? 1.0 : 0.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        width: 96,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.cyan.withValues(
                                                  alpha: isDark ? 0.35 : 0.25),
                                              Colors.lightBlueAccent.withValues(
                                                  alpha: isDark ? 0.22 : 0.16),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(32),
                                          border: Border.all(
                                            color: Colors.cyan.withValues(
                                                alpha: isDark ? 0.22 : 0.18),
                                          ),
                                        ),
                                        child: Icon(
                                          _contents[index].icon,
                                          size: 44,
                                          color: Colors.cyan,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 600),
                                  opacity: isVisible ? 1.0 : 0.0,
                                  curve: Curves.easeIn,
                                  child: AnimatedPadding(
                                    duration: const Duration(milliseconds: 600),
                                    padding:
                                        EdgeInsets.only(top: isVisible ? 0 : 20),
                                    child: Text(
                                      _contents[index].title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                        letterSpacing: -1,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 800),
                                  opacity: isVisible ? 0.75 : 0.0,
                                  curve: Curves.easeIn,
                                  child: Text(
                                    _contents[index].description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryColor,
                                      height: 1.6,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
                  child: Column(
                    children: [
                      _buildIndicators(primaryColor),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _currentPage == 0 ? 0.0 : 1.0,
                              child: IgnorePointer(
                                ignoring: _currentPage == 0,
                                child: OutlinedButton.icon(
                                  onPressed: _onBack,
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Back'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        primaryColor.withValues(alpha: 0.80),
                                    side: BorderSide(
                                      color: primaryColor.withValues(alpha: 0.15),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildPrimaryCtaButton(
                              isDark: isDark,
                              onPressed: _onNext,
                              label: _currentPage == _contents.length - 1
                                  ? 'GET STARTED'
                                  : 'NEXT',
                              isLast: _currentPage == _contents.length - 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.privacy),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            color: primaryColor.withValues(alpha: 0.35),
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
        ],
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
