import 'package:flutter/material.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';

class WeeklyDashboard extends StatelessWidget {
  final List<CultivationRecord> records;
  final List<MyPlant> plants;
  final int streak;

  const WeeklyDashboard({
    super.key,
    required this.records,
    required this.plants,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday =
        now.subtract(Duration(days: now.weekday - 1));
    final mondayDate =
        DateTime(monday.year, monday.month, monday.day);

    // 今週の記録
    final weekRecords = records.where((r) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      return !d.isBefore(mondayDate) &&
          d.isBefore(mondayDate.add(const Duration(days: 7)));
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _WeeklyStatsRow(
          streak: streak,
          weekCount: weekRecords.length,
          plants: plants,
          weekRecords: weekRecords,
        ),
        const SizedBox(height: 16),
        _WeeklyBarChart(
            records: records, mondayDate: mondayDate, today: now),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── 週間統計行 ────────────────────────────────────────────
class _WeeklyStatsRow extends StatelessWidget {
  final int streak;
  final int weekCount;
  final List<MyPlant> plants;
  final List<CultivationRecord> weekRecords;

  const _WeeklyStatsRow({
    required this.streak,
    required this.weekCount,
    required this.plants,
    required this.weekRecords,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // 今週最も活発な野菜
    final Map<String, int> vegCount = {};
    for (final r in weekRecords) {
      vegCount[r.vegetableName] = (vegCount[r.vegetableName] ?? 0) + 1;
    }
    String activePlant = '-';
    if (vegCount.isNotEmpty) {
      activePlant = vegCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return Row(
      children: [
        Expanded(
            child: _StatCard(
                emoji: '🔥',
                label: 'ストリーク',
                value: '$streak日',
                cs: cs)),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
                emoji: '📝',
                label: '今週の記録',
                value: '$weekCount件',
                cs: cs)),
        const SizedBox(width: 8),
        Expanded(
            child: _StatCard(
                emoji: '🌿',
                label: '活発な野菜',
                value: activePlant,
                cs: cs)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final ColorScheme cs;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ── 週間バーチャート ──────────────────────────────────────
class _WeeklyBarChart extends StatelessWidget {
  final List<CultivationRecord> records;
  final DateTime mondayDate;
  final DateTime today;

  const _WeeklyBarChart({
    required this.records,
    required this.mondayDate,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 曜日ごとの件数 (1=月 〜 7=日)
    final Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final r in records) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      final diff = d.difference(mondayDate).inDays;
      if (diff >= 0 && diff < 7) {
        counts[diff + 1] = (counts[diff + 1] ?? 0) + 1;
      }
    }

    final totalWeek = counts.values.fold(0, (a, b) => a + b);
    const maxBarHeight = 80.0;
    const labels = ['月', '火', '水', '木', '金', '土', '日'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今週の記録',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          if (totalWeek == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '今週はまだ記録がありません',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            )
          else
            SizedBox(
              height: maxBarHeight + 36,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final dayNum = i + 1;
                  final count = counts[dayNum] ?? 0;
                  final maxCount =
                      counts.values.fold(0, (a, b) => a > b ? a : b);
                  final barH = count == 0
                      ? 0.0
                      : (maxBarHeight * count / maxCount)
                          .clamp(4.0, maxBarHeight);
                  final isToday = today.weekday == dayNum;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (count > 0)
                        Text(
                          '$count',
                          style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? cs.primary
                                  : Colors.grey.shade500),
                        ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: 28,
                        height: barH,
                        decoration: BoxDecoration(
                          color: isToday
                              ? cs.primary
                              : cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? cs.primary
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

