# Phase 13: Gamification & Feature Extensions

## Overview

Phase 13 implements advanced gamification features and content expansions to increase user engagement, learning motivation, and long-term retention. This phase focuses on interactive pet systems, video-based pronunciation learning, and social engagement mechanics.

### Phase 13 Structure
- **Part 1**: Pet Breeding & Evolution System (Interactive Mascot)
- **Part 2**: Pronunciation Video Gallery (Learning Resources)
- **Part 3**: Social Challenges & Rewards (Community Engagement)

---

## Part 1: Pet Breeding & Evolution System

### Overview
An interactive virtual pet system where users raise, train, and evolve their own digital mascot character through consistent learning activities. This gamification layer encourages daily engagement and creates emotional attachment to the app.

### Core Components

#### Pet System Model
```dart
class PetSpecies {
  final String id;
  final String name;
  final String emoji; // Visual representation
  final int baseCost; // Starting cost in coins
  final List<String> traits; // Special characteristics
  final List<int> evolutionLevels; // Points needed for evolution
}

class UserPet {
  final String userId;
  final String petId;
  final String speciesId;
  final int level; // 1-10
  final int experience; // XP toward next level
  final int happiness; // 0-100 (affects growth rate)
  final int hunger; // 0-100 (needs feeding)
  final DateTime acquiredAt;
  final DateTime lastFedAt;
  final List<String> abilities; // Learned skills
  final Map<String, int> stats; // Strength, intelligence, cuteness
}

class PetEvolution {
  final String fromSpeciesId;
  final String toSpeciesId;
  final int requiredLevel;
  final int requiredExperience;
  final List<String> requiredAbilities;
  final bool requiresItem; // Special item needed
}
```

#### Pet Interaction Mechanics
- **Feeding**: Use coins/treats to feed pet (increases happiness)
- **Training**: Complete lessons to gain XP (level up)
- **Playing**: Mini-games to increase happiness and stats
- **Evolution**: Reach milestones to evolve pet form
- **Bonding**: Consistent interaction increases affection level

#### Pet Growth System
- **Daily XP Gain**: 10 XP per completed lesson
- **Happiness Factor**: 50-150% XP multiplier based on happiness
- **Hunger Penalty**: Reduced happiness/XP if pet hasn't been fed (>24 hours)
- **Level Progression**: 100 XP per level (1-10 levels max)
- **Evolution Stages**: 3-5 evolution stages per species

### Services & Providers

#### PetService
```dart
class PetService {
  // Pet Management
  Future<UserPet> createPet(String userId, String speciesId);
  Future<UserPet?> getUserPet(String userId);
  Future<void> updatePet(UserPet pet);
  Future<void> deletePet(String userId);
  
  // Interactions
  Future<void> feedPet(String userId, int hungerReduction);
  Future<void> playWithPet(String userId, int happinessGain);
  Future<void> trainPet(String userId, int xpGain);
  
  // Evolution
  Future<bool> checkEvolutionEligibility(String userId);
  Future<UserPet?> evolvePet(String userId);
  
  // Stats
  Future<Map<String, int>> getPetStats(String userId);
  Future<PetStatus> getPetStatus(String userId);
}
```

#### Pet-Related Providers
- `userPetProvider` - Current user's pet
- `petSpeciesProvider` - Available pet species list
- `petStatusProvider` - Pet health/happiness status
- `petEvolutionProvider` - Evolution eligibility check
- `petLeaderboardProvider` - Pets by level/experience

### Firestore Schema
```
pets/users/{userId}
├─ petId: string
├─ speciesId: string
├─ level: int (1-10)
├─ experience: int
├─ happiness: int (0-100)
├─ hunger: int (0-100)
├─ acquiredAt: Timestamp
├─ lastFedAt: Timestamp
├─ abilities: array
└─ stats: map
    ├─ strength: int
    ├─ intelligence: int
    └─ cuteness: int

petSpecies/{speciesId}
├─ name: string
├─ emoji: string
├─ baseCost: int
├─ traits: array
├─ evolutionLevels: array
└─ description: string

petEvolutions/{evolutionId}
├─ fromSpeciesId: string
├─ toSpeciesId: string
├─ requiredLevel: int
├─ requiredExperience: int
├─ requiredAbilities: array
└─ requiresItem: boolean
```

### UI Screens (Part 1)

#### 1. Pet Selection/Adoption Screen
- Available species grid with emoji and names
- Cost display (coins needed)
- Species description and abilities
- Adoption button with confirmation

#### 2. Pet Status Screen
- Large pet emoji/avatar display
- Level and experience bar
- Happiness meter with emoji feedback
- Hunger indicator
- Stats display (strength, intelligence, cuteness)

#### 3. Pet Care/Interaction Screen
- Tap areas for different interactions (feed, play, train)
- Animation feedback for each action
- Happiness/hunger change indicators
- Available items/treats inventory

#### 4. Pet Evolution Screen
- Evolution eligibility check
- Before/after comparison view
- Animated evolution sequence
- New abilities display

### Rewards & Economy
- **Adopt Pet**: 500 coins
- **Pet Treats**: 50-200 coins each
- **Level Up Bonus**: +100 XP multiplier
- **Evolution Reward**: +500 coins + special badge
- **Daily Bonus**: +100 happiness if pet cared for

---

## Part 2: Pronunciation Video Gallery

### Overview
A curated collection of professional pronunciation teaching videos covering phonetics, word pronunciation, sentence stress, and speaking techniques. Videos are categorized by difficulty and skill focus.

### Core Components

#### Video Content Model
```dart
class PronunciationVideo {
  final String id;
  final String title; // e.g., "R vs L Pronunciation"
  final String description;
  final String youtubeUrl; // or hosted video URL
  final Duration length;
  final String category; // phonetics, words, sentences, stress
  final int difficulty; // 1-5 (beginner to advanced)
  final List<String> tags; // Searchable keywords
  final DateTime publishedAt;
  final String instructor; // Teacher/creator name
  final List<String> focusAreas; // Skills covered
}

class VideoProgress {
  final String userId;
  final String videoId;
  final Duration watchedDuration;
  final bool isWatched; // > 90% watched
  final bool isLiked;
  final int rating; // 1-5
  final DateTime lastWatchedAt;
  final List<int> keyTimeStamps; // Bookmarked sections
}

class VideoQuiz {
  final String id;
  final String videoId;
  final List<QuizQuestion> questions; // 3-5 questions
  final int passingScore; // 70% default
  final String rewardBadge; // Badge earned on pass
}
```

#### Video Categories
1. **Phonetics** (音素学習)
   - Individual sounds (/r/, /l/, /th/, etc.)
   - Vowel sounds
   - Consonant combinations

2. **Word Pronunciation** (単語発音)
   - Common word stress patterns
   - Silent letters
   - Connected speech

3. **Sentence Stress** (文の強調)
   - Intonation patterns
   - Word stress in sentences
   - Rhythm and timing

4. **Speaking Techniques** (話し方技法)
   - Lip rounding
   - Tongue position
   - Breathing techniques

5. **Native Speakers** (ネイティブ集)
   - Different accents (American, British, Australian)
   - Speed variations
   - Real conversation examples

### Services & Providers

#### VideoService
```dart
class VideoService {
  // Video Management
  Future<List<PronunciationVideo>> getAllVideos({
    String? category,
    int? difficulty,
    String? searchQuery,
  });
  Future<PronunciationVideo?> getVideo(String videoId);
  Future<List<PronunciationVideo>> getRecommendedVideos(String userId);
  
  // Progress Tracking
  Future<void> updateVideoProgress(VideoProgress progress);
  Future<VideoProgress?> getUserVideoProgress(String userId, String videoId);
  Future<List<VideoProgress>> getUserWatchHistory(String userId, {int limit = 20});
  
  // Ratings & Engagement
  Future<void> rateVideo(String userId, String videoId, int rating);
  Future<void> likeVideo(String userId, String videoId);
  Future<double> getAverageRating(String videoId);
  
  // Quizzes
  Future<VideoQuiz?> getVideoQuiz(String videoId);
  Future<bool> submitQuizAnswers(String userId, String videoId, List<String> answers);
}
```

#### Video-Related Providers
- `pronunciationVideosProvider` - All videos with filters
- `userVideoProgressProvider` - Watch history and progress
- `recommendedVideosProvider` - Personalized recommendations
- `videoQuizProvider` - Quiz data for specific video

### Firestore Schema
```
videos/pronunciation/{videoId}
├─ title: string
├─ description: string
├─ youtubeUrl: string
├─ length: int (seconds)
├─ category: string
├─ difficulty: int (1-5)
├─ tags: array
├─ publishedAt: Timestamp
├─ instructor: string
├─ focusAreas: array
├─ averageRating: double
├─ viewCount: int
└─ likes: int

videoProgress/{userId}/{videoId}
├─ watchedDuration: int (seconds)
├─ isWatched: boolean
├─ isLiked: boolean
├─ rating: int (1-5)
├─ lastWatchedAt: Timestamp
└─ keyTimeStamps: array

videoQuizzes/{videoId}
├─ questions: array
│   ├─ questionText: string
│   ├─ options: array
│   ├─ correctAnswer: string
│   └─ explanation: string
├─ passingScore: int
└─ rewardBadge: string

userVideoQuizResults/{userId}/{videoId}
├─ score: int
├─ passed: boolean
├─ attemptCount: int
├─ lastAttemptAt: Timestamp
└─ badgesEarned: array
```

### UI Screens (Part 2)

#### 1. Video Gallery Screen
- Video grid/list with thumbnails
- Difficulty badges and duration
- Category tabs/filter chips
- Search functionality
- "Continue Watching" section
- Progress indicators for partially watched videos

#### 2. Video Player Screen
- Full-screen video playback
- Playback controls (play, pause, speed: 0.75x, 1x, 1.5x)
- Video duration and current time
- Bookmark feature for key sections
- Rating and like buttons
- Video description and metadata
- Transcript/subtitle display

#### 3. Quiz Screen (Post-Video)
- 3-5 comprehension questions
- Multiple choice with explanations
- Instant feedback (correct/incorrect)
- Score calculation
- Badge reward on passing
- Retry option

#### 4. Watch History & Recommendations
- Timeline of watched videos
- "Continue Watching" quick-start
- Personalized recommendations based on:
  - Difficulty progression
  - Category preferences
  - Watched videos similarity
  - Learning goals

### Content Curation
- **Initial Library**: 50+ videos
- **Update Frequency**: 2-3 videos per week
- **Production Quality**: Professional instructors
- **Accessibility**: Subtitles in Japanese and English
- **Mobile Optimized**: Adaptive streaming quality

### Engagement Mechanics
- **Video Badge**: Earn badge after watching 10 videos
- **Quiz Rewards**: 100 XP + coins per passing quiz
- **Streak Bonus**: Watch 3+ videos in a day → bonus coins
- **Expert Badge**: Complete all videos in a category
- **Rating System**: Top-rated videos featured on home screen

---

## Part 3: Social Challenges & Rewards

### Overview
Time-limited social challenges encouraging users to compete or collaborate while learning, with reward tiers and leaderboards for motivation.

### Challenge Types

#### 1. Daily Challenges
- Complete 5 lessons today
- Score 90%+ on 3 lessons
- Earn 500 XP today
- 24-hour window
- Reset daily at midnight JST

#### 2. Weekly Challenges
- Complete 30 lessons this week
- Achieve 5-day streak
- Improve pronunciation score by 50 points
- Participate in 1 multiplayer match
- 7-day window

#### 3. Community Challenges
- "Week of X" themes (e.g., "Week of Phonetics")
- Top 100 participants get featured
- Tier-based rewards (Gold/Silver/Bronze)
- Leaderboard tracking
- 1-2 running simultaneously

#### 4. Friend Challenges
- Head-to-head lesson completion race
- Compare pronunciation scores
- Group goal achievements
- Friendly competition with rewards

### Challenge Rewards
```dart
class ChallengeReward {
  final String id;
  final String challengeId;
  final int tier; // 1-5 (bronze to legendary)
  final int minProgress; // % to achieve
  final int coinReward;
  final int xpReward;
  final String? badgeId;
  final String? specialItem;
}
```

### Services & Providers
- `activeChallengesProvider` - Current challenges
- `userChallengeProgressProvider` - User progress tracking
- `challengeLeaderboardProvider` - Rankings
- `completedChallengesProvider` - History

### UI Screens (Part 3)

#### 1. Challenges Hub Screen
- Active challenges overview
- Progress bars for each challenge
- Remaining time display
- Leaderboard preview
- Join/claim reward buttons

#### 2. Challenge Detail Screen
- Full challenge description
- Reward tiers breakdown
- Current user ranking
- Leaderboard (top 10/100)
- Progress tracking in real-time

#### 3. Challenge Completion Screen
- Animated reward popup
- Badge/item display
- Coins/XP earned
- Leaderboard position
- "Share with Friends" option

---

## Integration Points

### With Existing Systems

#### Leaderboard Integration (Phase 12)
- Pet level leaderboard
- Video completion leaderboard
- Challenge rank integration
- XP earned comparisons

#### Notification System (Phase 8)
- Challenge started notifications
- Progress update reminders
- Leaderboard position changes
- Challenge completion celebrations

#### Admin Dashboard (Phase 11)
- Challenge management screen
- Video library management
- Pet species management
- Analytics dashboard for engagement metrics

#### User Profile (Phase 4)
- Pet display in profile
- Video progress badge
- Challenge completion history
- Social badges earned

---

## Performance Characteristics

### Load Times
- Pet status screen: < 100ms
- Video gallery: < 300ms (with thumbnails)
- Challenge hub: < 200ms

### Data Caching
- Video library: 1-hour cache
- User pet data: Real-time
- Challenge leaderboards: 5-minute cache
- Video progress: Real-time

### Database Queries
- Get user pet: < 50ms
- Update pet stats: < 100ms
- Fetch videos by category: < 200ms
- Challenge leaderboard: < 250ms

---

## Testing Checklist

- [ ] Pet creation and adoption
- [ ] Pet feeding and happiness mechanics
- [ ] Pet experience and leveling
- [ ] Pet evolution with eligibility checks
- [ ] Video gallery filtering and search
- [ ] Video progress tracking
- [ ] Video quiz submission and scoring
- [ ] Challenge progress calculation
- [ ] Leaderboard ranking accuracy
- [ ] Reward distribution
- [ ] Integration with existing systems
- [ ] Notification triggers
- [ ] Data persistence
- [ ] Performance benchmarks

---

## Future Enhancements

1. **Pet Customization**
   - Pet naming
   - Color/pattern variations
   - Accessory items
   - Pet housing/environment

2. **Video Features**
   - User-generated pronunciation submissions
   - Community voting on videos
   - Interactive phonetic exercises
   - Pronunciation challenge using videos

3. **Social Expansion**
   - Multiplayer pet battles
   - Pet trading system
   - Friend challenges with chat
   - Guild/team challenges

4. **Advanced Analytics**
   - Pronunciation improvement tracking via videos
   - Challenge completion insights
   - Pet growth statistics
   - Engagement metrics

---

## Configuration

### Default Settings
- **Pet Happiness Decay**: -10 per 24 hours without interaction
- **Pet Hunger Decay**: -10 per 24 hours without feeding
- **Daily Challenge Reset**: 00:00 JST
- **Challenge Reward Cap**: 1,000 coins per day
- **Video Library Size**: 50+ videos initially

### Thresholds
- **Evolution Level**: 5, 8, 10
- **Max Pet Level**: 10
- **Challenge Participation**: Minimum 1 interaction
- **Leaderboard Cutoff**: Top 100 players

---

**Phase 13 Status**: 🚀 Part 1 - Pet System (Starting)
**Next**: Phase 13 Part 2 - Pronunciation Videos, then Part 3 - Social Challenges
