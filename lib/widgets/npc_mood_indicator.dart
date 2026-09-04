import 'package:flutter/material.dart';
import 'package:eigo/models/npc_behavior_model.dart';

/// NPC ムード指標ウィジェット
class NPCMoodIndicator extends StatelessWidget {
  final NPCMood mood;

  const NPCMoodIndicator({
    required this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMoodEmoji(),
        const SizedBox(width: 8),
        Text(
          _getMoodLabel(),
          style: TextStyle(
            fontSize: 12,
            color: _getMoodColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodEmoji() {
    switch (mood) {
      case NPCMood.happy:
        return const Text('😊', style: TextStyle(fontSize: 16));
      case NPCMood.sad:
        return const Text('😢', style: TextStyle(fontSize: 16));
      case NPCMood.angry:
        return const Text('😠', style: TextStyle(fontSize: 16));
      case NPCMood.neutral:
        return const Text('😐', style: TextStyle(fontSize: 16));
      case NPCMood.excited:
        return const Text('🤩', style: TextStyle(fontSize: 16));
      case NPCMood.tired:
        return const Text('😴', style: TextStyle(fontSize: 16));
    }
  }

  String _getMoodLabel() {
    switch (mood) {
      case NPCMood.happy:
        return 'Happy';
      case NPCMood.sad:
        return 'Sad';
      case NPCMood.angry:
        return 'Angry';
      case NPCMood.neutral:
        return 'Neutral';
      case NPCMood.excited:
        return 'Excited';
      case NPCMood.tired:
        return 'Tired';
    }
  }

  Color _getMoodColor() {
    switch (mood) {
      case NPCMood.happy:
      case NPCMood.excited:
        return Colors.green;
      case NPCMood.sad:
        return Colors.blue;
      case NPCMood.angry:
        return Colors.red;
      case NPCMood.neutral:
        return Colors.grey;
      case NPCMood.tired:
        return Colors.orange;
    }
  }
}
