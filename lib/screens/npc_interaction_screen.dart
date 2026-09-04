import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/providers/npc_provider.dart';
import 'package:eigo/providers/npc_relationship_provider.dart';
import 'package:eigo/screens/npc_dialogue_screen.dart';
import 'package:eigo/widgets/npc_character_display_widget.dart';

/// NPC Interaction Screen
/// Shows list of NPCs available for dialogue interactions
class NPCInteractionScreen extends ConsumerWidget {
  final String? title;
  final bool showOnlyAvailable;

  const NPCInteractionScreen({
    Key? key,
    this.title = 'NPCs',
    this.showOnlyAvailable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final npcsAsync = ref.watch(npcsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'NPCs'),
        elevation: 0,
      ),
      body: npcsAsync.when(
        data: (npcs) {
          if (npcs.isEmpty) {
            return Center(
              child: Text(
                'No NPCs available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          // Filter by availability if requested
          final filteredNpcs = showOnlyAvailable
              ? npcs
                  .where(
                    (npc) => npc.availabilitySchedule.isCurrentlyAvailable(),
                  )
                  .toList()
              : npcs;

          if (filteredNpcs.isEmpty) {
            return Center(
              child: Text(
                'No NPCs currently available',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredNpcs.length,
            itemBuilder: (context, index) {
              final npc = filteredNpcs[index];
              return _buildNPCCard(context, npc);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading NPCs: $error'),
        ),
      ),
    );
  }

  /// Build NPC interaction card
  Widget _buildNPCCard(BuildContext context, dynamic npc) {
    return GestureDetector(
      onTap: () => _startDialogue(context, npc.npcId),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NPC Header with mood
              Row(
                children: [
                  _buildMoodEmoji(npc.currentMoodState),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          npc.npcId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          npc.personality.archetype,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAvailabilityBadge(npc.availabilitySchedule),
                ],
              ),
              const SizedBox(height: 12),

              // Interests
              Wrap(
                spacing: 6,
                children:
                    npc.personality.interests.take(3).map((interest) {
                  return Chip(
                    label: Text(
                      interest,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide(color: Colors.blue.shade200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _startDialogue(context, npc.npcId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Start Conversation',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build mood emoji indicator
  Widget _buildMoodEmoji(String mood) {
    const moodEmojis = {
      'happy': '😊',
      'neutral': '😐',
      'tired': '😴',
      'excited': '🤩',
      'sad': '😢',
      'confused': '😕',
    };

    final emoji = moodEmojis[mood] ?? '😐';
    return Text(emoji, style: const TextStyle(fontSize: 32));
  }

  /// Build availability badge
  Widget _buildAvailabilityBadge(dynamic availability) {
    final isAvailable = availability.isCurrentlyAvailable();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isAvailable ? 'Available' : 'Busy',
        style: TextStyle(
          fontSize: 11,
          color: isAvailable ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Start dialogue with NPC
  void _startDialogue(BuildContext context, String npcId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NPCDialogueScreen(npcId: npcId),
      ),
    );
  }
}

/// Quick NPC Interaction Button
/// Compact button for accessing NPC interactions from other screens
class QuickNPCInteractionButton extends ConsumerWidget {
  final String? label;
  final VoidCallback? onPressed;

  const QuickNPCInteractionButton({
    Key? key,
    this.label = 'Talk to NPCs',
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final npcsAsync = ref.watch(npcsProvider);

    return npcsAsync.when(
      data: (npcs) {
        final availableCount = npcs
            .where((npc) => npc.availabilitySchedule.isCurrentlyAvailable())
            .length;

        return FloatingActionButton.extended(
          onPressed: onPressed ??
              () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const NPCInteractionScreen(
                            showOnlyAvailable: true,
                          ),
                    ),
                  ),
          icon: const Icon(Icons.people),
          label: Text('$label ($availableCount)'),
          backgroundColor: Colors.blue,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

/// NPC Dialogue History Screen
/// Shows past interactions with NPCs
class NPCDialogueHistoryScreen extends ConsumerWidget {
  const NPCDialogueHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Conversation history features coming soon',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
