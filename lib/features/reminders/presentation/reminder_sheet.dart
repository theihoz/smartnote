import 'package:flutter/material.dart';

import '../../notes/domain/note.dart';
import '../../../l10n/feature_text.dart';
import '../data/local_notification_scheduler.dart';
import '../domain/note_reminder.dart';

class ReminderSheet extends StatefulWidget {
  const ReminderSheet({
    super.key,
    required this.note,
    required this.repository,
    required this.scheduler,
  });

  final Note note;
  final ReminderRepository? repository;
  final ReminderScheduler? scheduler;

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  late DateTime _scheduledAt;
  var _repeat = ReminderRepeatType.none;
  var _loading = true;
  var _saving = false;
  NoteReminder? _existing;

  @override
  void initState() {
    super.initState();
    _scheduledAt = DateTime.now().add(const Duration(hours: 1));
    _load();
  }

  Future<void> _load() async {
    final reminder = await widget.repository?.getByNoteId(widget.note.id);
    if (!mounted) return;
    setState(() {
      _existing = reminder;
      if (reminder != null) {
        _scheduledAt = reminder.scheduledAt.toLocal();
        _repeat = reminder.repeatType;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _loading
            ? const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    featureText(context, vi: 'Nhắc việc', en: 'Reminder'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_rounded),
                    title: Text(
                      featureText(
                        context,
                        vi: 'Ngày và giờ',
                        en: 'Date and time',
                      ),
                    ),
                    subtitle: Text(_formatDateTime(_scheduledAt)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDateTime,
                  ),
                  DropdownButtonFormField<ReminderRepeatType>(
                    initialValue: _repeat,
                    decoration: InputDecoration(
                      labelText: featureText(
                        context,
                        vi: 'Lặp lại',
                        en: 'Repeat',
                      ),
                      prefixIcon: const Icon(Icons.repeat_rounded),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ReminderRepeatType.none,
                        child: Text(
                          featureText(
                            context,
                            vi: 'Không lặp',
                            en: 'Does not repeat',
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ReminderRepeatType.daily,
                        child: Text(
                          featureText(context, vi: 'Hằng ngày', en: 'Daily'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ReminderRepeatType.weekly,
                        child: Text(
                          featureText(context, vi: 'Hằng tuần', en: 'Weekly'),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ReminderRepeatType.monthly,
                        child: Text(
                          featureText(context, vi: 'Hằng tháng', en: 'Monthly'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(
                      () => _repeat = value ?? ReminderRepeatType.none,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      if (_existing != null)
                        TextButton.icon(
                          onPressed: _saving ? null : _remove,
                          icon: const Icon(Icons.notifications_off_outlined),
                          label: Text(
                            featureText(
                              context,
                              vi: 'Xóa nhắc việc',
                              en: 'Remove reminder',
                            ),
                          ),
                        ),
                      const Spacer(),
                      FilledButton.icon(
                        key: const Key('save-reminder-button'),
                        onPressed: _saving || widget.repository == null
                            ? null
                            : _save,
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: Text(
                          _saving
                              ? featureText(
                                  context,
                                  vi: 'Đang lưu…',
                                  en: 'Saving…',
                                )
                              : featureText(
                                  context,
                                  vi: 'Lưu nhắc việc',
                                  en: 'Save reminder',
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            featureText(
              context,
              vi: 'Hãy chọn thời gian trong tương lai.',
              en: 'Choose a time in the future.',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final reminder = NoteReminder(
      noteId: widget.note.id,
      scheduledAt: _scheduledAt,
      timezone: _scheduledAt.timeZoneName,
      repeatType: _repeat,
    );
    try {
      await widget.repository!.save(reminder);
      await widget.scheduler?.schedule(
        reminder: reminder,
        title: widget.note.title,
        body: widget.note.body,
      );
    } on ReminderPermissionDenied {
      await widget.repository!.delete(widget.note.id);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            featureText(
              context,
              vi: 'Thông báo đang bị tắt. Hãy cấp quyền trong Cài đặt thiết bị.',
              en: 'Notifications are off. Enable them in device Settings.',
            ),
          ),
        ),
      );
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _remove() async {
    setState(() => _saving = true);
    await widget.repository?.delete(widget.note.id);
    await widget.scheduler?.cancel(widget.note.id);
    if (mounted) Navigator.pop(context, true);
  }

  String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}  '
        '${two(value.day)}/${two(value.month)}/${value.year}';
  }
}
