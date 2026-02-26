import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../data/vegetables_data.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../models/vegetable.dart';
import '../services/storage_service.dart';
import '../widgets/vegetable_avatar.dart';

class AddRecordScreen extends StatefulWidget {
  /// マイ畑の植物から呼び出す場合に渡す（野菜を固定してリンクする）
  final MyPlant? initialPlant;

  /// クイックアクションから作業種類を指定する場合に渡す
  final String? initialWorkType;

  const AddRecordScreen({super.key, this.initialPlant, this.initialWorkType});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _storage = StorageService();
  final _noteController = TextEditingController();
  final _harvestAmountController = TextEditingController();
  final _costController = TextEditingController();
  final _picker = ImagePicker();

  Vegetable? _selectedVegetable;
  DateTime _selectedDate = DateTime.now();
  String _workType = '種まき';
  String? _imageBase64;
  String? _myPlantId; // マイ畑リンク用
  bool _hasTime = false;
  TimeOfDay? _selectedTime;

  bool get _isLinkedToPlant => widget.initialPlant != null;

  @override
  void initState() {
    super.initState();
    final plant = widget.initialPlant;
    if (plant != null) {
      _myPlantId = plant.id;
      // 対応する野菜をマスターから検索
      final match = VegetablesData.all.where(
        (v) => v.id == plant.vegetableId,
      );
      if (match.isNotEmpty) _selectedVegetable = match.first;
      // ステータスに応じた作業種類の初期値
      _workType = switch (plant.status) {
        PlantStatus.sowed => '水やり',
        PlantStatus.sprouted => '水やり',
        PlantStatus.growing => '施肥',
        PlantStatus.harvesting => '収穫',
        PlantStatus.finished => 'メモ',
      };
    }
    // クイックアクションからの作業種類指定（ステータスデフォルトより優先）
    if (widget.initialWorkType != null) _workType = widget.initialWorkType!;
  }

  static const _workTypes = [
    ('種まき', Icons.grass, Colors.orange),
    ('定植', Icons.local_florist, Colors.blue),
    ('収穫', Icons.shopping_basket, Colors.green),
    ('水やり', Icons.water_drop, Colors.lightBlue),
    ('施肥', Icons.science, Colors.brown),
    ('剪定', Icons.content_cut, Colors.purple),
    ('防虫', Icons.pest_control, Colors.red),
    ('メモ', Icons.edit_note, Colors.grey),
  ];

  bool get _isHarvest => _workType == '収穫';

  @override
  void dispose() {
    _noteController.dispose();
    _harvestAmountController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('記録を追加',
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
            selected: _selectedVegetable,
            onTap: _isLinkedToPlant ? null : _showVegetablePicker,
            linkedPlantLocation: widget.initialPlant?.location,
          ),
          const SizedBox(height: 20),

          // ── 日付 ──
          _SectionLabel('日付'),
          const SizedBox(height: 8),
          _DatePicker(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: 8),
          // ── 時刻（任意） ──
          SwitchListTile(
            title: const Text('時刻を記録する',
                style: TextStyle(fontSize: 14)),
            value: _hasTime,
            onChanged: (v) => setState(() {
              _hasTime = v;
              if (v && _selectedTime == null) {
                _selectedTime = TimeOfDay.now();
              }
            }),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _hasTime
                ? Column(
                    children: [
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  size: 22),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTime != null
                                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                    : '--:--',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right,
                                  color: Colors.grey.shade400, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),

          // ── 作業種類 ──
          _SectionLabel('作業の種類'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _workTypes.map((t) {
              final (label, icon, color) = t;
              final isSelected = _workType == label;
              return GestureDetector(
                onTap: () => setState(() => _workType = label),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.shade600.withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? color.shade600
                          : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon,
                          size: 16,
                          color: isSelected
                              ? color.shade700
                              : Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? color.shade700
                                : Colors.grey.shade700,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── 収穫量（収穫時のみ） ──
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: _isHarvest
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('収穫量'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _harvestAmountController,
                        decoration: InputDecoration(
                          hintText: '例: 500g、3個、1束',
                          prefixIcon: const Icon(
                              Icons.shopping_basket_outlined,
                              color: Colors.green),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // ── 費用 ──
          _SectionLabel('費用（任意）'),
          const SizedBox(height: 8),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '例: 200（苗代・肥料代など）',
              prefixIcon: const Icon(Icons.payments_outlined,
                  color: Colors.teal),
              suffixText: '円',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 20),

          // ── 写真 ──
          _SectionLabel('写真（任意）'),
          const SizedBox(height: 8),
          _PhotoPicker(
            imageBase64: _imageBase64,
            onPickImage: _pickImage,
            onRemove: () => setState(() => _imageBase64 = null),
          ),
          const SizedBox(height: 20),

          // ── メモ ──
          _SectionLabel('メモ（任意）'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '気づいたこと、状態、天気など...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 32),

          // ── 保存ボタン ──
          FilledButton.icon(
            onPressed: _selectedVegetable == null ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('保存する', style: TextStyle(fontSize: 16)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 写真選択 ──────────────────────────────────────────

  Future<void> _pickImage() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 72,
      );
      if (xFile == null) return;
      final bytes = await xFile.readAsBytes();
      setState(() => _imageBase64 = base64Encode(bytes));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('写真の読み込みに失敗しました: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
              title: const Text('カメラで撮影'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.photo_library)),
              title: const Text('ギャラリーから選択'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── 野菜ピッカー ──────────────────────────────────────

  void _showVegetablePicker() {
    String pickerSearch = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
            builder: (context, scrollController) => Column(
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
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
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
                              style: TextStyle(
                                  color: Colors.grey.shade500)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final v = filtered[index];
                            return ListTile(
                              leading: VegetableAvatar(
                                vegetableId: v.id,
                                vegetableName: v.name,
                                size: 40,
                              ),
                              title: Text(v.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  '${v.category}  ·  ${v.difficulty}'),
                              onTap: () {
                                setState(
                                    () => _selectedVegetable = v);
                                Navigator.pop(context);
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
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _save() async {
    final costText = _costController.text.trim();
    final DateTime saveDate;
    if (_hasTime && _selectedTime != null) {
      saveDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    } else {
      saveDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day);
    }
    final record = CultivationRecord(
      id: const Uuid().v4(),
      vegetableId: _selectedVegetable!.id,
      vegetableName: _selectedVegetable!.name,
      date: saveDate,
      workType: _workType,
      note: _noteController.text.trim(),
      harvestAmount: _isHarvest && _harvestAmountController.text.isNotEmpty
          ? _harvestAmountController.text.trim()
          : null,
      cost: costText.isNotEmpty ? int.tryParse(costText) : null,
      imageBase64: _imageBase64,
      myPlantId: _myPlantId,
    );
    await _storage.saveRecord(record);
    if (mounted) Navigator.pop(context, true);
  }
}

// ── サブウィジェット ──────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  final String? imageBase64;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  const _PhotoPicker({
    required this.imageBase64,
    required this.onPickImage,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBase64 == null) {
      return OutlinedButton.icon(
        onPressed: onPickImage,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('写真を追加'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            base64Decode(imageBase64!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // 撮り直しボタン
        Positioned(
          bottom: 8,
          left: 8,
          child: FilledButton.tonalIcon(
            onPressed: onPickImage,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('変更', style: TextStyle(fontSize: 13)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
            ),
          ),
        ),
        // 削除ボタン
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(32, 32),
            ),
          ),
        ),
      ],
    );
  }
}

class _VegetablePicker extends StatelessWidget {
  final Vegetable? selected;
  final VoidCallback? onTap;
  final String? linkedPlantLocation;

  const _VegetablePicker({
    required this.selected,
    required this.onTap,
    this.linkedPlantLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLocked = onTap == null;
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
            selected != null
                ? VegetableAvatar(
                    vegetableId: selected!.id,
                    vegetableName: selected!.name,
                    size: 44,
                  )
                : const Text('🌱', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected?.name ?? '野菜をタップして選択',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selected != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selected == null ? Colors.grey.shade500 : null,
                    ),
                  ),
                  if (linkedPlantLocation != null)
                    Text(
                      '📍 $linkedPlantLocation',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
            if (isLocked)
              Icon(Icons.lock_outline,
                  size: 18, color: Colors.grey.shade400)
            else
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
