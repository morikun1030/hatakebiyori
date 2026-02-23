import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/shop_data.dart';

// ── アフィリエイトID ─────────────────────────────────────
const _amazonId = 'burichan0d-22';
const _rakutenId = '5140d37d.f8fb7eb4.5140d37e.429f963f';

String _amazonUrl(String keyword) {
  final encoded = Uri.encodeComponent(keyword);
  return 'https://www.amazon.co.jp/s?k=$encoded&tag=$_amazonId';
}

String _rakutenUrl(String keyword) {
  final dest = Uri.encodeComponent(
    'https://search.rakuten.co.jp/search/mall/${Uri.encodeComponent(keyword)}/',
  );
  return 'https://hb.afl.rakuten.co.jp/hgc/$_rakutenId/?pc=$dest';
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    debugPrint('URL を開けませんでした: $url');
  }
}

// ── メイン画面 ─────────────────────────────────────────
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedCategory = 'すべて';

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

  List<ShopProduct> get _filtered {
    if (_selectedCategory == 'すべて') return shopProducts;
    return shopProducts.where((p) => p.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ショップ'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.shopping_cart_outlined), text: '商品一覧'),
            Tab(icon: Icon(Icons.card_giftcard_outlined), text: 'おすすめキット'),
          ],
        ),
      ),
      body: Column(
        children: [
          // アフィリエイト表示バナー
          Container(
            width: double.infinity,
            color: const Color(0xFFFFFDE7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: const Text(
              '※ リンクにはAmazon・楽天のアフィリエイトリンクを含みます。'
              '購入により収益が発生する場合があります。',
              style: TextStyle(fontSize: 11, color: Color(0xFF5D4037)),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProductsView(
                  products: _filtered,
                  selectedCategory: _selectedCategory,
                  onCategoryChanged: (cat) =>
                      setState(() => _selectedCategory = cat),
                  colorScheme: colorScheme,
                ),
                _KitsView(colorScheme: colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 商品一覧ビュー ──────────────────────────────────────
class _ProductsView extends StatelessWidget {
  const _ProductsView({
    required this.products,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.colorScheme,
  });

  final List<ShopProduct> products;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // カテゴリフィルタ
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: shopCategories.map((cat) {
                  final active = cat == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: active,
                      onSelected: (_) => onCategoryChanged(cat),
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: active ? Colors.white : null,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // 商品グリッド
        if (products.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔍', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('該当する商品がありません',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(product: products[index]),
                childCount: products.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                mainAxisExtent: 260,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
      ],
    );
  }
}

// ── 商品カード ─────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // サムネイル
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            color: const Color(0xFFE8F5E9),
            child: Text(
              product.emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 48),
            ),
          ),
          // カード本文
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // カテゴリバッジ
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.desc,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B6B6B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  if (product.season.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '🗓 ${product.season}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFFF57F17)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // ショップボタン
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: _ShopButton(
                    label: 'Amazon',
                    color: const Color(0xFFFF9900),
                    textColor: Colors.black87,
                    onTap: () => _launch(_amazonUrl(product.keyword)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ShopButton(
                    label: '楽天',
                    color: const Color(0xFFBF0000),
                    textColor: Colors.white,
                    onTap: () => _launch(_rakutenUrl(product.keyword)),
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

// ── ショップボタン（汎用）────────────────────────────────
class _ShopButton extends StatelessWidget {
  const _ShopButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── おすすめキットビュー ─────────────────────────────────
class _KitsView extends StatelessWidget {
  const _KitsView({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: shopKits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _KitCard(kit: shopKits[index]),
    );
  }
}

// ── キットカード ───────────────────────────────────────
class _KitCard extends StatelessWidget {
  const _KitCard({required this.kit});
  final ShopKit kit;

  Color get _levelColor {
    switch (kit.level) {
      case '初心者向け':
        return const Color(0xFF2E7D32);
      case '中級者向け':
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFF6B6B6B);
    }
  }

  Color get _levelBg {
    switch (kit.level) {
      case '初心者向け':
        return const Color(0xFFE8F5E9);
      case '中級者向け':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // キットヘッダー
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kit.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kit.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          _Badge(
                            label: kit.level,
                            color: _levelColor,
                            bg: _levelBg,
                          ),
                          _Badge(
                            label: kit.season,
                            color: const Color(0xFFBF6000),
                            bg: const Color(0xFFFFF9C4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              kit.tagline,
              style:
                  const TextStyle(fontSize: 12.5, color: Color(0xFF6B6B6B)),
            ),
          ),

          const Divider(height: 1),

          // アイテムリスト
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              children: kit.items.map((item) => _KitItemRow(item: item)).toList(),
            ),
          ),

          const Divider(height: 1),

          // チップコメント
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFFF57F17),
                    width: 3,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                kit.tip,
                style: const TextStyle(
                    fontSize: 11.5, color: Color(0xFF5D4037)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── キット内アイテム行 ─────────────────────────────────
class _KitItemRow extends StatelessWidget {
  const _KitItemRow({required this.item});
  final ShopKitItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          _MiniButton(
            label: 'Amazon',
            color: const Color(0xFFFF9900),
            textColor: Colors.black87,
            onTap: () => _launch(_amazonUrl(item.keyword)),
          ),
          const SizedBox(width: 5),
          _MiniButton(
            label: '楽天',
            color: const Color(0xFFBF0000),
            textColor: Colors.white,
            onTap: () => _launch(_rakutenUrl(item.keyword)),
          ),
        ],
      ),
    );
  }
}

// ── ミニボタン ─────────────────────────────────────────
class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── バッジ ────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
