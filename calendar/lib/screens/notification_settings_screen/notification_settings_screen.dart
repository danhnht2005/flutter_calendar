import 'package:calender/helpers/token.dart';
import 'package:calender/models/notification_settings_model.dart';
import 'package:calender/services/notification_settings_service.dart';
import 'package:calender/widget/back_home/back_home.dart';
import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettingsModel? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  static const List<Map<String, dynamic>> _reminderOptions = [
    {'label': '5 phút', 'value': 5},
    {'label': '10 phút', 'value': 10},
    {'label': '15 phút', 'value': 15},
    {'label': '30 phút', 'value': 30},
    {'label': '1 giờ', 'value': 60},
    {'label': '2 giờ', 'value': 120},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = await Token.getId() ?? 'default';
    final settings = await NotificationSettingsService.getSettings(userId);
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (_settings == null) return;
    setState(() => _isSaving = true);
    await NotificationSettingsService.saveSettings(_settings!);
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu cài đặt'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart
        ? _settings!.quietHoursStart
        : _settings!.quietHoursEnd;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _settings = isStart
            ? _settings!.copyWith(quietHoursStart: formatted)
            : _settings!.copyWith(quietHoursEnd: formatted);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8F8),
        leading: const BackHome(),
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF04842),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'Lưu',
                style: TextStyle(
                  color: Color(0xFFF04842),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF04842)),
            )
          : ListView(
              children: [
                // --- Bật thông báo ---
                _buildSection(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: const Color(0xFFF04842),
                      title: 'Bật thông báo',
                      subtitle: 'Nhận thông báo về sự kiện sắp tới',
                      value: _settings!.enableNotifications,
                      onChanged: (v) => setState(
                        () => _settings =
                            _settings!.copyWith(enableNotifications: v),
                      ),
                    ),
                  ],
                ),

                // --- Nhắc trước ---
                if (_settings!.enableNotifications) ...[
                  _buildSectionLabel('Thời gian nhắc'),
                  _buildSection(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF42A5F5).withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.alarm_outlined,
                                color: Color(0xFF42A5F5),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Nhắc trước',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            DropdownButton<int>(
                              value: _settings!.reminderMinutes,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                color: Color(0xFFF04842),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              items: _reminderOptions
                                  .map(
                                    (o) => DropdownMenuItem<int>(
                                      value: o['value'] as int,
                                      child: Text(o['label'] as String),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(
                                () => _settings = _settings!.copyWith(
                                  reminderMinutes: v,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // --- Âm thanh & Rung ---
                  _buildSectionLabel('Kiểu thông báo'),
                  _buildSection(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.volume_up_outlined,
                        iconColor: const Color(0xFF66BB6A),
                        title: 'Âm thanh',
                        value: _settings!.enableSound,
                        onChanged: (v) => setState(
                          () => _settings = _settings!.copyWith(enableSound: v),
                        ),
                      ),
                      const Divider(height: 1, indent: 64),
                      _buildSwitchTile(
                        icon: Icons.vibration_outlined,
                        iconColor: const Color(0xFFAB47BC),
                        title: 'Rung',
                        value: _settings!.enableVibration,
                        onChanged: (v) => setState(
                          () =>
                              _settings = _settings!.copyWith(enableVibration: v),
                        ),
                      ),
                    ],
                  ),

                  // --- Giờ yên tĩnh ---
                  _buildSectionLabel('Giờ yên tĩnh'),
                  _buildSection(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.bedtime_outlined,
                        iconColor: const Color(0xFF5C6BC0),
                        title: 'Bật giờ yên tĩnh',
                        subtitle: 'Tắt thông báo trong khung giờ nhất định',
                        value: _settings!.enableQuietHours,
                        onChanged: (v) => setState(
                          () => _settings =
                              _settings!.copyWith(enableQuietHours: v),
                        ),
                      ),
                      if (_settings!.enableQuietHours) ...[
                        const Divider(height: 1, indent: 64),
                        _buildTimeTile(
                          title: 'Bắt đầu',
                          time: _settings!.quietHoursStart,
                          onTap: () => _pickTime(isStart: true),
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildTimeTile(
                          title: 'Kết thúc',
                          time: _settings!.quietHoursEnd,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFF04842),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15)),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFF04842),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}
