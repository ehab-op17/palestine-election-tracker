import 'package:flutter/material.dart';

class VoteSplitBar extends StatelessWidget {
  final double leftPct;
  final double rightPct;
  final double otherPct;
  final String leftLabel;
  final String rightLabel;
  final Color leftColor;
  final Color rightColor;
  final Color otherColor;

  const VoteSplitBar({
    super.key,
    required this.leftPct,
    required this.rightPct,
    required this.otherPct,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColor,
    required this.rightColor,
    required this.otherColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                _segment(leftPct, leftColor,
                    '$leftLabel ${leftPct.toStringAsFixed(0)}%'),
                _segment(rightPct, rightColor,
                    '$rightLabel ${rightPct.toStringAsFixed(0)}%'),
                _segment(
                    otherPct,
                    otherColor,
                    otherPct > 8
                        ? 'Other ${otherPct.toStringAsFixed(0)}%'
                        : ''),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _segment(double pct, Color color, String label) {
    return Expanded(
      flex: (pct * 10).round().clamp(1, 100000),
      child: Container(
        color: color,
        alignment: Alignment.center,
        child: label.isEmpty
            ? null
            : Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.clip,
              ),
      ),
    );
  }
}
