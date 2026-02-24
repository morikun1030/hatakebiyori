import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';

class ShareUtil {
  // ─── テキスト生成 ────────────────────────────────────────

  static String buildPlantText(MyPlant plant) {
    final days = DateTime.now().difference(plant.startDate).inDays;
    final parts = <String>[
      '${plant.vegetableEmoji} ${plant.vegetableName}を育てています！',
      '📅 栽培$days日目 | ${plant.status.emoji} ${plant.status.label}',
      if (plant.location.isNotEmpty) '📍 ${plant.location}',
      if (plant.note != null && plant.note!.isNotEmpty) '✍️ ${plant.note}',
      '',
      '#家庭菜園 #家庭菜園ノート #${plant.vegetableName}',
    ];
    return parts.join('\n');
  }

  static String buildRecordText(CultivationRecord record) {
    final parts = <String>[
      '${record.vegetableName}の${record.workType}をしました！',
      if (record.harvestAmount != null) '🧺 収穫量: ${record.harvestAmount}',
      if (record.note.isNotEmpty) '✍️ ${record.note}',
      '',
      '#家庭菜園 #家庭菜園ノート #${record.vegetableName}',
    ];
    return parts.join('\n');
  }

  // ─── シェアシート表示 ────────────────────────────────────

  static Future<void> showShareSheet(BuildContext context, String text) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ShareSheet(text: text),
    );
  }

  // ─── アクション ──────────────────────────────────────────

  static Future<void> shareToX(String text) async {
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://twitter.com/intent/tweet?text=$encoded');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<void> copyToClipboard(
      BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('クリップボードにコピーしました'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// ─── シェアシートUI ──────────────────────────────────────────

class _ShareSheet extends StatelessWidget {
  final String text;

  const _ShareSheet({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ハンドル
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // タイトル
          Text(
            'SNSでシェア',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 12),

          // テキストプレビュー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),

          // X (Twitter) ボタン
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await ShareUtil.shareToX(text);
              },
              icon: const _XLogo(),
              label: const Text('X (Twitter) でポスト'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // コピーボタン（Instagram用）
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ShareUtil.copyToClipboard(context, text);
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('テキストをコピー（Instagram用）'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: const Color(0xFFE1306C).withValues(alpha: 0.6),
                ),
                foregroundColor: const Color(0xFFE1306C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// X のロゴ（シンプルな X 文字）
class _XLogo extends StatelessWidget {
  const _XLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'X',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'serif',
      ),
    );
  }
}
