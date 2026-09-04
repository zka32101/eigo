import 'package:eigo/models/dialogue_template_model.dart';
import 'package:eigo/models/npc_extended_model.dart';
import 'package:eigo/services/prompt_engineering_service.dart';

/// Claude API統合ダイアログサービス（シングルトンパターン）
/// Claude APIを使用して動的なNPC応答を生成
class ClaudeDialogueService {
  static final ClaudeDialogueService _instance =
      ClaudeDialogueService._internal();

  factory ClaudeDialogueService() {
    return _instance;
  }

  ClaudeDialogueService._internal();

  /// シングルトンインスタンスを取得
  static ClaudeDialogueService getInstance() {
    return _instance;
  }

  final _promptService = PromptEngineeringService.getInstance();

  // ==================== RESPONSE GENERATION ====================

  /// Claude APIを使用してNPC応答を生成
  /// 注: 実装には実際のClaudeクライアント（anthropic パッケージ）が必要
  Future<String> generateNPCResponse({
    required NPCExtended npc,
    required DialogueContext context,
    required DialogueTemplate template,
    required List<DialogueMessage> recentMessages,
    int maxTokens = 200,
  }) async {
    try {
      // システムプロンプトを構築
      final systemPrompt = _buildSystemPrompt(npc, template);

      // ユーザープロンプトを構築
      final userPrompt = _promptService.buildContextualPrompt(
        context,
        npc,
        template,
        recentMessages,
      );

      // 最適化
      final optimizedUserPrompt = _promptService.optimizePrompt(userPrompt);

      // Claude APIへのリクエスト
      // 注: このメソッドは anthropic パッケージの統合が必要
      final response = await _callClaudeAPI(
        systemPrompt,
        optimizedUserPrompt,
        maxTokens,
      );

      return response;
    } catch (e) {
      print('Error generating NPC response: $e');
      rethrow;
    }
  }

  /// テンプレートに基づいた応答生成
  Future<String> generateTemplateBasedResponse({
    required NPCExtended npc,
    required DialogueContext context,
    required DialogueTemplate template,
    required String userInput,
    int maxTokens = 180,
  }) async {
    try {
      final systemPrompt = _buildSystemPrompt(npc, template);

      final userPrompt = StringBuffer();
      userPrompt.writeln(_promptService.buildTemplatePrompt(template));
      userPrompt.writeln('');
      userPrompt.writeln('User said: "$userInput"');
      userPrompt.writeln('');
      userPrompt.writeln('Respond naturally as ${npc.npcId}:');

      final response = await _callClaudeAPI(
        systemPrompt,
        userPrompt.toString(),
        maxTokens,
      );

      return response;
    } catch (e) {
      print('Error generating template-based response: $e');
      rethrow;
    }
  }

  /// ストリーミング応答を生成
  /// リアルタイムで応答をストリーミング配信
  Stream<String> generateNPCResponseStream({
    required NPCExtended npc,
    required DialogueContext context,
    required DialogueTemplate template,
    required String userInput,
    int maxTokens = 200,
  }) async* {
    try {
      final systemPrompt = _buildSystemPrompt(npc, template);

      final userPrompt = StringBuffer();
      userPrompt.writeln('Context:');
      userPrompt.writeln('- Time: ${context.timeOfDay}');
      userPrompt.writeln('- Mood: ${context.currentMood}');
      userPrompt.writeln('- Topic: ${template.topic}');
      userPrompt.writeln('');
      userPrompt.writeln('User: $userInput');
      userPrompt.writeln('${npc.npcId}: ');

      // ストリーミングレスポンス
      yield* _callClaudeAPIStream(
        systemPrompt,
        userPrompt.toString(),
        maxTokens,
      );
    } catch (e) {
      print('Error generating streaming response: $e');
      yield 'Error generating response. Please try again.';
    }
  }

  // ==================== SYSTEM PROMPT BUILDING ====================

  /// システムプロンプトを構築
  String _buildSystemPrompt(
    NPCExtended npc,
    DialogueTemplate template,
  ) {
    try {
      final buffer = StringBuffer();

      // ベースシステムプロンプト
      buffer.writeln(_promptService.getSystemPromptTemplate());
      buffer.writeln('');
      buffer.writeln('=== Character Profile ===');

      // NPC性格プロンプト
      buffer.writeln(_promptService.buildNPCPersonalityPrompt(npc));
      buffer.writeln('');

      // フェーズ固有の指示
      buffer.writeln(
        _promptService.buildConversationPhasePrompt(template.conversationPhase),
      );
      buffer.writeln('');

      // 難易度調整
      buffer.writeln(
        _promptService.adjustPromptByDifficulty(
          '',
          template.difficulty,
        ),
      );

      return buffer.toString();
    } catch (e) {
      print('Error building system prompt: $e');
      return _promptService.getSystemPromptTemplate();
    }
  }

  // ==================== API CALLS ====================

  /// Claude APIを呼び出す（実装例）
  /// 注: 実装にはanthropicパッケージが必要
  Future<String> _callClaudeAPI(
    String systemPrompt,
    String userPrompt,
    int maxTokens,
  ) async {
    try {
      // TODO: anthropic パッケージを使用した実装
      // 以下は実装プレースホルダー

      // 実装例:
      // import 'package:anthropic/anthropic.dart';
      // final client = Anthropic(apiKey: apiKey);
      // final message = await client.messages.create(
      //   model: 'claude-3-5-sonnet-20241022',
      //   maxTokens: maxTokens,
      //   system: systemPrompt,
      //   messages: [
      //     Message(
      //       role: 'user',
      //       content: userPrompt,
      //     ),
      //   ],
      // );
      // return message.content.first.text;

      // プレースホルダー実装
      print('Claude API call would be made here');
      print('System Prompt Length: ${systemPrompt.length} chars');
      print('User Prompt Length: ${userPrompt.length} chars');
      print('Max Tokens: $maxTokens');

      return 'This is a placeholder response. Please implement Claude API integration.';
    } catch (e) {
      print('Error calling Claude API: $e');
      rethrow;
    }
  }

  /// Claude APIをストリーミング呼び出す
  Stream<String> _callClaudeAPIStream(
    String systemPrompt,
    String userPrompt,
    int maxTokens,
  ) async* {
    try {
      // TODO: anthropic パッケージでストリーミング対応
      // 以下は実装プレースホルダー

      // 実装例:
      // import 'package:anthropic/anthropic.dart';
      // final client = Anthropic(apiKey: apiKey);
      // final stream = client.messages.stream(
      //   model: 'claude-3-5-sonnet-20241022',
      //   maxTokens: maxTokens,
      //   system: systemPrompt,
      //   messages: [
      //     Message(
      //       role: 'user',
      //       content: userPrompt,
      //     ),
      //   ],
      // );
      // await for (final event in stream) {
      //   if (event is ContentBlockDeltaEvent) {
      //     yield event.delta.text ?? '';
      //   }
      // }

      yield 'Streaming placeholder response...';
    } catch (e) {
      print('Error calling Claude API stream: $e');
      yield 'Error generating response.';
    }
  }

  // ==================== RESPONSE POST-PROCESSING ====================

  /// 応答後処理（トリミング、クリーンアップ）
  String postProcessResponse(String response) {
    try {
      var processed = response.trim();

      // 名前タグを削除（例: "NPC: response"）
      if (processed.contains(':')) {
        final parts = processed.split(':');
        if (parts.length > 1) {
          processed = parts.sublist(1).join(':').trim();
        }
      }

      // 過剰な句読点を削除
      processed = processed.replaceAll(RegExp(r'\.{2,}'), '.');
      processed = processed.replaceAll(RegExp(r'!{2,}'), '!');
      processed = processed.replaceAll(RegExp(r'\?{2,}'), '?');

      // 先頭と末尾の句読点を修正
      while (processed.startsWith('.') ||
          processed.startsWith(',') ||
          processed.startsWith('!')) {
        processed = processed.substring(1).trim();
      }

      if (!processed.endsWith('.') &&
          !processed.endsWith('!') &&
          !processed.endsWith('?')) {
        processed += '.';
      }

      return processed;
    } catch (e) {
      print('Error post-processing response: $e');
      return response;
    }
  }

  /// 応答を検証（品質チェック）
  bool validateResponse(String response) {
    try {
      // 最小長チェック
      if (response.trim().length < 10) return false;

      // 最大長チェック（トークン数制限）
      if (response.split(' ').length > 500) return false;

      // 基本的な文法チェック
      if (!response.contains(RegExp(r'[a-zA-Z]'))) return false;

      return true;
    } catch (e) {
      print('Error validating response: $e');
      return false;
    }
  }

  // ==================== RESPONSE ANALYSIS ====================

  /// 応答から感情を抽出
  String extractEmotion(String response) {
    try {
      const emotionKeywords = {
        'excited': ['!', 'amazing', 'wonderful', 'fantastic', 'great'],
        'happy': ['happy', 'glad', 'pleased', 'delighted', 'lovely'],
        'sad': ['sad', 'sorry', 'unfortunate', 'down', 'blue'],
        'curious': ['interesting', 'wonder', 'curious', 'hmm', 'really?'],
        'skeptical': ['really?', 'sure?', 'doubt', 'hmm', 'not sure'],
      };

      final lowerResponse = response.toLowerCase();
      var bestEmotion = 'neutral';
      var bestScore = 0;

      for (final emotion in emotionKeywords.entries) {
        var score = 0;
        for (final keyword in emotion.value) {
          if (lowerResponse.contains(keyword)) score++;
        }
        if (score > bestScore) {
          bestEmotion = emotion.key;
          bestScore = score;
        }
      }

      return bestEmotion;
    } catch (e) {
      print('Error extracting emotion: $e');
      return 'neutral';
    }
  }

  /// 応答からトピックを抽出
  List<String> extractTopics(String response) {
    try {
      final topics = <String>[];

      // 一般的なトピックキーワード
      const topicKeywords = {
        'travel': ['trip', 'travel', 'visit', 'country', 'city', 'airport'],
        'food': ['eat', 'food', 'restaurant', 'cooking', 'recipe', 'taste'],
        'weather': ['weather', 'rain', 'sun', 'cold', 'hot', 'temperature'],
        'hobbies': [
          'hobby',
          'hobby',
          'hobby',
          'hobby',
          'gaming',
          'reading',
          'sports'
        ],
        'work': [
          'work',
          'job',
          'career',
          'office',
          'project',
          'meeting',
          'colleague'
        ],
        'family': ['family', 'mother', 'father', 'brother', 'sister', 'parent'],
      };

      final lowerResponse = response.toLowerCase();

      for (final topic in topicKeywords.entries) {
        for (final keyword in topic.value) {
          if (lowerResponse.contains(keyword)) {
            topics.add(topic.key);
            break;
          }
        }
      }

      return topics.toList();
    } catch (e) {
      print('Error extracting topics: $e');
      return [];
    }
  }
}
