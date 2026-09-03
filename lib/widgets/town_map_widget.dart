import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eigo/models/english_town_model.dart';
import 'package:eigo/design_system/design_system.dart';

/// タウンマップ用のCustomPainter
class TownMapPainter extends CustomPainter {
  final List<Location> locations;
  final List<NPC> npcs;
  final String? selectedLocationId;
  final Function(String locationId) onLocationTap;
  final bool showDebugInfo;

  TownMapPainter({
    required this.locations,
    required this.npcs,
    this.selectedLocationId,
    required this.onLocationTap,
    this.showDebugInfo = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景を描画
    _drawBackground(canvas, size);

    // グリッドを描画（デバッグ用）
    if (showDebugInfo) {
      _drawGrid(canvas, size);
    }

    // ロケーション接続線を描画
    _drawConnectionLines(canvas, size);

    // ロケーションを描画
    _drawLocations(canvas, size);

    // NPC指標を描画
    _drawNPCIndicators(canvas, size);
  }

  /// 背景を描画
  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, bgPaint);

    // 微妙なパターンオーバーレイ
    final patternPaint = Paint()
      ..color = AppColors.border.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const patternSpacing = 20.0;
    for (double i = 0; i < size.width; i += patternSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        patternPaint,
      );
    }
    for (double i = 0; i < size.height; i += patternSpacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        patternPaint,
      );
    }
  }

  /// グリッドを描画（デバッグ用）
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 50.0;
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        gridPaint,
      );
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        gridPaint,
      );
    }
  }

  /// ロケーション間の接続線を描画
  void _drawConnectionLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // 近いロケーション同士を線で接続
    for (int i = 0; i < locations.length; i++) {
      for (int j = i + 1; j < locations.length; j++) {
        final loc1 = locations[i];
        final loc2 = locations[j];

        final pos1 = _parsePosition(loc1.position);
        final pos2 = _parsePosition(loc2.position);

        // 距離が150ピクセル以内なら線を描画
        final distance =
            (pos1 - pos2).distance;
        if (distance < 150 && distance > 0) {
          canvas.drawLine(pos1, pos2, linePaint);
        }
      }
    }
  }

  /// ロケーションを描画
  void _drawLocations(Canvas canvas, Size size) {
    for (final location in locations) {
      final pos = _parsePosition(location.position);

      // ロケーションがマップ内かチェック
      if (pos.dx < 0 || pos.dx > size.width || pos.dy < 0 || pos.dy > size.height) {
        continue;
      }

      final isSelected = location.id == selectedLocationId;
      final isUnlocked = location.unlockedAt != null;

      // ロケーション背景を描画
      _drawLocationBackground(canvas, pos, isUnlocked, isSelected);

      // ロケーション円を描画
      _drawLocationCircle(canvas, pos, location, isUnlocked, isSelected);

      // ロケーション名を描画
      _drawLocationLabel(canvas, pos, location.name, isUnlocked);
    }
  }

  /// ロケーション背景を描画
  void _drawLocationBackground(
    Canvas canvas,
    Offset pos,
    bool isUnlocked,
    bool isSelected,
  ) {
    final bgPaint = Paint()
      ..color = isSelected
          ? AppColors.accentGreen.withOpacity(0.15)
          : (isUnlocked
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.withOpacity(0.05))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 45, bgPaint);

    // 選択状態の外枠
    if (isSelected) {
      final borderPaint = Paint()
        ..color = AppColors.accentGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(pos, 45, borderPaint);
    }
  }

  /// ロケーション円を描画
  void _drawLocationCircle(
    Canvas canvas,
    Offset pos,
    Location location,
    bool isUnlocked,
    bool isSelected,
  ) {
    final circlePaint = Paint()
      ..color = isUnlocked
          ? AppColors.primary
          : Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 32, circlePaint);

    // エモジを描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: location.emoji,
        style: const TextStyle(fontSize: 36),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      pos - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // ロック状態のアイコン
    if (!isUnlocked) {
      _drawLockIcon(canvas, pos);
    }
  }

  /// ロック状態のアイコンを描画
  void _drawLockIcon(Canvas canvas, Offset pos) {
    const lockSize = 12.0;
    const lockX = lockSize / 2;
    const lockY = lockSize / 3;

    final lockPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // ロック本体
    canvas.drawRect(
      Rect.fromLTWH(
        pos.dx - lockX / 2 + 10,
        pos.dy - lockY / 2 + 8,
        lockX,
        lockY,
      ),
      lockPaint,
    );
  }

  /// ロケーション名ラベルを描画
  void _drawLocationLabel(
    Canvas canvas,
    Offset pos,
    String name,
    bool isUnlocked,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: isUnlocked ? AppColors.textPrimary : Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    textPainter.layout(maxWidth: 60);
    textPainter.paint(
      canvas,
      pos + Offset(-textPainter.width / 2, 40),
    );
  }

  /// NPC指標を描画
  void _drawNPCIndicators(Canvas canvas, Size size) {
    final locationMap = {for (var loc in locations) loc.id: loc};

    // 各ロケーションのNPC数を表示
    for (final location in locations) {
      final npcCount = location.npcIds.length;
      if (npcCount > 0) {
        final pos = _parsePosition(location.position);

        final badgePaint = Paint()
          ..color = AppColors.accentRed
          ..style = PaintingStyle.fill;

        // バッジを描画
        canvas.drawCircle(pos + const Offset(30, -25), 10, badgePaint);

        // NPC数を描画
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$npcCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          pos + Offset(30 - textPainter.width / 2, -25 - textPainter.height / 2),
        );
      }
    }
  }

  /// 位置文字列をOffsetに変換
  Offset _parsePosition(String position) {
    try {
      final parts = position.split(',');
      final x = double.parse(parts[0].split(':')[1]);
      final y = double.parse(parts[1].split(':')[1]);
      return Offset(x, y);
    } catch (e) {
      return Offset.zero;
    }
  }

  @override
  bool shouldRepaint(TownMapPainter oldDelegate) {
    return oldDelegate.selectedLocationId != selectedLocationId ||
        oldDelegate.locations != locations ||
        oldDelegate.npcs != npcs;
  }

  @override
  bool? hitTest(Offset position) => true;
}

/// タウンマップウィジェット
class TownMapWidget extends ConsumerStatefulWidget {
  final Function(String locationId) onLocationTap;
  final String? selectedLocationId;
  final bool showDebugInfo;

  const TownMapWidget({
    Key? key,
    required this.onLocationTap,
    this.selectedLocationId,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  ConsumerState<TownMapWidget> createState() => _TownMapWidgetState();
}

class _TownMapWidgetState extends ConsumerState<TownMapWidget> {
  late TapDownDetails _tapDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: CustomPaint(
        painter: _buildPainter(),
        child: Container(),
      ),
    );
  }

  /// Painterを構築
  TownMapPainter _buildPainter() {
    // Note: In a full implementation, these would come from providers
    final locations = <Location>[];
    final npcs = <NPC>[];

    return TownMapPainter(
      locations: locations,
      npcs: npcs,
      selectedLocationId: widget.selectedLocationId,
      onLocationTap: widget.onLocationTap,
      showDebugInfo: widget.showDebugInfo,
    );
  }

  /// タップを処理
  void _handleTap(TapDownDetails details) {
    // このメソッドは実装されます（後続のスクリーン統合で）
    // ロケーション判定とコールバック処理
  }
}
