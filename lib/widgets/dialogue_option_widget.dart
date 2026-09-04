import 'package:flutter/material.dart';
import 'package:eigo/models/npc_dialogue_model.dart';

/// 対話オプションウィジェット
class DialogueOptionWidget extends StatelessWidget {
  final DialogueOption option;
  final VoidCallback onSelected;

  const DialogueOptionWidget({
    required this.option,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (option.tooltip != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        option.tooltip!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (option.affectionChange > 0)
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+${option.affectionChange}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (option.affectionChange < 0)
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.grey, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${option.affectionChange}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (option.affectionChange == 0)
              const Icon(
                Icons.remove,
                color: Colors.grey,
                size: 14,
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
