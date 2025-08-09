class Medicine {
  int? id;
  String name;
  String dosage;
  String notes;
  List<String> scheduleTimes;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    this.notes = '',
    required this.scheduleTimes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'notes': notes,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, [List<String>? times]) {
    return Medicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      notes: map['notes'] as String? ?? '',
      scheduleTimes: times ?? [],
    );
  }
}
