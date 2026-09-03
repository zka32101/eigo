import 'package:flutter/material.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/design_system/design_system.dart';

/// ロケーション詳細カード
class LocationCardWidget extends StatelessWidget {
  final Location location;
  final List<NPC> npcsAtLocation;
  final VoidCallback onEnterLocation;
  final bool isUnlocked;

  const LocationCardWidget({
    Key? key,
    required this.location,
    required this.npcsAtLocation,
    required this.onEnterLocation,
    required this.isUnlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: AppSpacing.allPaddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー: エモジと名前
            _buildHeader(),
            SizedBox(height: AppSpacing.spacingMd),

            // 説明
            _buildDescription(),
            SizedBox(height: AppSpacing.spacingMd),

            // 難易度インジケーター
            _buildDifficultyIndicator(),
            SizedBox(height: AppSpacing.spacingMd),

            // NPC一覧
            if (npcsAtLocation.isNotEmpty) ...[
              _buildNPCList(),
              SizedBox(height: AppSpacing.spacingMd),
            ],

            // 統計情報
            _buildStats(),
            SizedBox(height: AppSpacing.spacingLg),

            // アクションボタン
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  /// ヘッダー（エモジと名前）を構築
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          location.emoji,
          style: const TextStyle(fontSize: 40),
        ),
        SizedBox(width: AppSpacing.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location.name,
                style: AppTypography.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              if (location.surroundingArea != null)
                Text(
                  location.surroundingArea!,
                  style: AppTypography.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ) ?? const TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 説明を構築
  Widget _buildDescription() {
    return Text(
      location.description,
      style: AppTypography.bodyMedium?.copyWith(
        height: 1.5,
      ) ?? const TextStyle(fontSize: 14, height: 1.5),
    );
  }

  /// 難易度インジケーターを構築
  Widget _buildDifficultyIndicator() {
    final difficultyLabel = _getDifficultyLabel(location.difficultyLevel);
    final difficultyColor = _getDifficultyColor(location.difficultyLevel);

    return Row(
      children: [
        Text(
          'Difficulty: ',
          style: AppTypography.labelMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: difficultyColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: difficultyColor),
          ),
          child: Text(
            difficultyLabel,
            style: TextStyle(
              color: difficultyColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// NPC一覧を構築
  Widget _buildNPCList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NPCs (${npcsAtLocation.length})',
          style: AppTypography.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ) ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: AppSpacing.spacingXs),
        Wrap(
          spacing: AppSpacing.spacingXs,
          runSpacing: AppSpacing.spacingXs,
          children: npcsAtLocation.map((npc) {
            return Chip(
              label: Text('${npc.emoji} ${npc.name}'),
              backgroundColor: AppColors.accentGreen.withOpacity(0.1),
              labelStyle: const TextStyle(fontSize: 12),
              side: BorderSide(
                color: AppColors.accentGreen,
                width: 0.5,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 統計情報を構築
  Widget _buildStats() {
    return Container(
      padding: AppSpacing.allPaddingSm,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: '🎯',
            label: 'Scenes',
            value: '${location.sceneIds.length}',
          ),
          _buildStatItem(
            icon: '👥',
            label: 'NPCs',
            value: '${location.npcIds.length}',
          ),
          _buildStatItem(
            icon: '⭐',
            label: 'Difficulty',
            value: '${location.difficultyLevel}/5',
          ),
        ],
      ),
    );
  }

  /// 統計項目を構築
  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        SizedBox(height: AppSpacing.spacingXs),
        Text(
          label,
          style: AppTypography.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ) ?? const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        Text(
          value,
          style: AppTypography.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ) ?? const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  /// アクションボタンを構築
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isUnlocked ? onEnterLocation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isUnlocked ? AppColors.accentGreen : Colors.grey,
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isUnlocked ? 'Enter Location' : 'Locked',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 難易度レベルに基づいて難易度ラベルを取得
  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      case 4:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  /// 難易度レベルに基づいて色を取得
  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
