import 'package:eigo/models/npc_schedule_model.dart';

/// NPC スケジュール管理サービス
class NPCScheduleService {
  static final NPCScheduleService _instance =
      NPCScheduleService._internal();

  factory NPCScheduleService.getInstance() {
    return _instance;
  }

  NPCScheduleService._internal();

  /// NPC スケジュールを初期化
  NPCSchedule initializeSchedule(
    String npcId,
    List<DayPattern> weeklyPattern,
    List<SeasonalPattern> seasonalPatterns,
    List<NPCBusinessHours> defaultBusinessHours,
  ) {
    return NPCSchedule(
      npcId: npcId,
      weeklyPattern: weeklyPattern,
      seasonalPatterns: seasonalPatterns,
      defaultBusinessHours: defaultBusinessHours,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// NPC の可用性を取得
  NPCAvailability getAvailability(
    NPCSchedule schedule,
    DateTime dateTime,
  ) {
    final isAvailable = schedule.isAvailable(dateTime);
    final activity = schedule.getActivity(dateTime) ?? 'Unknown';
    final locations = schedule.getAvailableLocations(dateTime);
    final nextAvailable = schedule.getNextAvailableTime(dateTime);
    final nextClosed = schedule.getNextClosedDay(dateTime);

    return NPCAvailability(
      npcId: schedule.npcId,
      isAvailable: isAvailable,
      activity: activity,
      currentLocations: locations,
      nextAvailableTime: nextAvailable,
      nextClosedDay: nextClosed,
      updatedAt: DateTime.now(),
    );
  }

  /// 特定時刻での可用性を確認
  bool isAvailableAt(
    NPCSchedule schedule,
    DateTime dateTime,
  ) {
    return schedule.isAvailable(dateTime);
  }

  /// 特定場所で会える確率を計算
  double getProbabilityAtLocation(
    NPCSchedule schedule,
    String locationId,
    TimeOfDay timeOfDay,
  ) {
    final dayPattern = schedule.weeklyPattern.firstWhere(
      (p) => p.dayOfWeek == DayOfWeek.fromDateTime(DateTime.now()),
      orElse: () => DayPattern(
        dayOfWeek: DayOfWeek.monday,
        hoursPattern: schedule.defaultBusinessHours,
      ),
    );

    final businessHour = dayPattern.hoursPattern.firstWhere(
      (h) => h.timeOfDay == timeOfDay,
      orElse: () => NPCBusinessHours(
        timeOfDay: timeOfDay,
        availableLocationIds: [],
        activity: 'Closed',
      ),
    );

    if (!businessHour.availableLocationIds.contains(locationId)) {
      return 0.0;
    }

    return (1.0 - businessHour.absentProbability) *
        (businessHour.availableLocationIds.length > 0 ? 1.0 : 0.5);
  }

  /// 次に会える時間を取得
  DateTime? getNextMeetTime(
    NPCSchedule schedule,
    DateTime fromTime,
    String? preferredLocationId,
  ) {
    DateTime current = fromTime;

    for (int i = 0; i < 168; i++) {
      // 1週間検索
      if (schedule.isAvailable(current)) {
        if (preferredLocationId != null) {
          final locations = schedule.getAvailableLocations(current);
          if (locations.contains(preferredLocationId)) {
            return current;
          }
        } else {
          return current;
        }
      }
      current = current.add(const Duration(hours: 1));
    }

    return null;
  }

  /// 次に会えない時間を取得
  DateTime? getNextUnavailableTime(
    NPCSchedule schedule,
    DateTime fromTime,
  ) {
    return schedule.getNextClosedDay(fromTime);
  }

  /// 訪問記録を作成
  NPCVisitRecord recordVisit(
    String npcId,
    DateTime visitedAt,
    String location,
    String npcState,
    bool hadDialogue,
    String? notes,
  ) {
    return NPCVisitRecord(
      npcId: npcId,
      visitedAt: visitedAt,
      location: location,
      timeOfDay: TimeOfDay.fromDateTime(visitedAt),
      npcState: npcState,
      hadDialogue: hadDialogue,
      notes: notes,
    );
  }

  /// スケジュールを更新
  NPCSchedule updateSchedule(
    NPCSchedule schedule,
    List<DayPattern>? weeklyPattern,
    List<SeasonalPattern>? seasonalPatterns,
  ) {
    return schedule.copyWith(
      weeklyPattern: weeklyPattern,
      seasonalPatterns: seasonalPatterns,
      updatedAt: DateTime.now(),
    );
  }

  /// 曜日の営業状況を取得
  Map<TimeOfDay, String> getWeekdayStatus(
    NPCSchedule schedule,
    DayOfWeek dayOfWeek,
  ) {
    final dayPattern = schedule.weeklyPattern.firstWhere(
      (p) => p.dayOfWeek == dayOfWeek,
      orElse: () => DayPattern(
        dayOfWeek: dayOfWeek,
        hoursPattern: schedule.defaultBusinessHours,
      ),
    );

    final Map<TimeOfDay, String> status = {};
    for (final hour in dayPattern.hoursPattern) {
      status[hour.timeOfDay] = hour.activity;
    }

    return status;
  }

  /// 週間スケジュールを取得
  Map<DayOfWeek, List<NPCBusinessHours>> getWeeklySchedule(
    NPCSchedule schedule,
  ) {
    final Map<DayOfWeek, List<NPCBusinessHours>> weekly = {};

    for (final dayPattern in schedule.weeklyPattern) {
      weekly[dayPattern.dayOfWeek] = dayPattern.hoursPattern;
    }

    return weekly;
  }

  /// 季節の営業修正を適用
  NPCSchedule applySeasonalAdjustments(
    NPCSchedule schedule,
    Season season,
  ) {
    final seasonalPattern = schedule.seasonalPatterns.firstWhere(
      (p) => p.season == season,
      orElse: () => SeasonalPattern(
        season: season,
        closedDays: [],
      ),
    );

    return schedule.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  /// NPCスポットを作成
  NPCSpot createSpot(
    String spotId,
    String name,
    String description,
    String locationId,
    List<TimeOfDay> usuallySeeAt,
    int avgDurationMinutes,
  ) {
    return NPCSpot(
      spotId: spotId,
      name: name,
      description: description,
      locationId: locationId,
      usuallySeeAt: usuallySeeAt,
      avgDurationMinutes: avgDurationMinutes,
    );
  }

  /// NPCルーチンを作成
  NPCRoutine createRoutine(
    String routineId,
    String npcId,
    DayOfWeek dayOfWeek,
    List<RoutineItem> items,
  ) {
    return NPCRoutine(
      routineId: routineId,
      npcId: npcId,
      dayOfWeek: dayOfWeek,
      items: items,
    );
  }

  /// ルーチンアイテムを作成
  RoutineItem createRoutineItem(
    TimeOfDay timeOfDay,
    String spotId,
    String activity,
    int duration,
  ) {
    return RoutineItem(
      timeOfDay: timeOfDay,
      spotId: spotId,
      activity: activity,
      duration: duration,
    );
  }

  /// 複数NPCの利用可能性を比較
  List<(String npcId, double availability)> compareAvailability(
    List<NPCSchedule> schedules,
    DateTime dateTime,
  ) {
    final comparisons = <(String, double)>[];

    for (final schedule in schedules) {
      double score = 0.0;

      // 基本可用性（50%）
      if (schedule.isAvailable(dateTime)) {
        score += 50.0;
      }

      // 次の営業時間までの時間（25%）
      final nextAvailable = schedule.getNextAvailableTime(dateTime);
      if (nextAvailable != null) {
        final hoursUntilAvailable = nextAvailable
            .difference(dateTime)
            .inHours;
        if (hoursUntilAvailable <= 24) {
          score += 25.0 * (1.0 - (hoursUntilAvailable / 24.0));
        }
      }

      // 営業時間の割合（25%）
      int openHours = 0;
      for (final dayPattern in schedule.weeklyPattern) {
        openHours += dayPattern.hoursPattern.length;
      }
      score += (openHours / 42.0) * 25.0; // 42 = 7日 * 6時間帯

      comparisons.add((schedule.npcId, score / 100.0));
    }

    // スコアでソート
    comparisons.sort((a, b) => b.$2.compareTo(a.$2));
    return comparisons;
  }

  /// スケジュールの要約を生成
  ScheduleSummary generateSummary(NPCSchedule schedule) {
    int totalOpenHours = 0;
    int totalClosedDays = 0;

    for (final dayPattern in schedule.weeklyPattern) {
      if (dayPattern.isActive) {
        totalOpenHours += dayPattern.hoursPattern.length * 24;
      } else {
        totalClosedDays += 1;
      }
    }

    final avgAvailability = (7 - totalClosedDays) / 7.0;

    return ScheduleSummary(
      npcId: schedule.npcId,
      totalOpenHours: totalOpenHours,
      closedDays: totalClosedDays,
      averageAvailability: avgAvailability,
      nextAvailableTime: schedule.getNextAvailableTime(DateTime.now()),
      nextClosedDay: schedule.getNextClosedDay(DateTime.now()),
    );
  }

  /// スケジュールをリセット
  NPCSchedule resetSchedule(NPCSchedule schedule) {
    return NPCSchedule(
      npcId: schedule.npcId,
      weeklyPattern: schedule.weeklyPattern,
      seasonalPatterns: schedule.seasonalPatterns,
      defaultBusinessHours: schedule.defaultBusinessHours,
      createdAt: schedule.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// スケジュール要約
class ScheduleSummary {
  final String npcId;
  final int totalOpenHours;
  final int closedDays;
  final double averageAvailability;
  final DateTime? nextAvailableTime;
  final DateTime? nextClosedDay;

  ScheduleSummary({
    required this.npcId,
    required this.totalOpenHours,
    required this.closedDays,
    required this.averageAvailability,
    this.nextAvailableTime,
    this.nextClosedDay,
  });

  /// 利用可能性をパーセンテージで取得
  double getAvailabilityPercentage() {
    return averageAvailability * 100.0;
  }

  /// 定休日数を取得
  int getClosedDaysCount() {
    return closedDays;
  }

  /// スケジュール予測テキストを生成
  String getScheduleForecast() {
    if (averageAvailability >= 0.9) {
      return 'ほぼ毎日営業しています / Almost always available';
    } else if (averageAvailability >= 0.7) {
      return 'ほぼ営業しています / Usually available';
    } else if (averageAvailability >= 0.5) {
      return 'たまに営業しています / Sometimes available';
    } else if (averageAvailability >= 0.3) {
      return 'あまり営業していません / Rarely available';
    } else {
      return 'ほぼ営業していません / Almost never available';
    }
  }
}
