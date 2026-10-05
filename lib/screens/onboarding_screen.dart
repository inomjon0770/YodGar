import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showingScrollStory = false;

  final ScrollController _storyScrollController = ScrollController();
  double _storyScrollOffset = 0.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _slides = [
    {
      'title': 'YODGAR ga Xush Kelibsiz!',
      'subtitle': 'So\'zlarni oson va mustahkam yodlang',
      'icon': '📖',
      'desc': 'Ingliz va Rus tillaridagi 4,000 dan ortiq eng kerakli so\'zlarni interaktiv usulda yod oling.',
    },
    {
      'title': '10 ta Qiziqarli O\'yin',
      'subtitle': 'Zerikmasdan bilim oling va Coin yuting',
      'icon': '🎮',
      'desc': 'Flashcards, Word Match, Spelling Bee va boshqa 10 xil o\'yin orqali har kuni so\'z boyligingizni oshiring.',
    },
    {
      'title': 'AI Sobir va Jamoaviy Chat',
      'subtitle': 'Sun\'iy intellekt va do\'stlar bilan o\'rganing',
      'icon': '🤖',
      'desc': 'AI Sobir sizga har qanday so\'z va qoidani tushuntirib beradi. Do\'stlaringiz bilan musobaqalashing!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _storyScrollController.addListener(() {
      setState(() {
        _storyScrollOffset = _storyScrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _storyScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _finishSlides() {
    setState(() {
      _showingScrollStory = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingScrollStory) {
      return _buildInteractiveScrollStory();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF007BFF),
                  Color(0xFF0056B3),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Stack(
                  children: [
                    // Slides PageView
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      itemCount: _slides.length,
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Glass Card with clean icon/logo
                              GlassContainer(
                                borderRadius: 32,
                                blur: 20,
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  children: [
                                    if (index == 0)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                                        ),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          height: 70,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.15),
                                          border: Border.all(color: Colors.white30, width: 2),
                                        ),
                                        child: Center(
                                          child: Text(
                                            slide['icon']!,
                                            style: const TextStyle(fontSize: 44),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    Text(
                                      slide['title']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      slide['subtitle']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      slide['desc']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Top Skip Button
                    Positioned(
                      top: 16,
                      right: 20,
                      child: TextButton(
                        onPressed: _finishSlides,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'O\'tkazib yuborish',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Controls (Dots & Next Button)
                    Positioned(
                      bottom: 30,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dots
                          Row(
                            children: List.generate(
                              _slides.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 8,
                                width: _currentPage == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.primaryGreen
                                      : Colors.white38,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),

                          // Next or Complete Button
                          GlassButton(
                            text: _currentPage == _slides.length - 1 ? 'Davom etish' : 'Keyingisi',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () {
                              if (_currentPage < _slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _finishSlides();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Scroll Story with rich floating animations
  Widget _buildInteractiveScrollStory() {
    final maxScroll = 600.0;
    final progress = (_storyScrollOffset / maxScroll).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Stack(
        children: [
          // Dynamic animated background gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(const Color(0xFF007BFF), const Color(0xFF1B263B), progress)!,
                    Color.lerp(const Color(0xFF28A745), const Color(0xFF0D1B2A), progress)!,
                  ],
                ),
              ),
            ),
          ),

          // Floating background ambient particles
          ...List.generate(6, (i) {
            final yPos = (100.0 * (i + 1) - _storyScrollOffset * 0.4) % 800;
            final xPos = 40.0 + (i * 55.0) % 300;
            return Positioned(
              left: xPos,
              top: yPos,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 30 + (i * 10).toDouble(),
                  height: 30 + (i * 10).toDouble(),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  controller: _storyScrollController,
                  child: SizedBox(
                    height: 1250, // scrollable runway
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Animated Pulsing Scroll Indicator
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white60, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.5),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    '↓ Pastga suring (${(progress * 100).toInt()}%)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Video-like Animated Interactive Stage
                          AnimatedBuilder(
                            animation: _storyScrollController,
                            builder: (context, child) {
                              return _buildDynamicVideoFrame(progress);
                            },
                          ),

                          const Spacer(),

                          // Final Get Started Button at bottom of scroll
                          GlassContainer(
                            borderRadius: 28,
                            blur: 20,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  'Siz to\'liq tayyorsiz!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Barcha imkoniyatlar siz uchun ochiq. Hoziroq boshlang!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                    ),
                                    onPressed: widget.onComplete,
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Boshlash 🚀',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicVideoFrame(double progress) {
    final scale = 1.0 + (progress * 0.15);
    final rotation = sin(progress * pi) * 0.05;

    String currentHeadline = '1-bosqich: Yodgar tizimi';
    String stageText = 'So\'zlar miyangizda uzoq muddatli xotiraga aylanadi.';

    Widget centerVisual = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: 75,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.menu_book_rounded, size: 70, color: AppColors.primaryBlue),
      ),
    );

    if (progress > 0.35 && progress <= 0.7) {
      currentHeadline = '2-bosqich: O\'yinlar va Amaliyot';
      stageText = '10 xil o\'yin orqali so\'zlarni eslab qolish 5 karra osonlashadi!';
      centerVisual = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStageBadge('🎮', 'O\'yinlar'),
          const SizedBox(width: 12),
          _buildStageBadge('🪙', '+Coinlar'),
          const SizedBox(width: 12),
          _buildStageBadge('🔥', 'Streak'),
        ],
      );
    } else if (progress > 0.7) {
      currentHeadline = '3-bosqich: Yangi Til Darajasi!';
      stageText = 'Bronze dan Gold va Diamond ligalariga ko\'tariling!';
      centerVisual = Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'OLTIN LIGA',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      );
    }

    return Transform.scale(
      scale: scale,
      child: Transform.rotate(
        angle: rotation,
        child: GlassContainer(
          borderRadius: 30,
          blur: 20,
          padding: const EdgeInsets.all(26),
          child: Column(
            children: [
              Text(
                currentHeadline,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              centerVisual,
              const SizedBox(height: 20),
              Text(
                stageText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageBadge(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
