import 'dart:async';
import 'package:flutter/material.dart';
import '../models/my_plant.dart';
import '../models/plant_month_memo.dart';
import '../services/storage_service.dart';

class AnnualPlanScreen extends StatefulWidget {
  final MyPlant plant;

  const AnnualPlanScreen({super.key, required this.plant});

  @override
  State<AnnualPlanScreen> createState() => _AnnualPlanScreenState();
}

class _AnnualPlanScreenState extends State<AnnualPlanScreen> {
  final _storage = StorageService();
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, Timer?> _debounceTimers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (int m = 1; m <= 12; m++) {
      _controllers[m] = TextEditingController();
      _debounceTimers[m] = null;
    }
    _load();
  }

  Future<void> _load() async {
    final memos = await _storage.getMonthMemos();
    final plantMemos =
        memos.where((m) => m.myPlantId == widget.plant.id).toList();
    for (final memo in plantMemos) {
      _controllers[memo.month]?.text = memo.memo;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onChanged(int month, String value) {
    _debounceTimers[month]?.cancel();
    _debounceTimers[month] = Timer(const Duration(milliseconds: 500), () {
      _storage.saveMonthMemo(PlantMonthMemo(
        myPlantId: widget.plant.id,
        month: month,
        memo: value,
      ));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final t in _debounceTimers.values) {
      t?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('年間計画',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 植物ヘッダー
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primaryContainer, cs.secondaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(widget.plant.vegetableEmoji,
                          style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.plant.vegetableName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '月ごとの作業メモを記録',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 月ごとカード
                ...List.generate(12, (i) {
                  final month = i + 1;
                  final isCurrentMonth = month == now.month;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isCurrentMonth
                          ? cs.primaryContainer.withValues(alpha: 0.4)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCurrentMonth
                            ? cs.primary.withValues(alpha: 0.5)
                            : cs.outlineVariant.withValues(alpha: 0.4),
                        width: isCurrentMonth ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$month月',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentMonth
                                      ? cs.primary
                                      : cs.onSurface,
                                ),
                              ),
                              if (isCurrentMonth) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '今月',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controllers[month],
                            maxLines: 3,
                            onChanged: (v) => _onChanged(month, v),
                            decoration: InputDecoration(
                              hintText: '作業内容、目標、メモ...',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
