class Reminder {
  int? id;
  int medicineId;
  String time;

  Reminder({this.id, required this.medicineId, required this.time});

  Map<String, dynamic> toMap() {
    return {'id': id, 'medicine_id': medicineId, 'time': time};
  }

  factory Reminder.fromMap(Map<String, dynamic> m) {
    return Reminder(
      id: m['id'] as int?,
      medicineId: m['medicine_id'] as int,
      time: m['time'] as String,
    );
  }
}
