import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/regions_data.dart';
import '../models/region.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../utils/download_util.dart';
import 'help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Region _selectedRegion = SettingsService.regionNotifier.value;

  // ─── アカウント：サインアウト ─────────────────────────────────────

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('サインアウト'),
        content: const Text('サインアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('サインアウト'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.signOut();
  }

  // ─── エクスポート ────────────────────────────────────────────────

  Future<void> _export() async {
    try {
      final data = await StorageService().exportData();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      downloadJson(jsonStr, 'hatakebiyori_backup_$dateStr.json');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('バックアップファイルをダウンロードしました'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エクスポートに失敗しました: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ─── インポート ──────────────────────────────────────────────────

  Future<void> _import() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;

      final jsonStr = utf8.decode(result.files.single.bytes!);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('データをインポート'),
          content: const Text(
            '現在のデータはすべて上書きされます。\nよろしいですか？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('上書きインポート'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      await StorageService().importData(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データをインポートしました'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('インポートに失敗しました: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── ヘルプセクション ────────────────────────────────────
          _SectionHeader(icon: Icons.help_outline, label: 'ヘルプ'),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('使い方・よくある質問'),
              subtitle: const Text('操作方法や機能の説明を確認'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── アカウントセクション ────────────────────────────────
          _SectionHeader(icon: Icons.account_circle_outlined, label: 'アカウント'),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (user != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          backgroundColor: cs.primaryContainer,
                          child: user.photoURL == null
                              ? Icon(Icons.person, color: cs.primary)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? '名前なし',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('サインアウト'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── バックアップセクション ──────────────────────────────
          _SectionHeader(icon: Icons.backup_outlined, label: 'バックアップ'),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '栽培データをJSONファイルとしてバックアップしたり、以前のバックアップから復元できます。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _export,
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: const Text('エクスポート'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.primary,
                            side: BorderSide(color: cs.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _import,
                          icon: const Icon(Icons.upload_outlined, size: 18),
                          label: const Text('インポート'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            side: BorderSide(color: Colors.orange.shade700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── 地域設定セクション ──────────────────────────────────
          _SectionHeader(icon: Icons.location_on, label: '栽培地域'),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '地域を選択すると、種まき・定植・収穫の目安時期がその地域の気候に合わせて補正されます。',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '※ データは関東地方を基準にしています',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 地域リスト
          ...RegionsData.all.map((region) {
            final isSelected = region.id == _selectedRegion.id;
            return _RegionTile(
              region: region,
              isSelected: isSelected,
              onTap: () async {
                setState(() => _selectedRegion = region);
                await SettingsService.setRegion(region);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${region.emoji} ${region.name} に設定しました'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            );
          }),

          const SizedBox(height: 24),

          // オフセット説明
          _SectionHeader(icon: Icons.info_outline, label: '補正の目安'),
          const SizedBox(height: 4),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: RegionsData.all.map((r) {
                  final offsetText = r.offset == 0
                      ? '基準（補正なし）'
                      : r.offset > 0
                          ? '約${r.offset}ヶ月遅め'
                          : '約${r.offset.abs()}ヶ月早め';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(r.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(r.name,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: r.offset == 0
                                ? Colors.grey.shade100
                                : r.offset > 0
                                    ? Colors.blue.shade50
                                    : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            offsetText,
                            style: TextStyle(
                              fontSize: 11,
                              color: r.offset == 0
                                  ? Colors.grey.shade600
                                  : r.offset > 0
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

class _RegionTile extends StatelessWidget {
  final Region region;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegionTile({
    required this.region,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide(color: Colors.grey.shade200),
      ),
      color: isSelected ? cs.primaryContainer.withValues(alpha: 0.5) : null,
      child: ListTile(
        leading: Text(region.emoji, style: const TextStyle(fontSize: 28)),
        title: Text(
          region.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(region.description,
            style: const TextStyle(fontSize: 12)),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: cs.primary)
            : const Icon(Icons.radio_button_unchecked,
                color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
