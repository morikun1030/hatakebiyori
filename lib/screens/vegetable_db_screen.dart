import 'package:flutter/material.dart';
import '../data/vegetables_data.dart';
import '../models/vegetable.dart';
import '../widgets/vegetable_avatar.dart';
import 'vegetable_detail_screen.dart';

PageRouteBuilder<T> _fadeSlideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

class VegetableDbScreen extends StatefulWidget {
  const VegetableDbScreen({super.key});

  @override
  State<VegetableDbScreen> createState() => _VegetableDbScreenState();
}

class _VegetableDbScreenState extends State<VegetableDbScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'すべて';

  @override
  Widget build(BuildContext context) {
    final categories = ['すべて', ...VegetablesData.categories];

    var veggies = VegetablesData.all;
    if (_selectedCategory != 'すべて') {
      veggies = veggies.where((v) => v.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      veggies = veggies.where((v) => v.name.contains(_searchQuery)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('野菜図鑑',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: '野菜名で検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),

          // カテゴリフィルター
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat, style: const TextStyle(fontSize: 13)),
                    selected: cat == _selectedCategory,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // 件数表示
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${veggies.length}種類',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 野菜リスト
          Expanded(
            child: veggies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('該当する野菜がありません',
                            style:
                                TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: veggies.length,
                    itemBuilder: (context, index) {
                      final v = veggies[index];
                      return _VegetableListItem(v: v, index: index);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _VegetableListItem extends StatelessWidget {
  final Vegetable v;
  final int index;

  const _VegetableListItem({required this.v, required this.index});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final canSow = v.sowingMonths.contains(currentMonth);
    final canPlant = v.plantingMonths.contains(currentMonth);
    final canHarvest = v.harvestMonths.contains(currentMonth);

    String? nowLabel;
    Color? nowColor;
    if (canHarvest) {
      nowLabel = '収穫期';
      nowColor = Colors.green.shade600;
    } else if (canSow) {
      nowLabel = '種まき期';
      nowColor = Colors.orange.shade600;
    } else if (canPlant) {
      nowLabel = '定植期';
      nowColor = Colors.blue.shade600;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 250 + index * 30),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          leading: Hero(
            tag: 'veg-${v.id}',
            child: VegetableAvatar(
              vegetableId: v.id,
              vegetableName: v.name,
              size: 44,
            ),
          ),
          title: Row(
            children: [
              Text(v.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (nowLabel != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: nowColor!.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    nowLabel,
                    style: TextStyle(
                        fontSize: 10,
                        color: nowColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text('${v.category}  ·  ${v.difficulty}',
              style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () {
            Navigator.push(
              context,
              _fadeSlideRoute(VegetableDetailScreen(vegetable: v)),
            );
          },
        ),
      ),
    );
  }
}
