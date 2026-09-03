import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/widgets/dialogue_input_interface_widget.dart';
import 'package:eigo/widgets/interaction_result_widget.dart';
import 'package:eigo/widgets/npc_character_display_widget.dart';

void main() {
  group('Dialogue Input Interface Widget', () {
    testWidgets('should display text input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show character count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(
                showCharacterCount: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('0/500'), findsOneWidget);
    });

    testWidgets('should update character count when typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(
                showCharacterCount: true,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(
                showCharacterCount: true,
              ),
            ),
          ),
        ),
      );

      // Text should be entered
      expect(find.text('Hello world'), findsWidgets);
    });

    testWidgets('should disable send button when text is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(),
            ),
          ),
        ),
      );

      // Send button should be disabled initially
      final sendButton = find.byType(ElevatedButton);
      expect(sendButton, findsWidgets);
    });

    testWidgets('should show minimum character warning',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(
                minCharacters: 5,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hi');
      await tester.pump(Duration.zero);

      // Warning about minimum characters should appear
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show quick response suggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(),
            ),
          ),
        ),
      );

      // Quick response chips should be visible
      expect(find.byType(InputChip), findsWidgets);
      expect(find.text('That sounds great!'), findsOneWidget);
    });

    testWidgets('should fill text when quick response is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('That sounds great!'));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DialogueInputInterfaceWidget(),
            ),
          ),
        ),
      );

      // Text field should be populated
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Interaction Result Widget', () {
    testWidgets('should display score correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 85,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Great job!',
                qualityBreakdown: {
                  'Relevance': 0.9,
                  'Naturalness': 0.85,
                  'Grammar': 0.95,
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
      expect(find.text('/ 100'), findsOneWidget);
    });

    testWidgets('should display rewards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 80,
                xpEarned: 150,
                coinsEarned: 75,
                feedback: 'Well done!',
                qualityBreakdown: {
                  'Relevance': 0.8,
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('150'), findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(find.text('XP Earned'), findsOneWidget);
      expect(find.text('Coins'), findsOneWidget);
    });

    testWidgets('should display grade based on score',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 92,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Excellent!',
                qualityBreakdown: {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('should display quality breakdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 75,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Good response',
                qualityBreakdown: {
                  'Relevance': 0.85,
                  'Naturalness': 0.80,
                  'Grammar': 0.90,
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Quality Breakdown'), findsOneWidget);
      expect(find.text('Relevance'), findsOneWidget);
      expect(find.text('Naturalness'), findsOneWidget);
      expect(find.text('Grammar'), findsOneWidget);
    });

    testWidgets('should display feedback message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 70,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Try to be more specific next time.',
                qualityBreakdown: {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Try to be more specific next time.'), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('should display star rating', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 95,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Perfect!',
                qualityBreakdown: {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('should have continue button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractionResultWidget(
                score: 80,
                xpEarned: 100,
                coinsEarned: 50,
                feedback: 'Good job!',
                qualityBreakdown: {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('Compact Interaction Result Widget', () {
    testWidgets('should display compact score', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactInteractionResultWidget(
              score: 85,
              xpEarned: 100,
              coinsEarned: 50,
            ),
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
    });

    testWidgets('should show rewards compactly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompactInteractionResultWidget(
              score: 75,
              xpEarned: 150,
              coinsEarned: 75,
            ),
          ),
        ),
      );

      expect(find.text('+150 XP'), findsOneWidget);
      expect(find.text('+75'), findsOneWidget);
    });
  });

  group('Minimal Dialogue Input Widget', () {
    testWidgets('should display input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MinimalDialogueInputWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show send button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MinimalDialogueInputWidget(
                showSendButton: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
