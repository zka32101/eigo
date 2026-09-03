import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';

/// プロンプトエンジニアリングサービス（シングルトンパターン）
/// Claude API用の効果的なプロンプトを構築
class PromptEngineeringService {
  static final PromptEngineeringService _instance =
      PromptEngineeringService._internal();

  factory PromptEngineeringService() {
    return _instance;
  }

  PromptEngineeringService._internal();

  /// シングルトンインスタンスを取得
  static PromptEngineeringService getInstance() {
    return _instance;
  }

  // ==================== PROMPT BUILDING ====================

  /// NPC性格プロンプトを構築
  String buildNPCPersonalityPrompt(NPCExtended npc) {
    try {
      final buffer = StringBuffer();

      buffer.writeln('You are roleplaying as ${npc.npcId}.');
      buffer.writeln('');

      // 性格アーキタイプ
      buffer.writeln(
        'Personality Archetype: ${npc.personality.archetype}',
      );
      buffer.writeln('Traits: ${npc.personality.traits.join(", ")}');
      buffer.writeln('');

      // 伝記
      buffer.writeln('Biography:');
      buffer.writeln(npc.personality.biography);
      buffer.writeln('');

      // 関心事
      buffer.writeln('Interests: ${npc.personality.interests.join(", ")}');
      buffer.writeln('');

      // 話し方
      buffer.writeln('Speaking Style: ${npc.personality.speakingStyle}');
      buffer.writeln('');

      // 好みのトピック
      buffer.writeln(
        'Preferred Topics: ${npc.personality.preferredTopics.join(", ")}',
      );
      buffer.writeln(
        'Topics to Avoid: ${npc.personality.avoidedTopics.join(", ")}',
      );
      buffer.writeln('');

      // カスタムプロンプト
      buffer.writeln('Special Instructions:');
      buffer.writeln(npc.personality.personalityPrompt);
      buffer.writeln('');

      return buffer.toString();
    } catch (e) {
      print('Error building personality prompt: $e');
      return 'You are an English conversation partner.';
    }
  }

  /// 会話フェーズプロンプトを構築
  String buildConversationPhasePrompt(String phase) {
    try {
      const phasePrompts = {
        'Greeting': '''You are starting a new conversation.
Greet the user warmly and naturally.
Ask an engaging opening question related to the topic.
Keep your greeting friendly and concise (1-2 sentences).''',
        'Main': '''You are in the middle of a conversation.
Respond naturally to the user's input.
Build on what they said.
Ask follow-up questions or share relevant thoughts.
Keep responses conversational and engaging.''',
        'Climax': '''You are at a key moment in the conversation.
This is an important decision point or emotional peak.
Make your response meaningful and impactful.
Challenge the user or encourage deeper thinking.
Show genuine interest in their perspective.''',
        'Resolution': '''You are wrapping up the main conversation.
Summarize the key points discussed.
Affirm the user's progress or insights.
Begin transitioning toward closure.
Keep it warm and encouraging.''',
        'Closing': '''You are ending the conversation.
Say goodbye warmly and encouragingly.
Remind them of something positive from the chat.
Express interest in talking again.
Keep it brief and genuine (1-2 sentences).''',
      };

      return phasePrompts[phase] ??
          'Respond naturally and helpfully to the user.';
    } catch (e) {
      print('Error building phase prompt: $e');
      return 'Respond naturally to the user.';
    }
  }

  /// ダイアログテンプレートプロンプトを構築
  String buildTemplatePrompt(DialogueTemplate template) {
    try {
      final buffer = StringBuffer();

      buffer.writeln('Topic: ${template.topic}');
      buffer.writeln('Difficulty: ${template.difficulty}');
      buffer.writeln('Phase: ${template.conversationPhase}');
      buffer.writeln('');

      buffer.writeln('Evaluation Criteria:');
      buffer.writeln(
        'Word Count: ${template.evaluationCriteria.minWordCount}-${template.evaluationCriteria.maxWordCount}',
      );
      buffer.writeln(
        'Must include: ${template.evaluationCriteria.keywordsMustInclude.join(", ")}',
      );
      if (template.evaluationCriteria.keywordsToAvoid.isNotEmpty) {
        buffer.writeln(
          'Avoid: ${template.evaluationCriteria.keywordsToAvoid.join(", ")}',
        );
      }
      buffer.writeln('');

      buffer.writeln('Response Templates:');
      for (final response in template.responseTemplates) {
        buffer.writeln('- $response');
      }
      buffer.writeln('');

      buffer.writeln('Suggested Follow-ups:');
      for (final question in template.followUpQuestions) {
        buffer.writeln('- $question');
      }
      buffer.writeln('');

      return buffer.toString();
    } catch (e) {
      print('Error building template prompt: $e');
      return 'Follow the conversation template.';
    }
  }

  /// 文脈を含むプロンプトを構築
  String buildContextualPrompt(
    DialogueContext context,
    NPCExtended npc,
    DialogueTemplate template,
    List<DialogueMessage> recentMessages,
  ) {
    try {
      final buffer = StringBuffer();

      // NPCの現在の状態
      buffer.writeln('=== Current Context ===');
      buffer.writeln('Current Mood: ${context.currentMood}');
      buffer.writeln('Time of Day: ${context.timeOfDay}');
      if (context.weatherEffect != null) {
        buffer.writeln('Weather: ${context.weatherEffect}');
      }
      if (context.relationshipData != null) {
        final affection = context.relationshipData?['affectionLevel'] ?? 0;
        final conversations =
            context.relationshipData?['conversationCount'] ?? 0;
        buffer.writeln('Relationship Level: $affection/100');
        buffer.writeln('Previous Conversations: $conversations');
      }
      buffer.writeln('');

      // 最近のメッセージ
      if (recentMessages.isNotEmpty) {
        buffer.writeln('=== Recent Conversation ===');
        for (final msg in recentMessages.take(4)) {
          final speaker = msg.speaker == 'npc' ? 'You' : 'User';
          buffer.writeln('$speaker: ${msg.text}');
        }
        buffer.writeln('');
      }

      // 現在のユーザー入力
      buffer.writeln('User just said: "${context.playerInput}"');
      buffer.writeln('');

      // 指示
      buffer.writeln('=== Instructions ===');
      buffer.writeln('Respond naturally to what the user just said.');
      buffer.writeln('Stay in character as ${npc.npcId}.');
      buffer.writeln('Topic: ${template.topic}');
      buffer.writeln('Phase: ${template.conversationPhase}');
      buffer.writeln(
        'Word count: ${template.evaluationCriteria.minWordCount}-${template.evaluationCriteria.maxWordCount}',
      );
      if (template.evaluationCriteria.keywordsMustInclude.isNotEmpty) {
        buffer.writeln(
          'Try to include: ${template.evaluationCriteria.keywordsMustInclude.join(", ")}',
        );
      }
      buffer.writeln('');

      return buffer.toString();
    } catch (e) {
      print('Error building contextual prompt: $e');
      return 'Respond naturally to the user.';
    }
  }

  // ==================== PROMPT OPTIMIZATION ====================

  /// プロンプトを最適化（トークン削減）
  String optimizePrompt(String prompt) {
    try {
      var optimized = prompt;

      // 連続した空行を削除
      optimized = optimized.replaceAll(RegExp(r'\n\n\n+'), '\n\n');

      // 先頭と末尾の空白を削除
      optimized = optimized.trim();

      return optimized;
    } catch (e) {
      print('Error optimizing prompt: $e');
      return prompt;
    }
  }

  /// プロンプトのトークン数を推定
  int estimateTokenCount(String prompt) {
    try {
      // 簡単な推定：単語数 × 1.3
      final wordCount = prompt.split(RegExp(r'\s+')).length;
      return (wordCount * 1.3).toInt();
    } catch (e) {
      return 0;
    }
  }

  // ==================== PROMPT TEMPLATES ====================

  /// システムプロンプトテンプレートを取得
  String getSystemPromptTemplate() {
    return '''You are an AI tutor helping users learn English through roleplay conversations.
Your role is to play different characters and have natural, engaging conversations.

Key responsibilities:
1. Stay in character throughout the conversation
2. Respond naturally and authentically
3. Correct grammar gently without being pedantic
4. Encourage the user to speak more
5. Maintain an encouraging and supportive tone
6. Adapt to the user's level

Remember to:
- Use simple vocabulary when needed
- Ask follow-up questions
- Provide feedback positively
- Make learning fun and engaging''';
  }

  /// ユーザープロンプトテンプレートを取得
  String getUserPromptTemplate() {
    return '''Please respond to the following as the character described.
Stay in character and respond naturally to: "{userInput}"

Context:
- Character: {characterName}
- Topic: {topic}
- Phase: {phase}
- Mood: {mood}

Keep your response natural and engaging.''';
  }

  // ==================== DIFFICULTY ADJUSTMENT ====================

  /// 難易度に応じてプロンプトを調整
  String adjustPromptByDifficulty(
    String basePrompt,
    String difficulty,
  ) {
    try {
      final buffer = StringBuffer();
      buffer.writeln(basePrompt);
      buffer.writeln('');

      const difficultyInstructions = {
        '初級': 'Beginner',
        'Beginner': '''Use simple words and short sentences.
Speak clearly and slowly.
Ask simple, direct questions.
Encourage the user often.''',
        '中級': 'Intermediate',
        'Intermediate': '''Use natural vocabulary and varied sentence structures.
Include some idioms or expressions.
Ask more complex questions.
Provide natural feedback.''',
        '上級': 'Advanced',
        'Advanced': '''Use sophisticated vocabulary and complex sentence structures.
Include idioms, slang, and cultural references.
Ask thought-provoking questions.
Challenge the user's understanding.''',
        'エキスパート': 'Expert',
        'Expert': '''Use advanced vocabulary and nuanced expressions.
Discuss abstract concepts and cultural nuances.
Use humor and subtle language.
Have deep, meaningful conversations.''',
      };

      final instruction = difficultyInstructions[difficulty];
      if (instruction != null && instruction != difficulty) {
        buffer.writeln('Difficulty Level Guidelines:');
        buffer.writeln(instruction);
      }

      return buffer.toString();
    } catch (e) {
      print('Error adjusting prompt by difficulty: $e');
      return basePrompt;
    }
  }

  /// トピック固有のプロンプトを調整
  String adjustPromptByTopic(
    String basePrompt,
    String topic,
    List<String> keywordsMustInclude,
  ) {
    try {
      final buffer = StringBuffer();
      buffer.writeln(basePrompt);
      buffer.writeln('');

      buffer.writeln('Topic: $topic');
      if (keywordsMustInclude.isNotEmpty) {
        buffer.writeln('Key terms to use: ${keywordsMustInclude.join(", ")}');
      }
      buffer.writeln('');

      return buffer.toString();
    } catch (e) {
      print('Error adjusting prompt by topic: $e');
      return basePrompt;
    }
  }
}
