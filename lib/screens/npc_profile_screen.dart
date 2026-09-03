import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/providers/npc_behavior_provider.dart';
import 'package:eigo/widgets/npc_mood_indicator.dart';

/// NPC プロフィールスクリーン（性格と行動表示）
class NPCProfileScreen extends ConsumerWidget {
  final String npcId;
  final String npcName;
  final String npcAvatarPath;

  const NPCProfileScreen({
    required this.npcId,
    required this.npcName,
    required this.npcAvatarPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final behaviorAsync = ref.watch(npcBehaviorStateProvider(npcId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$npcName\'s Profile'),
        centerTitle: true,
      ),
      body: behaviorAsync.when(
        data: (behavior) => _buildProfileContent(context, behavior),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    NPCBehaviorState behavior,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          _buildProfileHeader(behavior),
          const SizedBox(height: 32),

          // 基本情報
          _buildBasicInfo(behavior),
          const SizedBox(height: 24),

          // 性格特性（Big Five）
          _buildPersonalityTraits(behavior),
          const SizedBox(height: 24),

          // 現在の状態
          _buildCurrentState(behavior),
          const SizedBox(height: 24),

          // 相互作用統計
          _buildInteractionStats(behavior),
          const SizedBox(height: 24),

          // 習慣と好み
          _buildHabitsAndPreferences(behavior),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(NPCBehaviorState behavior) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // アバター
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(npcAvatarPath),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 16),

          // 名前
          Text(
            npcName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // 性格タイプ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              behavior.personalityTraits.getPrimaryType().english,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ムード
          NPCMoodIndicator(mood: behavior.currentMood),
          const SizedBox(height: 12),

          // 親密度ゲージ
          _buildAffectionBar(behavior.currentAffection),
        ],
      ),
    );
  }

  Widget _buildAffectionBar(int affection) {
    final percentage = (affection / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Affection',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              '$affection / 100',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.7
                  ? Colors.red
                  : percentage > 0.4
                      ? Colors.orange
                      : Colors.grey[400]!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(NPCBehaviorState behavior) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Personality Type', behavior.personalityTraits.getPrimaryType().english),
        _buildInfoRow('Current Mood', behavior.currentMood.english),
        _buildInfoRow('Affection Level', '${behavior.currentAffection} / 100'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityTraits(NPCBehaviorState behavior) {
    final traits = behavior.personalityTraits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personality Traits (Big Five)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildTraitBar('Openness', traits.openness),
        _buildTraitBar('Conscientiousness', traits.conscientiousness),
        _buildTraitBar('Extraversion', traits.extraversion),
        _buildTraitBar('Agreeableness', traits.agreeableness),
        _buildTraitBar('Neuroticism', traits.neuroticism),
      ],
    );
  }

  Widget _buildTraitBar(String name, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$value / 100',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentState(NPCBehaviorState behavior) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current State',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStateRow('Current Mood', behavior.currentMood.english),
              const SizedBox(height: 8),
              _buildStateRow('Affection', '${behavior.currentAffection}'),
              const SizedBox(height: 8),
              _buildStateRow(
                'Recent Interactions',
                '${behavior.memorizedInteractions.length}',
              ),
              const SizedBox(height: 8),
              _buildStateRow(
                'Executed Behaviors',
                '${behavior.executedBehaviors.length}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionStats(NPCBehaviorState behavior) {
    final interactionCount = behavior.memorizedInteractions.length;
    final averageValue = interactionCount > 0
        ? (behavior.memorizedInteractions
                .fold<int>(0, (sum, i) => sum + i.interactionValue) /
            interactionCount)
            .toInt()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interaction Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Interactions',
                '$interactionCount',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Average Value',
                '$averageValue',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsAndPreferences(NPCBehaviorState behavior) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habits & Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (behavior.habits.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Habits',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...behavior.habits.map((habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Chip(
                    label: Text(
                      '${habit.habitName} (${habit.frequency.english})',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                );
              }).toList(),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No habits recorded yet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
