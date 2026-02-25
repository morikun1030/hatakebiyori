import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ・使い方',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _HelpSection(
            emoji: '🌱',
            title: 'マイ畑の使い方',
            items: [
              _HelpItem(
                question: '野菜を追加するには？',
                answer:
                    '「マイ畑」画面右下の「＋」ボタンをタップします。野菜名・種まき日・場所・株数を入力して保存してください。',
              ),
              _HelpItem(
                question: 'ステータスを変更するには？',
                answer:
                    '野菜カードをタップして詳細画面を開き、「ステータスを変更」から現在の状態（発芽・生育中・収穫中など）を選択します。',
              ),
              _HelpItem(
                question: '野菜を削除するには？',
                answer:
                    '野菜の詳細画面を開き、右上メニュー（⋮）から「削除」を選択します。削除したデータは元に戻せません。',
              ),
            ],
          ),
          SizedBox(height: 8),
          _HelpSection(
            emoji: '📔',
            title: '栽培日誌の使い方',
            items: [
              _HelpItem(
                question: '日誌を記録するには？',
                answer:
                    '「栽培日誌」タブを開き、右下の「＋」ボタンをタップします。作業内容・対象の野菜・メモを入力して保存します。',
              ),
              _HelpItem(
                question: '写真を添付するには？',
                answer:
                    '記録画面の「写真を追加」ボタンからカメラ撮影またはギャラリーから選択できます。',
              ),
              _HelpItem(
                question: 'SNSにシェアするには？',
                answer:
                    '日誌の記録詳細画面を開き、右上の共有ボタン（↑）をタップします。X（Twitter）などにシェアできます。',
              ),
            ],
          ),
          SizedBox(height: 8),
          _HelpSection(
            emoji: '📅',
            title: 'カレンダーの使い方',
            items: [
              _HelpItem(
                question: 'カレンダーには何が表示されますか？',
                answer:
                    '各月の種まき・定植・収穫の適期を野菜ごとに確認できます。あなたが登録した野菜は色付きで強調表示されます。',
              ),
              _HelpItem(
                question: '地域によって時期が変わりますか？',
                answer:
                    'はい。「設定」→「栽培地域」で地域を選択すると、その地域の気候に合わせた時期に自動補正されます。',
              ),
            ],
          ),
          SizedBox(height: 8),
          _HelpSection(
            emoji: '📤',
            title: 'SNSシェアの方法',
            items: [
              _HelpItem(
                question: 'どこからシェアできますか？',
                answer:
                    '栽培日誌の記録詳細画面から共有ボタンをタップしてください。テキストと画像をまとめてシェアできます。',
              ),
              _HelpItem(
                question: 'シェアする内容をカスタマイズできますか？',
                answer:
                    'シェア画面でテキストを編集してから投稿できます。ハッシュタグは自動で付与されます。',
              ),
            ],
          ),
          SizedBox(height: 8),
          _HelpSection(
            emoji: '💾',
            title: 'エクスポート・インポート',
            items: [
              _HelpItem(
                question: 'データをバックアップするには？',
                answer:
                    '「設定」→「バックアップ」→「エクスポート」をタップするとJSONファイルがダウンロードされます。大切な場所に保存してください。',
              ),
              _HelpItem(
                question: '別のデバイスにデータを移すには？',
                answer:
                    'エクスポートしたJSONファイルを新しいデバイスに転送し、「設定」→「バックアップ」→「インポート」からファイルを選択します。',
              ),
              _HelpItem(
                question: 'インポートすると既存データはどうなりますか？',
                answer:
                    '現在のデータは上書きされます。インポート前に必ずエクスポートでバックアップを取っておいてください。',
              ),
            ],
          ),
          SizedBox(height: 8),
          _HelpSection(
            emoji: '👤',
            title: 'アカウント・サインアウト',
            items: [
              _HelpItem(
                question: 'サインアウトするには？',
                answer:
                    '「設定」→「アカウント」→「サインアウト」ボタンをタップします。サインアウトしてもクラウドのデータは保持されます。',
              ),
              _HelpItem(
                question: '別のGoogleアカウントに切り替えるには？',
                answer:
                    '一度サインアウトしてから、ログイン画面で別のGoogleアカウントでサインインしてください。',
              ),
              _HelpItem(
                question: 'データはどこに保存されますか？',
                answer:
                    'データはGoogle Firebaseのクラウドデータベースに安全に保存されます。ログインしているGoogleアカウントに紐づいています。',
              ),
            ],
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── ヘルプセクション ──────────────────────────────────────────────────────

class _HelpSection extends StatelessWidget {
  final String emoji;
  final String title;
  final List<_HelpItem> items;

  const _HelpSection({
    required this.emoji,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 24)),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconColor: cs.primary,
          collapsedIconColor: cs.onSurface.withValues(alpha: 0.5),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          children: items.map((item) => _HelpItemTile(item: item)).toList(),
        ),
      ),
    );
  }
}

class _HelpItem {
  final String question;
  final String answer;

  const _HelpItem({required this.question, required this.answer});
}

class _HelpItemTile extends StatelessWidget {
  final _HelpItem item;

  const _HelpItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.help_outline, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.question,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              item.answer,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
