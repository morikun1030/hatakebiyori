import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../services/storage_service.dart';
import '../utils/share_util.dart';
import 'add_record_screen.dart';
import 'plant_detail_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _storage = StorageService();
  List<CultivationRecord> _records = [];
  List<MyPlant> _plants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _storage.getRecords();
    final plants = await _storage.getPlants();
    records.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _records = records;
      _plants = plants;
      _loading = false;
    });
  }

  Future<void> _deleteRecord(String id) async {
    await _storage.deleteRecord(id);
    await _loadRecords();
  }

  Future<void> _showAddRecordPicker(BuildContext context) async {
    final activePlants =
        _plants.where((p) => p.status != PlantStatus.finished).toList();

    // マイ畑に植物がなければ直接記録追加へ
    if (activePlants.isEmpty) {
      await _navigateToAddRecord(null);
      return;
    }

    // 選択結果を追跡（null = キャンセル、(true, plant?) = 選択済み）
    MyPlant? selectedPlant;
    bool confirmed = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
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
            const Text('どの植物の記録ですか？',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('マイ畑に登録中の植物',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const Divider(height: 20),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...activePlants.map((plant) => ListTile(
                        leading: Text(plant.vegetableEmoji,
                            style: const TextStyle(fontSize: 28)),
                        title: Text(plant.vegetableName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '📍 ${plant.location}  ·  ${plant.status.label}'),
                        trailing:
                            const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          selectedPlant = plant;
                          confirmed = true;
                          Navigator.pop(ctx);
                        },
                      )),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.edit_note),
                    ),
                    title: const Text('マイ畑に登録せず記録する'),
                    subtitle: const Text('野菜マスターから野菜を選んで記録'),
                    onTap: () {
                      selectedPlant = null;
                      confirmed = true;
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!confirmed) return; // バックキー等でキャンセル
    await _navigateToAddRecord(selectedPlant);
  }

  Future<void> _navigateToAddRecord(MyPlant? plant) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            AddRecordScreen(initialPlant: plant),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    _loadRecords();
  }

  int get _totalCost =>
      _records.fold(0, (sum, r) => sum + (r.cost ?? 0));
  int get _harvestCount =>
      _records.where((r) => r.workType == '収穫').length;
  int get _photoCount =>
      _records.where((r) => r.imageBase64 != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('栽培日誌',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (_records.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${_records.length}件',
                    style: const TextStyle(fontSize: 12)),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmpty()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordPicker(context),
        icon: const Icon(Icons.add),
        label: const Text('記録を追加'),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _SummaryCard(
          totalRecords: _records.length,
          harvestCount: _harvestCount,
          totalCost: _totalCost,
          photoCount: _photoCount,
        ),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text('記録がまだありません',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('下のボタンから最初の記録を追加しましょう',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildList() {
    final grouped = <String, List<CultivationRecord>>{};
    for (final r in _records) {
      final key = '${r.date.year}年${r.date.month}月${r.date.day}日';
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
      itemCount: dateKeys.length,
      itemBuilder: (context, groupIndex) {
        final dateKey = dateKeys[groupIndex];
        final dayRecords = grouped[dateKey]!;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + groupIndex * 60),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 12 * (1 - value)),
              child: child,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付ヘッダー
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(dateKey,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.grey.shade700)),
                  ],
                ),
              ),
              ...dayRecords.map((record) => _RecordCard(
                    record: record,
                    linkedPlant: _plants
                        .where((p) => p.id == record.myPlantId)
                        .firstOrNull,
                    onDelete: () => _deleteRecord(record.id),
                    onShare: () => ShareUtil.showShareSheet(
                      context,
                      ShareUtil.buildRecordText(record),
                    ),
                  )),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

// ── サマリーカード ────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalRecords;
  final int harvestCount;
  final int totalCost;
  final int photoCount;

  const _SummaryCard({
    required this.totalRecords,
    required this.harvestCount,
    required this.totalCost,
    required this.photoCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.primaryContainer.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.edit_note,
            label: '総記録数',
            value: '$totalRecords件',
            color: cs.primary,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.shopping_basket,
            label: '収穫回数',
            value: '$harvestCount回',
            color: Colors.green.shade700,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.photo_camera,
            label: '写真あり',
            value: '$photoCount件',
            color: Colors.indigo.shade400,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.payments_outlined,
            label: '総費用',
            value: totalCost > 0 ? '¥$totalCost' : '未記録',
            color: Colors.teal.shade700,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: Colors.grey.shade300);
  }
}

// ── 記録カード ────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final CultivationRecord record;
  final MyPlant? linkedPlant;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _RecordCard({
    required this.record,
    required this.onDelete,
    required this.onShare,
    this.linkedPlant,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
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
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 26),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 写真サムネイル（あれば）
            if (record.imageBase64 != null)
              _PhotoThumbnail(imageBase64: record.imageBase64!),

            // テキスト情報
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _workIcon(record.workType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(record.vegetableName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const SizedBox(width: 8),
                            _workTypeLabel(record.workType),
                            const Spacer(),
                            GestureDetector(
                              onTap: onShare,
                              child: Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        if (linkedPlant != null) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantDetailScreen(
                                    plant: linkedPlant!),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(linkedPlant!.vegetableEmoji,
                                      style: const TextStyle(
                                          fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'マイ畑: ${linkedPlant!.vegetableName}（${linkedPlant!.location}）',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (record.harvestAmount != null ||
                            record.cost != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              if (record.harvestAmount != null)
                                _InfoBadge(
                                  icon: Icons.shopping_basket,
                                  text: record.harvestAmount!,
                                  color: Colors.green.shade600,
                                ),
                              if (record.cost != null &&
                                  record.cost! > 0)
                                _InfoBadge(
                                  icon: Icons.payments_outlined,
                                  text: '¥${record.cost}',
                                  color: Colors.teal.shade600,
                                ),
                            ],
                          ),
                        ],
                        if (record.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(record.note,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workIcon(String workType) {
    final (icon, color) = switch (workType) {
      '種まき' => (Icons.grass, Colors.orange.shade600),
      '定植' => (Icons.local_florist, Colors.blue.shade600),
      '収穫' => (Icons.shopping_basket, Colors.green.shade600),
      '水やり' => (Icons.water_drop, Colors.lightBlue.shade600),
      '施肥' => (Icons.science, Colors.brown.shade400),
      '剪定' => (Icons.content_cut, Colors.purple.shade400),
      '防虫' => (Icons.pest_control, Colors.red.shade400),
      _ => (Icons.edit_note, Colors.grey.shade500),
    };
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _workTypeLabel(String workType) {
    final (text, color) = switch (workType) {
      '種まき' => ('種まき', Colors.orange.shade600),
      '定植' => ('定植', Colors.blue.shade600),
      '収穫' => ('収穫', Colors.green.shade600),
      '水やり' => ('水やり', Colors.lightBlue.shade600),
      '施肥' => ('施肥', Colors.brown.shade400),
      '剪定' => ('剪定', Colors.purple.shade400),
      '防虫' => ('防虫', Colors.red.shade400),
      _ => (workType, Colors.grey.shade500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold)),
    );
  }
}

// ── 写真サムネイル ────────────────────────────────────────

class _PhotoThumbnail extends StatelessWidget {
  final String imageBase64;

  const _PhotoThumbnail({required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreen(context),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.memory(
          base64Decode(imageBase64),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 60,
            color: Colors.grey.shade100,
            child: Icon(Icons.broken_image,
                color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            _FullScreenPhoto(imageBase64: imageBase64),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

// ── フルスクリーン写真表示 ────────────────────────────────

class _FullScreenPhoto extends StatelessWidget {
  final String imageBase64;

  const _FullScreenPhoto({required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  base64Decode(imageBase64),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // 閉じるボタン
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close,
                    color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
            // 操作ヒント
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'ピンチでズーム・タップで閉じる',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── バッジウィジェット ────────────────────────────────────

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
