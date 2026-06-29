class MorningPhrase {
  final String english;
  final String japanese;
  final String category;

  const MorningPhrase({
    required this.english,
    required this.japanese,
    required this.category,
  });
}

final morningPhrases = [
  // グリーティング
  MorningPhrase(english: 'Good morning!', japanese: 'おはようございます！', category: 'greeting'),
  MorningPhrase(english: 'Have a great day!', japanese: '素晴らしい一日を過ごしてね！', category: 'greeting'),
  MorningPhrase(english: 'Rise and shine!', japanese: '目を覚まして！', category: 'greeting'),
  MorningPhrase(english: 'Welcome to a new day!', japanese: '新しい一日へようこそ！', category: 'greeting'),
  MorningPhrase(english: 'Time to wake up!', japanese: 'いい時間に起きましたね！', category: 'greeting'),

  // 朝の日常
  MorningPhrase(english: 'Did you sleep well?', japanese: 'よく眠れましたか？', category: 'routine'),
  MorningPhrase(english: 'What\'s for breakfast?', japanese: '朝食は何ですか？', category: 'routine'),
  MorningPhrase(english: 'I brush my teeth.', japanese: '私は歯を磨きます。', category: 'routine'),
  MorningPhrase(english: 'I take a shower.', japanese: 'シャワーを浴びます。', category: 'routine'),
  MorningPhrase(english: 'I get dressed.', japanese: '服を着ます。', category: 'routine'),

  // 肯定的な言葉
  MorningPhrase(english: 'You can do it!', japanese: 'あなたならできます！', category: 'motivation'),
  MorningPhrase(english: 'Be positive today!', japanese: '今日はポジティブになろう！', category: 'motivation'),
  MorningPhrase(english: 'Believe in yourself!', japanese: '自分を信じて！', category: 'motivation'),
  MorningPhrase(english: 'Today is your day!', japanese: '今日はあなたの日です！', category: 'motivation'),
  MorningPhrase(english: 'Stay positive!', japanese: 'ポジティブでいてね！', category: 'motivation'),

  // 天気
  MorningPhrase(english: 'It\'s a sunny day.', japanese: '晴れた日です。', category: 'weather'),
  MorningPhrase(english: 'It\'s cloudy today.', japanese: '今日は曇っています。', category: 'weather'),
  MorningPhrase(english: 'What\'s the weather like?', japanese: '天気はどうですか？', category: 'weather'),
  MorningPhrase(english: 'I love sunny days.', japanese: '晴れた日が好きです。', category: 'weather'),
  MorningPhrase(english: 'Don\'t forget your umbrella!', japanese: '傘を忘れずに！', category: 'weather'),

  // 学校・勉強
  MorningPhrase(english: 'Time for school!', japanese: '学校の時間です！', category: 'school'),
  MorningPhrase(english: 'Do your homework!', japanese: '宿題をしてね！', category: 'school'),
  MorningPhrase(english: 'Have fun at school!', japanese: '学校で楽しんでね！', category: 'school'),
  MorningPhrase(english: 'Make new friends!', japanese: '新しい友達を作ろう！', category: 'school'),
  MorningPhrase(english: 'Study hard today!', japanese: '今日は一生懸命勉強しよう！', category: 'school'),

  // 家族
  MorningPhrase(english: 'Good morning, Mom!', japanese: 'おはようお母さん！', category: 'family'),
  MorningPhrase(english: 'Good morning, Dad!', japanese: 'おはようお父さん！', category: 'family'),
  MorningPhrase(english: 'I love my family.', japanese: '家族が大好きです。', category: 'family'),
  MorningPhrase(english: 'Help your family!', japanese: '家族を手伝いましょう！', category: 'family'),
  MorningPhrase(english: 'Family time is the best!', japanese: '家族の時間が一番です！', category: 'family'),

  // 健康
  MorningPhrase(english: 'Drink some water!', japanese: '水を飲みましょう！', category: 'health'),
  MorningPhrase(english: 'Eat a healthy breakfast!', japanese: '健康的な朝食を食べましょう！', category: 'health'),
  MorningPhrase(english: 'Exercise is good for you!', japanese: '運動はあなたにいいです！', category: 'health'),
  MorningPhrase(english: 'Stay healthy!', japanese: '健康でいてね！', category: 'health'),
  MorningPhrase(english: 'Stretch your body!', japanese: '体をストレッチしましょう！', category: 'health'),

  // 計画・目標
  MorningPhrase(english: 'What\'s your plan today?', japanese: '今日の計画は何ですか？', category: 'planning'),
  MorningPhrase(english: 'Set your goals!', japanese: '目標を立てましょう！', category: 'planning'),
  MorningPhrase(english: 'Make today productive!', japanese: '今日を実りあるものにしましょう！', category: 'planning'),
  MorningPhrase(english: 'One step at a time!', japanese: '一歩ずつ進もう！', category: 'planning'),
  MorningPhrase(english: 'You\'ve got this!', japanese: 'あなたならできます！', category: 'planning'),

  // 感謝
  MorningPhrase(english: 'Thank you for everything!', japanese: 'いろいろありがとうございます！', category: 'gratitude'),
  MorningPhrase(english: 'I appreciate you!', japanese: 'あなたに感謝します！', category: 'gratitude'),
  MorningPhrase(english: 'Gratitude is powerful!', japanese: '感謝は強力です！', category: 'gratitude'),
  MorningPhrase(english: 'Be thankful today!', japanese: '今日は感謝しましょう！', category: 'gratitude'),
  MorningPhrase(english: 'Thank you for a new day!', japanese: '新しい一日をありがとう！', category: 'gratitude'),

  // 楽しみ・期待
  MorningPhrase(english: 'I\'m excited for today!', japanese: '今日が楽しみです！', category: 'excitement'),
  MorningPhrase(english: 'What a wonderful day!', japanese: 'なんて素晴らしい日でしょう！', category: 'excitement'),
  MorningPhrase(english: 'Let\'s have fun!', japanese: '楽しもう！', category: 'excitement'),
  MorningPhrase(english: 'Today is full of possibilities!', japanese: '今日は可能性でいっぱいです！', category: 'excitement'),
  MorningPhrase(english: 'Adventure awaits!', japanese: '冒険が待っています！', category: 'excitement'),
];
