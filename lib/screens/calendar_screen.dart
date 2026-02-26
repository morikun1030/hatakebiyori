import 'package:flutter/material.dart';
import '../data/vegetables_data.dart';
import '../models/region.dart';
import '../models/vegetable.dart';
import '../services/settings_service.dart';
import 'vegetable_detail_screen.dart';
import 'settings_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedMonth = DateTime.now().month;

  static const _monthLabels = [
    '1月', '2月', '3月', '4月', '5月', '6月',
    '7月', '8月', '9月', '10月', '11月', '12月',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Region>(
      valueListenable: SettingsService.regionNotifier,
      builder: (context, region, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('栽培カレンダー',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${region.emoji} ${region.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: '設定',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.calendar_month), text: '月別'),
                Tab(icon: Icon(Icons.view_timeline), text: '年間計画'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _MonthlyView(
                selectedMonth: _selectedMonth,
                monthLabels: _monthLabels,
                regionOffset: region.offset,
                onMonthChanged: (m) => setState(() => _selectedMonth = m),
              ),
              _GanttChartView(regionOffset: region.offset),
            ],
          ),
        );
      },
    );
  }
}

// ── 月別ビュー ───────────────────────────────────────────

class _MonthlyView extends StatelessWidget {
  final int selectedMonth;
  final List<String> monthLabels;
  final int regionOffset;
  final ValueChanged<int> onMonthChanged;

  const _MonthlyView({
    required this.selectedMonth,
    required this.monthLabels,
    required this.regionOffset,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final veggies = VegetablesData.all;

    List<int> adjusted(List<int> months) =>
        SettingsService.adjustMonths(months, regionOffset);

    final sowing = veggies
        .where((v) => adjusted(v.sowingMonths).contains(selectedMonth))
        .toList();
    final planting = veggies
        .where((v) => adjusted(v.plantingMonths).contains(selectedMonth))
        .toList();
    final harvest = veggies
        .where((v) => adjusted(v.harvestMonths).contains(selectedMonth))
        .toList();

    return Column(
      children: [
        _MonthSelector(
          selectedMonth: selectedMonth,
          monthLabels: monthLabels,
          onMonthChanged: onMonthChanged,
          sowingCount: sowing.length,
          plantingCount: planting.length,
          harvestCount: harvest.length,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sowing.isNotEmpty) ...[
                _SectionHeader(
                    label: '種まき',
                    color: Colors.orange.shade700,
                    icon: Icons.grass,
                    count: sowing.length),
                const SizedBox(height: 8),
                ...sowing.map((v) => _VeggieCard(v: v)),
                const SizedBox(height: 16),
              ],
              if (planting.isNotEmpty) ...[
                _SectionHeader(
                    label: '定植',
                    color: Colors.blue.shade700,
                    icon: Icons.local_florist,
                    count: planting.length),
                const SizedBox(height: 8),
                ...planting.map((v) => _VeggieCard(v: v)),
                const SizedBox(height: 16),
              ],
              if (harvest.isNotEmpty) ...[
                _SectionHeader(
                    label: '収穫',
                    color: Colors.green.shade700,
                    icon: Icons.shopping_basket,
                    count: harvest.length),
                const SizedBox(height: 8),
                ...harvest.map((v) => _VeggieCard(v: v)),
              ],
              if (sowing.isEmpty && planting.isEmpty && harvest.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Icon(Icons.yard_outlined,
                          size: 72, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('この月は屋外作業はひと休み',
                          style:
                              TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final int selectedMonth;
  final List<String> monthLabels;
  final ValueChanged<int> onMonthChanged;
  final int sowingCount;
  final int plantingCount;
  final int harvestCount;

  const _MonthSelector({
    required this.selectedMonth,
    required this.monthLabels,
    required this.onMonthChanged,
    required this.sowingCount,
    required this.plantingCount,
    required this.harvestCount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentMonth = DateTime.now().month;

    return Container(
      color: cs.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == selectedMonth;
                final isToday = month == currentMonth;
                return GestureDetector(
                  onTap: () => onMonthChanged(month),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 52,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary
                          : isToday
                              ? cs.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthLabels[index],
                          style: TextStyle(
                            color: isSelected
                                ? cs.onPrimary
                                : cs.onPrimaryContainer,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        if (isToday && !isSelected)
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                if (sowingCount > 0)
                  _CountBadge(
                      count: sowingCount,
                      label: '種まき',
                      color: Colors.orange.shade600),
                if (plantingCount > 0)
                  _CountBadge(
                      count: plantingCount,
                      label: '定植',
                      color: Colors.blue.shade600),
                if (harvestCount > 0)
                  _CountBadge(
                      count: harvestCount,
                      label: '収穫',
                      color: Colors.green.shade700),
                if (sowingCount == 0 &&
                    plantingCount == 0 &&
                    harvestCount == 0)
                  Text('作業なし',
                      style: TextStyle(
                          color: cs.onPrimaryContainer, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CountBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label $count種',
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final int count;

  const _SectionHeader(
      {required this.label,
      required this.color,
      required this.icon,
      required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(width: 6),
        Text('$count種',
            style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _VeggieCard extends StatelessWidget {
  final Vegetable v;

  const _VeggieCard({required this.v});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Hero(
          tag: 'veg-${v.id}',
          child: Text(v.emoji, style: const TextStyle(fontSize: 28)),
        ),
        title: Text(v.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${v.category}  ·  ${v.difficulty}'),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () {
          Navigator.push(
            context,
            _fadeSlideRoute(VegetableDetailScreen(vegetable: v)),
          );
        },
      ),
    );
  }
}

// ── 年間ガントチャート ────────────────────────────────────

class _GanttChartView extends StatelessWidget {
  final int regionOffset;

  const _GanttChartView({required this.regionOffset});

  static const _colWidth = 26.0;
  static const _nameWidth = 100.0;
  static const _rowHeight = 24.0;

  List<int> _adj(List<int> months) =>
      SettingsService.adjustMonths(months, regionOffset);

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final categories = VegetablesData.categories;

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              children: [
                _legendItem(Colors.orange.shade400, '種まき'),
                _legendItem(Colors.blue.shade400, '定植'),
                _legendItem(Colors.green.shade500, '収穫'),
              ],
            ),
            const SizedBox(height: 14),
            _buildHeaderRow(context, currentMonth),
            const SizedBox(height: 6),
            for (final cat in categories) ...[
              _buildCategoryLabel(context, cat),
              for (final veg
                  in VegetablesData.all.where((v) => v.category == cat))
                _buildVegetableRow(context, veg, currentMonth),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, int currentMonth) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const SizedBox(width: _nameWidth),
        ...List.generate(12, (i) {
          final isNow = i + 1 == currentMonth;
          return Container(
            width: _colWidth,
            height: 28,
            alignment: Alignment.center,
            decoration: isNow
                ? BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Text(
              '${i + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isNow ? FontWeight.bold : FontWeight.w400,
                color:
                    isNow ? cs.primary : Colors.grey.shade600,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCategoryLabel(BuildContext context, String category) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVegetableRow(
      BuildContext context, Vegetable v, int currentMonth) {
    final adjSow = _adj(v.sowingMonths);
    final adjPlant = _adj(v.plantingMonths);
    final adjHarvest = _adj(v.harvestMonths);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            _fadeSlideRoute(VegetableDetailScreen(vegetable: v)),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: _nameWidth,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '${v.emoji} ${v.name}',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            ...List.generate(12, (i) {
              final month = i + 1;
              Color barColor;
              if (adjHarvest.contains(month)) {
                barColor = Colors.green.shade400;
              } else if (adjSow.contains(month)) {
                barColor = Colors.orange.shade400;
              } else if (adjPlant.contains(month)) {
                barColor = Colors.blue.shade400;
              } else {
                barColor = Colors.grey.shade100;
              }
              final isNow = month == currentMonth;
              return Container(
                width: _colWidth,
                height: _rowHeight,
                margin: const EdgeInsets.symmetric(
                    horizontal: 1, vertical: 1),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                  border: isNow
                      ? Border.all(
                          color: Colors.grey.shade500, width: 1.5)
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ── ページ遷移ヘルパー ────────────────────────────────────

PageRoute<T> _fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
