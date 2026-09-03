import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/providers/npc_provider.dart';
import 'package:eigo/providers/npc_relationship_provider.dart';

/// NPC キャラクター表示ウィジェット
/// NPC の性格、気分、親密度などを表示
class NPCCharacterDisplayWidget extends ConsumerWidget {
  final String npcId;
  final bool showMood;
  final bool showRelationship;
  final bool showAvailability;

  const NPCCharacterDisplayWidget({
    Key? key,
    required this.npcId,
    this.showMood = true,
    this.showRelationship = true,
    this.showAvailability = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final npcAsync = ref.watch(npcByIdProvider(npcId));
    final relationshipAsync = ref.watch(npcRelationshipProvider(npcId));

    return npcAsync.when(
      data: (npc) {
        if (npc == null) {
          return Center(
            child: Text('NPC not found: $npcId'),
          );
        }

        return relationshipAsync.when(
          data: (relationship) {
            return _buildCharacterCard(
              context,
              npc,
              relationship,
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => Center(
            child: Text('Error loading relationship: $error'),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => Center(
        child: Text('Error loading NPC: $error'),
      ),
    );
  }

  /// キャラクターカードを構築
  Widget _buildCharacterCard(
    BuildContext context,
    NPCExtended npc,
    NPCRelationship? relationship,
  ) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー：名前と性格
            _buildHeader(npc),
            const Divider(height: 24),

            // 気分ステータス
            if (showMood) ...[
              _buildMoodDisplay(npc),
              const SizedBox(height: 12),
            ],

            // 親密度
            if (showRelationship && relationship != null) ...[
              _buildRelationshipDisplay(relationship),
              const SizedBox(height: 12),
            ],

            // 利用可能性
            if (showAvailability) ...[
              _buildAvailabilityDisplay(npc),
              const SizedBox(height: 12),
            ],

            // 性格特性
            _buildTraitsDisplay(npc),

            const SizedBox(height: 12),

            // 関心事
            _buildInterestsDisplay(npc),
          ],
        ),
      ),
    );
  }

  /// ヘッダーセクション
  Widget _buildHeader(NPCExtended npc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              npc.npcId,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              npc.personality.archetype,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        _buildPersonalityEmoji(npc),
      ],
    );
  }

  /// 性格絵文字
  Widget _buildPersonalityEmoji(NPCExtended npc) {
    const traitEmojis = {
      'friendly': '😊',
      'serious': '😐',
      'humorous': '😄',
      'analytical': '🤔',
      'adventurous': '🤩',
      'cautious': '😰',
    };

    final emoji = npc.personality.traits.isNotEmpty
        ? traitEmojis[npc.personality.traits.first] ?? '😊'
        : '😊';

    return Text(
      emoji,
      style: const TextStyle(fontSize: 40),
    );
  }

  /// 気分表示
  Widget _buildMoodDisplay(NPCExtended npc) {
    const moodEmojis = {
      'happy': '😊',
      'neutral': '😐',
      'tired': '😴',
      'excited': '🤩',
      'sad': '😢',
      'confused': '😕',
    };

    const moodColors = {
      'happy': Color(0xFFFFD700),
      'neutral': Color(0xFF808080),
      'tired': Color(0xFF4169E1),
      'excited': Color(0xFFFF6347),
      'sad': Color(0xFF6495ED),
      'confused': Color(0xFFFFB6C1),
    };

    final emoji = moodEmojis[npc.currentMoodState] ?? '😐';
    final color = moodColors[npc.currentMoodState] ?? Colors.grey;

    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Mood',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              npc.currentMoodState,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 親密度表示
  Widget _buildRelationshipDisplay(NPCRelationship relationship) {
    final affectionPercentage = relationship.affectionLevel / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Affection Level',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${relationship.affectionLevel}/100',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: affectionPercentage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getAffectionColor(relationship.affectionLevel),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.chat, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${relationship.conversationCount} conversations',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'Streak: ${relationship.currentStreak}/${relationship.maxStreak}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  /// 利用可能性表示
  Widget _buildAvailabilityDisplay(NPCExtended npc) {
    final isAvailable = npc.availabilitySchedule.isCurrentlyAvailable();

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isAvailable ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isAvailable ? 'Available now' : 'Not available',
          style: TextStyle(
            fontSize: 14,
            color: isAvailable ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 性格特性表示
  Widget _buildTraitsDisplay(NPCExtended npc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: npc.personality.traits.map((trait) {
        return Chip(
          label: Text(trait),
          backgroundColor: Colors.blue.shade100,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
          ),
        );
      }).toList(),
    );
  }

  /// 関心事表示
  Widget _buildInterestsDisplay(NPCExtended npc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: npc.personality.interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                interest,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 親密度レベルの色を取得
  Color _getAffectionColor(int affectionLevel) {
    if (affectionLevel >= 80) return Colors.red;
    if (affectionLevel >= 60) return Colors.orange;
    if (affectionLevel >= 40) return Colors.yellow;
    if (affectionLevel >= 20) return Colors.lightGreen;
    return Colors.grey;
  }

  /// ローディング状態
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// NPC キャラクター表示ウィジェット（コンパクト版）
class CompactNPCCharacterWidget extends ConsumerWidget {
  final String npcId;

  const CompactNPCCharacterWidget({
    Key? key,
    required this.npcId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final npcAsync = ref.watch(npcByIdProvider(npcId));

    return npcAsync.when(
      data: (npc) {
        if (npc == null) {
          return const SizedBox.shrink();
        }

        const moodEmojis = {
          'happy': '😊',
          'neutral': '😐',
          'tired': '😴',
          'excited': '🤩',
          'sad': '😢',
          'confused': '😕',
        };

        final emoji = moodEmojis[npc.currentMoodState] ?? '😐';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  npc.npcId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  npc.currentMoodState,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
