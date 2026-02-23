import 'package:flutter/material.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../services/storage_service.dart';
import 'add_plant_screen.dart';
import 'plant_detail_screen.dart';

const _maxPlants = 20;

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({super.key});

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  final _storage = StorageService();
  List<MyPlant> _plants = [];
  List<CultivationRecord> _records = [];
  bool _loading = true;
  bool _calendarMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plants = await _storage.getPlants();
    final records = await _storage.getRecords();
    if (mounted) {
      setState(() {
        _plants = plants
          ..sort((a, b) => a.status.index.compareTo(b.status.index));
        _records = records;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('マイ畑', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
        actions: [
          if (!_loading)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  '${_plants.length}/$_maxPlants件',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _plants.length >= _maxPlants
                        ? Colors.red.shade600
                        : cs.primary,
                  ),
                ),
              ),
            ),
          if (!_loading && _plants.isNotEmpty)
            IconButton(
              icon: Icon(
                  _calendarMode ? Icons.list : Icons.calendar_month),
              tooltip: _calendarMode ? 'リスト表示' : 'カレンダー表示',
              onPressed: () =>
                  setState(() => _calendarMode = !_calendarMode),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plants.isEmpty
              ? _EmptyState(onAdd: _goToAdd)
              : _calendarMode
                  ? _GardenCalendar(
                      plants: _plants,
                      records: _records,
                      onRecordTap: (r) async {
                        final plant = _plants
                            .where((p) => p.id == r.myPlantId)
                            .firstOrNull;
                        if (plant != null) await _goToDetail(plant);
                      },
                    )
                  : _PlantList(
                      plants: _plants,
                      onTap: _goToDetail,
                      onDelete: _delete,
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAdd,
        icon: const Icon(Icons.add),
        label: const Text('野菜を追加'),
      ),
    );
  }

  Future<void> _goToAdd() async {
    if (_plants.length >= _maxPlants) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登録できるのは最大$_maxPlants件までです'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result =
        await Navigator.push<bool>(context,
            MaterialPageRoute(builder: (_) => const AddPlantScreen()));
    if (result == true) _load();
  }

  Future<void> _goToDetail(MyPlant plant) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => PlantDetailScreen(plant: plant)),
    );
    if (result == 'deleted' || result == null) _load();
  }

  Future<void> _delete(MyPlant plant) async {
    await _storage.deletePlant(plant.id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${plant.vegetableName}を削除しました'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              await _storage.savePlant(plant);
              _load();
            },
          ),
        ),
      );
    }
  }
}

// ── 空状態 ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'まだ野菜を登録していません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '育てている野菜を登録して\n成長を記録しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('野菜を追加する'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 一覧 ────────────────────────────────────────────────

class _PlantList extends StatelessWidget {
  final List<MyPlant> plants;
  final Future<void> Function(MyPlant) onTap;
  final Future<void> Function(MyPlant) onDelete;

  const _PlantList({
    required this.plants,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <PlantStatus, List<MyPlant>>{};
    for (final p in plants) {
      grouped.putIfAbsent(p.status, () => []).add(p);
    }

    final sections = <Widget>[];
    for (final status in PlantStatus.values) {
      final group = grouped[status];
      if (group == null || group.isEmpty) continue;
      sections.add(_StatusHeader(status: status, count: group.length));
      for (final plant in group) {
        sections.add(_PlantCard(
          plant: plant,
          onTap: onTap,
          onDelete: onDelete,
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: sections,
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final PlantStatus status;
  final int count;

  const _StatusHeader({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final MyPlant plant;
  final Future<void> Function(MyPlant) onTap;
  final Future<void> Function(MyPlant) onDelete;

  const _PlantCard({
    required this.plant,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(plant.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('削除の確認'),
            content:
                Text('${plant.vegetableName}をマイ畑から削除しますか？'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('キャンセル')),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('削除する'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(plant),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: cs.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onTap(plant),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(plant.vegetableEmoji,
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.vegetableName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 6,
                        children: [
                          _InfoChip(
                              icon: Icons.place_outlined,
                              label: plant.location),
                          _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              label:
                                  '${plant.startDate.month}/${plant.startDate.day}〜'),
                          if (plant.quantity != null)
                            _InfoChip(
                                icon: Icons.format_list_numbered,
                                label: '${plant.quantity}株'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBadge(status: plant.status),
                    const SizedBox(height: 4),
                    Icon(Icons.chevron_right,
                        size: 16, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlantStatus status;

  const _StatusBadge({required this.status});

  Color _color(PlantStatus s) {
    switch (s) {
      case PlantStatus.sowed:
        return Colors.orange;
      case PlantStatus.sprouted:
        return Colors.lightGreen;
      case PlantStatus.growing:
        return Colors.green;
      case PlantStatus.harvesting:
        return Colors.amber;
      case PlantStatus.finished:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 16)),
          Text(
            status.label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.9)),
          ),
          if (status.next != null)
            Icon(Icons.arrow_forward_ios,
                size: 9, color: color.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 2),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

// ── カレンダービュー ──────────────────────────────────────

class _GardenCalendar extends StatefulWidget {
  final List<MyPlant> plants;
  final List<CultivationRecord> records;
  final Future<void> Function(CultivationRecord) onRecordTap;

  const _GardenCalendar({
    required this.plants,
    required this.records,
    required this.onRecordTap,
  });

  @override
  State<_GardenCalendar> createState() => _GardenCalendarState();
}

class _GardenCalendarState extends State<_GardenCalendar> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _displayMonth =
            DateTime(_displayMonth.year, _displayMonth.month + 1);
      });

  // その日の記録一覧を返す
  List<CultivationRecord> _recordsForDay(int day) {
    return widget.records.where((r) {
      return r.date.year == _displayMonth.year &&
          r.date.month == _displayMonth.month &&
          r.date.day == day;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // 植物IDからemoji取得
  String _emojiFor(CultivationRecord r) {
    return widget.plants
            .where((p) => p.id == r.myPlantId)
            .firstOrNull
            ?.vegetableEmoji ??
        '📝';
  }

  void _showDayDetail(BuildContext context, int day,
      List<CultivationRecord> dayRecords) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, sc) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_displayMonth.year}年${_displayMonth.month}月$day日',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('${dayRecords.length}件の記録',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade500)),
            const Divider(height: 20),
            Expanded(
              child: ListView.builder(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: dayRecords.length,
                itemBuilder: (_, i) {
                  final rec = dayRecords[i];
                  final emoji = _emojiFor(rec);
                  final (icon, color) = _workStyle(rec.workType);
                  final timeLabel =
                      rec.date.hour != 0 || rec.date.minute != 0
                          ? ' ${rec.date.hour.toString().padLeft(2, '0')}:${rec.date.minute.toString().padLeft(2, '0')}'
                          : '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    color: cs.surfaceContainerLow,
                    child: ListTile(
                      leading: Text(emoji,
                          style: const TextStyle(fontSize: 28)),
                      title: Text(rec.vegetableName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      subtitle: Row(
                        children: [
                          Icon(icon, size: 13, color: color),
                          const SizedBox(width: 4),
                          Text(rec.workType + timeLabel,
                              style: TextStyle(
                                  color: color, fontSize: 12)),
                          if (rec.note.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rec.note,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: rec.myPlantId != null
                          ? const Icon(Icons.chevron_right, size: 16)
                          : null,
                      onTap: rec.myPlantId != null
                          ? () {
                              Navigator.pop(ctx);
                              widget.onRecordTap(rec);
                            }
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final leadingBlanks =
        DateTime(_displayMonth.year, _displayMonth.month, 1).weekday - 1;
    const weekLabels = ['月', '火', '水', '木', '金', '土', '日'];

    return Column(
      children: [
        // ── 月ナビゲーション ──
        Container(
          color: cs.primaryContainer,
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
                color: cs.onPrimaryContainer,
              ),
              Text(
                '${_displayMonth.year}年${_displayMonth.month}月',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                color: cs.onPrimaryContainer,
              ),
            ],
          ),
        ),

        // ── 曜日ヘッダー ──
        Container(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: weekLabels.map((l) {
              final isSat = l == '土';
              final isSun = l == '日';
              return Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSun
                          ? Colors.red.shade400
                          : isSat
                              ? Colors.blue.shade400
                              : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── 日付グリッド ──
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final cellW = constraints.maxWidth / 7;
            final totalCells = leadingBlanks + daysInMonth;
            final rows = (totalCells / 7).ceil();
            final cellH =
                (constraints.maxHeight / rows).clamp(56.0, 100.0);

            return SingleChildScrollView(
              child: Column(
                children: List.generate(rows, (row) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(7, (col) {
                      final idx = row * 7 + col;
                      final day = idx - leadingBlanks + 1;
                      final blank = idx < leadingBlanks || day > daysInMonth;
                      if (blank) {
                        return SizedBox(
                            width: cellW, height: cellH);
                      }

                      final isToday = now.year == _displayMonth.year &&
                          now.month == _displayMonth.month &&
                          now.day == day;
                      final isSat = col == 5;
                      final isSun = col == 6;
                      final dayRecords = _recordsForDay(day);

                      return GestureDetector(
                        onTap: dayRecords.isEmpty
                            ? null
                            : () => _showDayDetail(
                                context, day, dayRecords),
                        child: Container(
                          width: cellW,
                          height: cellH,
                          decoration: BoxDecoration(
                            color: isToday
                                ? cs.primaryContainer
                                    .withValues(alpha: 0.6)
                                : null,
                            border: Border.all(
                                color: cs.outlineVariant
                                    .withValues(alpha: 0.3),
                                width: 0.5),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              // 日付番号
                              Container(
                                width: 26,
                                height: 26,
                                decoration: isToday
                                    ? BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                      )
                                    : null,
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isToday
                                          ? cs.onPrimary
                                          : isSun
                                              ? Colors.red.shade400
                                              : isSat
                                                  ? Colors.blue.shade400
                                                  : cs.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              // 記録ドット（最大3件まで emoji）
                              if (dayRecords.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 1,
                                  children: [
                                    ...dayRecords.take(3).map((r) =>
                                        Text(
                                          _emojiFor(r),
                                          style: const TextStyle(
                                              fontSize: 11),
                                        )),
                                    if (dayRecords.length > 3)
                                      Text(
                                        '+${dayRecords.length - 3}',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: cs.primary,
                                            fontWeight:
                                                FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            );
          }),
        ),

        // ── 凡例：栽培中の植物 ──
        if (widget.plants.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cs.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '栽培中の植物',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.plants
                      .where((p) => p.status != PlantStatus.finished)
                      .map((p) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.vegetableEmoji,
                                  style:
                                      const TextStyle(fontSize: 14)),
                              const SizedBox(width: 3),
                              Text(p.vegetableName,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700)),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

(IconData, Color) _workStyle(String workType) {
  return switch (workType) {
    '種まき' => (Icons.grass, Colors.orange.shade600),
    '定植' => (Icons.local_florist, Colors.blue.shade600),
    '収穫' => (Icons.shopping_basket, Colors.green.shade600),
    '水やり' => (Icons.water_drop, Colors.lightBlue.shade600),
    '施肥' => (Icons.science, Colors.brown.shade400),
    '剪定' => (Icons.content_cut, Colors.purple.shade400),
    '防虫' => (Icons.pest_control, Colors.red.shade400),
    _ => (Icons.edit_note, Colors.grey.shade500),
  };
}
