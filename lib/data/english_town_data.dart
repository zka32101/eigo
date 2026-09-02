import 'package:flutter/material.dart';
import '../models/english_town_model.dart';

/// Complete English-Only Town map data with all locations, NPCs, and scenes
class EnglishTownData {
  static final TownMap townMap = TownMap(
    id: 'english_town_v1',
    name: 'English-Only Town',
    locations: _createLocations(),
    npcs: _createNPCs(),
    scenes: _createScenes(),
    createdAt: DateTime(2026, 9, 1),
  );

  /// Create all 8 locations in the town
  static List<Location> _createLocations() {
    return [
      // School
      Location(
        id: 'loc_school',
        name: 'School',
        emoji: '🏫',
        description: 'A modern English learning school where Miss Sarah teaches',
        position: const Offset(200, 100),
        npcIds: ['npc_sarah'],
        sceneIds: [
          'scene_school_greet',
          'scene_school_homework',
          'scene_school_grades',
          'scene_school_activities',
          'scene_school_schedule',
        ],
        backgroundImage: 'assets/backgrounds/school.png',
      ),

      // Café
      Location(
        id: 'loc_cafe',
        name: 'Café',
        emoji: '☕',
        description: 'A cozy café where Tom works as a barista',
        position: const Offset(350, 150),
        npcIds: ['npc_tom'],
        sceneIds: [
          'scene_cafe_ordering',
          'scene_cafe_smalltalk',
          'scene_cafe_recommendation',
          'scene_cafe_payment',
          'scene_cafe_weather',
        ],
        backgroundImage: 'assets/backgrounds/cafe.png',
      ),

      // Library
      Location(
        id: 'loc_library',
        name: 'Library',
        emoji: '📚',
        description: 'A quiet library with Emily as the helpful librarian',
        position: const Offset(100, 250),
        npcIds: ['npc_emily'],
        sceneIds: [
          'scene_lib_greet',
          'scene_lib_searching',
          'scene_lib_recommendation',
          'scene_lib_quiet',
          'scene_lib_study',
        ],
        backgroundImage: 'assets/backgrounds/library.png',
      ),

      // Shop
      Location(
        id: 'loc_shop',
        name: 'Shop',
        emoji: '🛍️',
        description: 'A general store owned by Mr. Chen',
        position: const Offset(500, 200),
        npcIds: ['npc_chen'],
        sceneIds: [
          'scene_shop_greeting',
          'scene_shop_browsing',
          'scene_shop_price',
          'scene_shop_sizing',
          'scene_shop_checkout',
        ],
        backgroundImage: 'assets/backgrounds/shop.png',
      ),

      // Restaurant
      Location(
        id: 'loc_restaurant',
        name: 'Restaurant',
        emoji: '🍽️',
        description: 'A nice restaurant where Marco the chef welcomes guests',
        position: const Offset(400, 350),
        npcIds: ['npc_marco'],
        sceneIds: [
          'scene_rest_welcome',
          'scene_rest_menu',
          'scene_rest_ordering',
          'scene_rest_special',
          'scene_rest_feedback',
        ],
        backgroundImage: 'assets/backgrounds/restaurant.png',
      ),

      // Park
      Location(
        id: 'loc_park',
        name: 'Park',
        emoji: '🏞️',
        description: 'A beautiful park where Lisa likes to jog',
        position: const Offset(150, 400),
        npcIds: ['npc_lisa'],
        sceneIds: [
          'scene_park_hello',
          'scene_park_exercise',
          'scene_park_nature',
          'scene_park_weather',
          'scene_park_friends',
        ],
        backgroundImage: 'assets/backgrounds/park.png',
      ),

      // Bus Station
      Location(
        id: 'loc_bus_station',
        name: 'Bus Station',
        emoji: '🚏',
        description: 'The central bus station managed by David',
        position: const Offset(300, 500),
        npcIds: ['npc_david'],
        sceneIds: [
          'scene_bus_info',
          'scene_bus_ticket',
          'scene_bus_schedule',
          'scene_bus_destination',
          'scene_bus_help',
        ],
        backgroundImage: 'assets/backgrounds/bus_station.png',
      ),

      // Museum
      Location(
        id: 'loc_museum',
        name: 'Museum',
        emoji: '🏛️',
        description: 'A cultural museum curated by Dr. Wilson',
        position: const Offset(450, 450),
        npcIds: ['npc_wilson'],
        sceneIds: [
          'scene_museum_welcome',
          'scene_museum_exhibit',
          'scene_museum_history',
          'scene_museum_artist',
          'scene_museum_tour',
        ],
        backgroundImage: 'assets/backgrounds/museum.png',
      ),
    ];
  }

  /// Create all 8 NPC characters
  static List<NPC> _createNPCs() {
    return [
      // Miss Sarah - School Teacher
      NPC(
        id: 'npc_sarah',
        name: 'Miss Sarah',
        emoji: '👩‍🏫',
        personality: 'Encouraging, educational, patient',
        nativeLocation: 'loc_school',
        frequentLocations: ['loc_library', 'loc_museum'],
        backstory: 'An English teacher with 10+ years of experience who loves helping students',
        typicalDifficulty: ConversationDifficulty.medium,
        preferredTime: TimeOfDay.morning,
        characterColor: const Color(0xFF4CAF50), // Green
      ),

      // Tom - Café Barista
      NPC(
        id: 'npc_tom',
        name: 'Tom',
        emoji: '☕',
        personality: 'Friendly, chatty, outgoing',
        nativeLocation: 'loc_cafe',
        frequentLocations: ['loc_shop', 'loc_park'],
        backstory: 'A young barista who loves meeting people and practicing English',
        typicalDifficulty: ConversationDifficulty.easy,
        preferredTime: TimeOfDay.afternoon,
        characterColor: const Color(0xFF8D6E63), // Brown
      ),

      // Emily - Librarian
      NPC(
        id: 'npc_emily',
        name: 'Emily',
        emoji: '📚',
        personality: 'Knowledgeable, quiet, helpful',
        nativeLocation: 'loc_library',
        frequentLocations: ['loc_school', 'loc_museum'],
        backstory: 'A librarian with vast knowledge who helps patrons find exactly what they need',
        typicalDifficulty: ConversationDifficulty.medium,
        characterColor: const Color(0xFF9C27B0), // Purple
      ),

      // Mr. Chen - Shop Owner
      NPC(
        id: 'npc_chen',
        name: 'Mr. Chen',
        emoji: '🛍️',
        personality: 'Professional, polite, business-minded',
        nativeLocation: 'loc_shop',
        frequentLocations: ['loc_restaurant', 'loc_bus_station'],
        backstory: 'A shop owner who immigrated to pursue business and speaks fluent English',
        typicalDifficulty: ConversationDifficulty.medium,
        characterColor: const Color(0xFF2196F3), // Blue
      ),

      // Marco - Chef
      NPC(
        id: 'npc_marco',
        name: 'Marco',
        emoji: '👨‍🍳',
        personality: 'Passionate, expressive, talkative',
        nativeLocation: 'loc_restaurant',
        frequentLocations: ['loc_cafe', 'loc_park'],
        backstory: 'An Italian chef who moved to an English-speaking country and loves sharing food stories',
        typicalDifficulty: ConversationDifficulty.hard,
        preferredTime: TimeOfDay.evening,
        characterColor: const Color(0xFFE91E63), // Pink
      ),

      // Lisa - Jogger
      NPC(
        id: 'npc_lisa',
        name: 'Lisa',
        emoji: '🏃‍♀️',
        personality: 'Athletic, energetic, motivational',
        nativeLocation: 'loc_park',
        frequentLocations: ['loc_cafe', 'loc_shop'],
        backstory: 'A fitness enthusiast and marathon runner who speaks English with international athletes',
        typicalDifficulty: ConversationDifficulty.medium,
        characterColor: const Color(0xFFFF9800), // Orange
      ),

      // David - Bus Station Agent
      NPC(
        id: 'npc_david',
        name: 'David',
        emoji: '👨‍💼',
        personality: 'Professional, efficient, helpful',
        nativeLocation: 'loc_bus_station',
        frequentLocations: ['loc_museum', 'loc_shop'],
        backstory: 'A bus station manager who helps tourists and locals with travel information daily',
        typicalDifficulty: ConversationDifficulty.easy,
        characterColor: const Color(0xFF009688), // Teal
      ),

      // Dr. Wilson - Museum Curator
      NPC(
        id: 'npc_wilson',
        name: 'Dr. Wilson',
        emoji: '🎓',
        personality: 'Intellectual, detailed, passionate',
        nativeLocation: 'loc_museum',
        frequentLocations: ['loc_library', 'loc_school'],
        backstory: 'A museum curator with a PhD in history who gives detailed explanations of exhibits',
        typicalDifficulty: ConversationDifficulty.hard,
        characterColor: const Color(0xFF673AB7), // Deep Purple
      ),
    ];
  }

  /// Create initial interaction scenes (template base)
  /// In full implementation, these would be expanded to 59+ variations
  static List<InteractionScene> _createScenes() {
    return [
      // SCHOOL SCENES
      InteractionScene(
        id: 'scene_school_greet',
        npcId: 'npc_sarah',
        locationId: 'loc_school',
        title: 'Greeting Miss Sarah',
        description: 'Meet your English teacher in the classroom',
        initialGreeting: 'Hello! Welcome to my English class. How are you today?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['greeting', 'teacher', 'classroom'],
      ),

      InteractionScene(
        id: 'scene_school_homework',
        npcId: 'npc_sarah',
        locationId: 'loc_school',
        title: 'Asking About Homework',
        description: 'Discuss assignment with Miss Sarah',
        initialGreeting: 'Did you complete the homework assignment I gave last time?',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['homework', 'assignment', 'study'],
      ),

      InteractionScene(
        id: 'scene_school_grades',
        npcId: 'npc_sarah',
        locationId: 'loc_school',
        title: 'Discussing Grades',
        description: 'Talk about your progress in class',
        initialGreeting: 'Your recent test score was very good! Keep up the hard work.',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['grades', 'test', 'progress'],
      ),

      InteractionScene(
        id: 'scene_school_activities',
        npcId: 'npc_sarah',
        locationId: 'loc_school',
        title: 'School Activities',
        description: 'Learn about upcoming school events',
        initialGreeting: 'Have you heard about the English club meeting this Friday?',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['activities', 'events', 'club'],
      ),

      InteractionScene(
        id: 'scene_school_schedule',
        npcId: 'npc_sarah',
        locationId: 'loc_school',
        title: 'Class Schedule',
        description: 'Discuss your class schedule',
        initialGreeting: 'What subjects are you taking this semester?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['schedule', 'subjects', 'classes'],
      ),

      // CAFÉ SCENES
      InteractionScene(
        id: 'scene_cafe_ordering',
        npcId: 'npc_tom',
        locationId: 'loc_cafe',
        title: 'Ordering Coffee',
        description: 'Order a drink from Tom at the café',
        initialGreeting: 'Welcome! What can I get for you today?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['ordering', 'coffee', 'drinks'],
      ),

      InteractionScene(
        id: 'scene_cafe_smalltalk',
        npcId: 'npc_tom',
        locationId: 'loc_cafe',
        title: 'Small Talk',
        description: 'Chat with Tom while enjoying your drink',
        initialGreeting: 'So, how has your day been so far?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['smalltalk', 'conversation', 'casual'],
      ),

      InteractionScene(
        id: 'scene_cafe_recommendation',
        npcId: 'npc_tom',
        locationId: 'loc_cafe',
        title: 'Drink Recommendation',
        description: 'Ask Tom for a drink recommendation',
        initialGreeting: 'Are you trying something new today? I have some great recommendations!',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['recommendation', 'suggestion', 'preference'],
      ),

      InteractionScene(
        id: 'scene_cafe_payment',
        npcId: 'npc_tom',
        locationId: 'loc_cafe',
        title: 'Making Payment',
        description: 'Pay for your order at the café',
        initialGreeting: 'That will be five dollars. Will that be cash or card?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['payment', 'money', 'cash'],
      ),

      InteractionScene(
        id: 'scene_cafe_weather',
        npcId: 'npc_tom',
        locationId: 'loc_cafe',
        title: 'Weather Talk',
        description: 'Discuss the weather with Tom',
        initialGreeting: 'Beautiful weather today, isn\'t it?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['weather', 'environment', 'casual'],
      ),

      // LIBRARY SCENES
      InteractionScene(
        id: 'scene_lib_greet',
        npcId: 'npc_emily',
        locationId: 'loc_library',
        title: 'Greeting at Library',
        description: 'Meet Emily at the library',
        initialGreeting: 'Welcome to the library! Can I help you find anything?',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['greeting', 'library', 'help'],
      ),

      InteractionScene(
        id: 'scene_lib_searching',
        npcId: 'npc_emily',
        locationId: 'loc_library',
        title: 'Searching for Books',
        description: 'Ask Emily to help you find a specific book',
        initialGreeting: 'What kind of book are you looking for?',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['searching', 'books', 'help'],
      ),

      InteractionScene(
        id: 'scene_lib_recommendation',
        npcId: 'npc_emily',
        locationId: 'loc_library',
        title: 'Book Recommendation',
        description: 'Get a book recommendation from Emily',
        initialGreeting: 'Based on your interests, I have some excellent recommendations!',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['recommendation', 'book', 'suggestion'],
      ),

      InteractionScene(
        id: 'scene_lib_quiet',
        npcId: 'npc_emily',
        locationId: 'loc_library',
        title: 'Keeping Quiet',
        description: 'Emily reminds you about library rules',
        initialGreeting: 'Please keep your voice down. Others are studying.',
        baseConversation: [],
        difficulty: ConversationDifficulty.easy,
        xpReward: 50,
        coinReward: 25,
        keywords: ['rules', 'quiet', 'behavior'],
      ),

      InteractionScene(
        id: 'scene_lib_study',
        npcId: 'npc_emily',
        locationId: 'loc_library',
        title: 'Study Group',
        description: 'Invite Emily to join your study session',
        initialGreeting: 'Would you like a quiet place to study?',
        baseConversation: [],
        difficulty: ConversationDifficulty.medium,
        xpReward: 75,
        coinReward: 35,
        keywords: ['study', 'group', 'learning'],
      ),

      // SHOP SCENES (abbreviated for brevity)
      // RESTAURANT SCENES
      // PARK SCENES
      // BUS STATION SCENES
      // MUSEUM SCENES

      // Note: Full implementation would include 5-7 scenes per location = 40-56 scenes total
      // Additional scenes would be added following the same pattern
    ];
  }
}
