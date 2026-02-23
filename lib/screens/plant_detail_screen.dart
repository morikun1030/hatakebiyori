import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../services/storage_service.dart';
import 'add_record_screen.dart';
import 'annual_plan_screen.dart';

class PlantDetailScreen extends StatefulWidget {
  final MyPlant plant;

  const PlantDetailScreen({super.key, required this.plant});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  final _storage = StorageService();
  late MyPlant _plant;
  List<CultivationRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
    _load();
  }

  Future<void> _load() async {
    final records = await _storage.getRecordsForPlant(_plant.id);
    records.sort((a, b) => a.date.compareTo(b.date));
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  int get _daysSinceStart =>
      DateTime.now().difference(_plant.startDate).inDays;

  int get _harvestCount =>
      _records.where((r) => r.workType == '収穫').length;

  // ステータスを次に進める
  Future<void> _advanceStatus() async {
    final next = _plant.status.next;
    if (next == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${_plant.vegetableEmoji} ${_plant.vegetableName}'),
        content: Text(
            'ステータスを「${_plant.status.label}」→「${next.label}」に変更しますか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('変更する')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final updated = _plant.copyWith(status: next);
      await _storage.updatePlant(updated);
      setState(() => _plant = updated);
    }
  }

  // 植物を削除
  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text(
            '${_plant.vegetableName}をマイ畑から削除しますか？\n関連する日誌記録は残ります。'),
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
    if (confirmed == true && mounted) {
      await _storage.deletePlant(_plant.id);
      await _storage.deleteMonthMemos(_plant.id);
      if (mounted) Navigator.pop(context, 'deleted');
    }
  }

  // 記録を削除
  Future<void> _deleteRecord(String id) async {
    await _storage.deleteRecord(id);
    _load();
  }

  // 記録追加画面へ
  Future<void> _addRecord() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordScreen(initialPlant: _plant),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_plant.vegetableEmoji} ${_plant.vegetableName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: cs.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: '年間計画',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AnnualPlanScreen(plant: _plant)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '削除',
            onPressed: _delete,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _PlantInfoCard(
                          plant: _plant,
                          daysSinceStart: _daysSinceStart,
                          harvestCount: _harvestCount,
                          recordCount: _records.length,
                          onAdvanceStatus: _plant.status.next != null
                              ? _advanceStatus
                              : null,
                        ),
                        _StatusProgressBar(status: _plant.status),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Icon(Icons.timeline,
                                  size: 18, color: Color(0xFF2E7D32)),
                              SizedBox(width: 6),
                              Text(
                                '栽培タイムライン',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_records.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyTimeline(onAdd: _addRecord),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _TimelineItem(
                            record: _records[index],
                            isLast: index == _records.length - 1,
                            onDelete: () =>
                                _deleteRecord(_records[index].id),
                          ),
                          childCount: _records.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecord,
        icon: const Icon(Icons.add),
        label: const Text('記録を追加'),
      ),
    );
  }
}

// ── 植物情報カード ───────────────────────────────────────
class _PlantInfoCard extends StatelessWidget {
  final MyPlant plant;
  final int daysSinceStart;
  final int harvestCount;
  final int recordCount;
  final VoidCallback? onAdvanceStatus;

  const _PlantInfoCard({
    required this.plant,
    required this.daysSinceStart,
    required this.harvestCount,
    required this.recordCount,
    required this.onAdvanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.primaryContainer.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // 上段: emoji + 基本情報
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plant.vegetableEmoji,
                  style: const TextStyle(fontSize: 52)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ステータスバッジ
                    _StatusBadge(status: plant.status),
                    const SizedBox(height: 8),
                    _InfoRow(Icons.place_outlined, plant.location),
                    _InfoRow(Icons.eco_outlined, plant.plantType),
                    _InfoRow(
                      Icons.calendar_today_outlined,
                      '${plant.startDate.year}/${plant.startDate.month}/${plant.startDate.day} 〜',
                    ),
                    if (plant.quantity != null)
                      _InfoRow(Icons.format_list_numbered,
                          '${plant.quantity}株'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 下段: 統計 + ステータス進行ボタン
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.schedule,
                      label: '$daysSinceStart日目',
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.edit_note,
                      label: '$recordCount件',
                      color: Colors.indigo.shade400,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.shopping_basket,
                      label: '$harvestCount回',
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              if (onAdvanceStatus != null)
                FilledButton.tonal(
                  onPressed: onAdvanceStatus,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(plant.status.next!.emoji,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        plant.status.next!.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward, size: 14),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(text,
              style:
                  TextStyle(fontSize: 12.5, color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlantStatus status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case PlantStatus.sowed:
        return Colors.orange;
      case PlantStatus.sprouted:
        return Colors.lightGreen;
      case PlantStatus.growing:
        return Colors.green;
      case PlantStatus.harvesting:
        return Colors.amber.shade700;
      case PlantStatus.finished:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _color.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ステータス進捗バー ────────────────────────────────────
class _StatusProgressBar extends StatelessWidget {
  final PlantStatus status;

  const _StatusProgressBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final statuses = PlantStatus.values;
    final currentIndex = status.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: statuses.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final isDone = i <= currentIndex;
          final isLast = i == statuses.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDone
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDone
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s.emoji,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDone
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          fontWeight: isDone
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: i < currentIndex
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── タイムラインアイテム ───────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final CultivationRecord record;
  final bool isLast;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.record,
    required this.isLast,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _workStyle(record.workType);

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('記録を削除'),
          content: const Text('この記録を削除しますか？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('キャンセル')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('削除')),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 24),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // タイムラインの縦線 + ドット
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade200,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // カード
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日付 + 作業種類
                    Row(
                      children: [
                        Text(
                          record.date.hour != 0 || record.date.minute != 0
                              ? '${record.date.month}/${record.date.day} ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}'
                              : '${record.date.month}/${record.date.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.workType,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 写真
                    if (record.imageBase64 != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(record.imageBase64!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                    // バッジ行
                    if (record.harvestAmount != null ||
                        (record.cost != null && record.cost! > 0))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 6,
                          children: [
                            if (record.harvestAmount != null)
                              _MiniTag(
                                icon: Icons.shopping_basket,
                                text: record.harvestAmount!,
                                color: Colors.green.shade600,
                              ),
                            if (record.cost != null && record.cost! > 0)
                              _MiniTag(
                                icon: Icons.payments_outlined,
                                text: '¥${record.cost}',
                                color: Colors.teal.shade600,
                              ),
                          ],
                        ),
                      ),
                    // メモ
                    if (record.note.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          record.note,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}

class _MiniTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniTag(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── 空のタイムライン ──────────────────────────────────────
class _EmptyTimeline extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyTimeline({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'まだ記録がありません',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '種まき・水やり・収穫などを\nタイムラインに記録しましょう',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('最初の記録を追加'),
            ),
          ],
        ),
      ),
    );
  }
}
