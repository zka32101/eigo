import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/providers/dialogue_context_provider.dart';
import 'package:eigo/providers/npc_provider.dart';
import 'package:eigo/providers/dialogue_template_provider.dart';
import 'package:eigo/services/dialogue_engine_service.dart';
import 'package:eigo/services/response_validation_service.dart';
import 'package:eigo/services/response_scoring_service.dart';
import 'package:eigo/services/response_quality_evaluator_service.dart';
import 'package:eigo/widgets/npc_character_display_widget.dart';
import 'package:eigo/widgets/conversation_dialogue_box_widget.dart';
import 'package:eigo/widgets/dialogue_input_interface_widget.dart';
import 'package:eigo/widgets/interaction_result_widget.dart';

/// NPC Dialogue Screen
/// Full-screen dialogue interaction with an NPC in the game world
class NPCDialogueScreen extends ConsumerStatefulWidget {
  final String npcId;
  final String? initialTopic;
  final VoidCallback? onDialogueComplete;

  const NPCDialogueScreen({
    Key? key,
    required this.npcId,
    this.initialTopic,
    this.onDialogueComplete,
  }) : super(key: key);

  @override
  ConsumerState<NPCDialogueScreen> createState() =>
      _NPCDialogueScreenState();
}

class _NPCDialogueScreenState extends ConsumerState<NPCDialogueScreen> {
  late ScrollController _scrollController;
  bool _showingResult = false;
  int? _lastScore;
  int? _lastXpEarned;
  int? _lastCoinsEarned;
  String? _lastFeedback;
  Map<String, double>? _lastQualityBreakdown;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final npcAsync = ref.watch(npcByIdProvider(widget.npcId));
    final dialogueContext = ref.watch(dialogueContextProvider);
    final templates = ref.watch(
      dialogueTemplatesByNpcProvider(widget.npcId),
    );

    return npcAsync.when(
      data: (npc) {
        if (npc == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('NPC Not Found')),
            body: Center(
              child: Text('NPC ${widget.npcId} not found'),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(npc),
          body: _showingResult
              ? _buildResultView()
              : _buildDialogueView(context, npc, templates),
          backgroundColor: Colors.grey.shade50,
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  /// Build app bar with NPC info
  PreferredSizeWidget _buildAppBar(NPCExtended npc) {
    return AppBar(
      title: Text(npc.npcId),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// Build main dialogue view
  Widget _buildDialogueView(
    BuildContext context,
    NPCExtended npc,
    AsyncValue<List<DialogueTemplate>> templates,
  ) {
    return Column(
      children: [
        // NPC Character Display
        CompactNPCCharacterWidget(npcId: widget.npcId),
        const Divider(height: 1),

        // Dialogue History
        Expanded(
          child: templates.when(
            data: (templateList) {
              return ConversationDialogueBoxWidget(
                npcName: npc.npcId,
                scrollController: _scrollController,
                showTimestamps: true,
                showTranslations: false,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error loading templates: $error'),
            ),
          ),
        ),

        // Input Interface
        DialogueInputInterfaceWidget(
          onSubmit: (input) => _handleUserInput(context, npc, input),
          minCharacters: 2,
          maxCharacters: 500,
          showCharacterCount: true,
          enableVoiceInput: false,
        ),
      ],
    );
  }

  /// Build result view
  Widget _buildResultView() {
    return InteractionResultWidget(
      score: _lastScore ?? 0,
      xpEarned: _lastXpEarned ?? 0,
      coinsEarned: _lastCoinsEarned ?? 0,
      feedback: _lastFeedback ?? 'Interaction complete!',
      qualityBreakdown: _lastQualityBreakdown ?? {},
      nextSuggestion: 'Continue the conversation or explore the town.',
      onClose: _handleResultClose,
    );
  }

  /// Handle user input submission
  Future<void> _handleUserInput(
    BuildContext context,
    NPCExtended npc,
    String userInput,
  ) async {
    try {
      // Update dialogue context with player input
      ref.read(dialogueContextProvider.notifier).setPlayerInput(userInput);

      // Validate response
      final templates = await ref.read(
        dialogueTemplatesByNpcProvider(widget.npcId).future,
      );

      if (templates.isEmpty) {
        _showErrorDialog(context, 'No dialogue templates available');
        return;
      }

      // Select best template
      final dialogueEngine = DialogueEngineService.getInstance();
      final selectedTemplate = dialogueEngine.selectBestTemplate(
        templates: templates,
        npc: npc,
        userInput: userInput,
        currentPhase: ConversationPhase.main,
        preferredDifficulty: DialogueDifficulty.intermediate,
      );

      if (selectedTemplate == null) {
        _showErrorDialog(context, 'Could not select dialogue template');
        return;
      }

      // Validate user response
      final validator = ResponseValidationService.getInstance();
      final validationResults = validator.validateResponse(
        response: userInput,
        template: selectedTemplate,
        npc: npc,
      );

      // Score response
      final scorer = ResponseScoringService.getInstance();
      final score = scorer.scoreResponse(
        response: userInput,
        validationResults: validationResults,
        npc: npc,
        userInput: userInput,
      );

      // Evaluate quality
      final evaluator = ResponseQualityEvaluatorService.getInstance();
      final qualityScore = evaluator.evaluateResponseQuality(
        response: userInput,
        template: selectedTemplate,
        npc: npc,
      );

      // Generate feedback
      final feedback = scorer.generateFeedback(
        score: score,
        response: userInput,
        validationResults: validationResults,
        npc: npc,
      );

      // Build quality breakdown
      final qualityBreakdown = <String, double>{
        'Relevance': evaluator._evaluateRelevance(userInput, selectedTemplate, npc),
        'Naturalness': evaluator._evaluateNaturalness(userInput),
        'Grammar': evaluator._evaluateGrammar(userInput),
        'Topic Alignment':
            evaluator._evaluateTopicAlignment(userInput, selectedTemplate),
        'Character Consistency':
            evaluator._evaluateCharacterConsistency(userInput, npc),
      };

      // Calculate rewards (placeholder)
      final xpEarned = (score ~/ 10) + 10;
      final coinsEarned = (score ~/ 20) + 5;

      // Display results
      _lastScore = score;
      _lastXpEarned = xpEarned;
      _lastCoinsEarned = coinsEarned;
      _lastFeedback = feedback;
      _lastQualityBreakdown = qualityBreakdown;

      setState(() {
        _showingResult = true;
      });

      // Scroll to bottom
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      _showErrorDialog(context, 'Error processing response: $e');
    }
  }

  /// Handle result close
  void _handleResultClose() {
    setState(() {
      _showingResult = false;
      _lastScore = null;
      _lastXpEarned = null;
      _lastCoinsEarned = null;
      _lastFeedback = null;
      _lastQualityBreakdown = null;
    });
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// NPC Dialogue Modal
/// Compact modal for quick NPC interactions
class NPCDialogueModal extends ConsumerWidget {
  final String npcId;
  final VoidCallback? onComplete;

  const NPCDialogueModal({
    Key? key,
    required this.npcId,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: NPCDialogueScreen(
        npcId: npcId,
        onDialogueComplete: onComplete ?? () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Helper function to show NPC dialogue modal
Future<void> showNPCDialogueModal(
  BuildContext context, {
  required String npcId,
  VoidCallback? onComplete,
}) async {
  return showDialog(
    context: context,
    builder: (context) => NPCDialogueModal(
      npcId: npcId,
      onComplete: onComplete,
    ),
  );
}
