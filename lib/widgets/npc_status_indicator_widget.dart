import 'package:flutter/material.dart';

/// NPCステータスインジケーターウィジェット
/// 親密度、気分、レベルなどのNPCステータスを表示
class NPCStatusIndicatorWidget extends StatefulWidget {
  final String npcName;
  final int affection;
  final String mood;
  final int level;
  final double affectionProgress;

  const NPCStatusIndicatorWidget({
    Key? key,
    required this.npcName,
    required this.affection,
    required this.mood,
    required this.level,
    this.affectionProgress = 0.0,
  }) : super(key: key);

  @override
  State<NPCStatusIndicatorWidget> createState() =>
      _NPCStatusIndicatorWidgetState();
}

class _NPCStatusIndicatorWidgetState extends State<NPCStatusIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _affectionController;
  late Animation<double> _affectionAnimation;

  @override
  void initState() {
    super.initState();

    _affectionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _affectionAnimation = Tween<double>(
      begin: 0,
      end: widget.affectionProgress,
    ).animate(
      CurvedAnimation(parent: _affectionController, curve: Curves.easeOut),
    );

    _affectionController.forward();
  }

  @override
  void didUpdateWidget(NPCStatusIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.affectionProgress != widget.affectionProgress) {
      _affectionAnimation = Tween<double>(
        begin: oldWidget.affectionProgress,
        end: widget.affectionProgress,
      ).animate(
        CurvedAnimation(parent: _affectionController, curve: Curves.easeOut),
      );

      _affectionController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー：NPC名とレベル
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.npcName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Text(
                  'Lv.${widget.level}',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 親密度バー
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '親密度',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  Text(
                    '${widget.affection}/100',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedBuilder(
                animation: _affectionAnimation,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _affectionAnimation.value / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(
                        _getAffectionColor(_affectionAnimation.value.toInt()),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 気分ステータス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getMoodColor(widget.mood).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getMoodColor(widget.mood),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '気分: ${widget.mood}',
                  style: TextStyle(
                    color: _getMoodColor(widget.mood),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _getMoodEmoji(widget.mood),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAffectionColor(int affection) {
    if (affection >= 80) return Colors.red;
    if (affection >= 60) return Colors.orange;
    if (affection >= 40) return Colors.amber;
    return Colors.grey;
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'neutral':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'tired':
        return Colors.grey;
      case 'excited':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'tired':
        return '😴';
      case 'excited':
        return '🤩';
      default:
        return '😐';
    }
  }

  @override
  void dispose() {
    _affectionController.dispose();
    super.dispose();
  }
}
