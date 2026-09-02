import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/english_town_model.dart';
import '../providers/english_town_provider.dart';
import '../design_system/design_system.dart';

/// English-Only Town Conversation Screen
///
/// Displays interactive conversation with an NPC in the town.
/// Features:
/// - NPC dialogue display with character info
/// - Player input (text/speech-to-text)
/// - Response evaluation and scoring
/// - Conversation history
/// - Rewards display
class EnglishTownConversationScreen extends ConsumerStatefulWidget {
  final String npcId;
  final String locationId;
  final String sceneId;

  const EnglishTownConversationScreen({
    Key? key,
    required this.npcId,
    required this.locationId,
    required this.sceneId,
  }) : super(key: key);

  @override
  ConsumerState<EnglishTownConversationScreen> createState() =>
      _EnglishTownConversationScreenState();
}

class _EnglishTownConversationScreenState
    extends ConsumerState<EnglishTownConversationScreen> {
  late TextEditingController _inputController;
  bool _isLoading = false;
  String? _currentFeedback;
  int? _currentScore;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get NPC and location data
    final townMap = ref.watch(townMapProvider);
    final npc = townMap.getNPC(widget.npcId);
    final location = townMap.getLocation(widget.locationId);
    final currentConversation = ref.watch(currentConversationProvider);
    final progress = ref.watch(townProgressProvider);
    final timeOfDay = progress.currentTimeOfDay;
    final difficulty = ConversationDifficulty.medium; // TODO: Determine from player level

    if (npc == null || location == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('NPC or location not found')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(npc, location),
      body: Column(
        children: [
          // Conversation history
          Expanded(
            child: _buildConversationHistory(currentConversation),
          ),

          // Current NPC response and feedback area
          if (_isLoading)
            Padding(
              padding: AppSpacing.allPaddingMd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  const Text('Listening...'),
                ],
              ),
            )
          else if (_currentFeedback != null)
            _buildFeedbackArea(_currentScore),

          // Player input area
          _buildInputArea(npc, location, timeOfDay, difficulty),
        ],
      ),
    );
  }

  /// Build AppBar with NPC and location info
  PreferredSizeWidget _buildAppBar(NPC npc, Location location) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${npc.emoji} ${npc.name}',
            style: AppTypography.titleSmall,
          ),
          Text(
            location.name,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: npc.characterColor.withOpacity(0.1),
      titleSpacing: AppSpacing.md,
    );
  }

  /// Build conversation history display
  Widget _buildConversationHistory(CurrentConversationState conversation) {
    if (conversation.conversationHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.allPaddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline, size: 48),
              SizedBox(height: AppSpacing.md),
              const Text(
                'Start your conversation...',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.allPaddingMd,
      itemCount: conversation.conversationHistory.length,
      itemBuilder: (context, index) {
        final turn = conversation.conversationHistory[index];
        final isNPC = turn.speaker.toLowerCase() == 'npc';

        return _buildDialogueBubble(
          message: turn.message,
          isNPC: isNPC,
          correctness: turn.expectedCorrectness,
          feedback: turn.feedback,
        );
      },
    );
  }

  /// Build individual dialogue bubble
  Widget _buildDialogueBubble({
    required String message,
    required bool isNPC,
    int? correctness,
    String? feedback,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isNPC ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: isNPC ? 0 : AppSpacing.lg * 3,
              right: isNPC ? AppSpacing.lg * 3 : 0,
            ),
            padding: AppSpacing.allPaddingMd,
            decoration: BoxDecoration(
              color: isNPC
                  ? AppColors.surfaceLight
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.borderRadius),
                topRight: Radius.circular(AppSizes.borderRadius),
                bottomLeft: isNPC
                    ? Radius.zero
                    : Radius.circular(AppSizes.borderRadius),
                bottomRight: isNPC
                    ? Radius.circular(AppSizes.borderRadius)
                    : Radius.zero,
              ),
              border: Border.all(
                color: isNPC ? AppColors.border : AppColors.primary,
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: AppTypography.bodyMedium,
            ),
          ),
          if (correctness != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.sm,
                left: isNPC ? 0 : AppSpacing.lg,
                right: isNPC ? AppSpacing.lg : 0,
              ),
              child: Row(
                mainAxisAlignment:
                    isNPC ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  Text(
                    'Score: $correctness%',
                    style: AppTypography.labelSmall.copyWith(
                      color: correctness >= 70
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          if (feedback != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.sm,
                left: isNPC ? 0 : AppSpacing.lg,
                right: isNPC ? AppSpacing.lg : 0,
              ),
              child: Text(
                feedback,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build feedback area showing evaluation results
  Widget _buildFeedbackArea(int? score) {
    final scoreColor = score == null
        ? AppColors.warning
        : score >= 70
            ? AppColors.success
            : score >= 50
                ? AppColors.warning
                : AppColors.error;

    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        border: Border(top: BorderSide(color: scoreColor, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feedback',
                style: AppTypography.labelLarge.copyWith(
                  color: scoreColor,
                ),
              ),
              if (score != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadius / 2),
                  ),
                  child: Text(
                    '$score%',
                    style: AppTypography.labelSmall.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (_currentFeedback != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                _currentFeedback!,
                style: AppTypography.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  /// Build player input area with text input and send button
  Widget _buildInputArea(
    NPC npc,
    Location location,
    TimeOfDay timeOfDay,
    ConversationDifficulty difficulty,
  ) {
    return Container(
      padding: AppSpacing.allPaddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Type your response...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _buildSendButton(npc, location, timeOfDay, difficulty),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Difficulty: ${difficulty.name.capitalize()}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build send button with loading state
  Widget _buildSendButton(
    NPC npc,
    Location location,
    TimeOfDay timeOfDay,
    ConversationDifficulty difficulty,
  ) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _sendMessage(npc, location, timeOfDay, difficulty),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send),
    );
  }

  /// Send player message and get NPC response
  void _sendMessage(
    NPC npc,
    Location location,
    TimeOfDay timeOfDay,
    ConversationDifficulty difficulty,
  ) async {
    if (_inputController.text.trim().isEmpty) {
      return;
    }

    final playerMessage = _inputController.text.trim();
    _inputController.clear();

    setState(() {
      _isLoading = true;
      _currentFeedback = null;
      _currentScore = null;
    });

    // Add player message to conversation
    final currentConversation = ref.read(currentConversationProvider);
    final playerTurn = ConversationTurn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      speaker: 'PLAYER',
      message: playerMessage,
    );

    ref.read(currentConversationProvider.notifier).addTurn(playerTurn);

    // TODO: In Phase 3, integrate actual Claude API service here
    // For now, using placeholder logic

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Add NPC response
    final npcTurn = ConversationTurn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      speaker: 'NPC',
      message: "That's wonderful! Tell me more about that.",
    );

    ref.read(currentConversationProvider.notifier).addTurn(npcTurn);

    // Simulate evaluation
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
      _currentScore = 75;
      _currentFeedback = "Great response! You used good grammar and vocabulary.";
    });

    // Record progress
    ref.read(townProgressProvider.notifier).recordNPCConversation(
      npc.id,
      100, // xpReward
      50, // coinReward
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
