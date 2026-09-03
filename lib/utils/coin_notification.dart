import '../design_system/design_system.dart';
import 'package:flutter/material.dart';

void showCoinNotification(BuildContext context, int amount) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Text(
            '+$amount',
            style: const TextStyle(
              color:AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '🪙',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: const Color(0xFFFFB300),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
