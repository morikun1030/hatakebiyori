import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_screen.dart';

class GuideScreen extends StatefulWidget {
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
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      emoji: '🌻',
      title: 'ようこそ はたけびより へ',
      description:
          '家庭菜園の栽培を楽しく記録・管理できるアプリです。\nGoogleアカウントでログインするだけで、どのデバイスからでもクラウドに同期されたデータにアクセスできます。',
    ),
    _SlideData(
      emoji: '🌱',
      title: 'マイ畑に野菜を登録しよう',
      description:
          '「マイ畑」から育てたい野菜を追加しましょう。\n種まき・発芽・生育中・収穫中・終了の5つのステータスで成長段階を管理できます。',
    ),
    _SlideData(
      emoji: '📔',
      title: '日誌で作業を記録しよう',
      description:
          '水やり・施肥・収穫など日々の作業を「栽培日誌」に記録しましょう。\n写真付きで投稿でき、SNSへのシェアも簡単にできます。',
    ),
    _SlideData(
      emoji: '📅',
      title: 'カレンダーで栽培計画',
      description:
          '「カレンダー」では月ごとの種まき・定植・収穫の適期を一覧で確認できます。\n地域設定を変えると、あなたの地域に合わせた時期を表示します。',
    ),
    _SlideData(
      emoji: '📦',
      title: 'バックアップ＆シェア',
      description:
          'データはJSONファイルとしてエクスポート・インポートできます。\n日誌の記録はSNSでシェアして、菜園仲間と情報交換しましょう。',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'スキップ',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // スライドコンテンツ
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => _SlidePage(slide: _slides[i]),
            ),
          ),

          // ドットインジケーター
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? cs.primary
                        : cs.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // ボタン
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                if (isLast) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HelpScreen()),
                        );
                      },
                      icon: const Icon(Icons.help_outline, size: 18),
                      label: const Text('詳しい使い方を見る →'),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: cs.primary),
                        foregroundColor: cs.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'はじめる',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        '次へ',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── スライドページ ────────────────────────────────────────────────────────

class _SlideData {
  final String emoji;
  final String title;
  final String description;

  const _SlideData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class _SlidePage extends StatelessWidget {
  final _SlideData slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              slide.emoji,
              style: const TextStyle(fontSize: 60),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            slide.description,
            style: TextStyle(
              fontSize: 15,
              color: cs.onSurface.withValues(alpha: 0.75),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
