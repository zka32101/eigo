import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/services/dialogue_engine_service.dart';

void main() {
  group('DialogueEngineService', () {
    late DialogueEngineService service;

    setUp(() {
      service = DialogueEngineService.getInstance();
    });

    group('selectBestTemplate', () {
      test('should return highest scored template', () {
        // Create test NPC
        final npc = NPCExtended(
          npcId: 'test-npc',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: ['humorous', 'helpful'],
            interests: ['cooking', 'travel'],
            preferredTopics: ['food', 'adventure'],
            avoidedTopics: ['violence'],
            speakingStyle: ['casual'],
            biography: 'A friendly NPC',
          ),
          currentMoodState: 'happy',
          availabilitySchedule: NPCAvailabilitySchedule(
            timeSlots: [],
          ),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.5,
        );

        // Create test templates
        final templates = [
          DialogueTemplate(
            templateId: '1',
            npcId: 'test-npc',
            topic: 'cooking',
            difficulty: DialogueDifficulty.easy,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: ['Hello!'],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 5,
              maxWordCount: 100,
            ),
          ),
          DialogueTemplate(
            templateId: '2',
            npcId: 'test-npc',
            topic: 'travel',
            difficulty: DialogueDifficulty.intermediate,
            conversationPhase: ConversationPhase.main,
            responseTemplates: ['Tell me about travel'],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 10,
              maxWordCount: 200,
            ),
          ),
        ];

        final selected = service.selectBestTemplate(
          templates: templates,
          npc: npc,
          userInput: 'I love cooking and travel',
          currentPhase: ConversationPhase.greeting,
          preferredDifficulty: DialogueDifficulty.easy,
        );

        expect(selected, isNotNull);
        expect(templates.contains(selected), true);
      });

      test('should return null for empty template list', () {
        final npc = NPCExtended(
          npcId: 'test-npc',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: [],
            interests: [],
            preferredTopics: [],
            avoidedTopics: [],
            speakingStyle: [],
            biography: '',
          ),
          currentMoodState: 'neutral',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.0,
        );

        final selected = service.selectBestTemplate(
          templates: [],
          npc: npc,
          userInput: 'test',
          currentPhase: ConversationPhase.greeting,
          preferredDifficulty: DialogueDifficulty.easy,
        );

        expect(selected, isNull);
      });
    });

    group('shouldContinueConversation', () {
      test('should return true for valid conversation state', () {
        final result = service.shouldContinueConversation(
          turnCount: 3,
          currentScore: 75,
          currentPhase: ConversationPhase.main,
        );

        expect(result, true);
      });

      test('should return false when turn count exceeds maximum', () {
        final result = service.shouldContinueConversation(
          turnCount: 15,
          currentScore: 50,
          currentPhase: ConversationPhase.main,
        );

        expect(result, false);
      });

      test('should transition to closing phase appropriately', () {
        final result = service.shouldContinueConversation(
          turnCount: 8,
          currentScore: 60,
          currentPhase: ConversationPhase.climax,
        );

        // Should continue to allow transition to resolution/closing
        expect(result, true);
      });
    });

    group('filterTemplatesByDifficulty', () {
      test('should return templates matching difficulty', () {
        final templates = [
          DialogueTemplate(
            templateId: '1',
            npcId: 'test-npc',
            topic: 'test',
            difficulty: DialogueDifficulty.easy,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: [],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 0,
              maxWordCount: 100,
            ),
          ),
          DialogueTemplate(
            templateId: '2',
            npcId: 'test-npc',
            topic: 'test',
            difficulty: DialogueDifficulty.intermediate,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: [],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 0,
              maxWordCount: 200,
            ),
          ),
        ];

        final filtered = service.filterTemplatesByDifficulty(
          templates,
          DialogueDifficulty.easy,
        );

        expect(filtered.length, 1);
        expect(filtered.first.difficulty, DialogueDifficulty.easy);
      });

      test('should return empty list for non-matching difficulty', () {
        final templates = [
          DialogueTemplate(
            templateId: '1',
            npcId: 'test-npc',
            topic: 'test',
            difficulty: DialogueDifficulty.advanced,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: [],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 0,
              maxWordCount: 100,
            ),
          ),
        ];

        final filtered = service.filterTemplatesByDifficulty(
          templates,
          DialogueDifficulty.easy,
        );

        expect(filtered.isEmpty, true);
      });
    });

    group('filterTemplatesByPhase', () {
      test('should return templates matching phase', () {
        final templates = [
          DialogueTemplate(
            templateId: '1',
            npcId: 'test-npc',
            topic: 'test',
            difficulty: DialogueDifficulty.easy,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: [],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 0,
              maxWordCount: 100,
            ),
          ),
          DialogueTemplate(
            templateId: '2',
            npcId: 'test-npc',
            topic: 'test',
            difficulty: DialogueDifficulty.easy,
            conversationPhase: ConversationPhase.main,
            responseTemplates: [],
            followUpQuestions: [],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: [],
              keywordsToAvoid: [],
              minWordCount: 0,
              maxWordCount: 100,
            ),
          ),
        ];

        final filtered = service.filterTemplatesByPhase(
          templates,
          ConversationPhase.greeting,
        );

        expect(filtered.length, 1);
        expect(filtered.first.conversationPhase, ConversationPhase.greeting);
      });
    });
  });
}
