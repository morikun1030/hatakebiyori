import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/vegetables_data.dart';
import '../models/my_plant.dart';
import '../models/vegetable.dart';
import '../services/storage_service.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _storage = StorageService();
  final _noteController = TextEditingController();
  final _quantityController = TextEditingController();
  final _customLocationController = TextEditingController();

  Vegetable? _selectedVegetable;
  DateTime _startDate = DateTime.now();
  String _plantType = '種まき';
  String _location = 'プランター';
  bool _isCustomLocation = false;

  static const _plantTypes = ['種まき', '定植', '苗購入'];
  static const _locationPresets = ['プランター', '花壇', '畑', '鉢', '地植え'];

  @override
  void dispose() {
    _noteController.dispose();
    _quantityController.dispose();
    _customLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ畑に追加',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 野菜選択 ──
          _SectionLabel('野菜'),
          const SizedBox(height: 8),
          _VegetablePicker(
              selected: _selectedVegetable, onTap: _showVegetablePicker),
          const SizedBox(height: 20),

          // ── 栽培方法 ──
          _SectionLabel('栽培方法'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _plantTypes.map((type) {
              final isSelected = _plantType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (_) => setState(() => _plantType = type),
                selectedColor: cs.primaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── 開始日 ──
          _SectionLabel('開始日'),
          const SizedBox(height: 8),
          _DatePicker(date: _startDate, onTap: _pickDate),
          const SizedBox(height: 20),

          // ── 場所 ──
          _SectionLabel('場所'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ..._locationPresets.map((loc) {
                final isSelected = !_isCustomLocation && _location == loc;
                return ChoiceChip(
                  label: Text(loc),
                  selected: isSelected,
                  onSelected: (_) => setState(() {
                    _location = loc;
                    _isCustomLocation = false;
                  }),
                  selectedColor: cs.primaryContainer,
                );
              }),
              ChoiceChip(
                label: const Text('その他'),
                selected: _isCustomLocation,
                onSelected: (_) => setState(() {
                  _isCustomLocation = true;
                  _location = _customLocationController.text;
                }),
                selectedColor: cs.primaryContainer,
              ),
            ],
          ),
          if (_isCustomLocation) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _customLocationController,
              decoration: InputDecoration(
                hintText: '場所を入力（例: 北側ベランダ）',
                prefixIcon:
                    const Icon(Icons.edit_location_outlined, color: Colors.teal),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (v) => setState(() => _location = v),
            ),
          ],
          const SizedBox(height: 20),

          // ── 株数（任意）──
          _SectionLabel('株数（任意）'),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '例: 3',
              prefixIcon:
                  const Icon(Icons.format_list_numbered, color: Colors.orange),
              suffixText: '株',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),

          // ── メモ（任意）──
          _SectionLabel('メモ（任意）'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '品種、購入先、気づいたことなど...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 32),

          // ── 保存ボタン ──
          FilledButton.icon(
            onPressed: _selectedVegetable == null ? null : _save,
            icon: const Icon(Icons.add),
            label:
                const Text('マイ畑に追加する', style: TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showVegetablePicker() {
    String pickerSearch = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = pickerSearch.isEmpty
              ? VegetablesData.all
              : VegetablesData.all
                  .where((v) => v.name.contains(pickerSearch))
                  .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.92,
            minChildSize: 0.45,
            expand: false,
            builder: (ctx, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('野菜を選択',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '名前で検索...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                    ),
                    onChanged: (q) =>
                        setModalState(() => pickerSearch = q),
                  ),
                ),
                const SizedBox(height: 4),
                Divider(color: Colors.grey.shade200),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text('見つかりません',
                              style:
                                  TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (ctx, index) {
                            final v = filtered[index];
                            return ListTile(
                              leading: Text(v.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              title: Text(v.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  '${v.category}  ·  ${v.difficulty}'),
                              onTap: () {
                                setState(() => _selectedVegetable = v);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _save() async {
    // 登録上限チェック
    final existing = await _storage.getPlants();
    if (existing.length >= 20) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録できるのは最大20件までです'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final qText = _quantityController.text.trim();
    final loc =
        _isCustomLocation ? _customLocationController.text.trim() : _location;
    final plant = MyPlant(
      id: MyPlant.generateId(),
      vegetableId: _selectedVegetable!.id,
      vegetableName: _selectedVegetable!.name,
      vegetableEmoji: _selectedVegetable!.emoji,
      startDate: _startDate,
      plantType: _plantType,
      status: PlantStatus.sowed,
      location: loc.isEmpty ? 'プランター' : loc,
      quantity: qText.isNotEmpty ? int.tryParse(qText) : null,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    await _storage.savePlant(plant);
    if (mounted) Navigator.pop(context, true);
  }
}

// ── サブウィジェット ──────────────────────────────────────

class _VegetablePicker extends StatelessWidget {
  final Vegetable? selected;
  final VoidCallback onTap;

  const _VegetablePicker({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected == null
                ? Colors.grey.shade300
                : cs.primary.withValues(alpha: 0.5),
            width: selected == null ? 1 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selected == null
              ? null
              : cs.primaryContainer.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Text(selected?.emoji ?? '🌱',
                style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected?.name ?? '野菜をタップして選択',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: selected != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      selected == null ? Colors.grey.shade500 : null,
                ),
              ),
            ),
            Icon(Icons.expand_more,
                color: selected == null
                    ? Colors.grey.shade400
                    : cs.primary),
          ],
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DatePicker({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: cs.primary, size: 22),
            const SizedBox(width: 12),
            Text(
              '${date.year}年${date.month}月${date.day}日',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade600,
        letterSpacing: 0.3,
      ),
    );
  }
}
