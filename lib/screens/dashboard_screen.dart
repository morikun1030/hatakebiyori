import 'package:flutter/material.dart';
import '../data/vegetables_data.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import 'add_plant_screen.dart';
import 'add_record_screen.dart';
import 'guide_screen.dart';
import 'monthly_dashboard.dart';
import 'my_garden_screen.dart';
import 'settings_screen.dart';
import 'weekly_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _storage = StorageService();
  List<MyPlant> _plants = [];
  List<CultivationRecord> _records = [];
  int _streak = 0;
  bool _loading = true;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plants = await _storage.getPlants();
    final records = await _storage.getRecords();
    final streak = await _storage.getStreak();
    if (mounted) {
      setState(() {
        _plants = plants;
        _records = records;
        _streak = streak;
        _loading = false;
      });
    }
  }

  Future<void> _openRecord(MyPlant? plant, String? workType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddRecordScreen(initialPlant: plant, initialWorkType: workType),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ダッシュボード',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'はじめてガイド',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GuideScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.onPrimaryContainer,
          unselectedLabelColor:
              cs.onPrimaryContainer.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: '今日'),
            Tab(text: '今週'),
            Tab(text: '今月'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _TodayTab(
                  plants: _plants,
                  streak: _streak,
                  onLoad: _load,
                  onOpenRecord: _openRecord,
                ),
                WeeklyDashboard(
                  records: _records,
                  plants: _plants,
                  streak: _streak,
                ),
                MonthlyDashboard(
                  records: _records,
                  plants: _plants,
                ),
              ],
            ),
    );
  }
}

// ── 今日タブ ─────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  final List<MyPlant> plants;
  final int streak;
  final VoidCallback onLoad;
  final Future<void> Function(MyPlant?, String?) onOpenRecord;

  const _TodayTab({
    required this.plants,
    required this.streak,
    required this.onLoad,
    required this.onOpenRecord,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'おはようございます';
    if (hour < 18) return 'こんにちは';
    return 'こんばんは';
  }

  MyPlant? _highlight(List<MyPlant> plants) {
    final active =
        plants.where((p) => p.status != PlantStatus.finished).toList();
    if (active.isEmpty) return null;
    final harvesting =
        active.where((p) => p.status == PlantStatus.harvesting);
    if (harvesting.isNotEmpty) return harvesting.first;
    return active
        .reduce((a, b) => a.startDate.isBefore(b.startDate) ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final highlight = _highlight(plants);

    return RefreshIndicator(
      onRefresh: () async => onLoad(),
      child: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _GreetingHeader(
              greeting: _greeting, now: now, streak: streak),
          const SizedBox(height: 16),
          _SectionHeader(
              title: '今日のハイライト', icon: Icons.star_outline),
          const SizedBox(height: 8),
          if (highlight != null)
            _HighlightCard(
              plant: highlight,
              onWater: () => onOpenRecord(highlight, '水やり'),
              onHarvest: () => onOpenRecord(highlight, '収穫'),
              onRecord: () => onOpenRecord(highlight, null),
            )
          else
            _EmptyHighlight(
              onAdd: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddPlantScreen()),
                );
                if (result == true) onLoad();
              },
            ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'マイ畑',
            icon: Icons.yard,
            onMore: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MyGardenScreen()),
              );
              onLoad();
            },
          ),
          const SizedBox(height: 8),
          _MyGardenSection(
            plants: plants,
            onAdd: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddPlantScreen()),
              );
              if (result == true) onLoad();
            },
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: '今日のタスク',
            icon: Icons.task_alt,
            onMore: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddRecordScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _TodayTasksSection(plants: plants, now: now),
          const SizedBox(height: 20),
          _SectionHeader(
            title: '今月のワンポイント',
            icon: Icons.lightbulb_outline,
          ),
          const SizedBox(height: 8),
          _MonthlyTipSection(month: now.month),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── あいさつヘッダー（コンパクト1行 + ストリークバッジ） ──────────────────

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final DateTime now;
  final int streak;

  const _GreetingHeader(
      {required this.greeting, required this.now, required this.streak});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${now.year}年${now.month}月${now.day}日（${_weekdayLabel(now.weekday)}）',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          _StreakBadge(streak: streak),
        ],
      ),
    );
  }

  String _weekdayLabel(int wd) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[(wd - 1) % 7];
  }
}

// ── ストリークバッジ ──────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  (String, Color, bool) _streakStyle() {
    if (streak == 0) return ('今日はまだ記録なし', Colors.grey, false);
    if (streak == 1) return ('🌱 記録スタート！', Colors.green, false);
    if (streak < 7) return ('🔥 $streak日連続！', Colors.orange, false);
    return ('⚡ $streak日連続！すごい！', const Color(0xFFB8860B), true);
  }

  @override
  Widget build(BuildContext context) {
    final (label, color, bold) = _streakStyle();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}

// ── セクションヘッダー ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onMore;

  const _SectionHeader(
      {required this.title, required this.icon, this.onMore});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Text(title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (onMore != null)
          TextButton(onPressed: onMore, child: const Text('もっと見る')),
      ],
    );
  }
}

// ── ハイライトカード ──────────────────────────────────────────────────────

class _HighlightCard extends StatelessWidget {
  final MyPlant plant;
  final VoidCallback onWater;
  final VoidCallback onHarvest;
  final VoidCallback onRecord;

  const _HighlightCard({
    required this.plant,
    required this.onWater,
    required this.onHarvest,
    required this.onRecord,
  });

  double get _progress => switch (plant.status) {
        PlantStatus.sowed => 0.10,
        PlantStatus.sprouted => 0.30,
        PlantStatus.growing => 0.55,
        PlantStatus.harvesting => 0.85,
        PlantStatus.finished => 1.00,
      };

  Color _statusColor(PlantStatus s) {
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

  String _message(int days) {
    return switch (plant.status) {
      PlantStatus.sowed => days < 7
          ? '種をまいてくれてありがとう！芽が出るの楽しみにしてね🌱'
          : '毎日見てくれてる？そろそろ芽が出そうだよ👀',
      PlantStatus.sprouted => 'やっと芽が出たよ！これからもよろしくね😊',
      PlantStatus.growing => days < 30
          ? 'すくすく育ってるよ！水やり忘れずにね💧'
          : '大きくなってきたでしょ？もう少しで収穫できそう🎉',
      PlantStatus.harvesting => 'もう収穫できるよ！早く食べたいな🍅',
      PlantStatus.finished => 'お疲れさまでした！来シーズンもよろしくね✨',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(plant.status);
    final days = DateTime.now().difference(plant.startDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 植物情報行
          Row(
            children: [
              Text(plant.vegetableEmoji,
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.vegetableName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${plant.status.emoji} ${plant.status.label}',
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$days日目',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 成長プログレスバー
          Row(
            children: [
              Text('成長度',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 吹き出しメッセージ
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💬', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _message(days),
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSecondaryContainer),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // クイックアクション
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  label: '水やり',
                  emoji: '💧',
                  color: Colors.lightBlue,
                  onTap: onWater,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionButton(
                  label: '収穫',
                  emoji: '🧺',
                  color: Colors.green,
                  onTap: onHarvest,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickActionButton(
                  label: '記録する',
                  emoji: '📝',
                  color: Colors.purple,
                  onTap: onRecord,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── クイックアクションボタン ──────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ── ハイライト空状態 ──────────────────────────────────────────────────────

class _EmptyHighlight extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyHighlight({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
            color: cs.outline.withValues(alpha: 0.3),
            style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            '育てている野菜を登録しましょう',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            '野菜を追加すると今日のハイライトが表示されます',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('野菜を追加'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8)),
          ),
        ],
      ),
    );
  }
}

// ── マイ畑セクション ────────────────────────────────────────────────────

class _MyGardenSection extends StatelessWidget {
  final List<MyPlant> plants;
  final VoidCallback onAdd;

  const _MyGardenSection({required this.plants, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'まだ野菜を登録していません',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: onAdd,
              child: const Text('追加'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) {
          if (i == plants.length) return _AddPlantCard(onAdd: onAdd);
          return _PlantMiniCard(plant: plants[i]);
        },
      ),
    );
  }
}

class _PlantMiniCard extends StatelessWidget {
  final MyPlant plant;

  const _PlantMiniCard({required this.plant});

  Color _statusColor(PlantStatus s) {
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
    final cs = Theme.of(context).colorScheme;
    final color = _statusColor(plant.status);
    final days = DateTime.now().difference(plant.startDate).inDays;
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(plant.vegetableEmoji,
              style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 4),
          Text(
            plant.vegetableName,
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${plant.status.emoji} ${plant.status.label}',
              style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$days日目',
            style:
                TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _AddPlantCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddPlantCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          border: Border.all(
              color: cs.primary.withValues(alpha: 0.4),
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: cs.primary, size: 28),
            const SizedBox(height: 6),
            Text('追加',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── 今日のタスクセクション ────────────────────────────────────────────────

class _TodayTasksSection extends StatelessWidget {
  final List<MyPlant> plants;
  final DateTime now;

  const _TodayTasksSection({required this.plants, required this.now});

  List<_Task> _buildTasks() {
    final offset = SettingsService.regionNotifier.value.offset;
    final month = now.month;
    final tasks = <_Task>[];

    for (final plant in plants) {
      if (plant.status == PlantStatus.finished) continue;

      if (plant.status == PlantStatus.harvesting) {
        tasks.add(_Task(
          emoji: '🌿',
          message: '${plant.vegetableName}が収穫時期です',
          color: Colors.green,
        ));
        continue;
      }

      final veg = VegetablesData.all
          .where((v) => v.id == plant.vegetableId)
          .firstOrNull;
      if (veg == null) continue;

      final adjustedHarvest =
          SettingsService.adjustMonths(veg.harvestMonths, offset);
      if (adjustedHarvest.contains(month)) {
        tasks.add(_Task(
          emoji: '🧺',
          message: '${plant.vegetableName}の収穫適期です',
          color: Colors.amber.shade700,
        ));
      }

      if (tasks.length >= 3) break;
    }

    if (tasks.length < 3) {
      for (final veg in VegetablesData.all) {
        final adjustedSowing =
            SettingsService.adjustMonths(veg.sowingMonths, offset);
        if (adjustedSowing.contains(month)) {
          final alreadyGrowing =
              plants.any((p) => p.vegetableId == veg.id);
          if (!alreadyGrowing) {
            tasks.add(_Task(
              emoji: '🌱',
              message: '今月は${veg.name}の種まき適期です',
              color: Colors.orange,
            ));
            if (tasks.length >= 3) break;
          }
        }
      }
    }

    if (tasks.isEmpty) {
      tasks.add(_Task(
        emoji: '☀️',
        message: '今日は特別な作業はありません',
        color: Colors.blue,
      ));
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SettingsService.regionNotifier,
      builder: (context, region, _) {
        final builtTasks = _buildTasks();
        return Column(
          children: builtTasks.map((t) => _TaskCard(task: t)).toList(),
        );
      },
    );
  }
}

class _Task {
  final String emoji;
  final String message;
  final Color color;

  const _Task(
      {required this.emoji, required this.message, required this.color});
}

class _TaskCard extends StatelessWidget {
  final _Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: task.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: task.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(task.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.message,
              style: TextStyle(
                fontSize: 14,
                color: task.color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 今月のワンポイントセクション ──────────────────────────────────────────

class _MonthlyTipSection extends StatelessWidget {
  final int month;

  const _MonthlyTipSection({required this.month});

  static const _tips = {
    1: ('❄️', '1月', '霜対策を忘れずに。防寒シートや不織布で苗を守りましょう。根菜類の収穫は甘みが増す今が狙い目です。'),
    2: ('🌸', '2月', '寒さの中でも種まきの準備を始める時期。室内でセルトレイに種をまいてスタートしましょう。'),
    3: ('🌱', '3月', '春まきのシーズン到来。トマト・ナス・ピーマンの種まきを始めましょう。土の準備も大切です。'),
    4: ('🌼', '4月', '定植の適期。苗を畑に植え付けましょう。遅霜に注意し、天気予報をこまめにチェックして。'),
    5: ('☀️', '5月', '成長が加速する時期。追肥と水やりをしっかり。病害虫の発生にも目を光らせましょう。'),
    6: ('🌧️', '6月', '梅雨の時期。過湿による根腐れと病気に注意。風通しを良くする摘葉・整枝が大切です。'),
    7: ('🔥', '7月', '夏野菜の収穫最盛期。水分補給と遮光で高温対策を。早朝・夕方の水やりが効果的です。'),
    8: ('🌻', '8月', '猛暑対策が重要。秋野菜の種まき準備も始めましょう。連作を避けて土壌改良を進めて。'),
    9: ('🍂', '9月', '秋まきのシーズン。ホウレンソウ・小松菜・大根が狙い目。残暑の間は病害虫チェックも継続。'),
    10: ('🍁', '10月', '害虫が減り育てやすい季節。土の中の有機物を補充して来シーズンの準備を。'),
    11: ('🌾', '11月', '収穫の秋。根菜類は霜が当たって甘みが増します。来年向けに記録の整理も大切。'),
    12: ('⛄', '12月', '冬越し野菜の管理を丁寧に。土作りや堆肥づくりを進めて来春に備えましょう。'),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tip = _tips[month] ?? _tips[1]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.$1, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tip.$2}のポイント',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: cs.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.$3,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        cs.onTertiaryContainer.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
