import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/educational_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '🎧',
      title: 'リスニングで英語耳を鍛える',
      subtitle: 'ネイティブの発音を聞いて、\n本物の英語感覚を身につけよう！',
      color: AppColors.listeningColor,
    ),
    _OnboardPage(
      emoji: '🎤',
      title: 'スピーキングで話す力を育てる',
      subtitle: 'マイクに向かって発音練習。\nAIが発音をチェックしてくれる！',
      color: AppColors.speakingColor,
    ),
    _OnboardPage(
      emoji: '👨‍👩‍👧',
      title: '親向け詳細フィードバック',
      subtitle: '子どもの発音の上達を\n親が毎日確認できる！',
      color: AppColors.accentGreen,
    ),
    _OnboardPage(
      emoji: '🏆',
      title: '楽しくゲーム感覚で学習',
      subtitle: 'バッジを集めて、\n毎日の学習を続けよう！',
      color: AppColors.primary,
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? AppColors.primary : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
                      ),
                    )),
                  ),
                  AppSpacing.verticalSpacerLg,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_page < _pages.length - 1) {
                          _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _complete();
                        }
                      },
                      child: Text(_page < _pages.length - 1 ? 'つぎへ' : 'はじめる！'),
                    ),
                  ),
                  if (_page < _pages.length - 1)
                    TextButton(
                      onPressed: _complete,
                      child: Text('スキップ', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
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

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Custom illustration based on title
          _buildIllustration(),
          AppSpacing.verticalSpacerXl,
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalSpacerMd,
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    if (title.contains('リスニング')) {
      return ListeningIllustration(size: 140);
    } else if (title.contains('スピーキング')) {
      return SpeakingIllustration(size: 140);
    } else if (title.contains('親向け')) {
      return ParentFeedbackIllustration(size: 140);
    } else if (title.contains('ゲーム')) {
      return GamificationIllustration(size: 140);
    }
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(emoji, style: AppTypography.headlineLarge.copyWith(fontSize: 72))),
    );
  }
}
