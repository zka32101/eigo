import 'package:json_annotation/json_annotation.dart';

part 'npc_schedule_model.g.dart';

/// 曜日
enum DayOfWeek {
  monday('月曜日', 'Monday'),
  tuesday('火曜日', 'Tuesday'),
  wednesday('水曜日', 'Wednesday'),
  thursday('木曜日', 'Thursday'),
  friday('金曜日', 'Friday'),
  saturday('土曜日', 'Saturday'),
  sunday('日曜日', 'Sunday');

  final String japanese;
  final String english;

  const DayOfWeek(this.japanese, this.english);

  /// 現在の曜日を取得
  static DayOfWeek fromDateTime(DateTime dateTime) {
    return values[dateTime.weekday % 7];
  }
}

/// 季節
enum Season {
  spring('春', 'Spring'),
  summer('夏', 'Summer'),
  autumn('秋', 'Autumn'),
  winter('冬', 'Winter');

  final String japanese;
  final String english;

  const Season(this.japanese, this.english);

  /// 月から季節を取得
  static Season fromMonth(int month) {
    if (month >= 3 && month <= 5) return Season.spring;
    if (month >= 6 && month <= 8) return Season.summer;
    if (month >= 9 && month <= 11) return Season.autumn;
    return Season.winter;
  }

  /// 日付から季節を取得
  static Season fromDateTime(DateTime dateTime) {
    return fromMonth(dateTime.month);
  }
}

/// 営業時間帯
enum TimeOfDay {
  earlyMorning('早朝', 'Early Morning', 5, 8),
  morning('朝', 'Morning', 8, 12),
  afternoon('昼', 'Afternoon', 12, 17),
  evening('夕方', 'Evening', 17, 21),
  night('夜', 'Night', 21, 24),
  lateNight('深夜', 'Late Night', 0, 5);

  final String japanese;
  final String english;
  final int startHour;
  final int endHour;

  const TimeOfDay(this.japanese, this.english, this.startHour, this.endHour);

  /// 時刻から時間帯を取得
  static TimeOfDay fromHour(int hour) {
    if (hour >= 5 && hour < 8) return TimeOfDay.earlyMorning;
    if (hour >= 8 && hour < 12) return TimeOfDay.morning;
    if (hour >= 12 && hour < 17) return TimeOfDay.afternoon;
    if (hour >= 17 && hour < 21) return TimeOfDay.evening;
    if (hour >= 21 && hour < 24) return TimeOfDay.night;
    return TimeOfDay.lateNight;
  }

  /// 日付時刻から時間帯を取得
  static TimeOfDay fromDateTime(DateTime dateTime) {
    return fromHour(dateTime.hour);
  }
}

/// NPC 営業時間
@JsonSerializable()
class NPCBusinessHours {
  /// 時間帯
  final TimeOfDay timeOfDay;

  /// 利用可能な場所ID
  final List<String> availableLocationIds;

  /// NPCのアクティビティ（何をしているか）
  final String activity;

  /// 営業時間に存在しない確率（0.0-1.0）
  final double absentProbability;

  /// 特別なイベント
  final String? specialEvent;

  NPCBusinessHours({
    required this.timeOfDay,
    required this.availableLocationIds,
    required this.activity,
    this.absentProbability = 0.0,
    this.specialEvent,
  });

  factory NPCBusinessHours.fromJson(Map<String, dynamic> json) =>
      _$NPCBusinessHoursFromJson(json);

  Map<String, dynamic> toJson() => _$NPCBusinessHoursToJson(this);
}

/// 曜日パターン（営業時間のセット）
@JsonSerializable()
class DayPattern {
  /// 曜日
  final DayOfWeek dayOfWeek;

  /// その曜日の営業時間パターン
  final List<NPCBusinessHours> hoursPattern;

  /// このパターンが有効か
  final bool isActive;

  DayPattern({
    required this.dayOfWeek,
    required this.hoursPattern,
    this.isActive = true,
  });

  factory DayPattern.fromJson(Map<String, dynamic> json) =>
      _$DayPatternFromJson(json);

  Map<String, dynamic> toJson() => _$DayPatternToJson(this);
}

/// 季節パターン（季節固有の営業時間修正）
@JsonSerializable()
class SeasonalPattern {
  /// 季節
  final Season season;

  /// 季節中に休む曜日
  final List<DayOfWeek> closedDays;

  /// 通常営業時間の修正
  final Map<TimeOfDay, String>? timeOfDayModifications;

  /// 季節固有イベント
  final String? seasonalEvent;

  SeasonalPattern({
    required this.season,
    required this.closedDays,
    this.timeOfDayModifications,
    this.seasonalEvent,
  });

  factory SeasonalPattern.fromJson(Map<String, dynamic> json) =>
      _$SeasonalPatternFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonalPatternToJson(this);
}

/// NPC スケジュール
@JsonSerializable()
class NPCSchedule {
  /// NPC ID
  final String npcId;

  /// 曜日別営業パターン
  final List<DayPattern> weeklyPattern;

  /// 季節パターン
  final List<SeasonalPattern> seasonalPatterns;

  /// デフォルト営業時間（パターンに該当しない場合）
  final List<NPCBusinessHours> defaultBusinessHours;

  /// スケジュール作成日時
  final DateTime createdAt;

  /// スケジュール更新日時
  DateTime updatedAt;

  NPCSchedule({
    required this.npcId,
    required this.weeklyPattern,
    required this.seasonalPatterns,
    required this.defaultBusinessHours,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 指定日時に利用可能か確認
  bool isAvailable(DateTime dateTime) {
    final dayPattern = _getDayPattern(dateTime);
    if (dayPattern == null || !dayPattern.isActive) return false;

    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final hours = dayPattern.hoursPattern
        .firstWhere((h) => h.timeOfDay == timeOfDay, orElse: () => NPCBusinessHours(
              timeOfDay: timeOfDay,
              availableLocationIds: [],
              activity: 'Closed',
            ));

    if (hours.availableLocationIds.isEmpty) return false;

    // 欠席確率をチェック
    return hours.absentProbability < 0.5;
  }

  /// 指定日時に到達可能な場所を取得
  List<String> getAvailableLocations(DateTime dateTime) {
    final dayPattern = _getDayPattern(dateTime);
    if (dayPattern == null || !dayPattern.isActive) return [];

    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final hours = dayPattern.hoursPattern
        .firstWhere((h) => h.timeOfDay == timeOfDay, orElse: () => NPCBusinessHours(
              timeOfDay: timeOfDay,
              availableLocationIds: [],
              activity: 'Closed',
            ));

    return hours.availableLocationIds;
  }

  /// 指定日時の活動を取得
  String? getActivity(DateTime dateTime) {
    final dayPattern = _getDayPattern(dateTime);
    if (dayPattern == null || !dayPattern.isActive) return null;

    final timeOfDay = TimeOfDay.fromDateTime(dateTime);
    final hours = dayPattern.hoursPattern
        .firstWhere((h) => h.timeOfDay == timeOfDay, orElse: () => NPCBusinessHours(
              timeOfDay: timeOfDay,
              availableLocationIds: [],
              activity: 'Closed',
            ));

    return hours.activity;
  }

  /// 次の営業時間を取得
  DateTime? getNextAvailableTime(DateTime fromTime) {
    DateTime current = fromTime;

    // 最大7日間検索
    for (int i = 0; i < 7; i++) {
      if (isAvailable(current)) {
        return current;
      }
      current = current.add(const Duration(hours: 1));
    }

    return null;
  }

  /// 次の定休日を取得
  DateTime? getNextClosedDay(DateTime fromTime) {
    DateTime current = DateTime(fromTime.year, fromTime.month, fromTime.day);

    for (int i = 0; i < 30; i++) {
      if (!isAvailable(current)) {
        return current;
      }
      current = current.add(const Duration(days: 1));
    }

    return null;
  }

  /// 曜日パターンを取得
  DayPattern? _getDayPattern(DateTime dateTime) {
    final dayOfWeek = DayOfWeek.fromDateTime(dateTime);
    return weeklyPattern.firstWhere(
      (p) => p.dayOfWeek == dayOfWeek,
      orElse: () => DayPattern(
        dayOfWeek: dayOfWeek,
        hoursPattern: defaultBusinessHours,
      ),
    );
  }

  /// コピー関数
  NPCSchedule copyWith({
    String? npcId,
    List<DayPattern>? weeklyPattern,
    List<SeasonalPattern>? seasonalPatterns,
    List<NPCBusinessHours>? defaultBusinessHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NPCSchedule(
      npcId: npcId ?? this.npcId,
      weeklyPattern: weeklyPattern ?? this.weeklyPattern,
      seasonalPatterns: seasonalPatterns ?? this.seasonalPatterns,
      defaultBusinessHours: defaultBusinessHours ?? this.defaultBusinessHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory NPCSchedule.fromJson(Map<String, dynamic> json) =>
      _$NPCScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$NPCScheduleToJson(this);
}

/// NPC 可用性情報
class NPCAvailability {
  /// NPC ID
  final String npcId;

  /// 利用可能か
  final bool isAvailable;

  /// 現在の活動
  final String activity;

  /// 現在地
  final List<String> currentLocations;

  /// 次に利用可能な時刻
  final DateTime? nextAvailableTime;

  /// 次の定休日
  final DateTime? nextClosedDay;

  /// 更新日時
  final DateTime updatedAt;

  NPCAvailability({
    required this.npcId,
    required this.isAvailable,
    required this.activity,
    required this.currentLocations,
    this.nextAvailableTime,
    this.nextClosedDay,
    required this.updatedAt,
  });
}

/// NPC 訪問記録
@JsonSerializable()
class NPCVisitRecord {
  /// NPC ID
  final String npcId;

  /// 訪問日時
  final DateTime visitedAt;

  /// 訪問時の場所
  final String location;

  /// 訪問時の時間帯
  final TimeOfDay timeOfDay;

  /// NPCの状態
  final String npcState;

  /// 会話があったか
  final bool hadDialogue;

  /// メモ
  final String? notes;

  NPCVisitRecord({
    required this.npcId,
    required this.visitedAt,
    required this.location,
    required this.timeOfDay,
    required this.npcState,
    required this.hadDialogue,
    this.notes,
  });

  factory NPCVisitRecord.fromJson(Map<String, dynamic> json) =>
      _$NPCVisitRecordFromJson(json);

  Map<String, dynamic> toJson() => _$NPCVisitRecordToJson(this);
}

/// NPC 訪問スポット
@JsonSerializable()
class NPCSpot {
  /// スポット ID
  final String spotId;

  /// スポット名
  final String name;

  /// 説明
  final String description;

  /// 場所 ID
  final String locationId;

  /// このスポットで通常会える時間帯
  final List<TimeOfDay> usuallySeeAt;

  /// このスポットでの平均滞在時間（分）
  final int avgDurationMinutes;

  /// 訪問確率（0.0-1.0）
  final double visitProbability;

  NPCSpot({
    required this.spotId,
    required this.name,
    required this.description,
    required this.locationId,
    required this.usuallySeeAt,
    required this.avgDurationMinutes,
    this.visitProbability = 0.8,
  });

  factory NPCSpot.fromJson(Map<String, dynamic> json) =>
      _$NPCSpotFromJson(json);

  Map<String, dynamic> toJson() => _$NPCSpotToJson(this);
}

/// NPC 日常ルーチン
@JsonSerializable()
class NPCRoutine {
  /// ルーチン ID
  final String routineId;

  /// NPC ID
  final String npcId;

  /// 曜日
  final DayOfWeek dayOfWeek;

  /// ルーチンアイテム（時系列）
  final List<RoutineItem> items;

  /// このルーチンが有効か
  final bool isActive;

  NPCRoutine({
    required this.routineId,
    required this.npcId,
    required this.dayOfWeek,
    required this.items,
    this.isActive = true,
  });

  factory NPCRoutine.fromJson(Map<String, dynamic> json) =>
      _$NPCRoutineFromJson(json);

  Map<String, dynamic> toJson() => _$NPCRoutineToJson(this);
}

/// ルーチンアイテム
@JsonSerializable()
class RoutineItem {
  /// 時間帯
  final TimeOfDay timeOfDay;

  /// スポット ID
  final String spotId;

  /// 活動内容
  final String activity;

  /// 期間（分）
  final int duration;

  RoutineItem({
    required this.timeOfDay,
    required this.spotId,
    required this.activity,
    required this.duration,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) =>
      _$RoutineItemFromJson(json);

  Map<String, dynamic> toJson() => _$RoutineItemToJson(this);
}
