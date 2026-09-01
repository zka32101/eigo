import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/coin_provider.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../theme/sizes.dart';
import '../theme/typography.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0)),
    );
    _ctrl.forward();
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      _initServices(),
    ]);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final nav = Navigator.of(context);

    if (onboardingDone) {
      nav.pushReplacementNamed('/home');
    } else {
      nav.pushReplacementNamed('/onboarding');
    }
  }

  Future<void> _initServices() async {
    await Future.wait([
      FirebaseService().init(),
      NotificationService().init(),
      ref.read(coinProvider.notifier).load(),
    ]);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Text('🇬🇧', style: AppTypography.headlineLarge),
              ),
              AppSpacing.verticalSpacerLg,
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      '英語コレ！',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    AppSpacing.verticalSpacerXs,
                    Text(
                      'Listening & Speaking',
                      style: AppTypography.labelLarge.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
