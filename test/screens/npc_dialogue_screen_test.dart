import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:eigo/models/npc_dialogue_model.dart';
import 'package:eigo/models/npc_behavior_model.dart';
import 'package:eigo/models/npc_event_model.dart';
import 'package:eigo/screens/npc_dialogue_screen.dart';
import 'package:eigo/services/npc_dialogue_service.dart';
import 'package:eigo/services/npc_behavior_service.dart';
import 'package:eigo/services/npc_event_service.dart';

void main() {
  group('NPCDialogueScreen Widget Tests', () {
    late NPCDialogueService dialogueService;
    late NPCBehaviorService behaviorService;
    late NPCEventService eventService;

    setUp(() {
      dialogueService = NPCDialogueService.getInstance();
      behaviorService = NPCBehaviorService.getInstance();
      eventService = NPCEventService.getInstance();
    });

    testWidgets('should render with NPC info', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCDialogueScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
              npcAvatarPath: 'assets/avatar.png',
            ),
          ),
        ),
      );

      expect(find.text('Test NPC'), findsWidgets);
      expect(find.byIcon(Icons.favorite), findsWidgets);
    });

    testWidgets('should display start conversation button when inactive',
        (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCDialogueScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
              npcAvatarPath: 'assets/avatar.png',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle mood indicator display', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCDialogueScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
              npcAvatarPath: 'assets/avatar.png',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.emoji_emotions), findsWidgets);
    });
  });

  group('DialogueOptionWidget Tests', () {
    testWidgets('should render dialogue option', (tester) async {
      final option = DialogueOption(
        text: 'Hello!',
        affectionChange: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DialogueOptionWidget(
                option: option,
                onSelected: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.text('+10'), findsOneWidget);
    });

    testWidgets('should show affection indicator', (tester) async {
      final option = DialogueOption(
        text: 'Test',
        affectionChange: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOptionWidget(
              option: option,
              onSelected: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should show negative affection', (tester) async {
      final option = DialogueOption(
        text: 'Rude comment',
        affectionChange: -10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOptionWidget(
              option: option,
              onSelected: () {},
            ),
          ),
        ),
      );

      expect(find.text('-10'), findsOneWidget);
    });

    testWidgets('should call onSelected when tapped', (tester) async {
      bool tapped = false;

      final option = DialogueOption(
        text: 'Click me',
        affectionChange: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DialogueOptionWidget(
              option: option,
              onSelected: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DialogueOptionWidget));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });

  group('NPCMoodIndicator Widget Tests', () {
    testWidgets('should display happy mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.happy),
          ),
        ),
      );

      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
    });

    testWidgets('should display sad mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.sad),
          ),
        ),
      );

      expect(find.text('Sad'), findsOneWidget);
      expect(find.text('😢'), findsOneWidget);
    });

    testWidgets('should display excited mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.excited),
          ),
        ),
      );

      expect(find.text('Excited'), findsOneWidget);
      expect(find.text('🤩'), findsOneWidget);
    });

    testWidgets('should display tired mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.tired),
          ),
        ),
      );

      expect(find.text('Tired'), findsOneWidget);
      expect(find.text('😴'), findsOneWidget);
    });

    testWidgets('should display angry mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.angry),
          ),
        ),
      );

      expect(find.text('Angry'), findsOneWidget);
      expect(find.text('😠'), findsOneWidget);
    });

    testWidgets('should display neutral mood', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NPCMoodIndicator(mood: NPCMood.neutral),
          ),
        ),
      );

      expect(find.text('Neutral'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
    });
  });

  group('NPCProfileScreen Widget Tests', () {
    testWidgets('should render profile screen', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCProfileScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
              npcAvatarPath: 'assets/avatar.png',
            ),
          ),
        ),
      );

      expect(find.text("Test NPC's Profile"), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display personality traits section', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCProfileScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
              npcAvatarPath: 'assets/avatar.png',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('NPCInteractionLogScreen Widget Tests', () {
    testWidgets('should render interaction log screen', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCInteractionLogScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
            ),
          ),
        ),
      );

      expect(find.text('Test NPC - Interaction Log'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('NPCEventNotificationScreen Widget Tests', () {
    testWidgets('should render event notification screen', (tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: NPCEventNotificationScreen(
              npcId: 'test-npc',
              npcName: 'Test NPC',
            ),
          ),
        ),
      );

      expect(find.text('Test NPC - Events'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}
