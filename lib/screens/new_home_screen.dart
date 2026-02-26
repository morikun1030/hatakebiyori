import 'package:flutter/material.dart';
import '../models/my_plant.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'calendar_screen.dart';
import 'diary_screen.dart';
import 'guide_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'vegetable_db_screen.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final _storage = StorageService();
  List<MyPlant> _plants = [];
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GuideScreen.showIfFirstLaunch(context);
    });
  }

  Future<void> _load() async {
    final plants = await _storage.getPlants();
    final streak = await _storage.getStreak();
    if (mounted) {
      setState(() {
        _plants = plants.where((p) => p.status != PlantStatus.finished).toList();
        _streak = streak;
        _loading = false;
      });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'おはようございます';
    if (hour < 18) return 'こんにちは';
    return 'こんばんは';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = AuthService.currentUser;
    final name = user?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primaryContainer,
        title: Text(
          'はたけびより',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: cs.onPrimaryContainer,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          if (user?.photoURL != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(user!.photoURL!),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: cs.primary,
                child: const Icon(Icons.person, size: 18, color: Colors.white),
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
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ① グリーティングヘッダー
                          _GreetingHeader(
                            greeting: _greeting,
                            name: name,
                            streak: _streak,
                          ),
                          const SizedBox(height: 20),

                          // ② アクティブな植物クイックビュー
                          _SectionLabel(
                            icon: Icons.yard_outlined,
                            title: '育てている野菜',
                          ),
                          const SizedBox(height: 8),
                          _ActivePlantsSection(
                            plants: _plants,
                            onAdd: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()),
                              );
                              _load();
                            },
                          ),
                          const SizedBox(height: 20),

                          // ③ 機能カードグリッド
                          _SectionLabel(
                            icon: Icons.apps_outlined,
                            title: 'メニュー',
                          ),
                          const SizedBox(height: 8),
                          _FeatureCardGrid(
                            onMyGarden: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            ),
                            onDiary: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DiaryScreen()),
                            ),
                            onCalendar: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CalendarScreen()),
                            ),
                            onVegetableDb: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const VegetableDbScreen()),
                            ),
                            onGuide: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const GuideScreen()),
                            ),
                            onSettings: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ④ 今月のワンポイント
                          _SectionLabel(
                            icon: Icons.lightbulb_outline,
                            title: '今月のワンポイント',
                          ),
                          const SizedBox(height: 8),
                          _MonthlyTipCard(month: DateTime.now().month),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── グリーティングヘッダー ────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final int streak;

  const _GreetingHeader({
    required this.greeting,
    required this.name,
    required this.streak,
  });

  (String, Color) _streakStyle() {
    if (streak == 0) return ('今日はまだ記録なし', Colors.grey);
    if (streak == 1) return ('🌱 記録スタート！', Colors.green);
    if (streak < 7) return ('🔥 $streak日連続！', Colors.orange);
    return ('⚡ $streak日連続！すごい！', const Color(0xFFB8860B));
  }

  String _weekdayLabel(int wd) {
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[(wd - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final (streakLabel, streakColor) = _streakStyle();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isNotEmpty ? '$greeting、$name さん！' : '$greeting！',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${now.year}年${now.month}月${now.day}日（${_weekdayLabel(now.weekday)}）',
            style: TextStyle(
              fontSize: 13,
              color: cs.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: streakColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: streakColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              streakLabel,
              style: TextStyle(
                fontSize: 12,
                color: streakColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── セクションラベル ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionLabel({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ── アクティブな植物クイックビュー ────────────────────────────────────────

class _ActivePlantsSection extends StatelessWidget {
  final List<MyPlant> plants;
  final VoidCallback onAdd;

  const _ActivePlantsSection({required this.plants, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (plants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text(
              'まだ野菜を登録していません',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '野菜を追加してはたけびよりを始めましょう',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('マイ畑へ'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) => _PlantMiniCard(plant: plants[i]),
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
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(plant.vegetableEmoji,
              style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(
            plant.vegetableName,
            style:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${plant.status.emoji} ${plant.status.label}',
              style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$days日目',
            style:
                TextStyle(fontSize: 9, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ── 機能カードグリッド ────────────────────────────────────────────────────

class _FeatureCardGrid extends StatelessWidget {
  final VoidCallback onMyGarden;
  final VoidCallback onDiary;
  final VoidCallback onCalendar;
  final VoidCallback onVegetableDb;
  final VoidCallback onGuide;
  final VoidCallback onSettings;

  const _FeatureCardGrid({
    required this.onMyGarden,
    required this.onDiary,
    required this.onCalendar,
    required this.onVegetableDb,
    required this.onGuide,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatureItem('🌱', 'マイ畑', 'マイ畑を管理', onMyGarden),
      _FeatureItem('📔', '栽培日誌', '作業を記録', onDiary),
      _FeatureItem('📅', 'カレンダー', '栽培計画を立てる', onCalendar),
      _FeatureItem('🌿', '野菜図鑑', '野菜情報を調べる', onVegetableDb),
      _FeatureItem('❓', '使い方', 'ガイドを見る', onGuide),
      _FeatureItem('⚙️', '設定', '地域・バックアップ', onSettings),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 400 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cols == 3 ? 1.4 : 1.6,
          children: items.map((item) => _FeatureCard(item: item)).toList(),
        );
      },
    );
  }
}

class _FeatureItem {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureItem(this.emoji, this.title, this.subtitle, this.onTap);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;

  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 今月のワンポイント ────────────────────────────────────────────────────

class _MonthlyTipCard extends StatelessWidget {
  final int month;

  const _MonthlyTipCard({required this.month});

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
                    color: cs.onTertiaryContainer.withValues(alpha: 0.85),
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
