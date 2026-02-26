import 'package:flutter/material.dart';

/// 野菜ごとの代表カラーマップ
class VegetableColors {
  static const Color _fallback = Color(0xFF66BB6A);

  static const Map<String, Color> _map = {
    // ── 葉物野菜 ──────────────────────────────────
    'spinach':     Color(0xFF2E7D32), // ホウレンソウ  濃緑
    'komatsuna':   Color(0xFF43A047), // コマツナ      中緑
    'lettuce':     Color(0xFF7B8B2A), // レタス        黄緑
    'cabbage':     Color(0xFF558B2F), // キャベツ      オリーブ緑
    'hakusai':     Color(0xFF8D9B0A), // ハクサイ      黄緑
    'negi':        Color(0xFF004D40), // ネギ          最濃ティール
    'broccoli':    Color(0xFF33691E), // ブロッコリー  こもれび緑
    'mizuna':      Color(0xFF00796B), // 水菜          ティール
    'chingensai':  Color(0xFF00695C), // チンゲンサイ  深ティール
    'shungiku':    Color(0xFF00838F), // 春菊          水色ティール
    'arugula':     Color(0xFF827717), // ルッコラ      オリーブ
    'kale':        Color(0xFF37474F), // ケール        青灰緑
    // ── 根菜 ──────────────────────────────────────
    'daikon':      Color(0xFF546E7A), // ダイコン      青灰（白い根菜）
    'carrot':      Color(0xFFD84315), // ニンジン      深オレンジ
    'potato':      Color(0xFF6D4C41), // ジャガイモ    茶
    'sweet_potato':Color(0xFF6A1B9A), // サツマイモ    紫
    'turnip':      Color(0xFF78909C), // カブ          灰白
    'onion':       Color(0xFF4E342E), // タマネギ      褐色
    'radish':      Color(0xFFC62828), // ラディッシュ  赤
    'ginger':      Color(0xFFA16B10), // ショウガ      黄土
    'garlic':      Color(0xFF757575), // ニンニク      グレー
    'taro':        Color(0xFF5D4037), // サトイモ      深茶
    'burdock':     Color(0xFF4A3728), // ゴボウ        最深茶
    // ── 実野菜 ────────────────────────────────────
    'tomato':      Color(0xFFC62828), // トマト        赤
    'cherry_tomato':Color(0xFFE53935),// ミニトマト    明赤
    'cucumber':    Color(0xFF388E3C), // キュウリ      緑
    'eggplant':    Color(0xFF4A148C), // ナス          深紫
    'bell_pepper': Color(0xFF2D6A1F), // ピーマン      緑ピーマン
    'pumpkin':     Color(0xFFE65100), // カボチャ      深オレンジ
    'watermelon':  Color(0xFF880E4F), // スイカ        深ピンク
    'goya':        Color(0xFF1B5E20), // ゴーヤ        濃緑
    'corn':        Color(0xFFB8861B), // トウモロコシ  濃黄金
    'zucchini':    Color(0xFF558B2F), // ズッキーニ    緑
    'okra':        Color(0xFF2E5B1C), // オクラ        深緑
    'paprika':     Color(0xFFBF360C), // パプリカ      深赤橙
    'chili':       Color(0xFFB71C1C), // トウガラシ    深赤
    'melon':       Color(0xFF6B7A1A), // メロン        深オリーブ
    // ── 豆類 ──────────────────────────────────────
    'edamame':     Color(0xFF558B2F), // エダマメ      緑
    'green_bean':  Color(0xFF2E7D32), // インゲン      深緑
    'fava_bean':   Color(0xFF558B2F), // ソラマメ      緑
    'peas':        Color(0xFF43A047), // エンドウ      中緑
    'peanut':      Color(0xFF8D6E63), // ラッカセイ    落花生色
    // ── 果樹・果実 ────────────────────────────────
    'strawberry':  Color(0xFFAD1457), // イチゴ        ピンク赤
    'blueberry':   Color(0xFF283593), // ブルーベリー  深青
    'lemon':       Color(0xFFB8861B), // レモン        濃黄
    'fig':         Color(0xFF6A1B9A), // イチジク      紫
    'persimmon':   Color(0xFFD84315), // カキ          橙
    'ume':         Color(0xFF880E4F), // ウメ          深ピンク
    'grape':       Color(0xFF4A148C), // ブドウ        深紫
    'apple':       Color(0xFFC62828), // リンゴ        赤
    'yuzu':        Color(0xFFA16B10), // ユズ          黄橙
    'raspberry':   Color(0xFFE91E63), // ラズベリー    ピンク
    // ── ハーブ ────────────────────────────────────
    'shiso':       Color(0xFF880E4F), // シソ          紫赤（赤しそ）
    'basil':       Color(0xFF1B5E20), // バジル        濃緑
    'mint':        Color(0xFF00838F), // ミント        ティール
    'parsley':     Color(0xFF33691E), // パセリ        深緑
    'rosemary':    Color(0xFF546E7A), // ローズマリー  青灰
    'chive':       Color(0xFF2E7D32), // チャイブ      緑
    'cilantro':    Color(0xFF558B2F), // コリアンダー  緑
    'dill':        Color(0xFF827717), // ディル        オリーブ
    'thyme':       Color(0xFF6D4C41), // タイム        アース
  };

  static Color forId(String id) => _map[id] ?? _fallback;
}

/// 野菜の頭文字カラーアバター
class VegetableAvatar extends StatelessWidget {
  final String vegetableId;
  final String vegetableName;
  final double size;

  const VegetableAvatar({
    super.key,
    required this.vegetableId,
    required this.vegetableName,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final bg = VegetableColors.forId(vegetableId);
    final char = vegetableName.isNotEmpty ? vegetableName[0] : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: size >= 32
            ? [
                BoxShadow(
                  color: bg.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.46,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }
}
