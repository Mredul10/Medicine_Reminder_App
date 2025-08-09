import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/medicine.dart';


class AddEditMedicine extends StatefulWidget {
  final Medicine? medicine;
  const AddEditMedicine({this.medicine, Key? key}) : super(key: key);

  @override
  State<AddEditMedicine> createState() => _AddEditMedicineState();
}

class _AddEditMedicineState extends State<AddEditMedicine> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dosage = TextEditingController();
  final _notes = TextEditingController();
  List<TimeOfDay> _times = [];

  final db = DatabaseHelper();
  // final notifier = NotificationService();

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _name.text = widget.medicine!.name;
      _dosage.text = widget.medicine!.dosage;
      _notes.text = widget.medicine!.notes;
      _times = widget.medicine!.scheduleTimes.map((s) => _parseTime(s)!).whereType<TimeOfDay>().toList();
    }
  }

  TimeOfDay? _parseTime(String s) {
    try {
      final parts = s.split(' ');
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

  String _format(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> _pickTime(int? index) async {
    final initial = index != null && index < _times.length ? _times[index] : TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (index != null && index < _times.length) {
          _times[index] = picked;
        } else {
          _times.add(picked);
        }
      });
    }
  }

  Future<void> _removeTime(int idx) async {
    setState(() => _times.removeAt(idx));
  }

  Future<void> _save() async {
  if (!_form.currentState!.validate()) return;
  final timesStr = _times.map((t) => _format(t)).toList();

  if (widget.medicine != null) {
    // Editing existing medicine
    final med = Medicine(
      id: widget.medicine!.id,
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      notes: _notes.text.trim(),
      scheduleTimes: timesStr,
    );
    await db.updateMedicine(med);
    await db.deleteRemindersForMedicine(med.id!);
    for (var t in timesStr) {
      await db.insertReminder(med.id!, t);
    }
  } else {
    // Adding new medicine
    final med = Medicine(
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      notes: _notes.text.trim(),
      scheduleTimes: timesStr,
    );
    int newId = await db.insertMedicine(med);  // <-- INSERT here, get new id
    await db.deleteRemindersForMedicine(newId);
    for (var t in timesStr) {
      await db.insertReminder(newId, t);
    }
  }

  Navigator.pop(context, true);  // pass true to trigger reload on HomeScreen
}


  @override
Widget build(BuildContext context) {
  final isEdit = widget.medicine != null;
  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [ Color(0xFFEF7A9A), Color(0xFF6EC1C6)], // Blue gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent, // Make Scaffold see-through
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'card-${widget.medicine?.id ?? 'new'}',
                child: Center(
                  child: Image.asset('assets/images/pill.png', width: 90),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Medicine name',),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dosage,
                decoration: const InputDecoration(labelText: 'Dosage (e.g. 500mg)'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter dosage' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 16),
              const Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < _times.length; i++)
                    InputChip(
                      label: Text(_format(_times[i])),
                      avatar: const Icon(Icons.access_time, size: 18),
                      onPressed: () => _pickTime(i),
                      onDeleted: () => _removeTime(i),
                    ),
                  ActionChip(
                    backgroundColor: Colors.white70,
                    label: const Text('Add time'),
                    avatar: const Icon(Icons.add),
                    onPressed: () => _pickTime(null),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Update' : 'Add',style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
