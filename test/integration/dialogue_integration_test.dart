import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/services/dialogue_engine_service.dart';
import 'package:eigo/services/response_validation_service.dart';
import 'package:eigo/services/response_scoring_service.dart';
import 'package:eigo/services/response_quality_evaluator_service.dart';

void main() {
  group('Dialogue Integration Tests', () {
    late DialogueEngineService dialogueEngine;
    late ResponseValidationService responseValidator;
    late ResponseScoringService responseScorer;
    late ResponseQualityEvaluatorService qualityEvaluator;

    setUp(() {
      dialogueEngine = DialogueEngineService.getInstance();
      responseValidator = ResponseValidationService.getInstance();
      responseScorer = ResponseScoringService.getInstance();
      qualityEvaluator = ResponseQualityEvaluatorService.getInstance();
    });

    group('Complete Dialogue Flow', () {
      test('should execute full dialogue pipeline correctly', () {
        // Setup
        final npc = NPCExtended(
          npcId: 'alice',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: ['helpful', 'humorous'],
            interests: ['cooking', 'reading'],
            preferredTopics: ['food', 'books'],
            avoidedTopics: ['violence'],
            speakingStyle: ['casual', 'warm'],
            biography: 'Alice is a friendly NPC who loves cooking.',
          ),
          currentMoodState: 'happy',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.5,
        );

        final templates = [
          DialogueTemplate(
            templateId: '1',
            npcId: 'alice',
            topic: 'cooking',
            difficulty: DialogueDifficulty.easy,
            conversationPhase: ConversationPhase.greeting,
            responseTemplates: [
              'Hi there! Welcome to my kitchen!',
            ],
            followUpQuestions: [
              'What\'s your favorite dish?',
            ],
            evaluationCriteria: ResponseEvaluationCriteria(
              keywordsMustInclude: ['food', 'cook'],
              keywordsToAvoid: ['violence'],
              minWordCount: 5,
              maxWordCount: 200,
            ),
          ),
        ];

        // Step 1: Engine selects best template
        final selectedTemplate = dialogueEngine.selectBestTemplate(
          templates: templates,
          npc: npc,
          userInput: 'I want to talk about cooking',
          currentPhase: ConversationPhase.greeting,
          preferredDifficulty: DialogueDifficulty.easy,
        );

        expect(selectedTemplate, isNotNull);
        expect(selectedTemplate!.topic, equals('cooking'));

        // Step 2: Validate response
        final userResponse = 'I love cooking Italian food at home!';
        final validationResults = responseValidator.validateResponse(
          response: userResponse,
          template: selectedTemplate,
          npc: npc,
        );

        expect(validationResults['isValid'], true);
        expect(validationResults['wordCount'], greaterThanOrEqualTo(5));

        // Step 3: Score response
        final score = responseScorer.scoreResponse(
          response: userResponse,
          validationResults: validationResults,
          npc: npc,
          userInput: 'I want to talk about cooking',
        );

        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));

        // Step 4: Evaluate quality
        final qualityScore = qualityEvaluator.evaluateResponseQuality(
          response: userResponse,
          template: selectedTemplate,
          npc: npc,
        );

        expect(qualityScore, greaterThanOrEqualTo(0.0));
        expect(qualityScore, lessThanOrEqualTo(1.0));

        // Step 5: Check if quality meets threshold
        final meetsThreshold = qualityEvaluator.meetsQualityThreshold(
          response: userResponse,
          template: selectedTemplate,
          npc: npc,
          threshold: 0.6,
        );

        expect(meetsThreshold, true);
      });

      test('should handle invalid responses correctly', () {
        final npc = NPCExtended(
          npcId: 'bob',
          personality: NPCPersonality(
            archetype: 'serious',
            traits: ['analytical'],
            interests: ['science'],
            preferredTopics: ['technology'],
            avoidedTopics: ['gossip'],
            speakingStyle: ['formal'],
            biography: 'Bob is serious and analytical.',
          ),
          currentMoodState: 'neutral',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.3,
        );

        final template = DialogueTemplate(
          templateId: '1',
          npcId: 'bob',
          topic: 'science',
          difficulty: DialogueDifficulty.intermediate,
          conversationPhase: ConversationPhase.main,
          responseTemplates: [],
          followUpQuestions: [],
          evaluationCriteria: ResponseEvaluationCriteria(
            keywordsMustInclude: ['science', 'research'],
            keywordsToAvoid: ['gossip'],
            minWordCount: 10,
            maxWordCount: 200,
          ),
        );

        // Too short response
        final tooShort = 'Yes.';
        final validationShort = responseValidator.validateResponse(
          response: tooShort,
          template: template,
          npc: npc,
        );

        expect(validationShort['isValid'], false);

        // Response with avoided topic
        const badResponse = 'I heard some gossip about the lab today';
        final validationBad = responseValidator.validateResponse(
          response: badResponse,
          template: template,
          npc: npc,
        );

        // Should identify issues
        expect(validationBad, isNotNull);
      });

      test('should continue conversation based on score', () {
        // Simulate a mid-conversation state
        final shouldContinue1 = dialogueEngine.shouldContinueConversation(
          turnCount: 3,
          currentScore: 70,
          currentPhase: ConversationPhase.main,
        );

        expect(shouldContinue1, true);

        // Too many turns
        final shouldContinue2 = dialogueEngine.shouldContinueConversation(
          turnCount: 15,
          currentScore: 50,
          currentPhase: ConversationPhase.main,
        );

        expect(shouldContinue2, false);

        // Low score in early phase
        final shouldContinue3 = dialogueEngine.shouldContinueConversation(
          turnCount: 2,
          currentScore: 30,
          currentPhase: ConversationPhase.greeting,
        );

        // Should still allow continuation to try improve
        expect(shouldContinue3, true);
      });

      test('should handle conversation phase transitions', () {
        final templates = [
          // Greeting templates
          DialogueTemplate(
            templateId: '1',
            npcId: 'npc',
            topic: 'greeting',
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
          // Main templates
          DialogueTemplate(
            templateId: '2',
            npcId: 'npc',
            topic: 'main',
            difficulty: DialogueDifficulty.intermediate,
            conversationPhase: ConversationPhase.main,
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

        // Filter templates by phase
        final greetingTemplates = dialogueEngine.filterTemplatesByPhase(
          templates,
          ConversationPhase.greeting,
        );

        expect(greetingTemplates.length, 1);
        expect(
          greetingTemplates.first.conversationPhase,
          ConversationPhase.greeting,
        );

        final mainTemplates = dialogueEngine.filterTemplatesByPhase(
          templates,
          ConversationPhase.main,
        );

        expect(mainTemplates.length, 1);
        expect(mainTemplates.first.conversationPhase, ConversationPhase.main);
      });
    });

    group('Response Quality Evaluation', () {
      test('should evaluate natural vs unnatural responses', () {
        final template = DialogueTemplate(
          templateId: '1',
          npcId: 'npc',
          topic: 'test',
          difficulty: DialogueDifficulty.easy,
          conversationPhase: ConversationPhase.main,
          responseTemplates: [],
          followUpQuestions: [],
          evaluationCriteria: ResponseEvaluationCriteria(
            keywordsMustInclude: [],
            keywordsToAvoid: [],
            minWordCount: 0,
            maxWordCount: 200,
          ),
        );

        final npc = NPCExtended(
          npcId: 'npc',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: [],
            interests: [],
            preferredTopics: [],
            avoidedTopics: [],
            speakingStyle: ['casual'],
            biography: '',
          ),
          currentMoodState: 'happy',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.0,
        );

        // Natural response
        const naturalResponse = 'Yeah, I totally agree with you on that!';
        final naturalScore =
            qualityEvaluator.evaluateResponseQuality(
          response: naturalResponse,
          template: template,
          npc: npc,
        );

        // Unnatural response
        const unnaturalResponse =
            'I shall hereby respond upon this matter with utmost formality.';
        final unnaturalScore =
            qualityEvaluator.evaluateResponseQuality(
          response: unnaturalResponse,
          template: template,
          npc: npc,
        );

        expect(naturalScore, greaterThan(unnaturalScore));
      });

      test('should evaluate grammar and punctuation', () {
        final template = DialogueTemplate(
          templateId: '1',
          npcId: 'npc',
          topic: 'test',
          difficulty: DialogueDifficulty.easy,
          conversationPhase: ConversationPhase.main,
          responseTemplates: [],
          followUpQuestions: [],
          evaluationCriteria: ResponseEvaluationCriteria(
            keywordsMustInclude: [],
            keywordsToAvoid: [],
            minWordCount: 0,
            maxWordCount: 200,
          ),
        );

        final npc = NPCExtended(
          npcId: 'npc',
          personality: NPCPersonality(
            archetype: 'friendly',
            traits: [],
            interests: [],
            preferredTopics: [],
            avoidedTopics: [],
            speakingStyle: [],
            biography: '',
          ),
          currentMoodState: 'happy',
          availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
          lastInteractionTime: DateTime.now(),
          learningProgress: 0.0,
        );

        // Good grammar
        const goodGrammar = 'This is a well-written response with proper grammar.';
        final goodScore =
            qualityEvaluator.evaluateResponseQuality(
          response: goodGrammar,
          template: template,
          npc: npc,
        );

        // Poor grammar
        const poorGrammar = 'this response no proper grammar and punctuation';
        final poorScore =
            qualityEvaluator.evaluateResponseQuality(
          response: poorGrammar,
          template: template,
          npc: npc,
        );

        expect(goodScore, greaterThan(poorScore));
      });
    });

    group('Scoring Distribution', () {
      test('should calculate score statistics', () {
        final scores = <int>[
          85, 90, 78, 82, 88, 75, 92, 80, 86, 79,
        ];

        // Calculate mean
        final mean = scores.reduce((a, b) => a + b) ~/ scores.length;
        expect(mean, isNotNull);
        expect(mean, greaterThan(0);
        expect(mean, lessThanOrEqualTo(100);

        // Verify distribution characteristics
        final highScores = scores.where((s) => s >= 85).length;
        expect(highScores, greaterThan(0));
      });
    });
  });
}
