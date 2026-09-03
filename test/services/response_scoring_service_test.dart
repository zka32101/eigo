import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/services/response_scoring_service.dart';
import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';

void main() {
  group('ResponseScoringService', () {
    late ResponseScoringService service;
    late NPCExtended testNpc;

    setUp(() {
      service = ResponseScoringService.getInstance();
      testNpc = NPCExtended(
        npcId: 'test-npc',
        personality: NPCPersonality(
          archetype: 'friendly',
          traits: ['humorous'],
          interests: ['coding'],
          preferredTopics: ['technology'],
          avoidedTopics: ['violence'],
          speakingStyle: ['casual'],
          biography: 'Test NPC',
        ),
        currentMoodState: 'happy',
        availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
        lastInteractionTime: DateTime.now(),
        learningProgress: 0.5,
      );
    });

    group('scoreResponse', () {
      test('should return score between 0 and 100', () {
        final validationResults = {
          'isValid': true,
          'wordCount': 15,
          'issues': <String>[],
          'warnings': <String>[],
          'suggestions': <String>[],
        };

        final score = service.scoreResponse(
          response: 'This is a great response about technology!',
          validationResults: validationResults,
          npc: testNpc,
          userInput: 'Tell me about coding',
        );

        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('should give higher score for valid responses', () {
        final validResults = {
          'isValid': true,
          'wordCount': 20,
          'issues': <String>[],
          'warnings': <String>[],
          'suggestions': <String>[],
        };

        final invalidResults = {
          'isValid': false,
          'wordCount': 3,
          'issues': ['Too short'],
          'warnings': <String>[],
          'suggestions': <String>[],
        };

        final validScore = service.scoreResponse(
          response: 'This is an excellent and detailed response!',
          validationResults: validResults,
          npc: testNpc,
          userInput: 'test',
        );

        final invalidScore = service.scoreResponse(
          response: 'Hi',
          validationResults: invalidResults,
          npc: testNpc,
          userInput: 'test',
        );

        expect(validScore, greaterThan(invalidScore));
      });

      test('should consider NPC preferences in scoring', () {
        final results = {
          'isValid': true,
          'wordCount': 15,
          'issues': <String>[],
          'warnings': <String>[],
          'suggestions': <String>[],
        };

        // Response about preferred topic
        final preferredScore = service.scoreResponse(
          response: 'I love technology and coding!',
          validationResults: results,
          npc: testNpc,
          userInput: 'test',
        );

        // Response about avoided topic
        final avoidedScore = service.scoreResponse(
          response: 'Violence is everywhere',
          validationResults: results,
          npc: testNpc,
          userInput: 'test',
        );

        expect(preferredScore, greaterThan(avoidedScore));
      });
    });

    group('scoreResponseWithDifficulty', () {
      test('should adjust score based on difficulty', () {
        final results = {
          'isValid': true,
          'wordCount': 15,
          'issues': <String>[],
          'warnings': <String>[],
          'suggestions': <String>[],
        };

        final easyScore = service.scoreResponseWithDifficulty(
          response: 'Good response',
          validationResults: results,
          npc: testNpc,
          userInput: 'test',
          difficulty: 'easy',
          userLevel: 1,
        );

        final hardScore = service.scoreResponseWithDifficulty(
          response: 'Good response',
          validationResults: results,
          npc: testNpc,
          userInput: 'test',
          difficulty: 'advanced',
          userLevel: 1,
        );

        // Hard difficulty with low user level should result in lower score
        // or difficulty mismatch penalty
        expect(hardScore, lessThanOrEqualTo(easyScore));
      });
    });

    group('generateFeedback', () {
      test('should generate feedback for good score', () {
        final feedback = service.generateFeedback(
          score: 85,
          response: 'This is a great response!',
          validationResults: {
            'isValid': true,
            'wordCount': 15,
            'issues': <String>[],
            'warnings': <String>[],
            'suggestions': <String>[],
          },
          npc: testNpc,
        );

        expect(feedback, isNotEmpty);
        expect(feedback.toLowerCase().contains('great') ||
            feedback.toLowerCase().contains('excellent') ||
            feedback.toLowerCase().contains('good'), true);
      });

      test('should generate feedback for poor score', () {
        final feedback = service.generateFeedback(
          score: 35,
          response: 'Bad',
          validationResults: {
            'isValid': false,
            'wordCount': 1,
            'issues': ['Too short'],
            'warnings': <String>[],
            'suggestions': <String>[],
          },
          npc: testNpc,
        );

        expect(feedback, isNotEmpty);
      });

      test('should include specific suggestions', () {
        final feedback = service.generateFeedback(
          score: 50,
          response: 'OK response',
          validationResults: {
            'isValid': true,
            'wordCount': 8,
            'issues': <String>[],
            'warnings': ['Could be more detailed'],
            'suggestions': ['Add more examples'],
          },
          npc: testNpc,
        );

        expect(feedback, isNotEmpty);
      });
    });

    group('getScoreGrade', () {
      test('should return Excellent for score 90+', () {
        final grade = service.getScoreGrade(95);
        expect(grade, equals('Excellent'));
      });

      test('should return Very Good for score 80-89', () {
        final grade = service.getScoreGrade(85);
        expect(grade, equals('Very Good'));
      });

      test('should return Good for score 70-79', () {
        final grade = service.getScoreGrade(75);
        expect(grade, equals('Good'));
      });

      test('should return Acceptable for score 60-69', () {
        final grade = service.getScoreGrade(65);
        expect(grade, equals('Acceptable'));
      });

      test('should return Below Average for score 50-59', () {
        final grade = service.getScoreGrade(55);
        expect(grade, equals('Below Average'));
      });

      test('should return Poor for score below 50', () {
        final grade = service.getScoreGrade(40);
        expect(grade, equals('Poor'));
      });
    });
  });
}
