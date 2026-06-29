class ConversationTurn {
  final String speaker;    // 'ai' or 'user'
  final String text;       // 表示テキスト（英語）
  final String textJa;     // 日本語ヒント
  final String? hint;      // ユーザーターンの期待する応答ヒント

  const ConversationTurn({
    required this.speaker,
    required this.text,
    required this.textJa,
    this.hint,
  });
}

class ConversationScript {
  final String id;
  final String title;
  final String titleJa;
  final String emoji;
  final String situation;  // シチュエーション説明
  final List<ConversationTurn> turns;

  const ConversationScript({
    required this.id,
    required this.title,
    required this.titleJa,
    required this.emoji,
    required this.situation,
    required this.turns,
  });
}

final allConversations = <ConversationScript>[
  // ─── 1: はじめまして ──────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_1',
    title: 'Nice to Meet You',
    titleJa: 'はじめまして',
    emoji: '🤝',
    situation: '新しいクラスメートと自己紹介をしよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! My name is Alex. What is your name?', textJa: 'こんにちは！私はアレックスです。あなたの名前は？'),
      ConversationTurn(speaker: 'user', text: 'My name is ___', textJa: '自分の名前を言ってみよう', hint: 'My name is'),
      ConversationTurn(speaker: 'ai',   text: 'Nice to meet you! How old are you?', textJa: 'はじめまして！何歳ですか？'),
      ConversationTurn(speaker: 'user', text: 'I am ___ years old', textJa: '年齢を答えよう', hint: 'I am'),
      ConversationTurn(speaker: 'ai',   text: 'Cool! Where are you from?', textJa: 'すごい！どこから来ましたか？'),
      ConversationTurn(speaker: 'user', text: 'I am from Japan', textJa: '日本出身と答えよう', hint: 'I am from Japan'),
      ConversationTurn(speaker: 'ai',   text: 'That is great! Nice to meet you!', textJa: 'それはすごい！よろしくね！'),
    ],
  ),

  // ─── 2: レストランで ──────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_2',
    title: 'At the Restaurant',
    titleJa: 'レストランで',
    emoji: '🍽️',
    situation: 'レストランで注文してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Welcome to our restaurant. Can I help you?', textJa: 'いらっしゃいませ！何にしますか？'),
      ConversationTurn(speaker: 'user', text: 'Can I have a pizza please?', textJa: 'ピザをください、と言ってみよう', hint: 'Can I have'),
      ConversationTurn(speaker: 'ai',   text: 'Sure! Would you like something to drink?', textJa: '飲み物はいかがですか？'),
      ConversationTurn(speaker: 'user', text: 'I want water please', textJa: 'お水をください、と言ってみよう', hint: 'I want water'),
      ConversationTurn(speaker: 'ai',   text: 'How much is it? It is five dollars.', textJa: 'いくらですか？5ドルです。'),
      ConversationTurn(speaker: 'user', text: 'Thank you very much', textJa: 'ありがとうと言ってみよう', hint: 'Thank you'),
      ConversationTurn(speaker: 'ai',   text: 'You are welcome. Enjoy your meal!', textJa: 'どういたしまして。お楽しみください！'),
    ],
  ),

  // ─── 3: 買い物 ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_3',
    title: 'Shopping',
    titleJa: 'お買い物',
    emoji: '🛒',
    situation: 'お店で買い物してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Can I help you?', textJa: 'いらっしゃいませ！'),
      ConversationTurn(speaker: 'user', text: 'How much is this?', textJa: 'これはいくらですか？と聞いてみよう', hint: 'How much'),
      ConversationTurn(speaker: 'ai',   text: 'It is three hundred yen.', textJa: '300円です。'),
      ConversationTurn(speaker: 'user', text: 'I want to buy this please', textJa: 'これを買いたいです、と言ってみよう', hint: 'I want to buy'),
      ConversationTurn(speaker: 'ai',   text: 'OK! Do you have a bag?', textJa: '袋はお持ちですか？'),
      ConversationTurn(speaker: 'user', text: 'No thank you', textJa: '結構です、と答えよう', hint: 'No thank you'),
      ConversationTurn(speaker: 'ai',   text: 'OK! Here you go. Thank you!', textJa: 'はいどうぞ。ありがとうございます！'),
    ],
  ),

  // ─── 4: 道案内 ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_4',
    title: 'Asking Directions',
    titleJa: '道案内',
    emoji: '🗺️',
    situation: '迷子になった外国人に道を教えてあげよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Excuse me! Where is the park?', textJa: 'すみません！公園はどこですか？'),
      ConversationTurn(speaker: 'user', text: 'Go straight', textJa: 'まっすぐ行って、と言ってみよう', hint: 'Go straight'),
      ConversationTurn(speaker: 'ai',   text: 'Go straight? And then?', textJa: 'まっすぐ？それから？'),
      ConversationTurn(speaker: 'user', text: 'Turn left', textJa: '左に曲がって、と言ってみよう', hint: 'Turn left'),
      ConversationTurn(speaker: 'ai',   text: 'Turn left. Is it far from here?', textJa: '左に曲がる。ここから遠いですか？'),
      ConversationTurn(speaker: 'user', text: 'No, it is near', textJa: 'いいえ、近いです、と言ってみよう', hint: 'No it is near'),
      ConversationTurn(speaker: 'ai',   text: 'Thank you so much! You are very helpful!', textJa: 'ありがとうございます！とても助かりました！'),
    ],
  ),

  // ─── 5: 学校の話 ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_5',
    title: 'Talking About School',
    titleJa: '学校の話',
    emoji: '🏫',
    situation: '友達と好きな科目について話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hey! What subject do you like?', textJa: 'ねえ！好きな科目は何？'),
      ConversationTurn(speaker: 'user', text: 'I like science', textJa: '好きな科目を英語で言ってみよう', hint: 'I like'),
      ConversationTurn(speaker: 'ai',   text: 'Science is cool! Do you like math too?', textJa: '理科いいね！数学も好き？'),
      ConversationTurn(speaker: 'user', text: 'Yes I like math', textJa: 'はい、数学も好きです、と言ってみよう', hint: 'Yes I like math'),
      ConversationTurn(speaker: 'ai',   text: 'Wow! What do you want to be when you grow up?', textJa: 'すごい！大きくなったら何になりたい？'),
      ConversationTurn(speaker: 'user', text: 'I want to be a scientist', textJa: '科学者になりたい、と言ってみよう', hint: 'I want to be'),
      ConversationTurn(speaker: 'ai',   text: 'That is amazing! Study hard and you can do it!', textJa: 'それはすごい！頑張れば絶対なれるよ！'),
    ],
  ),

  // ─── 6: 病院で ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_6',
    title: 'At the Doctor',
    titleJa: '病院で',
    emoji: '🏥',
    situation: 'お医者さんと話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! How are you feeling today?', textJa: 'こんにちは！今日の体調はどうですか？'),
      ConversationTurn(speaker: 'user', text: 'I have a headache', textJa: '頭が痛いです、と言ってみよう', hint: 'I have a headache'),
      ConversationTurn(speaker: 'ai',   text: 'I see. Do you have a fever too?', textJa: 'わかりました。熱もありますか？'),
      ConversationTurn(speaker: 'user', text: 'Yes I have a fever', textJa: 'はい、熱があります、と言ってみよう', hint: 'Yes I have a fever'),
      ConversationTurn(speaker: 'ai',   text: 'Let me check. Please open your mouth.', textJa: '診てみましょう。口を開けてください。'),
      ConversationTurn(speaker: 'user', text: 'Okay', textJa: 'わかりました、と言ってみよう', hint: 'Okay'),
      ConversationTurn(speaker: 'ai',   text: 'You have a cold. Please take this medicine and rest.', textJa: '風邪ですね。このくすりを飲んで休んでください。'),
      ConversationTurn(speaker: 'user', text: 'Thank you doctor', textJa: 'ありがとうございます先生、と言ってみよう', hint: 'Thank you doctor'),
    ],
  ),

  // ─── 7: 教室で ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_7',
    title: 'In the Classroom',
    titleJa: '教室で',
    emoji: '📚',
    situation: '英語の授業で先生と話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Good morning everyone! Please open your books.', textJa: 'おはようございます！本を開いてください。'),
      ConversationTurn(speaker: 'user', text: 'Good morning', textJa: 'おはようございます、と言ってみよう', hint: 'Good morning'),
      ConversationTurn(speaker: 'ai',   text: 'Who can answer this question?', textJa: 'この問題に答えられる人は？'),
      ConversationTurn(speaker: 'user', text: 'Raise your hand', textJa: '手を挙げてみよう', hint: 'Raise your hand'),
      ConversationTurn(speaker: 'ai',   text: 'Yes? Do you have the answer?', textJa: 'はい？答えはわかりますか？'),
      ConversationTurn(speaker: 'user', text: 'I think the answer is ten', textJa: '答えは10だと思います、と言ってみよう', hint: 'I think the answer is'),
      ConversationTurn(speaker: 'ai',   text: 'That is correct! Well done! You are very smart.', textJa: '正解！よくできました！とても賢いですね。'),
    ],
  ),

  // ─── 8: 公園で友達と ──────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_8',
    title: 'At the Park',
    titleJa: '公園で友達と',
    emoji: '🌳',
    situation: '公園で友達と遊ぼう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! Do you want to play with me?', textJa: 'こんにちは！一緒に遊ばない？'),
      ConversationTurn(speaker: 'user', text: 'Yes let\'s play!', textJa: 'はい、遊ぼう！と言ってみよう', hint: 'Yes let\'s play'),
      ConversationTurn(speaker: 'ai',   text: 'Great! What game do you want to play?', textJa: 'やった！何をして遊びたい？'),
      ConversationTurn(speaker: 'user', text: 'Let\'s play tag', textJa: '鬼ごっこをしよう、と言ってみよう', hint: 'Let\'s play tag'),
      ConversationTurn(speaker: 'ai',   text: 'OK! You are it! Run!', textJa: 'いいよ！あなたが鬼！逃げて！'),
      ConversationTurn(speaker: 'user', text: 'I got you! Your turn!', textJa: 'つかまえた！あなたの番！と言ってみよう', hint: 'I got you'),
      ConversationTurn(speaker: 'ai',   text: 'Oh no! That was so fun! Let\'s play again!', textJa: 'やられた！すごく楽しかった！またやろう！'),
    ],
  ),

  // ─── 9: 電話で ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_9',
    title: 'On the Phone',
    titleJa: '電話で',
    emoji: '📱',
    situation: '友達に電話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello?', textJa: 'もしもし？'),
      ConversationTurn(speaker: 'user', text: 'Hello! This is Yuki. Is Tom there?', textJa: 'もしもし！ユキです。トムはいますか？と言ってみよう', hint: 'This is'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! This is Tom. Hi Yuki!', textJa: 'はい！トムです。ユキちゃん！'),
      ConversationTurn(speaker: 'user', text: 'Do you want to come to my house today?', textJa: '今日うちに来ない？と聞いてみよう', hint: 'Do you want to come'),
      ConversationTurn(speaker: 'ai',   text: 'That sounds great! What time?', textJa: 'いいね！何時に？'),
      ConversationTurn(speaker: 'user', text: 'Come at three o\'clock', textJa: '3時に来て、と言ってみよう', hint: 'Come at three'),
      ConversationTurn(speaker: 'ai',   text: 'OK! See you at three! Bye!', textJa: 'わかった！3時に会おう！バイバイ！'),
      ConversationTurn(speaker: 'user', text: 'Bye! See you later!', textJa: 'バイバイ！またね！と言ってみよう', hint: 'Bye see you'),
    ],
  ),

  // ─── 10: 図書館で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_10',
    title: 'At the Library',
    titleJa: '図書館で',
    emoji: '📖',
    situation: '図書館で本を借りてみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Welcome to the library! Can I help you?', textJa: '図書館へようこそ！何かお探しですか？'),
      ConversationTurn(speaker: 'user', text: 'I am looking for a book about animals', textJa: '動物の本を探しています、と言ってみよう', hint: 'I am looking for'),
      ConversationTurn(speaker: 'ai',   text: 'Animals! They are in section two. Follow me.', textJa: '動物！2番の棚にあります。ついてきてください。'),
      ConversationTurn(speaker: 'user', text: 'Thank you', textJa: 'ありがとうございます、と言ってみよう', hint: 'Thank you'),
      ConversationTurn(speaker: 'ai',   text: 'Here you are! Can I borrow this book?', textJa: 'こちらです！この本を借りたいですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes please. Can I borrow this?', textJa: 'はい、これを借りていいですか？と言ってみよう', hint: 'Can I borrow'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! Please bring it back in two weeks.', textJa: 'もちろん！2週間後に返してください。'),
      ConversationTurn(speaker: 'user', text: 'OK I will. Thank you very much!', textJa: 'わかりました。ありがとうございます！と言ってみよう', hint: 'Thank you very much'),
    ],
  ),

  // ─── 11: 動物園で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_11',
    title: 'At the Zoo',
    titleJa: '動物園で',
    emoji: '🦁',
    situation: '友達と動物園に来たよ！好きな動物を話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Wow! Look at the elephants! They are so big!', textJa: 'わあ！ゾウを見て！とても大きい！'),
      ConversationTurn(speaker: 'user', text: 'Yes! My favorite animal is the giraffe', textJa: '私の好きな動物はキリンです、と言ってみよう', hint: 'My favorite animal is'),
      ConversationTurn(speaker: 'ai',   text: 'Giraffes are so tall! What do giraffes eat?', textJa: 'キリンは背が高い！キリンは何を食べますか？'),
      ConversationTurn(speaker: 'user', text: 'They eat leaves from trees', textJa: '木の葉を食べます、と言ってみよう', hint: 'They eat leaves'),
      ConversationTurn(speaker: 'ai',   text: 'That is right! Let\'s go see the lions next!', textJa: 'その通り！次はライオンを見に行こう！'),
      ConversationTurn(speaker: 'user', text: 'OK! Let\'s go!', textJa: 'よし！行こう！と言ってみよう', hint: 'Let\'s go'),
      ConversationTurn(speaker: 'ai',   text: 'Roar! The lion is so cool! This is the best zoo!', textJa: 'ガオー！ライオンかっこいい！最高の動物園だ！'),
    ],
  ),

  // ─── 12: 誕生日パーティー ─────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_12',
    title: 'Birthday Party',
    titleJa: '誕生日パーティー',
    emoji: '🎂',
    situation: '友達の誕生日パーティーに来たよ！お祝いしよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Happy Birthday! This present is for you!', textJa: 'お誕生日おめでとう！これはあなたへのプレゼントです！'),
      ConversationTurn(speaker: 'user', text: 'Thank you so much! Can I open it now?', textJa: 'ありがとう！今開けていい？と言ってみよう', hint: 'Can I open it'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! Go ahead!', textJa: 'もちろん！どうぞ！'),
      ConversationTurn(speaker: 'user', text: 'Wow! I love it! Thank you!', textJa: 'わあ！大好き！ありがとう！と言ってみよう', hint: 'I love it'),
      ConversationTurn(speaker: 'ai',   text: 'You are welcome! How old are you today?', textJa: 'どういたしまして！今日で何歳になりましたか？'),
      ConversationTurn(speaker: 'user', text: 'I am ten years old today!', textJa: '今日で10歳になりました！と言ってみよう', hint: 'I am ten years old'),
      ConversationTurn(speaker: 'ai',   text: 'Ten years old! That is wonderful! Let\'s eat cake!', textJa: '10歳！素晴らしい！ケーキを食べよう！'),
    ],
  ),

  // ─── 13: 天気の話 ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_13',
    title: 'Talking About the Weather',
    titleJa: '天気の話',
    emoji: '☀️',
    situation: '今日の天気について話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Good morning! How is the weather today?', textJa: 'おはよう！今日の天気はどう？'),
      ConversationTurn(speaker: 'user', text: 'It is sunny and warm today!', textJa: '今日は晴れて暖かいです！と言ってみよう', hint: 'It is sunny'),
      ConversationTurn(speaker: 'ai',   text: 'Great! Let\'s go outside and play!', textJa: 'よかった！外に出て遊ぼう！'),
      ConversationTurn(speaker: 'user', text: 'Yes! But I need my hat', textJa: 'うん！でも帽子が必要だよ、と言ってみよう', hint: 'I need my hat'),
      ConversationTurn(speaker: 'ai',   text: 'Good idea! It is very bright. What is your favorite weather?', textJa: 'いい考え！すごく明るいね。好きな天気は何ですか？'),
      ConversationTurn(speaker: 'user', text: 'I like snowy weather', textJa: '雪の天気が好きです、と言ってみよう', hint: 'I like snowy'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Snow is so beautiful and fun!', textJa: '私も！雪はとても美しくて楽しい！'),
    ],
  ),

  // ─── 14: スーパーで ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_14',
    title: 'At the Supermarket',
    titleJa: 'スーパーで',
    emoji: '🛒',
    situation: 'お母さんと一緒にスーパーで買い物しよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'We need to buy some vegetables. Do you see the carrots?', textJa: '野菜を買わないといけないね。にんじんはどこ？'),
      ConversationTurn(speaker: 'user', text: 'Yes! The carrots are over there', textJa: 'にんじんはあそこにあります、と言ってみよう', hint: 'The carrots are over there'),
      ConversationTurn(speaker: 'ai',   text: 'Great! How many do we need?', textJa: 'よかった！いくつ必要かな？'),
      ConversationTurn(speaker: 'user', text: 'We need three carrots', textJa: 'にんじんが3本必要です、と言ってみよう', hint: 'We need three'),
      ConversationTurn(speaker: 'ai',   text: 'Perfect! Now let\'s find the apples. Do you like apples?', textJa: 'よし！次はりんごを探そう。りんごは好き？'),
      ConversationTurn(speaker: 'user', text: 'Yes I love apples! They are sweet', textJa: 'はい、りんごが大好き！甘いね、と言ってみよう', hint: 'I love apples'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Let\'s buy some apples too. Good job shopping today!', textJa: '私も！りんごも買おう。今日のお買い物上手だったね！'),
    ],
  ),

  // ─── 15: 旅行の計画 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_15',
    title: 'Planning a Trip',
    titleJa: '旅行の計画',
    emoji: '✈️',
    situation: '夏休みの旅行について話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Summer vacation is coming! Where do you want to go?', textJa: '夏休みが近づいてきた！どこに行きたい？'),
      ConversationTurn(speaker: 'user', text: 'I want to go to the beach!', textJa: 'ビーチに行きたい！と言ってみよう', hint: 'I want to go to'),
      ConversationTurn(speaker: 'ai',   text: 'The beach sounds fun! What will you do there?', textJa: 'ビーチ楽しそう！そこで何をしますか？'),
      ConversationTurn(speaker: 'user', text: 'I will swim and build sandcastles', textJa: '泳いで砂のお城を作ります、と言ってみよう', hint: 'I will swim'),
      ConversationTurn(speaker: 'ai',   text: 'Sounds amazing! How long will you stay?', textJa: 'すごそう！何日間滞在しますか？'),
      ConversationTurn(speaker: 'user', text: 'We will stay for three days', textJa: '3日間滞在します、と言ってみよう', hint: 'We will stay'),
      ConversationTurn(speaker: 'ai',   text: 'Three days! That is perfect! Have a wonderful trip!', textJa: '3日間！最高！素晴らしい旅になるといいね！'),
    ],
  ),

  // ─── 16: 音楽の時間 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_16',
    title: 'Music Time',
    titleJa: '音楽の時間',
    emoji: '🎵',
    situation: '音楽の授業で先生と話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Today we are going to sing a song! Do you like singing?', textJa: '今日は歌を歌います！歌うのは好きですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes I love singing!', textJa: 'はい、歌うのが大好きです！と言ってみよう', hint: 'I love singing'),
      ConversationTurn(speaker: 'ai',   text: 'Wonderful! Can you play any instruments?', textJa: '素晴らしい！楽器は弾けますか？'),
      ConversationTurn(speaker: 'user', text: 'Yes I can play the piano', textJa: 'はい、ピアノが弾けます、と言ってみよう', hint: 'I can play the piano'),
      ConversationTurn(speaker: 'ai',   text: 'Amazing! Let\'s sing together. Are you ready?', textJa: 'すごい！一緒に歌いましょう。準備はいいですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes I am ready! Let\'s sing!', textJa: 'はい、準備OK！歌おう！と言ってみよう', hint: 'I am ready'),
      ConversationTurn(speaker: 'ai',   text: 'Great! You have a beautiful voice! Well done!', textJa: 'すごい！きれいな声だね！よくできました！'),
    ],
  ),

  // ─── 17: キャンプで ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_17',
    title: 'Camping Trip',
    titleJa: 'キャンプで',
    emoji: '⛺',
    situation: '家族でキャンプに来たよ！楽しんでみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'We are at the campsite! Help me put up the tent please.', textJa: 'キャンプ場に着いた！テントを張るのを手伝って。'),
      ConversationTurn(speaker: 'user', text: 'OK! What do I do first?', textJa: 'わかった！最初に何をすればいい？と言ってみよう', hint: 'What do I do first'),
      ConversationTurn(speaker: 'ai',   text: 'Hold this pole and push it into the ground.', textJa: 'このポールを持って地面に刺して。'),
      ConversationTurn(speaker: 'user', text: 'Like this? Is that right?', textJa: 'こうやって？合ってる？と言ってみよう', hint: 'Is that right'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! Perfect! Now let\'s make a campfire. Are you hungry?', textJa: 'そう！完璧！じゃあ焚き火を作ろう。お腹すいた？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I am very hungry! What are we cooking?', textJa: 'うん！すごくお腹すいた！何を作るの？と言ってみよう', hint: 'I am very hungry'),
      ConversationTurn(speaker: 'ai',   text: 'We are having curry! Nothing tastes better than campfire food!', textJa: 'カレーだよ！キャンプで食べるご飯が一番おいしい！'),
    ],
  ),

  // ─── 18: 学校で友達を作る ─────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_18',
    title: 'Making Friends at School',
    titleJa: '友達を作ろう',
    emoji: '🤝',
    situation: '転校してきた友達に話しかけてみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! You are new here, right? I am Sam!', textJa: 'こんにちは！転校してきたんでしょ？僕はサムです！'),
      ConversationTurn(speaker: 'user', text: 'Yes! I am new here. My name is Yuki!', textJa: 'はい！転校してきました。ユキです！と言ってみよう', hint: 'My name is'),
      ConversationTurn(speaker: 'ai',   text: 'Nice to meet you Yuki! Where are you from?', textJa: 'はじめまして、ユキさん！どこから来ましたか？'),
      ConversationTurn(speaker: 'user', text: 'I am from Osaka. I moved here last week', textJa: '大阪から来ました。先週引っ越してきました、と言ってみよう', hint: 'I am from'),
      ConversationTurn(speaker: 'ai',   text: 'Osaka! Cool! Do you like soccer? I love soccer!', textJa: '大阪！かっこいい！サッカーは好き？僕はサッカーが大好き！'),
      ConversationTurn(speaker: 'user', text: 'Yes I like soccer too! Let\'s play together!', textJa: 'はい、私もサッカーが好き！一緒に遊ぼう！と言ってみよう', hint: 'Let\'s play together'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! We are going to be great friends! See you at lunch!', textJa: 'やった！きっといい友達になれるよ！お昼休みにまた！'),
    ],
  ),

  // ─── 19: おじいちゃんおばあちゃんに電話 ──────────────────────────────────
  ConversationScript(
    id: 'conv_19',
    title: 'Calling Grandparents',
    titleJa: 'おじいちゃんに電話',
    emoji: '📞',
    situation: 'おじいちゃんに英語で電話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Is that you? How are you doing?', textJa: 'もしもし！元気にしてるかな？'),
      ConversationTurn(speaker: 'user', text: 'Hi Grandpa! I am fine thank you!', textJa: 'おじいちゃん！元気だよ、ありがとう！と言ってみよう', hint: 'I am fine'),
      ConversationTurn(speaker: 'ai',   text: 'Good! How is school going?', textJa: 'よかった！学校はどうだい？'),
      ConversationTurn(speaker: 'user', text: 'School is great! I got a good grade on my test!', textJa: '学校は楽しいよ！テストでいい点が取れた！と言ってみよう', hint: 'I got a good grade'),
      ConversationTurn(speaker: 'ai',   text: 'That is wonderful! I am so proud of you! What did you study?', textJa: 'それは素晴らしい！誇らしいよ！何を勉強したの？'),
      ConversationTurn(speaker: 'user', text: 'I studied English! I am learning a lot!', textJa: '英語を勉強したよ！たくさん学んでいるよ！と言ってみよう', hint: 'I am learning'),
      ConversationTurn(speaker: 'ai',   text: 'Keep it up! I will visit you next month. I love you!', textJa: '頑張って！来月会いに行くよ。大好きだよ！'),
      ConversationTurn(speaker: 'user', text: 'I love you too Grandpa! See you next month!', textJa: '私も大好き！来月会おうね！と言ってみよう', hint: 'See you next month'),
    ],
  ),

  // ─── 20: 夢について話す ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_20',
    title: 'Talking About Dreams',
    titleJa: '将来の夢',
    emoji: '🌟',
    situation: '将来の夢について友達と話してみよう！',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'What do you want to be when you grow up?', textJa: '大きくなったら何になりたい？'),
      ConversationTurn(speaker: 'user', text: 'I want to be a doctor and help sick people', textJa: 'お医者さんになって病気の人を助けたい、と言ってみよう', hint: 'I want to be a doctor'),
      ConversationTurn(speaker: 'ai',   text: 'That is a wonderful dream! Why do you want to be a doctor?', textJa: 'それは素晴らしい夢！なぜお医者さんになりたいの？'),
      ConversationTurn(speaker: 'user', text: 'Because I want to help people feel better', textJa: '人々を元気にしたいから、と言ってみよう', hint: 'Because I want to help'),
      ConversationTurn(speaker: 'ai',   text: 'That is very kind! What about you? I want to be an astronaut!', textJa: 'とても優しいね！私は宇宙飛行士になりたい！'),
      ConversationTurn(speaker: 'user', text: 'Wow! That is so cool! You can go to space!', textJa: 'わあ！すごいかっこいい！宇宙に行けるね！と言ってみよう', hint: 'That is so cool'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! Let\'s both work hard and make our dreams come true!', textJa: 'そう！二人とも頑張って夢を叶えよう！'),
    ],
  ),

  // ─── 21: 図書館で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_21',
    title: 'At the Library',
    titleJa: '図書館で',
    emoji: '📚',
    situation: 'You are at the library looking for a book.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Can I help you?', textJa: 'こんにちは！お手伝いできますか？'),
      ConversationTurn(speaker: 'user', text: 'Yes, please. I\'m looking for a book about animals.', textJa: 'はい、お願いします。動物の本を探しています。', hint: 'I\'m looking for'),
      ConversationTurn(speaker: 'ai',   text: 'Sure! What kind of animals do you like?', textJa: 'もちろん！どんな動物が好きですか？'),
      ConversationTurn(speaker: 'user', text: 'I like dogs and cats.', textJa: '犬と猫が好きです。', hint: 'I like'),
      ConversationTurn(speaker: 'ai',   text: 'Great! We have a wonderful book about pets. Follow me.', textJa: 'いいですね！ペットについての素晴らしい本があります。ついてきてください。'),
      ConversationTurn(speaker: 'user', text: 'Thank you! How many days can I borrow it?', textJa: 'ありがとうございます！何日間借りられますか？', hint: 'How many days'),
      ConversationTurn(speaker: 'ai',   text: 'You can keep it for two weeks.', textJa: '2週間借りられます。'),
      ConversationTurn(speaker: 'user', text: 'That\'s great! I will bring it back on time.', textJa: 'それは良かった！ちゃんと返します。', hint: 'I will bring it back'),
      ConversationTurn(speaker: 'ai',   text: 'Wonderful! Enjoy reading. Come back anytime!', textJa: '素晴らしい！楽しんで読んでね。またいつでも来てください！'),
    ],
  ),

  // ─── 22: 病院で ───────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_22',
    title: 'At the Hospital',
    titleJa: '病院で',
    emoji: '🏥',
    situation: 'You are at the hospital with a stomachache.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Please come in. What is the matter?', textJa: 'こんにちは！どうぞ入ってください。どうしましたか？'),
      ConversationTurn(speaker: 'user', text: 'I have a stomachache. It hurts a lot.', textJa: 'お腹が痛いです。とても痛い。', hint: 'I have a stomachache'),
      ConversationTurn(speaker: 'ai',   text: 'I see. When did the pain start?', textJa: 'わかりました。いつから痛みが始まりましたか？'),
      ConversationTurn(speaker: 'user', text: 'It started this morning after breakfast.', textJa: '朝ごはんの後、今朝から始まりました。', hint: 'It started this morning'),
      ConversationTurn(speaker: 'ai',   text: 'Did you eat anything unusual yesterday?', textJa: '昨日、変なものを食べましたか？'),
      ConversationTurn(speaker: 'user', text: 'I ate a lot of ice cream last night.', textJa: '昨夜、アイスクリームをたくさん食べました。', hint: 'I ate a lot of'),
      ConversationTurn(speaker: 'ai',   text: 'I see. Please lie down and let me check your stomach.', textJa: 'なるほど。横になってお腹を診させてください。'),
      ConversationTurn(speaker: 'user', text: 'OK. Is it serious, doctor?', textJa: 'わかりました。深刻ですか、先生？', hint: 'Is it serious'),
      ConversationTurn(speaker: 'ai',   text: 'Not too serious! Take this medicine and rest today.', textJa: 'そんなに深刻じゃないよ！この薬を飲んで今日は休んでください。'),
    ],
  ),

  // ─── 23: 公園で遊ぶ ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_23',
    title: 'Playing at the Park',
    titleJa: '公園で遊ぶ',
    emoji: '🌳',
    situation: 'You are playing at the park with a new friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! Do you want to play on the swings?', textJa: 'こんにちは！ブランコで遊ばない？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I love the swings! Let\'s go!', textJa: 'うん！ブランコが大好き！行こう！', hint: 'I love the swings'),
      ConversationTurn(speaker: 'ai',   text: 'Wow you are swinging so high! Are you scared?', textJa: 'わあ、すごく高く揺れてるね！怖くない？'),
      ConversationTurn(speaker: 'user', text: 'No, I\'m not scared. It\'s really fun!', textJa: 'いいえ、怖くないです。とても楽しい！', hint: 'I\'m not scared'),
      ConversationTurn(speaker: 'ai',   text: 'You\'re so brave! Do you want to try the slide next?', textJa: '勇敢だね！次は滑り台やってみる？'),
      ConversationTurn(speaker: 'user', text: 'Sure! I\'ll race you to the slide!', textJa: 'もちろん！滑り台まで競走しよう！', hint: 'I\'ll race you'),
      ConversationTurn(speaker: 'ai',   text: 'Ready, set, go! Haha, you are so fast!', textJa: 'よーいドン！ははは、すごく速いね！'),
      ConversationTurn(speaker: 'user', text: 'I won! This is the best park ever!', textJa: '勝った！最高の公園だ！', hint: 'I won'),
    ],
  ),

  // ─── 24: 週末の計画 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_24',
    title: 'Making Weekend Plans',
    titleJa: '週末の計画',
    emoji: '📅',
    situation: 'You and your friend are making plans for the weekend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hey! What are you doing this weekend?', textJa: 'ねえ！週末は何するの？'),
      ConversationTurn(speaker: 'user', text: 'I don\'t have any plans yet. What about you?', textJa: 'まだ何も計画してないよ。あなたは？', hint: 'I don\'t have any plans'),
      ConversationTurn(speaker: 'ai',   text: 'My family is going to the aquarium on Saturday. Do you want to come?', textJa: '土曜日に家族で水族館に行くんだ。一緒に来る？'),
      ConversationTurn(speaker: 'user', text: 'That sounds amazing! I love fish!', textJa: 'それはすごい！魚が大好き！', hint: 'That sounds amazing'),
      ConversationTurn(speaker: 'ai',   text: 'Great! We leave at ten in the morning. Is that OK?', textJa: 'よかった！朝10時に出発するよ。大丈夫？'),
      ConversationTurn(speaker: 'user', text: 'Yes, that\'s perfect! I will ask my mom first.', textJa: 'うん、ちょうどいい！まずお母さんに聞いてみます。', hint: 'I will ask my mom'),
      ConversationTurn(speaker: 'ai',   text: 'Sure! Let me know what she says.', textJa: 'もちろん！何て言ったか教えてね。'),
      ConversationTurn(speaker: 'user', text: 'She said yes! I\'m so excited!', textJa: 'いいよって言ってくれた！すごく楽しみ！', hint: 'She said yes'),
      ConversationTurn(speaker: 'ai',   text: 'Yay! See you Saturday! It\'s going to be so fun!', textJa: 'やった！土曜日に会おう！めちゃくちゃ楽しくなるよ！'),
    ],
  ),

  // ─── 25: 道を聞く ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_25',
    title: 'Asking for Directions',
    titleJa: '道を聞く',
    emoji: '🗺️',
    situation: 'You are lost and asking someone for directions.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'You look lost. Can I help you?', textJa: '迷子みたいだね。手伝おうか？'),
      ConversationTurn(speaker: 'user', text: 'Yes please. Where is the train station?', textJa: 'はい、お願いします。駅はどこですか？', hint: 'Where is the'),
      ConversationTurn(speaker: 'ai',   text: 'The station is not far. Go straight down this road.', textJa: '駅はそんなに遠くないよ。この道をまっすぐ行って。'),
      ConversationTurn(speaker: 'user', text: 'Go straight. Then what do I do?', textJa: 'まっすぐ行く。それから何をすればいい？', hint: 'Then what'),
      ConversationTurn(speaker: 'ai',   text: 'Turn right at the big park. You will see the station.', textJa: '大きな公園で右に曲がって。駅が見えるよ。'),
      ConversationTurn(speaker: 'user', text: 'Turn right at the park. How far is it?', textJa: '公園で右に曲がる。どのくらい遠い？', hint: 'How far is it'),
      ConversationTurn(speaker: 'ai',   text: 'About five minutes on foot. It\'s easy to find.', textJa: '歩いて5分ぐらいだよ。簡単に見つかるよ。'),
      ConversationTurn(speaker: 'user', text: 'Thank you so much! You are very kind.', textJa: 'ありがとうございます！とても親切ですね。', hint: 'Thank you so much'),
      ConversationTurn(speaker: 'ai',   text: 'No problem! Have a safe trip!', textJa: 'どういたしまして！気をつけてね！'),
    ],
  ),

  // ─── 26: 郵便局で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_26',
    title: 'At the Post Office',
    titleJa: '郵便局で',
    emoji: '📮',
    situation: 'You are at the post office to send a letter.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! How can I help you today?', textJa: 'こんにちは！今日はどのようなご用件ですか？'),
      ConversationTurn(speaker: 'user', text: 'I want to send a letter to my friend.', textJa: '友達に手紙を送りたいです。', hint: 'I want to send'),
      ConversationTurn(speaker: 'ai',   text: 'Sure! Is your friend in Japan or another country?', textJa: 'もちろん！友達は日本ですか、それとも別の国ですか？'),
      ConversationTurn(speaker: 'user', text: 'She is in America. It\'s a birthday card.', textJa: '彼女はアメリカにいます。誕生日カードです。', hint: 'She is in America'),
      ConversationTurn(speaker: 'ai',   text: 'How nice! Please put the letter on the scale.', textJa: '素敵ですね！手紙を秤に乗せてください。'),
      ConversationTurn(speaker: 'user', text: 'OK. How much does it cost to send it?', textJa: 'わかりました。送るのにいくらかかりますか？', hint: 'How much does it cost'),
      ConversationTurn(speaker: 'ai',   text: 'It costs one hundred and thirty yen. Do you need a stamp?', textJa: '130円です。切手は必要ですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes please. Here is two hundred yen.', textJa: 'はい、お願いします。200円です。', hint: 'Here is'),
      ConversationTurn(speaker: 'ai',   text: 'Here is your change. Your card will arrive in one week!', textJa: 'おつりどうぞ。カードは1週間で届きますよ！'),
    ],
  ),

  // ─── 27: スポーツについて ─────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_27',
    title: 'Talking About Sports',
    titleJa: 'スポーツについて',
    emoji: '⚽',
    situation: 'You are talking with a friend about your favorite sports.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Do you like sports? What is your favorite?', textJa: 'スポーツは好き？一番好きなのは？'),
      ConversationTurn(speaker: 'user', text: 'I love soccer! I play it every weekend.', textJa: 'サッカーが大好き！毎週末やってるよ。', hint: 'I love soccer'),
      ConversationTurn(speaker: 'ai',   text: 'Cool! What position do you play?', textJa: 'かっこいい！どのポジションやってるの？'),
      ConversationTurn(speaker: 'user', text: 'I play striker. I like to score goals!', textJa: 'ストライカーやってるよ。ゴールを決めるのが好き！', hint: 'I play striker'),
      ConversationTurn(speaker: 'ai',   text: 'Awesome! I play basketball. Do you like basketball too?', textJa: 'すごい！私はバスケットボールやってるよ。バスケも好き？'),
      ConversationTurn(speaker: 'user', text: 'Yes, a little. But soccer is my favorite.', textJa: 'うん、少しね。でもサッカーが一番好き。', hint: 'Yes, a little'),
      ConversationTurn(speaker: 'ai',   text: 'Let\'s play soccer together sometime!', textJa: 'いつかサッカー一緒にやろう！'),
      ConversationTurn(speaker: 'user', text: 'That would be great! I\'ll teach you some moves!', textJa: 'いいね！技を教えてあげるよ！', hint: 'I\'ll teach you'),
    ],
  ),

  // ─── 28: 料理する ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_28',
    title: 'Cooking Together',
    titleJa: '料理する',
    emoji: '🍳',
    situation: 'You are cooking lunch with your mom.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Let\'s make sandwiches for lunch! Can you help me?', textJa: 'ランチにサンドイッチを作ろう！手伝ってくれる？'),
      ConversationTurn(speaker: 'user', text: 'Sure! What do I need to do?', textJa: 'もちろん！何をすればいい？', hint: 'What do I need to do'),
      ConversationTurn(speaker: 'ai',   text: 'First, wash your hands. Then we need bread and cheese.', textJa: 'まず手を洗って。それからパンとチーズが必要だよ。'),
      ConversationTurn(speaker: 'user', text: 'OK, my hands are clean. Where is the cheese?', textJa: 'わかった、手を洗ったよ。チーズはどこ？', hint: 'Where is the cheese'),
      ConversationTurn(speaker: 'ai',   text: 'It\'s in the fridge. Can you get it for me?', textJa: '冷蔵庫に入ってるよ。取ってきてくれる？'),
      ConversationTurn(speaker: 'user', text: 'Got it! Should I put it on the bread now?', textJa: '取ってきた！もうパンに乗せていい？', hint: 'Should I put it'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! Great job! You are a good cook!', textJa: 'そう！よくできました！料理上手だね！'),
      ConversationTurn(speaker: 'user', text: 'Thank you! Cooking is really fun!', textJa: 'ありがとう！料理ってすごく楽しい！', hint: 'Cooking is really fun'),
      ConversationTurn(speaker: 'ai',   text: 'It is! Let\'s eat. Enjoy your sandwich!', textJa: 'そうだね！食べよう。サンドイッチを楽しんでね！'),
    ],
  ),

  // ─── 29: 教室で ───────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_29',
    title: 'In the Classroom',
    titleJa: '教室で',
    emoji: '📝',
    situation: 'You are helping a classmate understand a math problem.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Excuse me. I don\'t understand this math problem.', textJa: 'すみません。この数学の問題がわかりません。'),
      ConversationTurn(speaker: 'user', text: 'Sure, I can help you! Which problem is it?', textJa: 'もちろん、手伝うよ！どの問題？', hint: 'I can help you'),
      ConversationTurn(speaker: 'ai',   text: 'It\'s number five. What is twenty plus thirty?', textJa: '5番です。20たす30はいくつ？'),
      ConversationTurn(speaker: 'user', text: 'That\'s easy! The answer is fifty.', textJa: '簡単だよ！答えは50です。', hint: 'The answer is'),
      ConversationTurn(speaker: 'ai',   text: 'Oh, I see! Thank you so much! You\'re really smart.', textJa: 'あ、わかった！ありがとう！本当に賢いね。'),
      ConversationTurn(speaker: 'user', text: 'No problem! Do you need help with number six too?', textJa: '大丈夫！6番も手伝おうか？', hint: 'Do you need help'),
      ConversationTurn(speaker: 'ai',   text: 'Yes please! That would be great!', textJa: 'はい、お願いします！助かります！'),
      ConversationTurn(speaker: 'user', text: 'OK, let\'s solve it together step by step.', textJa: 'じゃあ、一緒に一つずつ解いていこう。', hint: 'Let\'s solve it together'),
    ],
  ),

  // ─── 30: 映画を見る ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_30',
    title: 'Watching a Movie',
    titleJa: '映画を見る',
    emoji: '🎬',
    situation: 'You are at the movie theater with a friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'I\'m so excited! What movie are we watching?', textJa: 'わくわくする！何の映画を見るの？'),
      ConversationTurn(speaker: 'user', text: 'We\'re watching the new superhero movie!', textJa: '新しいスーパーヒーロー映画を見るよ！', hint: 'We\'re watching'),
      ConversationTurn(speaker: 'ai',   text: 'Amazing! Do you want popcorn? I\'m buying!', textJa: 'すごい！ポップコーン食べる？おごるよ！'),
      ConversationTurn(speaker: 'user', text: 'Yes please! A large one with butter.', textJa: 'はい、お願い！バター付きのLサイズを。', hint: 'A large one with'),
      ConversationTurn(speaker: 'ai',   text: 'Great choice! The movie is starting. Let\'s find our seats!', textJa: 'いい選択！映画が始まるよ。席を探そう！'),
      ConversationTurn(speaker: 'user', text: 'Here are our seats! Right in the middle!', textJa: '席はここだよ！ちょうど真ん中！', hint: 'Here are our seats'),
      ConversationTurn(speaker: 'ai',   text: 'Perfect seats! Shhh, the movie is starting!', textJa: '完璧な席！しー、映画が始まったよ！'),
      ConversationTurn(speaker: 'user', text: 'This is so exciting! I love this movie!', textJa: 'めちゃくちゃ楽しみ！この映画大好き！', hint: 'This is so exciting'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Best movie night ever!', textJa: '私も！最高のムービーナイトだ！'),
    ],
  ),

  // ─── 31: 海で ─────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_31',
    title: 'At the Beach',
    titleJa: '海で',
    emoji: '🏖️',
    situation: 'You are spending a sunny day at the beach.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'What a beautiful day! The ocean is so blue!', textJa: 'なんて良い天気！海がとても青い！'),
      ConversationTurn(speaker: 'user', text: 'Yes! Let\'s swim! The water looks warm.', textJa: 'そうだね！泳ごう！水が暖かそう。', hint: 'Let\'s swim'),
      ConversationTurn(speaker: 'ai',   text: 'Great! Don\'t forget to put on sunscreen first!', textJa: 'いいね！まず日焼け止めを塗るのを忘れずに！'),
      ConversationTurn(speaker: 'user', text: 'OK! I already put some on. Can we build a sandcastle?', textJa: 'わかった！もう塗ったよ。砂のお城を作ろう！', hint: 'Can we build'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! Let\'s make a really big one!', textJa: 'もちろん！すごく大きいのを作ろう！'),
      ConversationTurn(speaker: 'user', text: 'I\'ll make the walls. You make the towers!', textJa: '私が壁を作るよ。あなたが塔を作って！', hint: 'I\'ll make the walls'),
      ConversationTurn(speaker: 'ai',   text: 'This is the best sandcastle ever! Let\'s take a photo!', textJa: '最高の砂のお城だ！写真を撮ろう！'),
      ConversationTurn(speaker: 'user', text: 'Great idea! Then let\'s go swim in the ocean!', textJa: 'いい考え！それから海で泳ごう！', hint: 'Then let\'s go swim'),
    ],
  ),

  // ─── 32: 服を買う ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_32',
    title: 'Shopping for Clothes',
    titleJa: '服を買う',
    emoji: '👕',
    situation: 'You are shopping for a new shirt at a clothing store.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Welcome! Are you looking for anything special today?', textJa: 'いらっしゃいませ！今日は何かお探しですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes, I\'m looking for a blue T-shirt.', textJa: 'はい、青いTシャツを探しています。', hint: 'I\'m looking for'),
      ConversationTurn(speaker: 'ai',   text: 'We have many blue shirts! What size are you?', textJa: '青いシャツがたくさんありますよ！サイズは何ですか？'),
      ConversationTurn(speaker: 'user', text: 'I think I\'m a medium. Can I try this one?', textJa: 'Mサイズだと思います。これを試着できますか？', hint: 'Can I try'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! The fitting room is over there.', textJa: 'もちろんです！試着室はあちらです。'),
      ConversationTurn(speaker: 'user', text: 'It fits perfectly! How much is it?', textJa: 'ぴったり！いくらですか？', hint: 'How much is it'),
      ConversationTurn(speaker: 'ai',   text: 'It\'s one thousand two hundred yen. It looks great on you!', textJa: '1200円です。よく似合っていますよ！'),
      ConversationTurn(speaker: 'user', text: 'I\'ll take it! Here is my money.', textJa: '買います！はい、お金です。', hint: 'I\'ll take it'),
      ConversationTurn(speaker: 'ai',   text: 'Thank you! Enjoy your new shirt!', textJa: 'ありがとうございます！新しいシャツを楽しんでください！'),
    ],
  ),

  // ─── 33: 好きな教科 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_33',
    title: 'Talking About School Subjects',
    titleJa: '好きな教科',
    emoji: '📐',
    situation: 'You are talking with a new classmate about your favorite school subjects.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! What is your favorite subject at school?', textJa: 'こんにちは！学校で一番好きな教科は何ですか？'),
      ConversationTurn(speaker: 'user', text: 'My favorite subject is art. I love drawing!', textJa: '図工が一番好きです。絵を描くのが大好き！', hint: 'My favorite subject is'),
      ConversationTurn(speaker: 'ai',   text: 'That\'s so cool! Are you good at drawing?', textJa: 'すごい！絵は得意ですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I draw animals and nature. What about you?', textJa: 'うん！動物や自然を描きます。あなたは？', hint: 'What about you'),
      ConversationTurn(speaker: 'ai',   text: 'I love science! We do fun experiments in class.', textJa: '理科が大好き！授業で楽しい実験をするよ。'),
      ConversationTurn(speaker: 'user', text: 'That sounds interesting! Is science hard?', textJa: 'おもしろそう！理科って難しい？', hint: 'Is science hard'),
      ConversationTurn(speaker: 'ai',   text: 'Sometimes, but our teacher makes it really fun.', textJa: '時々難しいけど、先生がとても楽しくしてくれるよ。'),
      ConversationTurn(speaker: 'user', text: 'I want to try science then! It sounds great.', textJa: 'じゃあ理科もやってみたい！よさそうだね。', hint: 'I want to try'),
    ],
  ),

  // ─── 34: 雨の日 ───────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_34',
    title: 'A Rainy Day',
    titleJa: '雨の日',
    emoji: '🌧️',
    situation: 'It is raining outside and you are at home with your friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'It\'s raining so hard today! We can\'t go outside.', textJa: '今日はすごく雨が降ってる！外に出られないね。'),
      ConversationTurn(speaker: 'user', text: 'That\'s too bad. What shall we do inside?', textJa: 'それは残念。家の中で何をしよう？', hint: 'What shall we do'),
      ConversationTurn(speaker: 'ai',   text: 'We could play board games or do a puzzle!', textJa: 'ボードゲームかパズルをやろうよ！'),
      ConversationTurn(speaker: 'user', text: 'Let\'s do a puzzle! I love puzzles.', textJa: 'パズルをしよう！パズルが大好き。', hint: 'Let\'s do a puzzle'),
      ConversationTurn(speaker: 'ai',   text: 'Great! I have a five hundred piece puzzle. Is that OK?', textJa: 'いいね！500ピースのパズルがあるよ。大丈夫？'),
      ConversationTurn(speaker: 'user', text: 'Five hundred pieces? That\'s a lot! Let\'s try!', textJa: '500ピース？たくさんだ！でもやってみよう！', hint: 'Let\'s try'),
      ConversationTurn(speaker: 'ai',   text: 'Here it is! It\'s a picture of the ocean.', textJa: 'ここにあるよ！海の絵だよ。'),
      ConversationTurn(speaker: 'user', text: 'Beautiful! I\'ll start with the blue pieces.', textJa: 'きれい！青いピースから始めるよ。', hint: 'I\'ll start with'),
      ConversationTurn(speaker: 'ai',   text: 'Good idea! Rainy days are perfect for puzzles!', textJa: 'いいアイデア！雨の日はパズル日和だね！'),
    ],
  ),

  // ─── 35: ファストフードで ─────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_35',
    title: 'At a Fast Food Restaurant',
    titleJa: 'ファストフードで',
    emoji: '🍔',
    situation: 'You are ordering food at a fast food restaurant.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Welcome! What would you like to order?', textJa: 'いらっしゃいませ！ご注文はいかがですか？'),
      ConversationTurn(speaker: 'user', text: 'I\'d like a hamburger and some fries, please.', textJa: 'ハンバーガーとフライドポテトをお願いします。', hint: 'I\'d like a hamburger'),
      ConversationTurn(speaker: 'ai',   text: 'Would you like a drink with that?', textJa: 'ドリンクはいかがですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes, a medium cola please.', textJa: 'はい、Mサイズのコーラをお願いします。', hint: 'A medium cola'),
      ConversationTurn(speaker: 'ai',   text: 'Would you like to make it a combo meal? It\'s cheaper!', textJa: 'セットにしますか？お得ですよ！'),
      ConversationTurn(speaker: 'user', text: 'Yes please! How much is the combo?', textJa: 'はい、お願いします！セットはいくらですか？', hint: 'How much is'),
      ConversationTurn(speaker: 'ai',   text: 'It\'s seven hundred yen. Eat in or take out?', textJa: '700円です。店内でお召し上がりですか、お持ち帰りですか？'),
      ConversationTurn(speaker: 'user', text: 'Eat in please. I\'m really hungry!', textJa: '店内でいただきます。本当にお腹すいてる！', hint: 'Eat in please'),
      ConversationTurn(speaker: 'ai',   text: 'Great! Your order will be ready in two minutes!', textJa: 'ありがとうございます！2分で準備できます！'),
    ],
  ),

  // ─── 36: 新しい友達 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_36',
    title: 'Making a New Friend',
    titleJa: '新しい友達',
    emoji: '🤝',
    situation: 'You meet a new student at your school.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hi! I\'m new here. My name is Emma.', textJa: 'こんにちは！転校してきました。エマといいます。'),
      ConversationTurn(speaker: 'user', text: 'Hi Emma! I\'m glad to meet you! I\'m Yuki.', textJa: 'こんにちは、エマさん！会えて嬉しいよ！私はユキです。', hint: 'I\'m glad to meet you'),
      ConversationTurn(speaker: 'ai',   text: 'Nice to meet you Yuki! This school is so big. Is it hard to find classrooms?', textJa: 'はじめまして、ユキさん！この学校すごく大きい。教室を見つけるのは難しい？'),
      ConversationTurn(speaker: 'user', text: 'A little, but I can show you around if you want!', textJa: '少しね。でもよかったら案内してあげるよ！', hint: 'I can show you around'),
      ConversationTurn(speaker: 'ai',   text: 'That would be amazing! Thank you so much!', textJa: 'それはすごく助かる！ありがとう！'),
      ConversationTurn(speaker: 'user', text: 'No problem! Where are you from, Emma?', textJa: 'どういたしまして！エマはどこから来たの？', hint: 'Where are you from'),
      ConversationTurn(speaker: 'ai',   text: 'I\'m from Canada! I moved here last month.', textJa: 'カナダから来ました！先月引っ越してきたの。'),
      ConversationTurn(speaker: 'user', text: 'Canada! That\'s so far away! Do you miss it?', textJa: 'カナダ！すごく遠いね！カナダが恋しい？', hint: 'Do you miss it'),
      ConversationTurn(speaker: 'ai',   text: 'A little, but I\'m happy I met you! Let\'s be friends!', textJa: '少しね。でもあなたに会えてよかった！友達になろう！'),
    ],
  ),

  // ─── 37: ペットについて ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_37',
    title: 'Talking About Pets',
    titleJa: 'ペットについて',
    emoji: '🐱',
    situation: 'You are talking with your friend about your pets.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Do you have any pets at home?', textJa: '家にペットはいる？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I have a cat. Her name is Momo.', textJa: 'うん！猫がいるよ。モモっていう名前。', hint: 'I have a cat'),
      ConversationTurn(speaker: 'ai',   text: 'Momo! That\'s so cute! What does she look like?', textJa: 'モモ！かわいい！どんな見た目なの？'),
      ConversationTurn(speaker: 'user', text: 'She is white and fluffy with big green eyes.', textJa: '白くてふわふわで、大きな緑の目をしてるよ。', hint: 'She is white and fluffy'),
      ConversationTurn(speaker: 'ai',   text: 'She sounds adorable! What does she like to do?', textJa: 'かわいそうだね！何をするのが好きなの？'),
      ConversationTurn(speaker: 'user', text: 'She loves to sleep and chase a ball of yarn!', textJa: '寝るのと毛糸のボールを追いかけるのが大好きなの！', hint: 'She loves to sleep'),
      ConversationTurn(speaker: 'ai',   text: 'So cute! I have a dog. His name is Max.', textJa: 'かわいい！私は犬を飼ってるよ。マックスっていうの。'),
      ConversationTurn(speaker: 'user', text: 'A dog! I love dogs too! Is he friendly?', textJa: '犬！私も犬が大好き！人なつこい？', hint: 'Is he friendly'),
      ConversationTurn(speaker: 'ai',   text: 'Very! He wags his tail at everyone he meets!', textJa: 'すごく！会う人みんなにしっぽを振るよ！'),
    ],
  ),

  // ─── 38: 祖父母の家 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_38',
    title: 'Visiting a Grandparent',
    titleJa: '祖父母の家',
    emoji: '👴',
    situation: 'You are visiting your grandpa at his house.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Welcome! Come in, come in! I\'m so happy to see you!', textJa: 'よく来たね！入って入って！会えてとても嬉しいよ！'),
      ConversationTurn(speaker: 'user', text: 'Hi Grandpa! I missed you so much!', textJa: 'おじいちゃん！すごく会いたかった！', hint: 'I missed you'),
      ConversationTurn(speaker: 'ai',   text: 'I missed you too! You are growing so tall! Are you hungry?', textJa: '私もだよ！背が伸びたね！お腹すいてる？'),
      ConversationTurn(speaker: 'user', text: 'Yes! Did you make your delicious cookies?', textJa: 'うん！おいしいクッキーを作った？', hint: 'Did you make'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! I made them just for you. Here you go!', textJa: 'もちろん！あなたのために作ったよ。はいどうぞ！'),
      ConversationTurn(speaker: 'user', text: 'They smell amazing! Thank you, Grandpa!', textJa: 'すごくいい匂い！ありがとう、おじいちゃん！', hint: 'They smell amazing'),
      ConversationTurn(speaker: 'ai',   text: 'You\'re welcome! Tell me about school. How is it going?', textJa: 'どういたしまして！学校の話を聞かせて。どう？'),
      ConversationTurn(speaker: 'user', text: 'School is great! I made a new friend named Emma.', textJa: '学校は楽しいよ！エマって新しい友達ができた。', hint: 'I made a new friend'),
      ConversationTurn(speaker: 'ai',   text: 'Wonderful! It\'s always good to make new friends. You make me so proud!', textJa: '素晴らしい！新しい友達を作るのはいいことだよ。誇らしいよ！'),
    ],
  ),

  // ─── 39: 旅行の計画 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_39',
    title: 'Planning a Trip',
    titleJa: '旅行の計画',
    emoji: '✈️',
    situation: 'You and your friend are planning a fun trip together.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'I want to go on a trip this summer! Do you want to come?', textJa: '今年の夏に旅行に行きたい！一緒に来る？'),
      ConversationTurn(speaker: 'user', text: 'Yes! Where do you want to go?', textJa: 'うん！どこに行きたいの？', hint: 'Where do you want to go'),
      ConversationTurn(speaker: 'ai',   text: 'I\'d love to go to Hokkaido! I want to see the lavender fields.', textJa: '北海道に行きたい！ラベンダー畑が見たいな。'),
      ConversationTurn(speaker: 'user', text: 'That sounds beautiful! How will we get there?', textJa: 'きれいそう！どうやって行くの？', hint: 'How will we get there'),
      ConversationTurn(speaker: 'ai',   text: 'We can take an airplane. It\'s only one and a half hours!', textJa: '飛行機で行けるよ。1時間半だけだよ！'),
      ConversationTurn(speaker: 'user', text: 'Great! What should we pack? I\'ll bring my camera.', textJa: 'いいね！何を持っていけばいい？カメラを持っていくよ。', hint: 'I\'ll bring my camera'),
      ConversationTurn(speaker: 'ai',   text: 'Good idea! Bring warm clothes too. Hokkaido can be cool in summer.', textJa: 'いい考え！暖かい服も持ってきてね。北海道は夏でも涼しいよ。'),
      ConversationTurn(speaker: 'user', text: 'OK! I can\'t wait. This is going to be the best trip!', textJa: 'わかった！待ちきれない。最高の旅になるね！', hint: 'I can\'t wait'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Let\'s tell our parents and start planning!', textJa: '私も！親に言って計画を始めよう！'),
    ],
  ),

  // ─── 40: 歯医者で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_40',
    title: 'At the Dentist',
    titleJa: '歯医者で',
    emoji: '🦷',
    situation: 'You are at the dentist\'s office for a checkup.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Hello! Please sit down in the chair.', textJa: 'こんにちは！椅子に座ってください。'),
      ConversationTurn(speaker: 'user', text: 'Thank you. My tooth hurts a little.', textJa: 'ありがとうございます。歯が少し痛いです。', hint: 'My tooth hurts'),
      ConversationTurn(speaker: 'ai',   text: 'I see. Which tooth hurts? Can you point to it?', textJa: 'そうですか。どの歯が痛いですか？指で教えてもらえますか？'),
      ConversationTurn(speaker: 'user', text: 'This one, on the right side.', textJa: 'こっちの、右側です。', hint: 'This one, on the right side'),
      ConversationTurn(speaker: 'ai',   text: 'OK. Open your mouth wide, please. Say "Ahh."', textJa: 'わかりました。大きく口を開けてください。「アー」と言って。'),
      ConversationTurn(speaker: 'user', text: 'Ahh. Is it bad?', textJa: 'アー。悪いですか？', hint: 'Is it bad'),
      ConversationTurn(speaker: 'ai',   text: 'It looks like a small cavity. Don\'t worry, it\'s not serious.', textJa: '小さい虫歯のようですね。心配しないで、大したことはないですよ。'),
      ConversationTurn(speaker: 'user', text: 'Will it hurt? I\'m a little scared.', textJa: '痛いですか？少し怖いです。', hint: 'I\'m a little scared'),
      ConversationTurn(speaker: 'ai',   text: 'I will be very gentle. Brush your teeth well every day!', textJa: 'とても優しくしますよ。毎日歯をよく磨いてね！'),
      ConversationTurn(speaker: 'user', text: 'OK! I will brush twice a day from now on.', textJa: 'わかりました！これから1日2回磨きます。', hint: 'I will brush twice a day'),
    ],
  ),

  // ─── 41: プールで ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_41',
    title: 'At the Swimming Pool',
    titleJa: 'プールで',
    emoji: '🏊',
    situation: 'You are at the school swimming pool with your friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'The pool looks so cool! Can you swim?', textJa: 'プールは気持ちよさそう！泳げる？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I can swim freestyle. Can you?', textJa: 'うん！クロールができるよ。君は？', hint: 'I can swim freestyle'),
      ConversationTurn(speaker: 'ai',   text: 'I can swim a little, but I\'m not very fast.', textJa: '少し泳げるけど、あまり速くないよ。'),
      ConversationTurn(speaker: 'user', text: 'I can teach you! Let\'s practice together.', textJa: '教えてあげるよ！一緒に練習しよう。', hint: 'I can teach you'),
      ConversationTurn(speaker: 'ai',   text: 'Really? That\'s so nice of you! How many laps can you swim?', textJa: '本当に？優しいね！何周泳げる？'),
      ConversationTurn(speaker: 'user', text: 'I can swim about ten laps. It\'s fun!', textJa: '10周くらい泳げるよ。楽しいよ！', hint: 'I can swim about ten laps'),
      ConversationTurn(speaker: 'ai',   text: 'Wow, that\'s amazing! I can only swim two laps.', textJa: 'わあ、すごい！私は2周しか泳げないよ。'),
      ConversationTurn(speaker: 'user', text: 'Don\'t give up! Practice every day and you will get better.', textJa: '諦めないで！毎日練習したら上手になるよ。', hint: 'Don\'t give up'),
      ConversationTurn(speaker: 'ai',   text: 'You\'re right! Let\'s jump in the water now!', textJa: 'そうだね！さあ水に入ろう！'),
    ],
  ),

  // ─── 42: クラブ活動 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_42',
    title: 'Club Activities',
    titleJa: 'クラブ活動',
    emoji: '⚽',
    situation: 'You are talking with a friend about school club activities.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'What club are you in at school?', textJa: '学校でどのクラブに入っているの？'),
      ConversationTurn(speaker: 'user', text: 'I\'m in the soccer club. What about you?', textJa: 'サッカークラブに入っているよ。君は？', hint: 'I\'m in the soccer club'),
      ConversationTurn(speaker: 'ai',   text: 'I\'m in the art club. I love drawing pictures.', textJa: '美術クラブに入っているよ。絵を描くのが好きなんだ。'),
      ConversationTurn(speaker: 'user', text: 'That\'s cool! When do you have club activities?', textJa: 'いいね！クラブ活動はいつあるの？', hint: 'When do you have club'),
      ConversationTurn(speaker: 'ai',   text: 'We meet every Wednesday after school. How about soccer?', textJa: '毎週水曜日の放課後にあるよ。サッカーは？'),
      ConversationTurn(speaker: 'user', text: 'We practice on Tuesday and Friday. I love it!', textJa: '火曜日と金曜日に練習があるよ。大好き！', hint: 'We practice on Tuesday and Friday'),
      ConversationTurn(speaker: 'ai',   text: 'Do you play in any games or matches?', textJa: '試合とかあるの？'),
      ConversationTurn(speaker: 'user', text: 'Yes! We had a big match last month. We won!', textJa: 'うん！先月大きな試合があったよ。勝ったよ！', hint: 'We won'),
      ConversationTurn(speaker: 'ai',   text: 'Congratulations! You must be very proud.', textJa: 'おめでとう！すごく誇りに思うね。'),
    ],
  ),

  // ─── 43: 理科の実験 ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_43',
    title: 'Science Experiment',
    titleJa: '理科の実験',
    emoji: '🔬',
    situation: 'You are doing a science experiment in class with your partner.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Today\'s experiment looks exciting! What are we making?', textJa: '今日の実験は楽しそう！何を作るの？'),
      ConversationTurn(speaker: 'user', text: 'We are making a volcano! It will bubble and foam.', textJa: '火山を作るよ！泡立つんだ。', hint: 'We are making a volcano'),
      ConversationTurn(speaker: 'ai',   text: 'Wow! What do we need for the experiment?', textJa: 'わあ！実験に何が必要なの？'),
      ConversationTurn(speaker: 'user', text: 'We need baking soda and vinegar. And some red food coloring.', textJa: '重曹とお酢が必要だよ。それと赤い食用色素も。', hint: 'We need baking soda and vinegar'),
      ConversationTurn(speaker: 'ai',   text: 'I see them on the table. Shall I pour the vinegar?', textJa: 'テーブルの上にあるね。お酢を注いでもいい？'),
      ConversationTurn(speaker: 'user', text: 'Wait! First put in the baking soda. Then pour the vinegar.', textJa: 'ちょっと待って！先に重曹を入れてね。それからお酢を注いで。', hint: 'First put in the baking soda'),
      ConversationTurn(speaker: 'ai',   text: 'OK! Here we go. Whoa, it\'s bubbling!', textJa: 'わかった！行くよ。わあ、泡立ってる！'),
      ConversationTurn(speaker: 'user', text: 'It works! Science is so amazing!', textJa: 'うまくいった！理科って本当にすごいね！', hint: 'Science is so amazing'),
      ConversationTurn(speaker: 'ai',   text: 'That was the best experiment ever! Let\'s write our report.', textJa: '今まで一番の実験だった！レポートを書こう。'),
    ],
  ),

  // ─── 44: 遠足 ────────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_44',
    title: 'Field Trip',
    titleJa: '遠足',
    emoji: '🎒',
    situation: 'You are on a school field trip to a nature park.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'I\'m so excited about today\'s field trip! Where are we going?', textJa: '今日の遠足、すごく楽しみ！どこに行くの？'),
      ConversationTurn(speaker: 'user', text: 'We\'re going to a nature park. We will see animals!', textJa: '自然公園に行くよ。動物を見るんだ！', hint: 'We\'re going to a nature park'),
      ConversationTurn(speaker: 'ai',   text: 'I love animals! What did you bring for lunch?', textJa: '動物が大好き！お弁当は何を持ってきたの？'),
      ConversationTurn(speaker: 'user', text: 'I have rice balls and some fruit. What about you?', textJa: 'おにぎりと果物があるよ。君は？', hint: 'I have rice balls'),
      ConversationTurn(speaker: 'ai',   text: 'I have sandwiches and juice. Let\'s eat together!', textJa: 'サンドイッチとジュースがあるよ。一緒に食べよう！'),
      ConversationTurn(speaker: 'user', text: 'Sure! Look at that deer! It\'s so cute.', textJa: 'もちろん！あのシカを見て！かわいいね。', hint: 'Look at that deer'),
      ConversationTurn(speaker: 'ai',   text: 'Wow, it\'s eating grass! Stay quiet so it doesn\'t run away.', textJa: 'わあ、草を食べてる！逃げないようにしずかにして。'),
      ConversationTurn(speaker: 'user', text: 'This is the best field trip ever!', textJa: 'これは今まで一番の遠足だよ！', hint: 'This is the best field trip'),
      ConversationTurn(speaker: 'ai',   text: 'I agree! I will draw pictures of it in my journal tonight.', textJa: 'そうだね！今夜日記に絵を描くよ。'),
    ],
  ),

  // ─── 45: 給食時間 ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_45',
    title: 'School Lunch',
    titleJa: '給食時間',
    emoji: '🍱',
    situation: 'It is lunchtime at school. You are eating with your classmates.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Lunch time! What did we get today?', textJa: 'お昼だ！今日は何かな？'),
      ConversationTurn(speaker: 'user', text: 'Today we have curry and rice. It smells delicious!', textJa: '今日はカレーライスだよ。おいしそうなにおい！', hint: 'Today we have curry and rice'),
      ConversationTurn(speaker: 'ai',   text: 'I love curry! Is it spicy?', textJa: 'カレー大好き！辛い？'),
      ConversationTurn(speaker: 'user', text: 'It\'s a little spicy, but really good. Try it!', textJa: '少し辛いけど、すごくおいしいよ。食べてみて！', hint: 'Try it'),
      ConversationTurn(speaker: 'ai',   text: 'Mmm, you\'re right! It\'s so yummy. What\'s for dessert?', textJa: 'うん、そうだね！とてもおいしい。デザートは何？'),
      ConversationTurn(speaker: 'user', text: 'We have milk and a bread roll today.', textJa: '今日は牛乳とパンがあるよ。', hint: 'We have milk and a bread roll'),
      ConversationTurn(speaker: 'ai',   text: 'I always drink all my milk. It\'s good for my bones!', textJa: '私はいつも牛乳を全部飲むよ。骨にいいもんね！'),
      ConversationTurn(speaker: 'user', text: 'Me too! I eat everything. I don\'t like wasting food.', textJa: '私も！全部食べるよ。食べ物を残すのは好きじゃないな。', hint: 'I eat everything'),
      ConversationTurn(speaker: 'ai',   text: 'That\'s wonderful! Let\'s clean up after we finish.', textJa: 'えらいね！食べ終わったら片付けしよう。'),
    ],
  ),

  // ─── 46: 休み時間 ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_46',
    title: 'Recess / Break Time',
    titleJa: '休み時間',
    emoji: '🛝',
    situation: 'It is recess time and you are playing outside with friends.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Finally, recess! What do you want to play?', textJa: 'やっと休み時間！何して遊びたい？'),
      ConversationTurn(speaker: 'user', text: 'Let\'s play tag! It\'s my favorite game.', textJa: '鬼ごっこしよう！私のお気に入りのゲームだよ。', hint: 'Let\'s play tag'),
      ConversationTurn(speaker: 'ai',   text: 'OK! Who will be "it" first?', textJa: 'わかった！最初の鬼は誰がやる？'),
      ConversationTurn(speaker: 'user', text: 'Let\'s do rock-paper-scissors to decide!', textJa: 'じゃんけんで決めよう！', hint: 'Let\'s do rock-paper-scissors'),
      ConversationTurn(speaker: 'ai',   text: 'I lost! I\'ll be "it." Ready? Here I come!', textJa: '負けた！私が鬼やるよ。準備はいい？行くよ！'),
      ConversationTurn(speaker: 'user', text: 'Run! She\'s coming! Go to the slide!', textJa: '走れ！来てるよ！すべり台に行って！', hint: 'Run! She\'s coming'),
      ConversationTurn(speaker: 'ai',   text: 'I tagged you! Now you\'re "it!"', textJa: 'タッチした！今度はあなたが鬼だよ！'),
      ConversationTurn(speaker: 'user', text: 'OK! I\'ll catch everyone. Watch out!', textJa: 'わかった！みんなを捕まえるよ。気をつけて！', hint: 'Watch out'),
      ConversationTurn(speaker: 'ai',   text: 'This is so fun! Recess goes by too fast.', textJa: 'すごく楽しい！休み時間が早く終わっちゃうね。'),
    ],
  ),

  // ─── 47: アニメについて ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_47',
    title: 'Talking About Anime',
    titleJa: 'アニメについて',
    emoji: '📺',
    situation: 'You are talking with a friend about your favorite anime shows.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Do you watch anime? I love it!', textJa: 'アニメ見る？大好きなんだ！'),
      ConversationTurn(speaker: 'user', text: 'Yes! What is your favorite anime?', textJa: 'うん！好きなアニメは何？', hint: 'What is your favorite anime'),
      ConversationTurn(speaker: 'ai',   text: 'My favorite is One Piece! I love the adventure story.', textJa: 'ワンピースが一番好き！冒険の話が好きなんだ。'),
      ConversationTurn(speaker: 'user', text: 'I like it too! My favorite character is Luffy.', textJa: '私も好き！お気に入りのキャラはルフィだよ。', hint: 'My favorite character is'),
      ConversationTurn(speaker: 'ai',   text: 'Mine is Zoro! He is so cool. Which part are you watching now?', textJa: '私はゾロ！すごくかっこいいよ。今どこ見てる？'),
      ConversationTurn(speaker: 'user', text: 'I just started. I\'m only on episode ten.', textJa: '始めたばかりだよ。まだ10話しか見てないよ。', hint: 'I\'m only on episode ten'),
      ConversationTurn(speaker: 'ai',   text: 'Oh, it gets even better! Keep watching, you will love it.', textJa: 'そうか、もっとよくなるよ！見続けて、絶対好きになるよ。'),
      ConversationTurn(speaker: 'user', text: 'I can\'t wait! Do you have any other recommendations?', textJa: '楽しみ！他にもおすすめある？', hint: 'Do you have any other recommendations'),
      ConversationTurn(speaker: 'ai',   text: 'Try Demon Slayer! It has beautiful animation and a great story.', textJa: '鬼滅の刃を見てみて！アニメーションがきれいでストーリーもいいよ。'),
      ConversationTurn(speaker: 'user', text: 'Great idea! Let\'s watch it together sometime.', textJa: 'いいね！いつか一緒に見よう。', hint: 'Let\'s watch it together'),
    ],
  ),

  // ─── 48: 誕生日カードを作る ───────────────────────────────────────────────
  ConversationScript(
    id: 'conv_48',
    title: 'Making a Birthday Card',
    titleJa: '誕生日カードを作る',
    emoji: '🎂',
    situation: 'You are making a birthday card for a friend with another classmate.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Mia\'s birthday is tomorrow! Let\'s make her a card.', textJa: '明日はミアの誕生日！カードを作ろう。'),
      ConversationTurn(speaker: 'user', text: 'Good idea! What should we draw on it?', textJa: 'いいね！何を描こうか？', hint: 'What should we draw'),
      ConversationTurn(speaker: 'ai',   text: 'She loves flowers. Let\'s draw big colorful flowers!', textJa: '彼女は花が好きだよ。大きくてカラフルな花を描こう！'),
      ConversationTurn(speaker: 'user', text: 'Perfect! I\'ll draw the flowers and you write the message.', textJa: 'いいね！私が花を描くから、君がメッセージを書いてね。', hint: 'I\'ll draw the flowers'),
      ConversationTurn(speaker: 'ai',   text: 'OK! What should I write? "Happy Birthday, Mia!"?', textJa: 'わかった！何て書こう？「ハッピーバースデー、ミア！」？'),
      ConversationTurn(speaker: 'user', text: 'Yes! And also write "We hope you have a great day!"', textJa: 'うん！あと「素晴らしい一日になりますように！」も書いてね。', hint: 'We hope you have a great day'),
      ConversationTurn(speaker: 'ai',   text: 'Done! The card looks so pretty. She will love it.', textJa: 'できた！カードがとてもきれい。喜んでくれるよ。'),
      ConversationTurn(speaker: 'user', text: 'Let\'s add some stickers to make it even more fun!', textJa: 'もっと楽しくするためにシールを貼ろう！', hint: 'Let\'s add some stickers'),
      ConversationTurn(speaker: 'ai',   text: 'Great idea! I bet Mia will be so happy and surprised.', textJa: 'いいね！ミアはきっとすごく喜んで驚くよ。'),
    ],
  ),

  // ─── 49: おもちゃ屋で ─────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_49',
    title: 'At the Toy Store',
    titleJa: 'おもちゃ屋で',
    emoji: '🧸',
    situation: 'You are at a toy store with your parent looking for a birthday gift.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Welcome! Can I help you find something today?', textJa: 'いらっしゃいませ！今日は何かお探しですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes, please. I\'m looking for a birthday gift for my friend.', textJa: 'はい、お願いします。友達への誕生日プレゼントを探しています。', hint: 'I\'m looking for a birthday gift'),
      ConversationTurn(speaker: 'ai',   text: 'How old is your friend? Is it a boy or a girl?', textJa: 'お友達は何歳ですか？男の子ですか女の子ですか？'),
      ConversationTurn(speaker: 'user', text: 'She is ten years old. She likes animals.', textJa: '10歳の女の子です。動物が好きです。', hint: 'She is ten years old'),
      ConversationTurn(speaker: 'ai',   text: 'I have some great animal toys over here. Look at these!', textJa: 'こちらに素敵な動物のおもちゃがありますよ。見てください！'),
      ConversationTurn(speaker: 'user', text: 'Oh, this stuffed panda is so cute! How much is it?', textJa: 'あ、このパンダのぬいぐるみ、かわいい！いくらですか？', hint: 'How much is it'),
      ConversationTurn(speaker: 'ai',   text: 'It\'s 1,500 yen. It\'s very popular with kids.', textJa: '1500円です。子どもたちにとても人気ですよ。'),
      ConversationTurn(speaker: 'user', text: 'I think she will love it. I\'ll take it, please!', textJa: '彼女は喜ぶと思います。これをください！', hint: 'I\'ll take it'),
      ConversationTurn(speaker: 'ai',   text: 'Great choice! Would you like gift wrapping?', textJa: 'いい選択ですね！ギフト包装はいかがですか？'),
      ConversationTurn(speaker: 'user', text: 'Yes, please! Thank you so much.', textJa: 'はい、お願いします！ありがとうございます。', hint: 'Yes, please'),
    ],
  ),

  // ─── 50: ゲームについて ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_50',
    title: 'Video Game Talk',
    titleJa: 'ゲームについて',
    emoji: '🎮',
    situation: 'You are talking with a friend about your favorite video games.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Do you play video games? What\'s your favorite?', textJa: 'ゲームする？お気に入りは何？'),
      ConversationTurn(speaker: 'user', text: 'I love Minecraft! I play it every weekend.', textJa: 'マインクラフトが大好き！毎週末プレイしてるよ。', hint: 'I love Minecraft'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! What do you like to build in Minecraft?', textJa: '私も！マインクラフトで何を作るのが好き？'),
      ConversationTurn(speaker: 'user', text: 'I love building big castles. I made one with a moat!', textJa: '大きなお城を作るのが好き！お堀のあるお城を作ったよ！', hint: 'I love building big castles'),
      ConversationTurn(speaker: 'ai',   text: 'That sounds amazing! I usually build houses and farms.', textJa: 'すごそう！私はいつも家や農場を作るよ。'),
      ConversationTurn(speaker: 'user', text: 'You should try survival mode. It\'s more exciting!', textJa: 'サバイバルモードを試してみてよ。もっとわくわくするよ！', hint: 'You should try survival mode'),
      ConversationTurn(speaker: 'ai',   text: 'I\'m a little scared of the monsters. Are they hard to beat?', textJa: 'モンスターが少し怖くて。倒すのは難しい？'),
      ConversationTurn(speaker: 'user', text: 'Not if you have a good sword! I can show you how to play.', textJa: 'いい剣があれば大丈夫！プレイの仕方を教えてあげるよ。', hint: 'I can show you how to play'),
      ConversationTurn(speaker: 'ai',   text: 'Yes please! Let\'s play together after school.', textJa: 'お願い！放課後一緒にやろう。'),
    ],
  ),

  // ─── 51: 朝の準備 ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_51',
    title: 'Morning Routine',
    titleJa: '朝の準備',
    emoji: '☀️',
    situation: 'It is morning and you are getting ready for school.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Good morning! It\'s time to wake up!', textJa: 'おはよう！起きる時間だよ！'),
      ConversationTurn(speaker: 'user', text: 'Good morning. I\'m still sleepy.', textJa: 'おはよう。まだ眠いよ。', hint: 'I\'m still sleepy'),
      ConversationTurn(speaker: 'ai',   text: 'School starts in one hour! Did you brush your teeth?', textJa: '1時間後に学校が始まるよ！歯を磨いた？'),
      ConversationTurn(speaker: 'user', text: 'Not yet. I\'ll brush them after breakfast.', textJa: 'まだだよ。朝ごはんの後に磨くよ。', hint: 'Not yet'),
      ConversationTurn(speaker: 'ai',   text: 'OK! What do you want for breakfast?', textJa: 'わかった！朝ごはんは何食べたい？'),
      ConversationTurn(speaker: 'user', text: 'I want toast and orange juice, please.', textJa: 'トーストとオレンジジュースが欲しいな。', hint: 'I want toast and orange juice'),
      ConversationTurn(speaker: 'ai',   text: 'Good choice! Don\'t forget to pack your bag.', textJa: 'いい選択！ランドセルを準備するのを忘れないで。'),
      ConversationTurn(speaker: 'user', text: 'I packed it last night. I have everything ready.', textJa: '昨夜準備したよ。全部用意できてるよ。', hint: 'I packed it last night'),
      ConversationTurn(speaker: 'ai',   text: 'Great! You are very organized. Have a wonderful day!', textJa: 'えらいね！とてもしっかりしてるね。いい1日を！'),
    ],
  ),

  // ─── 52: 先生に質問する ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_52',
    title: 'Asking the Teacher for Help',
    titleJa: '先生に質問する',
    emoji: '✋',
    situation: 'You don\'t understand something in class and ask your teacher for help.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Does everyone understand the math problem?', textJa: 'みんな算数の問題はわかりましたか？'),
      ConversationTurn(speaker: 'user', text: 'Excuse me, I don\'t understand question three.', textJa: 'すみません、3番の問題がわかりません。', hint: 'I don\'t understand question three'),
      ConversationTurn(speaker: 'ai',   text: 'No problem! Which part is confusing?', textJa: '大丈夫ですよ！どの部分がわかりにくいですか？'),
      ConversationTurn(speaker: 'user', text: 'I don\'t know how to start. Can you show me?', textJa: 'どこから始めればいいかわからないんです。教えてもらえますか？', hint: 'Can you show me'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! First, read the problem carefully. What do you see?', textJa: 'もちろん！まず問題をよく読んでね。何が見える？'),
      ConversationTurn(speaker: 'user', text: 'I see two numbers. I need to add them together.', textJa: '2つの数字があります。それを足すんですね。', hint: 'I need to add them together'),
      ConversationTurn(speaker: 'ai',   text: 'Exactly right! See, you did understand. Good thinking!', textJa: 'その通り！ほら、わかってたじゃないですか。いい考え方だよ！'),
      ConversationTurn(speaker: 'user', text: 'Oh, I see it now! Thank you for helping me.', textJa: 'あ、わかった！助けてくれてありがとうございます。', hint: 'Thank you for helping me'),
      ConversationTurn(speaker: 'ai',   text: 'You\'re welcome! Always ask when you need help.', textJa: 'どういたしまして！わからないときはいつでも聞いてね。'),
    ],
  ),

  // ─── 53: 放課後 ──────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_53',
    title: 'After School',
    titleJa: '放課後',
    emoji: '🏫',
    situation: 'School is over and you are talking with a friend about your plans.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'School\'s over! What are you doing this afternoon?', textJa: '学校終わった！今日の午後は何するの？'),
      ConversationTurn(speaker: 'user', text: 'I have piano practice at four o\'clock.', textJa: '4時にピアノのレッスンがあるよ。', hint: 'I have piano practice'),
      ConversationTurn(speaker: 'ai',   text: 'Oh nice! How long have you been playing piano?', textJa: 'いいね！ピアノはどのくらい弾いてるの？'),
      ConversationTurn(speaker: 'user', text: 'For three years. I can play some songs now!', textJa: '3年間だよ。今は曲が弾けるよ！', hint: 'For three years'),
      ConversationTurn(speaker: 'ai',   text: 'That\'s great! Do you have any homework today?', textJa: 'すごい！今日は宿題ある？'),
      ConversationTurn(speaker: 'user', text: 'Yes, I have to read two pages and do some math.', textJa: 'うん、2ページ読んで算数もやらないといけないよ。', hint: 'I have to read two pages'),
      ConversationTurn(speaker: 'ai',   text: 'Me too. I always do my homework right after dinner.', textJa: '私も。夕ご飯の後すぐに宿題するようにしてるよ。'),
      ConversationTurn(speaker: 'user', text: 'I do mine before dinner. Then I can relax after.', textJa: '私は夕ご飯前にやるよ。そうすると後でゆっくりできるから。', hint: 'I do mine before dinner'),
      ConversationTurn(speaker: 'ai',   text: 'Good idea! See you tomorrow at school!', textJa: 'いいね！また明日学校で！'),
    ],
  ),

  // ─── 54: お泊り会の計画 ───────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_54',
    title: 'Sleepover Plans',
    titleJa: 'お泊り会の計画',
    emoji: '🌙',
    situation: 'You are planning a sleepover with your best friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Can you come to my house for a sleepover on Saturday?', textJa: '土曜日にうちにお泊まりに来られる？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I\'ll ask my mom tonight. What will we do?', textJa: 'うん！今夜お母さんに聞いてみるよ。何して遊ぶ？', hint: 'I\'ll ask my mom'),
      ConversationTurn(speaker: 'ai',   text: 'We can watch movies and eat popcorn! And make a fort!', textJa: '映画を見てポップコーンを食べよう！秘密基地も作ろう！'),
      ConversationTurn(speaker: 'user', text: 'A fort sounds so fun! What movie should we watch?', textJa: '秘密基地楽しそう！どんな映画を見る？', hint: 'What movie should we watch'),
      ConversationTurn(speaker: 'ai',   text: 'Let\'s watch an adventure movie! Or maybe a funny one?', textJa: '冒険映画を見よう！それかおもしろいやつ？'),
      ConversationTurn(speaker: 'user', text: 'I vote for an adventure movie. They are so exciting!', textJa: '冒険映画に一票！すごくわくわくするから！', hint: 'I vote for an adventure movie'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Bring your pajamas and a sleeping bag.', textJa: '私も！パジャマと寝袋を持ってきてね。'),
      ConversationTurn(speaker: 'user', text: 'OK! I\'ll bring some snacks too. I have chips!', textJa: 'わかった！おやつも持ってくるよ。ポテチがあるよ！', hint: 'I\'ll bring some snacks'),
      ConversationTurn(speaker: 'ai',   text: 'Perfect! Saturday is going to be the best night ever!', textJa: 'やった！土曜日は最高の夜になりそう！'),
    ],
  ),

  // ─── 55: 本について ───────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_55',
    title: 'Talking About Books',
    titleJa: '本について',
    emoji: '📚',
    situation: 'You are at the school library talking about books with your friend.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'I love the school library! What kind of books do you like?', textJa: '学校の図書館が大好き！どんな本が好き？'),
      ConversationTurn(speaker: 'user', text: 'I like adventure stories. They are so exciting!', textJa: '冒険の話が好き。すごくわくわくするよ！', hint: 'I like adventure stories'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Have you read any good books lately?', textJa: '私も！最近何かいい本読んだ？'),
      ConversationTurn(speaker: 'user', text: 'Yes! I just finished a book about a boy who finds a dragon.', textJa: 'うん！ドラゴンを見つける男の子の本を読み終えたよ。', hint: 'I just finished a book about'),
      ConversationTurn(speaker: 'ai',   text: 'That sounds amazing! Was it scary or exciting?', textJa: 'すごそう！怖かった？それともわくわくした？'),
      ConversationTurn(speaker: 'user', text: 'Both! I couldn\'t put it down. I read until midnight.', textJa: '両方！止まらなかったよ。夜中12時まで読んだよ。', hint: 'I couldn\'t put it down'),
      ConversationTurn(speaker: 'ai',   text: 'Wow! Can I borrow it when you\'re done?', textJa: 'わあ！終わったら貸してもらえる？'),
      ConversationTurn(speaker: 'user', text: 'Of course! I think you will love it too.', textJa: 'もちろん！君も好きになると思うよ。', hint: 'I think you will love it'),
      ConversationTurn(speaker: 'ai',   text: 'Thank you! Let\'s look for more books together today.', textJa: 'ありがとう！今日一緒にもっと本を探そう。'),
    ],
  ),

  // ─── 56: 水族館で ─────────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_56',
    title: 'At the Aquarium',
    titleJa: '水族館で',
    emoji: '🐠',
    situation: 'You are visiting an aquarium on a class trip.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Look at all the fish! This aquarium is huge!', textJa: 'お魚を見て！この水族館は大きいね！'),
      ConversationTurn(speaker: 'user', text: 'Wow! I can see so many colorful fish!', textJa: 'わあ！カラフルな魚がたくさん見えるよ！', hint: 'I can see so many colorful fish'),
      ConversationTurn(speaker: 'ai',   text: 'What is your favorite sea animal?', textJa: '好きな海の生き物は何？'),
      ConversationTurn(speaker: 'user', text: 'I love dolphins! They are so smart and playful.', textJa: 'イルカが大好き！とても賢くて遊び好きだよ。', hint: 'I love dolphins'),
      ConversationTurn(speaker: 'ai',   text: 'Me too! Look over there — it\'s a shark!', textJa: '私も！あっちを見て—サメがいるよ！'),
      ConversationTurn(speaker: 'user', text: 'Whoa! It\'s so big! I\'m a little scared.', textJa: 'うわあ！すごく大きい！少し怖いよ。', hint: 'I\'m a little scared'),
      ConversationTurn(speaker: 'ai',   text: 'Don\'t worry, it\'s behind the glass. You are safe!', textJa: '心配しないで、ガラスの向こうにいるよ。安全だよ！'),
      ConversationTurn(speaker: 'user', text: 'You\'re right! Let\'s go see the jellyfish next.', textJa: 'そうだね！次はクラゲを見に行こう。', hint: 'Let\'s go see the jellyfish'),
      ConversationTurn(speaker: 'ai',   text: 'The jellyfish tank is beautiful. They glow in the dark!', textJa: 'クラゲの水槽はきれいだよ。暗闇で光るんだよ！'),
      ConversationTurn(speaker: 'user', text: 'Amazing! I want to come back here with my family.', textJa: 'すごい！家族とまた来たいな。', hint: 'I want to come back here'),
    ],
  ),

  // ─── 57: スポーツ練習 ─────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_57',
    title: 'Sports Practice',
    titleJa: 'スポーツ練習',
    emoji: '🏃',
    situation: 'You are at soccer practice with your team.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'Everyone line up! Let\'s start practice with a warm-up.', textJa: 'みんな並んで！ウォームアップから練習を始めよう。'),
      ConversationTurn(speaker: 'user', text: 'OK, coach! Are we going to practice shooting today?', textJa: 'はい、コーチ！今日はシュートの練習しますか？', hint: 'Are we going to practice shooting'),
      ConversationTurn(speaker: 'ai',   text: 'Yes! First we run two laps around the field. Ready?', textJa: 'そうよ！まずグラウンドを2周走るよ。準備はいい？'),
      ConversationTurn(speaker: 'user', text: 'Ready! I\'ll try my best. I want to score a goal today.', textJa: '準備できた！頑張ります。今日ゴールを決めたいです。', hint: 'I want to score a goal'),
      ConversationTurn(speaker: 'ai',   text: 'Great attitude! Now let\'s practice passing to each other.', textJa: 'いい気持ちだね！では互いにパスの練習をしよう。'),
      ConversationTurn(speaker: 'user', text: 'I\'ll pass to you! Kick it back to me.', textJa: 'パスするよ！蹴り返してね。', hint: 'Kick it back to me'),
      ConversationTurn(speaker: 'ai',   text: 'Nice pass! Now try to kick it into the goal!', textJa: 'ナイスパス！今度はゴールに蹴り込んでみて！'),
      ConversationTurn(speaker: 'user', text: 'I did it! I scored a goal! That felt amazing!', textJa: 'できた！ゴール決めた！最高の気分！', hint: 'I scored a goal'),
      ConversationTurn(speaker: 'ai',   text: 'Excellent! Practice hard and you will be a great player!', textJa: '素晴らしい！一生懸命練習すれば素晴らしい選手になれるよ！'),
    ],
  ),

  // ─── 58: 学校のお祭り ─────────────────────────────────────────────────────
  ConversationScript(
    id: 'conv_58',
    title: 'School Festival',
    titleJa: '学校のお祭り',
    emoji: '🎪',
    situation: 'It is the day of the school festival. You are at a booth with your class.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'The school festival is finally here! Are you excited?', textJa: 'ついに学校のお祭りが来たね！楽しみ？'),
      ConversationTurn(speaker: 'user', text: 'Yes! Our class is running a game booth. Come play!', textJa: 'うん！うちのクラスはゲームの屋台をやってるよ。遊んでみて！', hint: 'Our class is running a game booth'),
      ConversationTurn(speaker: 'ai',   text: 'What game are you playing? I want to try!', textJa: 'どんなゲームをやってるの？やってみたい！'),
      ConversationTurn(speaker: 'user', text: 'You throw balls to knock down bottles. It\'s really fun!', textJa: 'ボールを投げてビンを倒すゲームだよ。すごく楽しいよ！', hint: 'You throw balls to knock down bottles'),
      ConversationTurn(speaker: 'ai',   text: 'Cool! How many throws do I get?', textJa: 'いいね！何回投げられるの？'),
      ConversationTurn(speaker: 'user', text: 'You get three throws. If you knock all down, you win a prize!', textJa: '3回投げられるよ。全部倒したらプレゼントがもらえるよ！', hint: 'You get three throws'),
      ConversationTurn(speaker: 'ai',   text: 'Here I go! Oh no, I only knocked down two!', textJa: '行くよ！あれ、2本しか倒せなかった！'),
      ConversationTurn(speaker: 'user', text: 'Try again! You can do it! I believe in you!', textJa: 'もう一回！できるよ！応援してるよ！', hint: 'I believe in you'),
      ConversationTurn(speaker: 'ai',   text: 'I got them all! This festival is so much fun!', textJa: '全部倒せた！このお祭り、すごく楽しいね！'),
      ConversationTurn(speaker: 'user', text: 'Congratulations! Let\'s go try the other booths next!', textJa: 'おめでとう！次はほかの屋台も行こう！', hint: 'Let\'s go try the other booths'),
    ],
  ),

  // ─── 59: さようならのあいさつ ─────────────────────────────────────────────
  ConversationScript(
    id: 'conv_59',
    title: 'Saying Goodbye',
    titleJa: 'さようならのあいさつ',
    emoji: '👋',
    situation: 'The school year is ending and you are saying goodbye to your friends.',
    turns: [
      ConversationTurn(speaker: 'ai',   text: 'I can\'t believe the school year is almost over!', textJa: 'もうすぐ学年が終わるなんて信じられない！'),
      ConversationTurn(speaker: 'user', text: 'Me too! It went by so fast. I had so much fun.', textJa: '私も！本当に早かった。すごく楽しかったよ。', hint: 'It went by so fast'),
      ConversationTurn(speaker: 'ai',   text: 'What was your favorite memory from this year?', textJa: '今年一番の思い出は何？'),
      ConversationTurn(speaker: 'user', text: 'The field trip to the nature park was the best!', textJa: '自然公園への遠足が一番だったよ！', hint: 'The field trip was the best'),
      ConversationTurn(speaker: 'ai',   text: 'Mine too! I hope we are in the same class next year.', textJa: '私も！来年も同じクラスになれるといいな。'),
      ConversationTurn(speaker: 'user', text: 'Me too! Let\'s stay friends forever, OK?', textJa: '私も！ずっと友達でいようね！', hint: 'Let\'s stay friends forever'),
      ConversationTurn(speaker: 'ai',   text: 'Of course! I\'ll miss you a lot over summer vacation.', textJa: 'もちろん！夏休みはすごく寂しいよ。'),
      ConversationTurn(speaker: 'user', text: 'Let\'s meet up during the summer! We can go to the park.', textJa: '夏に会おう！公園に行けるよ。', hint: 'Let\'s meet up during the summer'),
      ConversationTurn(speaker: 'ai',   text: 'That sounds perfect! Take care and have a great summer!', textJa: 'それは最高！気をつけてね、いい夏を！'),
      ConversationTurn(speaker: 'user', text: 'You too! Goodbye! See you soon!', textJa: '君もね！さようなら！またね！', hint: 'See you soon'),
    ],
  ),
];
