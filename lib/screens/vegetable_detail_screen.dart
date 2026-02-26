import 'package:flutter/material.dart';
import '../data/companion_data.dart';
import '../data/pest_disease_data.dart';
import '../data/vegetables_data.dart';
import '../models/companion_relation.dart';
import '../models/pest_disease.dart';
import '../models/region.dart';
import '../models/vegetable.dart';
import '../services/settings_service.dart';
import 'add_plant_screen.dart';

class VegetableDetailScreen extends StatelessWidget {
  final Vegetable vegetable;

  const VegetableDetailScreen({super.key, required this.vegetable});

  static const _monthLabels = [
    '1月', '2月', '3月', '4月', '5月', '6月',
    '7月', '8月', '9月', '10月', '11月', '12月',
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Region>(
      valueListenable: SettingsService.regionNotifier,
      builder: (context, region, _) {
        final offset = region.offset;
        final adjSow =
            SettingsService.adjustMonths(vegetable.sowingMonths, offset);
        final adjPlant =
            SettingsService.adjustMonths(vegetable.plantingMonths, offset);
        final adjHarvest =
            SettingsService.adjustMonths(vegetable.harvestMonths, offset);
        final currentMonth = DateTime.now().month;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddPlantScreen(initialVegetable: vegetable),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('マイ畑に追加'),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    vegetable.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: false,
                  background: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Hero(
                        tag: 'veg-${vegetable.id}',
                        child: Text(
                          vegetable.emoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // カテゴリ・難易度
                    Row(
                      children: [
                        Chip(
                          label: Text(vegetable.category,
                              style: const TextStyle(fontSize: 13)),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        _difficultyChip(vegetable.difficulty),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 地域補正バナー（補正がある場合のみ）
                    if (offset != 0) ...[
                      _RegionOffsetBanner(region: region),
                      const SizedBox(height: 12),
                    ],

                    // 説明
                    _InfoCard(
                      title: '特徴・育て方',
                      child: Text(vegetable.description,
                          style: const TextStyle(height: 1.7)),
                    ),
                    const SizedBox(height: 12),

                    // 作業時期（補正済み）
                    _InfoCard(
                      title: '作業時期',
                      child: Column(
                        children: [
                          if (adjSow.isNotEmpty)
                            _WorkRow(
                                icon: Icons.grass,
                                label: '種まき',
                                months: adjSow,
                                color: Colors.orange.shade700),
                          if (adjPlant.isNotEmpty)
                            _WorkRow(
                                icon: Icons.local_florist,
                                label: '定植',
                                months: adjPlant,
                                color: Colors.blue.shade700),
                          if (adjHarvest.isNotEmpty)
                            _WorkRow(
                                icon: Icons.shopping_basket,
                                label: '収穫',
                                months: adjHarvest,
                                color: Colors.green.shade700),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 年間カレンダー（補正済み）
                    _InfoCard(
                      title: '年間栽培カレンダー',
                      child: Column(
                        children: [
                          // 月ヘッダー
                          Row(
                            children: [
                              const SizedBox(width: 52),
                              ...List.generate(
                                12,
                                (i) => Expanded(
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: i + 1 == currentMonth
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: i + 1 == currentMonth
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (adjSow.isNotEmpty)
                            _MonthBar(
                              label: '種まき',
                              activeMonths: adjSow,
                              color: Colors.orange.shade300,
                              currentMonth: currentMonth,
                            ),
                          if (adjPlant.isNotEmpty)
                            _MonthBar(
                              label: '定植',
                              activeMonths: adjPlant,
                              color: Colors.blue.shade300,
                              currentMonth: currentMonth,
                            ),
                          if (adjHarvest.isNotEmpty)
                            _MonthBar(
                              label: '収穫',
                              activeMonths: adjHarvest,
                              color: Colors.green.shade400,
                              currentMonth: currentMonth,
                            ),
                          const SizedBox(height: 8),
                          _CurrentMonthStatus(
                            adjSow: adjSow,
                            adjPlant: adjPlant,
                            adjHarvest: adjHarvest,
                            currentMonth: currentMonth,
                            monthLabel: _monthLabels[currentMonth - 1],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // コンパニオンプランツ
                    _CompanionCard(vegetableId: vegetable.id),
                    const SizedBox(height: 12),

                    // 病害虫チェックリスト
                    _PestDiseaseCard(vegetableId: vegetable.id),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _difficultyChip(String difficulty) {
    final color = switch (difficulty) {
      '初心者向け' => Colors.green.shade600,
      '中級' => Colors.orange.shade600,
      '上級' => Colors.red.shade600,
      _ => Colors.grey,
    };
    return Chip(
      label: Text(difficulty,
          style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold)),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.4)),
      padding: EdgeInsets.zero,
    );
  }
}

// ── サブウィジェット ──────────────────────────────────────

class _RegionOffsetBanner extends StatelessWidget {
  final Region region;

  const _RegionOffsetBanner({required this.region});

  @override
  Widget build(BuildContext context) {
    final isLate = region.offset > 0;
    final color = isLate ? Colors.blue.shade600 : Colors.green.shade600;
    final label = isLate
        ? '${region.emoji} ${region.name}：関東基準より約${region.offset}ヶ月遅めに補正'
        : '${region.emoji} ${region.name}：関東基準より約${region.offset.abs()}ヶ月早めに補正';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WorkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<int> months;
  final Color color;

  const _WorkRow(
      {required this.icon,
      required this.label,
      required this.months,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          Expanded(
            child: Text(months.map((m) => '$m月').join(' · '),
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final String label;
  final List<int> activeMonths;
  final Color color;
  final int currentMonth;

  const _MonthBar({
    required this.label,
    required this.activeMonths,
    required this.color,
    required this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
              width: 52,
              child:
                  Text(label, style: const TextStyle(fontSize: 11))),
          ...List.generate(12, (i) {
            final month = i + 1;
            final isActive = activeMonths.contains(month);
            final isNow = month == currentMonth;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: isNow
                      ? Border.all(
                          color:
                              Theme.of(context).colorScheme.primary,
                          width: 1.5)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CurrentMonthStatus extends StatelessWidget {
  final List<int> adjSow;
  final List<int> adjPlant;
  final List<int> adjHarvest;
  final int currentMonth;
  final String monthLabel;

  const _CurrentMonthStatus({
    required this.adjSow,
    required this.adjPlant,
    required this.adjHarvest,
    required this.currentMonth,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final canSow = adjSow.contains(currentMonth);
    final canPlant = adjPlant.contains(currentMonth);
    final canHarvest = adjHarvest.contains(currentMonth);

    if (!canSow && !canPlant && !canHarvest) {
      return Row(
        children: [
          Icon(Icons.info_outline,
              size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text('$monthLabel は作業時期外です',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500)),
        ],
      );
    }

    final works = <String>[];
    if (canSow) works.add('種まき');
    if (canPlant) works.add('定植');
    if (canHarvest) works.add('収穫');

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            '$monthLabel は ${works.join('・')} の時期です',
            style: TextStyle(
                fontSize: 12,
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── コンパニオンプランツカード ────────────────────────────

class _CompanionCard extends StatelessWidget {
  final String vegetableId;

  const _CompanionCard({required this.vegetableId});

  @override
  Widget build(BuildContext context) {
    final entry = CompanionData.findById(vegetableId);

    if (entry == null ||
        (entry.goodPartners.isEmpty && entry.badPartners.isEmpty)) {
      return const SizedBox.shrink();
    }

    return _InfoCard(
      title: 'コンパニオンプランツ',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.goodPartners.isNotEmpty) ...[
            _CompanionSectionHeader(
              icon: Icons.thumb_up_outlined,
              label: '一緒に植えると良い',
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            ...entry.goodPartners
                .map((info) => _CompanionTile(info: info, isGood: true)),
          ],
          if (entry.badPartners.isNotEmpty) ...[
            if (entry.goodPartners.isNotEmpty) const SizedBox(height: 12),
            _CompanionSectionHeader(
              icon: Icons.thumb_down_outlined,
              label: '一緒に植えない方が良い',
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 8),
            ...entry.badPartners
                .map((info) => _CompanionTile(info: info, isGood: false)),
          ],
        ],
      ),
    );
  }
}

class _CompanionSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CompanionSectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CompanionTile extends StatelessWidget {
  final CompanionInfo info;
  final bool isGood;

  const _CompanionTile({required this.info, required this.isGood});

  @override
  Widget build(BuildContext context) {
    final partner =
        VegetablesData.all.where((v) => v.id == info.partnerId).firstOrNull;
    if (partner == null) return const SizedBox.shrink();

    final color = isGood ? Colors.green.shade600 : Colors.red.shade600;
    final bgColor = isGood ? Colors.green.shade50 : Colors.red.shade50;
    final borderColor =
        isGood ? Colors.green.shade200 : Colors.red.shade200;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VegetableDetailScreen(vegetable: partner),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Text(partner.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        partner.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isGood
                            ? Icons.arrow_forward_ios
                            : Icons.warning_amber,
                        size: 12,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    info.effect,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
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
}

// ── 病害虫チェックリストカード ────────────────────────────

class _PestDiseaseCard extends StatelessWidget {
  final String vegetableId;

  const _PestDiseaseCard({required this.vegetableId});

  @override
  Widget build(BuildContext context) {
    final items = PestDiseaseData.forVegetable(vegetableId);
    if (items.isEmpty) return const SizedBox.shrink();

    final pests = items.where((i) => i.type == PestDiseaseType.pest).toList();
    final diseases =
        items.where((i) => i.type == PestDiseaseType.disease).toList();

    return _InfoCard(
      title: '病害虫チェックリスト',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pests.isNotEmpty) ...[
            _PestDiseaseSectionHeader(
              icon: Icons.bug_report_outlined,
              label: '害虫 (${pests.length}種)',
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 8),
            ...pests.map((item) => _PestDiseaseTile(item: item)),
          ],
          if (diseases.isNotEmpty) ...[
            if (pests.isNotEmpty) const SizedBox(height: 12),
            _PestDiseaseSectionHeader(
              icon: Icons.coronavirus_outlined,
              label: '病気 (${diseases.length}種)',
              color: Colors.purple.shade700,
            ),
            const SizedBox(height: 8),
            ...diseases.map((item) => _PestDiseaseTile(item: item)),
          ],
        ],
      ),
    );
  }
}

class _PestDiseaseSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PestDiseaseSectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PestDiseaseTile extends StatelessWidget {
  final PestDiseaseInfo item;

  const _PestDiseaseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPest = item.type == PestDiseaseType.pest;
    final color =
        isPest ? Colors.orange.shade700 : Colors.purple.shade700;
    final bgColor =
        isPest ? Colors.orange.shade50 : Colors.purple.shade50;
    final borderColor =
        isPest ? Colors.orange.shade200 : Colors.purple.shade200;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Text(item.emoji,
              style: const TextStyle(fontSize: 24)),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          children: [
            _DetailRow(
              icon: Icons.search,
              label: '症状・特徴',
              text: item.symptom,
              color: color,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.shield_outlined,
              label: '予防法',
              text: item.prevention,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.healing_outlined,
              label: '対処法',
              text: item.treatment,
              color: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
