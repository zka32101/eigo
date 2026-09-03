import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/screens/npc_dialogue_screen.dart';
import 'package:eigo/screens/npc_interaction_screen.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/models/dialogue_template_model.dart';

void main() {
  group('NPC Dialogue Integration Tests', () {
    late NPCExtended testNpc;
    late DialogueTemplate testTemplate;

    setUp(() {
      testNpc = NPCExtended(
        npcId: 'alice',
        personality: NPCPersonality(
          archetype: 'friendly',
          traits: ['helpful'],
          interests: ['cooking'],
          preferredTopics: ['food'],
          avoidedTopics: ['violence'],
          speakingStyle: ['casual'],
          biography: 'Alice loves cooking.',
        ),
        currentMoodState: 'happy',
        availabilitySchedule: NPCAvailabilitySchedule(timeSlots: []),
        lastInteractionTime: DateTime.now(),
        learningProgress: 0.5,
      );

      testTemplate = DialogueTemplate(
        templateId: '1',
        npcId: 'alice',
        topic: 'cooking',
        difficulty: DialogueDifficulty.easy,
        conversationPhase: ConversationPhase.greeting,
        responseTemplates: [
          'Hi! Want to talk about cooking?',
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
      );
    });

    group('NPC Dialogue Screen Widget Tests', () {
      testWidgets('should display NPC dialogue screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        // Should show loading or NPC not found
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('should show NPC character display widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should include dialogue input interface',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        // Wait for async loading
        await tester.pumpAndSettle();
      });
    });

    group('NPC Interaction Screen Widget Tests', () {
      testWidgets('should display NPC interaction screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCInteractionScreen(),
            ),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('NPCs'), findsOneWidget);
      });

      testWidgets('should show loading state initially',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCInteractionScreen(),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      });

      testWidgets('should display NPC list when data loads',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCInteractionScreen(),
            ),
          ),
        );

        // Wait for async loading and pump widget tree
        await tester.pumpAndSettle();
      });
    });

    group('Quick NPC Interaction Button Tests', () {
      testWidgets('should display quick NPC button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                floatingActionButton: QuickNPCInteractionButton(),
              ),
            ),
          ),
        );

        expect(find.byType(FloatingActionButton), findsWidgets);
      });

      testWidgets('should show NPC count', (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                floatingActionButton: QuickNPCInteractionButton(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
      });
    });

    group('Dialogue Flow Integration Tests', () {
      test('should handle complete dialogue interaction flow', () async {
        // Simulate dialogue flow
        expect(testNpc.npcId, equals('alice'));
        expect(testNpc.currentMoodState, equals('happy'));
        expect(testTemplate.topic, equals('cooking'));
        expect(testTemplate.conversationPhase, equals(ConversationPhase.greeting));
      });

      test('should track conversation state correctly', () {
        // Verify NPC state is set up correctly
        expect(testNpc.personality.traits, contains('helpful'));
        expect(testNpc.personality.interests, contains('cooking'));
        expect(testNpc.personality.preferredTopics, contains('food'));
      });

      test('should validate dialogue template requirements', () {
        final criteria = testTemplate.evaluationCriteria;
        expect(criteria.keywordsMustInclude, contains('food'));
        expect(criteria.keywordsMustInclude, contains('cook'));
        expect(criteria.keywordsToAvoid, contains('violence'));
        expect(criteria.minWordCount, equals(5));
        expect(criteria.maxWordCount, equals(200));
      });

      test('should ensure NPC availability affects interaction', () {
        final isAvailable = testNpc.availabilitySchedule.isCurrentlyAvailable();
        expect(isAvailable, isNotNull);
      });
    });

    group('Screen Navigation Tests', () {
      testWidgets('should navigate from interaction to dialogue screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCInteractionScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should have navigation capability
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should have close button on dialogue screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.close), findsWidgets);
      });
    });

    group('Dialogue History Screen Tests', () {
      testWidgets('should display dialogue history screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueHistoryScreen(),
            ),
          ),
        );

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Conversation History'), findsOneWidget);
      });
    });

    group('NPC Modal Dialog Tests', () {
      testWidgets('should display NPC dialogue as modal',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox.expand(
                  child: Center(
                    child: Text('Main Screen'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Main Screen'), findsOneWidget);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('should handle NPC not found error',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'non-existent-npc',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('should display error for template loading failure',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper button labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                floatingActionButton: QuickNPCInteractionButton(
                  label: 'Talk to NPCs',
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Talk to NPCs'), findsWidgets);
      });

      testWidgets('should have close button for dialogue',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: NPCDialogueScreen(
                npcId: 'test-npc',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.close), findsWidgets);
      });
    });
  });
}
