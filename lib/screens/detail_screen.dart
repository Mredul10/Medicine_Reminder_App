import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';
import 'add_edit_medicine.dart';

class DetailScreen extends StatefulWidget {
  final int medicineId;
  const DetailScreen({required this.medicineId, Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final db = DatabaseHelper();
  Medicine? med;
  List<Reminder> reminders = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    med = await db.getMedicineById(widget.medicineId);
    reminders = await db.getRemindersForMedicine(widget.medicineId);
    setState(() => loading = false);
  }

  Future<void> _editMedicine() async {
    if (med == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditMedicine(medicine: med)),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _editReminder(Reminder reminder) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(reminder.time) ?? TimeOfDay.now(),
    );
    if (picked != null) {
      String formattedTime = _formatTimeOfDay(picked);
      Reminder updated = Reminder(id: reminder.id, medicineId: reminder.medicineId, time: formattedTime);
      await db.updateReminder(updated);
      await _load();
    }
  }
  Future<void> _deleteReminder(Reminder reminder) async {
    // Optional: show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder at ${reminder.time}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      await db.deleteReminder(reminder.id!);
      await _load();
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      final hm = parts[0].split(':');
      int h = int.parse(hm[0]);
      int m = int.parse(hm[1]);
      final ampm = parts[1].toUpperCase();
      if (ampm == 'PM' && h < 12) h += 12;
      if (ampm == 'AM' && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return null;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: _editMedicine,
            tooltip: 'Edit Medicine',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEF7A9A),
              Color(0xFF6EC1C6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: loading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'card-${med!.id}',
                        child: Image.asset(
                          'assets/images/pill.png',
                          width: 120,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        med!.name,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        med!.dosage,
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 8),
                      Text(
                        med!.notes,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Schedule:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 8),
                        ...reminders.map((r) => Card(
                            color: Colors.white70,
                            margin: EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: Icon(Icons.alarm,
                                  color: Theme.of(context).primaryColor),
                              title: Text(r.time),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editReminder(r),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteReminder(r),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () {},
                                  child: Text('Export PDF',
                                      style: TextStyle(color: Colors.white)))),
                          SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Log Medication',
                                      style: TextStyle(color: Colors.white)))),
                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
