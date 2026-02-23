import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  static const _guideShownKey = 'guide_shown';

  /// 初回起動時に自動表示するかチェックし、未表示なら表示する
  static Future<void> showIfFirstLaunch(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_guideShownKey) ?? false;
    if (!shown) {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GuideScreen()),
        );
      }
      await prefs.setBool(_guideShownKey, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('はじめてのガイド',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: ListView(
        children: [
          // ── ヒーローバナー ──
          _HeroBanner(),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── はじめ方 3ステップ ──
                _SectionTitle('はじめ方 3ステップ'),
                const SizedBox(height: 12),
                const _StepCard(
                  number: 1,
                  emoji: '🌱',
                  title: 'マイ畑に野菜を登録する',
                  description: '育てたい・育てている野菜を「マイ畑」タブから登録しましょう。'
                      '種まきや定植の日付、場所、株数を記録できます。',
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                const _StepCard(
                  number: 2,
                  emoji: '☀️',
                  title: '今日のダッシュボードで確認する',
                  description: '「今日」タブでは登録した野菜の状況や今日すべき作業が一目でわかります。'
                      '収穫時期や種まき適期もお知らせします。',
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                const _StepCard(
                  number: 3,
                  emoji: '📔',
                  title: '日誌に記録して来年に活かす',
                  description: '水やり・収穫量・病害虫の発生など、気づいたことを日誌に残しましょう。'
                      '写真付きで記録することで来年の参考になります。',
                  color: Colors.blue,
                ),
                const SizedBox(height: 28),

                // ── 機能紹介 ──
                _SectionTitle('機能紹介'),
                const SizedBox(height: 12),
                _FeatureGrid(),
                const SizedBox(height: 28),

                // ── 家庭菜園のコツ ──
                _SectionTitle('家庭菜園のコツ'),
                const SizedBox(height: 12),
                const _TipCard(
                  emoji: '💧',
                  title: '水やりは朝のうちに',
                  description: '夕方や夜の水やりは病気の原因になりやすいです。'
                      '朝に土の表面が乾いていたらたっぷり与えましょう。',
                ),
                const _TipCard(
                  emoji: '🌿',
                  title: '肥料は少量・定期的に',
                  description: '一度に大量に与えると肥料焼けの原因に。'
                      '「追肥」として定期的に少量ずつ補給するのがコツです。',
                ),
                const _TipCard(
                  emoji: '🔄',
                  title: '連作を避ける',
                  description: '同じ場所に同じ野菜（同じ科）を続けて育てると病気が出やすくなります。'
                      '毎年場所をローテーションしましょう。',
                ),
                const _TipCard(
                  emoji: '🔍',
                  title: '早期発見・早期対処',
                  description: '病気や害虫は初期の小さなうちに対処するのが鉄則。'
                      '毎日少し観察する習慣をつけましょう。',
                ),
                const _TipCard(
                  emoji: '📝',
                  title: '記録することで上達する',
                  description: '成功も失敗も記録しておくことで次の年に活かせます。'
                      '写真と一言メモで十分です。',
                ),
                const SizedBox(height: 28),

                // ── フッターボタン ──
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('ガイドを閉じる', style: TextStyle(fontSize: 16)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ヒーローバナー ────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌻', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 8),
          Text(
            '家庭菜園を、もっと楽しく。',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AgriApp で栽培を記録・管理しよう',
            style: TextStyle(
              fontSize: 13,
              color: cs.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ── セクションタイトル ────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: cs.onSurface,
      ),
    );
  }
}

// ── ステップカード ────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final int number;
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _StepCard({
    required this.number,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
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

// ── 機能紹介グリッド ─────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  static const _features = [
    ('📅', 'カレンダー', '月ごとの種まき・収穫時期を確認'),
    ('🌿', 'マイ畑', '育てている野菜を管理・記録'),
    ('📚', '野菜図鑑', '野菜の栽培情報を調べる'),
    ('📔', '日誌', '作業内容や気づきを記録'),
    ('🤝', 'コンパニオン', '相性の良い野菜の組み合わせ'),
    ('🐛', '病害虫チェック', '症状から原因を特定する'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: _features.map((f) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(f.$2,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(f.$3,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── ヒントカード ─────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _TipCard({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
