import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/english_town_polish_provider.dart';
import '../design_system/design_system.dart';

/// English-Only Town Settings Screen
///
/// Provides options for:
/// - Sound effects toggle
/// - Particle effects toggle
/// - Animation speed settings
/// - Performance optimization preferences
class EnglishTownSettingsScreen extends ConsumerWidget {
  const EnglishTownSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled = ref.watch(soundEffectsEnabledProvider);
    final particlesEnabled = ref.watch(particleEffectsEnabledProvider);
    final animationMultiplier = ref.watch(animationDurationMultiplierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.titleLarge.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.md),

            // Audio Settings Section
            _buildSectionHeader('🔊 Audio Settings'),
            SizedBox(height: AppSpacing.md),
            _buildToggleSetting(
              title: 'Sound Effects',
              subtitle: 'Enable sound effects for rewards and interactions',
              value: soundEnabled,
              onChanged: (value) {
                ref.read(soundEffectsEnabledProvider.notifier).state = value;
              },
              icon: soundEnabled ? '🔊' : '🔇',
            ),

            SizedBox(height: AppSpacing.lg),

            // Visual Effects Section
            _buildSectionHeader('✨ Visual Effects'),
            SizedBox(height: AppSpacing.md),
            _buildToggleSetting(
              title: 'Particle Effects',
              subtitle: 'Show confetti and particle animations on rewards',
              value: particlesEnabled,
              onChanged: (value) {
                ref.read(particleEffectsEnabledProvider.notifier).state = value;
              },
              icon: particlesEnabled ? '✨' : '·',
            ),

            SizedBox(height: AppSpacing.lg),

            // Animation Settings Section
            _buildSectionHeader('⏱️ Animation Speed'),
            SizedBox(height: AppSpacing.md),
            _buildAnimationSpeedSetting(
              currentMultiplier: animationMultiplier,
              onChanged: (value) {
                ref.read(animationDurationMultiplierProvider.notifier).state = value;
              },
            ),

            SizedBox(height: AppSpacing.lg),

            // Performance Section
            _buildSectionHeader('⚙️ Performance'),
            SizedBox(height: AppSpacing.md),
            _buildPerformanceInfo(ref),

            SizedBox(height: AppSpacing.lg),

            // About Section
            _buildSectionHeader('ℹ️ About'),
            SizedBox(height: AppSpacing.md),
            _buildAboutSection(),

            SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.titleSmall,
    );
  }

  /// Build toggle setting
  Widget _buildToggleSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String icon,
  }) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  /// Build animation speed setting
  Widget _buildAnimationSpeedSetting({
    required double currentMultiplier,
    required ValueChanged<double> onChanged,
  }) {
    final speeds = [
      (label: 'Fastest', value: 0.5),
      (label: 'Fast', value: 0.75),
      (label: 'Normal', value: 1.0),
      (label: 'Slow', value: 1.25),
      (label: 'Slowest', value: 1.5),
    ];

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animation Speed',
            style: AppTypography.bodyMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Current: ${speeds.firstWhere((s) => s.value == currentMultiplier).label}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accentOrange,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Slider(
            value: currentMultiplier,
            min: 0.5,
            max: 1.5,
            divisions: 4,
            label: speeds.firstWhere((s) => s.value == currentMultiplier).label,
            onChanged: onChanged,
            activeColor: AppColors.accentOrange,
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fastest',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'Slowest',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build performance info
  Widget _buildPerformanceInfo(WidgetRef ref) {
    final metrics = ref.watch(performanceMetricsProvider);
    final showOptimizations = ref.watch(showPerformanceOptimizationsProvider);

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(
          color: metrics.isOptimized ? AppColors.accentGreen : Colors.orangeAccent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                metrics.isOptimized ? '✅' : '⚠️',
                style: const TextStyle(fontSize: 24),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics.isOptimized ? 'Performance: Optimized' : 'Performance: Could be improved',
                      style: AppTypography.bodyMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Response time: ${metrics.averageResponseTimeMs}ms | Frame rate: ${metrics.avgFrameRate.toStringAsFixed(1)} fps',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showOptimizations) ...[
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optimization Tips:',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '• Reduce particle effect count\n'
                    '• Lower animation complexity\n'
                    '• Disable sound if device is slow\n'
                    '• Close other apps for better performance',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build about section
  Widget _buildAboutSection() {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'English-Only Town',
            style: AppTypography.bodyMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'A conversational English learning game with NPC interactions, location exploration, and achievement tracking.',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Version: 1.0.0 (Phase 5)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Phase 5: Polish & Optimization\n'
            '• Dialogue caching for performance\n'
            '• NPC mood variations\n'
            '• Weather-based effects\n'
            '• Animated rewards & confetti\n'
            '• Engagement analytics',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
