import 'package:eigo/models/dialogue_model.dart';

/// 対話ツリーデータベース
/// すべてのNPCの対話ツリーを一元管理
class DialogueTrees {
  static final DialogueTrees _instance = DialogueTrees._internal();

  factory DialogueTrees.getInstance() {
    return _instance;
  }

  DialogueTrees._internal();

  final Map<String, DialogueTree> _trees = {};

  /// すべての対話ツリーを初期化
  void initializeAllTrees() {
    _trees.clear();

    // Aria（魔法使い）の対話ツリー
    _initializeAriaDialogues();

    // Luna（学者）の対話ツリー
    _initializeLunaDialogues();

    // Kai（戦士）の対話ツリー
    _initializeKaiDialogues();

    // Eloise（盗賊）の対話ツリー
    _initializeEloiseDialogues();

    // Thorn（治療者）の対話ツリー
    _initializeThornDialogues();

    // Zephyr（商人）の対話ツリー
    _initializeZephyrDialogues();
  }

  /// Aria（魔法使い）の対話ツリー
  void _initializeAriaDialogues() {
    final tree = DialogueTree(
      npcId: 'aria_001',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'こんにちは！久しぶりだね。',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: '久しぶり！元気にしてた？',
              nextNodeId: 'chat_about_life',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: '何か手伝えることはある？',
              nextNodeId: 'quest_offer',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: 'ちょっと忙しいんだ',
              nextNodeId: 'farewell',
              affectionChange: -5,
            ),
          ],
        ),
        'chat_about_life': DialogueNode(
          id: 'chat_about_life',
          text: 'ね、最近は魔法の研究に没頭してるんだ。',
          choices: [
            DialogueChoice(
              id: 'chat_1',
              text: 'すごいね。何か教えてよ',
              nextNodeId: 'teach_magic',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'chat_2',
              text: 'そっか、頑張ってね',
              nextNodeId: 'farewell',
              affectionChange: 5,
            ),
          ],
        ),
        'quest_offer': DialogueNode(
          id: 'quest_offer',
          text: 'これはタイムリーだ！助けてくれないかな？',
          choices: [
            DialogueChoice(
              id: 'quest_1',
              text: 'もちろん！何を手伝えばいい？',
              nextNodeId: 'quest_detail',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'quest_2',
              text: 'それは危なくない？',
              nextNodeId: 'quest_explain',
              affectionChange: 10,
            ),
          ],
        ),
        'teach_magic': DialogueNode(
          id: 'teach_magic',
          text: 'ファイアボールの詠唱を教えよう...',
          choices: [
            DialogueChoice(
              id: 'teach_1',
              text: 'ありがとう！',
              nextNodeId: 'farewell',
              affectionChange: 25,
            ),
          ],
        ),
        'quest_detail': DialogueNode(
          id: 'quest_detail',
          text: 'この森の奥に魔法の水晶があるんだ。それを取ってきてくれないかな？',
          choices: [
            DialogueChoice(
              id: 'detail_1',
              text: '了解した。頑張ってくるね',
              nextNodeId: 'quest_accepted',
              affectionChange: 30,
            ),
            DialogueChoice(
              id: 'detail_2',
              text: 'それは神聖な場所だ',
              nextNodeId: 'quest_explain_sacred',
              affectionChange: 0,
            ),
          ],
        ),
        'quest_accepted': DialogueNode(
          id: 'quest_accepted',
          text: 'ありがとう！君のことは本当に信頼している。',
          choices: [],
        ),
        'quest_explain': DialogueNode(
          id: 'quest_explain',
          text: 'まあ、多少の危険はあるけど...',
          choices: [
            DialogueChoice(
              id: 'explain_1',
              text: 'でもやりたい',
              nextNodeId: 'quest_detail',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'explain_2',
              text: 'やっぱりやめよう',
              nextNodeId: 'farewell',
              affectionChange: -10,
            ),
          ],
        ),
        'quest_explain_sacred': DialogueNode(
          id: 'quest_explain_sacred',
          text: 'そう、だからこそ水晶を守る必要があるんだ',
          choices: [
            DialogueChoice(
              id: 'sacred_1',
              text: 'わかった。手伝うよ',
              nextNodeId: 'quest_accepted',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'sacred_2',
              text: 'それでもいい',
              nextNodeId: 'quest_detail',
              affectionChange: 10,
            ),
          ],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: 'また会おう！',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['aria_001'] = tree;
  }

  /// Luna（学者）の対話ツリー
  void _initializeLunaDialogues() {
    final tree = DialogueTree(
      npcId: 'luna_002',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'こんにちは。古い本を探しているんですが...',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: '何か手伝えることは？',
              nextNodeId: 'research_explanation',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: 'アリア知ってる？',
              nextNodeId: 'about_aria',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: '邪魔だ',
              nextNodeId: 'offended',
              affectionChange: -20,
            ),
          ],
        ),
        'research_explanation': DialogueNode(
          id: 'research_explanation',
          text: '古い魔法の書を三冊探しているんです。重要な研究なんです。',
          choices: [
            DialogueChoice(
              id: 'research_1',
              text: '何の研究？',
              nextNodeId: 'research_detail',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'research_2',
              text: '手伝おうか？',
              nextNodeId: 'accept_help',
              affectionChange: 20,
            ),
          ],
        ),
        'research_detail': DialogueNode(
          id: 'research_detail',
          text: '失われた古い言語の解読です。だれも知らない魔法が隠されているかもしれません。',
          choices: [
            DialogueChoice(
              id: 'detail_1',
              text: '手伝いたい',
              nextNodeId: 'accept_help',
              affectionChange: 25,
            ),
            DialogueChoice(
              id: 'detail_2',
              text: '難しそうだ',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'accept_help': DialogueNode(
          id: 'accept_help',
          text: 'ありがとうございます！あなたの助けは本当に貴重です。',
          choices: [],
        ),
        'about_aria': DialogueNode(
          id: 'about_aria',
          text: 'ああ、アリアなら知ってます。才能のある魔法使いです。でも時々危ない実験をしています。',
          choices: [
            DialogueChoice(
              id: 'aria_1',
              text: '彼女を助けてあげて',
              nextNodeId: 'farewell',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'aria_2',
              text: 'それより研究に戻ろう',
              nextNodeId: 'research_explanation',
              affectionChange: 5,
            ),
          ],
        ),
        'offended': DialogueNode(
          id: 'offended',
          text: 'そう... 失礼しました。',
          choices: [],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: '本を見つけたら教えてください。',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['luna_002'] = tree;
  }

  /// Kai（戦士）の対話ツリー
  void _initializeKaiDialogues() {
    final tree = DialogueTree(
      npcId: 'kai_004',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'やあ！一緒に戦いに行かないか？',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: 'もちろん！何があるの？',
              nextNodeId: 'quest_description',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: 'どんなクエスト？',
              nextNodeId: 'quest_types',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: '今は無理だ',
              nextNodeId: 'farewell',
              affectionChange: -5,
            ),
          ],
        ),
        'quest_description': DialogueNode(
          id: 'quest_description',
          text: '村の近くに盗賊団が出没している。彼らを追い払ってくれないか？',
          choices: [
            DialogueChoice(
              id: 'desc_1',
              text: '承知した。倒してくる',
              nextNodeId: 'quest_accepted',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'desc_2',
              text: '数はどれくらい？',
              nextNodeId: 'squad_info',
              affectionChange: 10,
            ),
          ],
        ),
        'squad_info': DialogueNode(
          id: 'squad_info',
          text: 'だいたい10人くらい。手強いが、君ならできると思う。',
          choices: [
            DialogueChoice(
              id: 'squad_1',
              text: 'わかった。やってくる',
              nextNodeId: 'quest_accepted',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'squad_2',
              text: 'ちょっと待ってもらえる？',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'quest_types': DialogueNode(
          id: 'quest_types',
          text: 'いろんな種類があるよ。敵を倒すクエスト、人を救出するクエスト、宝物を探すクエスト...',
          choices: [
            DialogueChoice(
              id: 'types_1',
              text: '敵を倒すクエストで',
              nextNodeId: 'quest_description',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'types_2',
              text: 'もう少し考えさせて',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'quest_accepted': DialogueNode(
          id: 'quest_accepted',
          text: 'よし！頼りにしてるぜ。帰ってきたら話をしよう。',
          choices: [],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: '需要なことが出てきたら、いつでも声をかけてくれ。',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['kai_004'] = tree;
  }

  /// Eloise（盗賊）の対話ツリー
  void _initializeEloiseDialogues() {
    final tree = DialogueTree(
      npcId: 'eloise_005',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'ふふ... こんなところで君に会うとは。何か用？',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: '何もない、ただ挨拶',
              nextNodeId: 'suspicious',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: '一緒に何か盗みたいんだ',
              nextNodeId: 'interest_shown',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: '仕事があるか？',
              nextNodeId: 'job_offer',
              affectionChange: 10,
            ),
          ],
        ),
        'suspicious': DialogueNode(
          id: 'suspicious',
          text: 'へえ、本当かな？ 何か企んでるんじゃなくて？',
          choices: [
            DialogueChoice(
              id: 'sus_1',
              text: '本当だよ',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
            DialogueChoice(
              id: 'sus_2',
              text: 'うーん、実は相談がある',
              nextNodeId: 'job_offer',
              affectionChange: 10,
            ),
          ],
        ),
        'interest_shown': DialogueNode(
          id: 'interest_shown',
          text: 'へえ、おもしろい。何を盗みたい？',
          choices: [
            DialogueChoice(
              id: 'interest_1',
              text: 'ある貴族の宝石',
              nextNodeId: 'heist_planning',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'interest_2',
              text: 'まだ決めていない',
              nextNodeId: 'farewell',
              affectionChange: 5,
            ),
          ],
        ),
        'job_offer': DialogueNode(
          id: 'job_offer',
          text: 'ま、いくつか仕事を持ってるね。報酬は値切られないぞ。',
          choices: [
            DialogueChoice(
              id: 'job_1',
              text: '報酬はいくら？',
              nextNodeId: 'payment_discussion',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'job_2',
              text: '詳しく聞かせて',
              nextNodeId: 'job_details',
              affectionChange: 15,
            ),
          ],
        ),
        'heist_planning': DialogueNode(
          id: 'heist_planning',
          text: 'ふふ... 悪くない。計画を立てるのに手伝ってくれるね？',
          choices: [
            DialogueChoice(
              id: 'heist_1',
              text: 'もちろん',
              nextNodeId: 'quest_accepted',
              affectionChange: 25,
            ),
          ],
        ),
        'payment_discussion': DialogueNode(
          id: 'payment_discussion',
          text: '仕事の難易度にもよるが、だいたい100〜1000ゴールドってとこ。',
          choices: [
            DialogueChoice(
              id: 'payment_1',
              text: 'やってみるか',
              nextNodeId: 'job_details',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'payment_2',
              text: 'ちょっと高い',
              nextNodeId: 'farewell',
              affectionChange: -5,
            ),
          ],
        ),
        'job_details': DialogueNode(
          id: 'job_details',
          text: '第一に、城の文書をいくつか盗んでくる必要がある。本当は誰が頼んだのか言えないけど...',
          choices: [
            DialogueChoice(
              id: 'details_1',
              text: 'わかった、やろう',
              nextNodeId: 'quest_accepted',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'details_2',
              text: 'それは危ない',
              nextNodeId: 'farewell',
              affectionChange: -10,
            ),
          ],
        ),
        'quest_accepted': DialogueNode(
          id: 'quest_accepted',
          text: 'よし。後で回るんじゃない。俺の評判に傷がつく。',
          choices: [],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: '気が変わったら、また来な。',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['eloise_005'] = tree;
  }

  /// Thorn（治療者）の対話ツリー
  void _initializeThornDialogues() {
    final tree = DialogueTree(
      npcId: 'thorn_006',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'こんにちは！怪我とか病気とかありませんか？',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: 'ちょっと怪我してる',
              nextNodeId: 'heal_offered',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: '大丈夫です',
              nextNodeId: 'quest_offer',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: 'ちょっと忙しい',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'heal_offered': DialogueNode(
          id: 'heal_offered',
          text: '見せてください。治してあげます。',
          choices: [
            DialogueChoice(
              id: 'heal_1',
              text: 'ありがとう',
              nextNodeId: 'healed',
              affectionChange: 20,
            ),
          ],
        ),
        'healed': DialogueNode(
          id: 'healed',
          text: 'どうぞ。完全に治っているはずです。何か他に手伝えることはありますか？',
          choices: [
            DialogueChoice(
              id: 'healed_1',
              text: 'ありがとう、大丈夫です',
              nextNodeId: 'farewell',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'healed_2',
              text: '実は手伝ってほしいことが',
              nextNodeId: 'quest_offer',
              affectionChange: 10,
            ),
          ],
        ),
        'quest_offer': DialogueNode(
          id: 'quest_offer',
          text: 'もし手伝ってくれるなら、村の人たちは本当に感謝するでしょう。',
          choices: [
            DialogueChoice(
              id: 'quest_1',
              text: '何をすればいい？',
              nextNodeId: 'quest_detail',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'quest_2',
              text: 'それはいいや',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'quest_detail': DialogueNode(
          id: 'quest_detail',
          text: '薬草を集めてくれるといいんです。山に生えているはずです。',
          choices: [
            DialogueChoice(
              id: 'detail_1',
              text: '頑張ってくるね',
              nextNodeId: 'quest_accepted',
              affectionChange: 20,
            ),
          ],
        ),
        'quest_accepted': DialogueNode(
          id: 'quest_accepted',
          text: 'ありがとうございます。本当に助かります。',
          choices: [],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: '何か必要なことがあったら、いつでも来てください。',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['thorn_006'] = tree;
  }

  /// Zephyr（商人）の対話ツリー
  void _initializeZephyrDialogues() {
    final tree = DialogueTree(
      npcId: 'zephyr_007',
      nodes: {
        'greeting': DialogueNode(
          id: 'greeting',
          text: 'いらっしゃい！いい品があります。見ていきませんか？',
          choices: [
            DialogueChoice(
              id: 'greeting_1',
              text: '何か売ってくれる？',
              nextNodeId: 'shop_offer',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'greeting_2',
              text: '何か買ってくれる？',
              nextNodeId: 'buy_offer',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'greeting_3',
              text: 'ただ見てるだけ',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'shop_offer': DialogueNode(
          id: 'shop_offer',
          text: 'もちろんです。剣、鎧、薬... いろいろあります。何をお探しですか？',
          choices: [
            DialogueChoice(
              id: 'shop_1',
              text: '魔法の剣を探している',
              nextNodeId: 'sword_negotiation',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'shop_2',
              text: 'ちょっと見てみる',
              nextNodeId: 'farewell',
              affectionChange: 5,
            ),
          ],
        ),
        'buy_offer': DialogueNode(
          id: 'buy_offer',
          text: 'いい品があれば買いますよ。どんなものをお持ちですか？',
          choices: [
            DialogueChoice(
              id: 'buy_1',
              text: '古い本を持ってきた',
              nextNodeId: 'book_negotiation',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'buy_2',
              text: 'まだ何も',
              nextNodeId: 'farewell',
              affectionChange: 0,
            ),
          ],
        ),
        'sword_negotiation': DialogueNode(
          id: 'sword_negotiation',
          text: 'ふむふむ。いい剣があります。ただ、結構高いですよ。500ゴールドはします。',
          choices: [
            DialogueChoice(
              id: 'sword_1',
              text: '買おう',
              nextNodeId: 'transaction_complete',
              affectionChange: 10,
            ),
            DialogueChoice(
              id: 'sword_2',
              text: 'ちょっと高い',
              nextNodeId: 'price_negotiation',
              affectionChange: 5,
            ),
          ],
        ),
        'book_negotiation': DialogueNode(
          id: 'book_negotiation',
          text: 'へえ、古い本ですか。見せてもらえます？ ああ、いい本だ。150ゴールド出しましょう。',
          choices: [
            DialogueChoice(
              id: 'book_1',
              text: 'いいでしょう',
              nextNodeId: 'transaction_complete',
              affectionChange: 15,
            ),
            DialogueChoice(
              id: 'book_2',
              text: '200ゴール望みたい',
              nextNodeId: 'price_negotiation',
              affectionChange: 10,
            ),
          ],
        ),
        'price_negotiation': DialogueNode(
          id: 'price_negotiation',
          text: 'ふむ... 商売ですからね。少し値切ってもいいでしょう。',
          choices: [
            DialogueChoice(
              id: 'price_1',
              text: 'ありがとう',
              nextNodeId: 'transaction_complete',
              affectionChange: 20,
            ),
            DialogueChoice(
              id: 'price_2',
              text: 'もっと値切りたい',
              nextNodeId: 'hard_negotiation',
              affectionChange: 5,
            ),
          ],
        ),
        'hard_negotiation': DialogueNode(
          id: 'hard_negotiation',
          text: 'これ以上は無理ですね。別の買い手を探した方がいいんじゃないですか？',
          choices: [
            DialogueChoice(
              id: 'hard_1',
              text: '元の値段でいい',
              nextNodeId: 'transaction_complete',
              affectionChange: 5,
            ),
            DialogueChoice(
              id: 'hard_2',
              text: 'わかった、やめておく',
              nextNodeId: 'farewell',
              affectionChange: -5,
            ),
          ],
        ),
        'transaction_complete': DialogueNode(
          id: 'transaction_complete',
          text: 'ありがとうございます。今後もご利用ください。',
          choices: [],
        ),
        'farewell': DialogueNode(
          id: 'farewell',
          text: 'また機会があれば。',
          choices: [],
        ),
      },
      startNodeId: 'greeting',
    );
    _trees['zephyr_007'] = tree;
  }

  /// 対話ツリーを取得
  DialogueTree? getDialogueTree(String npcId) {
    return _trees[npcId];
  }

  /// 特定のノードを取得
  DialogueNode? getDialogueNode(String npcId, String nodeId) {
    return _trees[npcId]?.nodes[nodeId];
  }
}

/// 対話ツリーモデル
class DialogueTree {
  final String npcId;
  final Map<String, DialogueNode> nodes;
  final String startNodeId;

  DialogueTree({
    required this.npcId,
    required this.nodes,
    required this.startNodeId,
  });

  /// 開始ノードを取得
  DialogueNode? getStartNode() {
    return nodes[startNodeId];
  }
}
