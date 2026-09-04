import 'package:flutter_test/flutter_test.dart';
import 'package:eigo/models/npc_quest_model.dart';
import 'package:eigo/models/npc_skill_model.dart';
import 'package:eigo/services/npc_quest_service.dart';
import 'package:eigo/services/npc_skill_service.dart';

void main() {
  group('NPCQuestService', () {
    late NPCQuestService questService;

    setUp(() {
      questService = NPCQuestService.getInstance();
      questService.clearCache();
    });

    test('should create quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
        affectionBonus: 20,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Find item',
        objective: 'Locate the treasure',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Treasure Hunt',
        description: 'Find treasure',
        steps: [step],
        reward: reward,
      );

      expect(quest.questId, 'quest-1');
      expect(quest.questName, 'Treasure Hunt');
      expect(quest.status, QuestStatus.available);
    });

    test('should accept quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test objective',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
      );

      final accepted = questService.acceptQuest(quest.questId);
      expect(accepted.status, QuestStatus.accepted);
    });

    test('should start quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
      );

      questService.acceptQuest(quest.questId);
      final started = questService.startQuest(quest.questId);
      expect(started.status, QuestStatus.in_progress);
    });

    test('should complete quest step', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step1 = QuestStep(
        stepId: 'step-1',
        description: 'Step 1',
        objective: 'First objective',
      );

      final step2 = QuestStep(
        stepId: 'step-2',
        description: 'Step 2',
        objective: 'Second objective',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Multi-step Quest',
        description: 'Quest with multiple steps',
        steps: [step1, step2],
        reward: reward,
      );

      questService.acceptQuest(quest.questId);
      final updated = questService.completeQuestStep(quest.questId, 'step-1');

      expect(updated.currentStepIndex, 1);
    });

    test('should complete quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
      );

      final completed = questService.completeQuest(quest.questId);
      expect(completed.status, QuestStatus.completed);
      expect(completed.completedAt, isNotNull);
    });

    test('should fail quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
      );

      final failed = questService.failQuest(quest.questId);
      expect(failed.status, QuestStatus.failed);
    });

    test('should get NPC quests', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest 1',
        description: 'Description 1',
        steps: [step],
        reward: reward,
      );

      questService.createQuest(
        questId: 'quest-2',
        npcId: 'npc-1',
        questName: 'Quest 2',
        description: 'Description 2',
        steps: [step],
        reward: reward,
      );

      questService.createQuest(
        questId: 'quest-3',
        npcId: 'npc-2',
        questName: 'Quest 3',
        description: 'Description 3',
        steps: [step],
        reward: reward,
      );

      final npc1Quests = questService.getNPCQuests('npc-1');
      expect(npc1Quests.length, 2);
    });

    test('should generate quest statistics', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
        affectionBonus: 20,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
      );

      questService.completeQuest(quest.questId);
      final stats = questService.generateStatistics('npc-1');

      expect(stats.npcId, 'npc-1');
      expect(stats.completedCount, 1);
      expect(stats.totalXpEarned, 500);
    });

    test('should reset repeatable quest', () {
      final reward = QuestReward(
        xpReward: 500,
        goldReward: 100,
      );

      final step = QuestStep(
        stepId: 'step-1',
        description: 'Test',
        objective: 'Test',
      );

      final quest = questService.createQuest(
        questId: 'quest-1',
        npcId: 'npc-1',
        questName: 'Repeatable Quest',
        description: 'Description',
        steps: [step],
        reward: reward,
        isRepeatable: true,
      );

      questService.completeQuest(quest.questId);
      final reset = questService.resetQuest(quest.questId);

      expect(reset.status, QuestStatus.available);
      expect(reset.lastRepeatAt, isNotNull);
    });
  });

  group('NPCSkillService', () {
    late NPCSkillService skillService;

    setUp(() {
      skillService = NPCSkillService.getInstance();
      skillService.clearCache();
    });

    test('should register skill', () {
      final method = SkillTeachingMethod(
        methodId: 'method-1',
        name: 'Direct Teaching',
        description: 'Learn by doing',
        requiredInteractionCount: 5,
        requiredAffection: 50,
        teachingDurationMinutes: 30,
      );

      final skill = skillService.registerSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
        description: 'Cast a fireball',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Deals fire damage',
      );

      expect(skill.skillId, 'skill-1');
      expect(skill.skillName, 'Fireball');
      expect(skill.category, SkillCategory.magic);
    });

    test('should start learning session', () {
      final method = SkillTeachingMethod(
        methodId: 'method-1',
        name: 'Teaching',
        description: 'Learn',
        requiredInteractionCount: 5,
        requiredAffection: 50,
        teachingDurationMinutes: 30,
      );

      skillService.registerSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
        description: 'Cast a fireball',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Deals damage',
      );

      final session = skillService.startLearningSession(
        sessionId: 'session-1',
        npcId: 'npc-1',
        skillId: 'skill-1',
        teachingMethodId: 'method-1',
      );

      expect(session.sessionId, 'session-1');
      expect(session.isCompleted, false);
    });

    test('should complete learning session', () {
      final method = SkillTeachingMethod(
        methodId: 'method-1',
        name: 'Teaching',
        description: 'Learn',
        requiredInteractionCount: 5,
        requiredAffection: 50,
        teachingDurationMinutes: 30,
      );

      skillService.registerSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
        description: 'Cast a fireball',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Deals damage',
      );

      final session = skillService.startLearningSession(
        sessionId: 'session-1',
        npcId: 'npc-1',
        skillId: 'skill-1',
        teachingMethodId: 'method-1',
      );

      final completed = skillService.completeLearningSession(
        session.sessionId,
        experienceGained: 150,
      );

      expect(completed.isCompleted, true);
      expect(completed.experienceGained, 150);
    });

    test('should learn skill', () {
      final learned = skillService.learnSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
      );

      expect(learned.skillId, 'skill-1');
      expect(learned.currentLevel, SkillLevel.novice);
      expect(learned.timesUsed, 0);
    });

    test('should add skill experience', () {
      skillService.learnSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
      );

      final updated = skillService.addSkillExperience('skill-1', 150);
      expect(updated.skillExperience, 150);
    });

    test('should use skill', () {
      skillService.learnSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
      );

      final used = skillService.useSkill('skill-1');
      expect(used.timesUsed, 1);
      expect(used.lastUsedAt, isNotNull);
    });

    test('should get NPC skills', () {
      final method = SkillTeachingMethod(
        methodId: 'method-1',
        name: 'Teaching',
        description: 'Learn',
        requiredInteractionCount: 5,
        requiredAffection: 50,
        teachingDurationMinutes: 30,
      );

      skillService.registerSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
        description: 'Cast a fireball',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Deals damage',
      );

      skillService.registerSkill(
        skillId: 'skill-2',
        skillName: 'Healing',
        description: 'Heal wounds',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Heals HP',
      );

      final npcSkills = skillService.getNPCSkills('npc-1');
      expect(npcSkills.length, 2);
    });

    test('should generate skill statistics', () {
      final method = SkillTeachingMethod(
        methodId: 'method-1',
        name: 'Teaching',
        description: 'Learn',
        requiredInteractionCount: 5,
        requiredAffection: 50,
        teachingDurationMinutes: 30,
      );

      skillService.registerSkill(
        skillId: 'skill-1',
        skillName: 'Fireball',
        description: 'Cast a fireball',
        category: SkillCategory.magic,
        teachingNpcId: 'npc-1',
        maxLevel: SkillLevel.master,
        teachingMethods: [method],
        experienceRequired: 1000,
        effectDescription: 'Deals damage',
      );

      final session = skillService.startLearningSession(
        sessionId: 'session-1',
        npcId: 'npc-1',
        skillId: 'skill-1',
        teachingMethodId: 'method-1',
      );

      skillService.completeLearningSession(
        session.sessionId,
        experienceGained: 150,
      );

      final stats = skillService.generateStatistics('npc-1');
      expect(stats.npcId, 'npc-1');
      expect(stats.completedSessions, 1);
      expect(stats.totalExperienceGranted, 150);
    });
  });
}
