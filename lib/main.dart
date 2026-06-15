import 'package:flutter/material.dart';

void main() {
  runApp(const TerangaSkillsApp());
}

// ─── App Root ────────────────────────────────────────────────────────────────

class TerangaSkillsApp extends StatelessWidget {
  const TerangaSkillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerangaSkills',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const OnboardingScreen(),
    );
  }
}

// ─── Design System ───────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const background = Color(0xFFFBFBFB);
  static const surface = Color(0xFFF3F4F8);
  static const primary = Color(0xFF1B4FD8);      // Bleu souverain
  static const primaryLight = Color(0xFF5780FA);
  static const accent = Color(0xFF00A651);        // Vert Sénégal
  static const danger = Color(0xFFE8352A);        // Rouge Sénégal
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
  static const dotActive = Color(0xFF1B4FD8);
  static const dotInactive = Color(0xFFD1D5DB);
  static const white = Color(0xFFFFFFFF);
  static const ctaBackground = Color(0xFF1A1A2E);
}

class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.5,
  );

  static const buttonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  static const skipLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class OnboardingPage {
  final String title;
  final String subtitle;
  final String? note;
  final Color illustrationColor;
  final IconData illustrationIcon;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    this.note,
    required this.illustrationColor,
    required this.illustrationIcon,
  });
}

const List<OnboardingPage> kOnboardingPages = [
  OnboardingPage(
    title: 'Gardiens de\nl\'identité nationale',
    subtitle: 'Protéger l\'état civil sénégalais',
    note:
        'Vous êtes en première ligne pour défendre chaque citoyen contre la fraude documentaire.',
    illustrationColor: Color(0xFFE8F0FE),
    illustrationIcon: Icons.shield_outlined,
  ),
  OnboardingPage(
    title: 'Simple.\nRapide.\nIntelligent.',
    subtitle: 'L\'IA analyse, vous décidez',
    note:
        'Pas de réseau ? Aucun problème. Vos signalements sont sauvegardés et synchronisés dès que la connexion revient.',
    illustrationColor: Color(0xFFE6F4EA),
    illustrationIcon: Icons.document_scanner_outlined,
  ),
  OnboardingPage(
    title: 'Votre mission\ncommence ici',
    subtitle: 'Connectez-vous pour accéder à votre espace agent',
    note:
        'Vos données sont chiffrées. Chaque action est tracée dans un journal d\'audit sécurisé.',
    illustrationColor: Color(0xFFFCE8E6),
    illustrationIcon: Icons.verified_user_outlined,
  ),
];

// ─── Onboarding Screen ───────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _goToNext() {
    if (_currentIndex < kOnboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    // TODO: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigation vers l\'écran de connexion')),
    );
  }

  bool get _isLastPage => _currentIndex == kOnboardingPages.length - 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: AnimatedOpacity(
                  opacity: _isLastPage ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(
                    onPressed: _isLastPage ? null : _navigateToLogin,
                    child: const Text('Passer', style: AppTextStyles.skipLabel),
                  ),
                ),
              ),
            ),

            // ── PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: kOnboardingPages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(page: kOnboardingPages[index]);
                },
              ),
            ),

            // ── Bottom controls
            _BottomControls(
              currentIndex: _currentIndex,
              totalPages: kOnboardingPages.length,
              isLastPage: _isLastPage,
              onNext: _goToNext,
              onPrevious: _goToPrevious,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Page Content ─────────────────────────────────────────────────────────────

class _OnboardingPageView extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Illustration
          Center(
            child: _IllustrationCard(
              color: page.illustrationColor,
              icon: page.illustrationIcon,
            ),
          ),

          const SizedBox(height: 48),

          // ── Title
          Text(page.title, style: AppTextStyles.displayLarge),

          const SizedBox(height: 12),

          // ── Subtitle
          Text(page.subtitle, style: AppTextStyles.displayMedium),

          if (page.note != null) ...[
            const SizedBox(height: 20),
            _NoteCard(text: page.note!),
          ],
        ],
      ),
    );
  }
}

// ─── Illustration Card ────────────────────────────────────────────────────────

class _IllustrationCard extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _IllustrationCard({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(
        icon,
        size: 96,
        color: color.computeLuminance() > 0.5
            ? AppColors.primary.withOpacity(0.8)
            : AppColors.white,
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final String text;

  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dotInactive),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

// ─── Bottom Controls ──────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _BottomControls({
    required this.currentIndex,
    required this.totalPages,
    required this.isLastPage,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Dot indicators
          _DotIndicators(
            currentIndex: currentIndex,
            totalPages: totalPages,
          ),

          // ── Navigation buttons
          Row(
            children: [
              if (currentIndex > 0) ...[
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onPrevious,
                  backgroundColor: AppColors.surface,
                  iconColor: AppColors.textPrimary,
                ),
                const SizedBox(width: 12),
              ],
              _PrimaryButton(
                label: isLastPage ? 'Se connecter' : 'Suivant',
                onTap: onNext,
                isExpanded: isLastPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Dot Indicators ───────────────────────────────────────────────────────────

class _DotIndicators extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const _DotIndicators({
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPages, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.dotActive : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

// ─── Circle Icon Button ───────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.dotInactive),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isExpanded;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 50,
        width: isExpanded ? 180 : 50,
        decoration: BoxDecoration(
          color: AppColors.ctaBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        child: isExpanded
            ? Center(
                child: Text(label, style: AppTextStyles.buttonLabel),
              )
            : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.white,
              ),
      ),
    );
  }
}