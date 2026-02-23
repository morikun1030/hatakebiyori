import 'package:flutter/material.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';

class MonthlyDashboard extends StatelessWidget {
  final List<CultivationRecord> records;
  final List<MyPlant> plants;

  const MonthlyDashboard({
    super.key,
    required this.records,
    required this.plants,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthRecords = records
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _MonthlySummaryRow(records: monthRecords),
        const SizedBox(height: 16),
        _ActivityHeatmap(records: monthRecords, now: now),
        const SizedBox(height: 16),
        _WorkTypeBreakdown(records: monthRecords),
        const SizedBox(height: 16),
        _PlantRanking(records: monthRecords),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── 月間サマリー行 ────────────────────────────────────────
class _MonthlySummaryRow extends StatelessWidget {
  final List<CultivationRecord> records;

  const _MonthlySummaryRow({required this.records});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final harvestCount =
        records.where((r) => r.workType == '収穫').length;
    final totalCost =
        records.fold<int>(0, (sum, r) => sum + (r.cost ?? 0));

    return Row(
      children: [
        Expanded(
            child: _SummaryCard(
                emoji: '📝',
                label: '記録',
                value: '${records.length}件',
                cs: cs)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryCard(
                emoji: '🧺',
                label: '収穫',
                value: '$harvestCount件',
                cs: cs)),
        const SizedBox(width: 8),
        Expanded(
            child: _SummaryCard(
                emoji: '💴',
                label: '費用',
                value: '¥$totalCost',
                cs: cs)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final ColorScheme cs;

  const _SummaryCard({
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

// ── アクティビティヒートマップ ────────────────────────────
class _ActivityHeatmap extends StatelessWidget {
  final List<CultivationRecord> records;
  final DateTime now;

  const _ActivityHeatmap({required this.records, required this.now});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysInMonth =
        DateTime(now.year, now.month + 1, 0).day;
    final leadingBlanks =
        DateTime(now.year, now.month, 1).weekday - 1;

    final Map<int, int> dayCounts = {};
    for (final r in records) {
      dayCounts[r.date.day] = (dayCounts[r.date.day] ?? 0) + 1;
    }

    Color cellColor(int count) {
      if (count == 0) return Colors.grey.shade100;
      if (count == 1) return Colors.green.shade200;
      if (count == 2) return Colors.green.shade400;
      return Colors.green.shade700;
    }

    const weekLabels = ['月', '火', '水', '木', '金', '土', '日'];

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
            '${now.month}月のアクティビティ',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface),
          ),
          const SizedBox(height: 10),
          // 曜日ヘッダー
          Row(
            children: weekLabels
                .map((l) => Expanded(
                      child: Center(
                        child: Text(l,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(builder: (context, constraints) {
            final cellSize = (constraints.maxWidth - 12) / 7;
            final totalCells = leadingBlanks + daysInMonth;
            final rows = (totalCells / 7).ceil();

            return Column(
              children: List.generate(rows, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: List.generate(7, (col) {
                      final cellIndex = row * 7 + col;
                      final dayNum = cellIndex - leadingBlanks + 1;
                      final isBlank = cellIndex < leadingBlanks ||
                          dayNum > daysInMonth;
                      final isToday = !isBlank && dayNum == now.day;
                      final count =
                          isBlank ? 0 : (dayCounts[dayNum] ?? 0);

                      return SizedBox(
                        width: cellSize,
                        height: cellSize,
                        child: isBlank
                            ? const SizedBox()
                            : Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: cellColor(count),
                                  borderRadius: BorderRadius.circular(4),
                                  border: isToday
                                      ? Border.all(
                                          color: cs.primary, width: 1.5)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    '$dayNum',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: count >= 3
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                      );
                    }),
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 8),
          // 凡例
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('少',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(width: 4),
              for (final c in [
                Colors.grey.shade100,
                Colors.green.shade200,
                Colors.green.shade400,
                Colors.green.shade700,
              ])
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              const SizedBox(width: 4),
              Text('多',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 作業種類の内訳 ────────────────────────────────────────
class _WorkTypeBreakdown extends StatelessWidget {
  final List<CultivationRecord> records;

  const _WorkTypeBreakdown({required this.records});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (records.isEmpty) return const SizedBox.shrink();

    final Map<String, int> counts = {};
    for (final r in records) {
      counts[r.workType] = (counts[r.workType] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount =
        sorted.isEmpty ? 1 : sorted.first.value;

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
            '作業の内訳',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          ...sorted.map((entry) {
            final ratio = entry.value / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 14,
                        backgroundColor:
                            cs.primaryContainer.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            cs.primary.withValues(alpha: 0.7)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value}件',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── 植物ランキング Top3 ───────────────────────────────────
class _PlantRanking extends StatelessWidget {
  final List<CultivationRecord> records;

  const _PlantRanking({required this.records});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (records.isEmpty) return const SizedBox.shrink();

    final Map<String, int> counts = {};
    for (final r in records) {
      counts[r.vegetableName] = (counts[r.vegetableName] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3).toList();

    const medals = ['🥇', '🥈', '🥉'];

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
            '今月の活動ランキング',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: cs.onSurface),
          ),
          const SizedBox(height: 12),
          ...top3.asMap().entries.map((e) {
            final rank = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(medals[rank],
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${entry.value}件',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
