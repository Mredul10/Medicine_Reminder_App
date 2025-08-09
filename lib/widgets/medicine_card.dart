import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final String dosage;

  const MedicineCard({required this.name, required this.time, required this.dosage, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white70,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(children: [
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.all(8),
            child: Icon(Icons.medical_services, color: Theme.of(context).primaryColor, size: 28),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 6),
              Text(dosage, style: TextStyle(color: Colors.black54)),
            ]),
          ),
          Column(children: [
            Icon(Icons.access_time, size: 18),
            SizedBox(height: 4),
            Text(time, style: TextStyle(fontWeight: FontWeight.w600)),
          ])
        ]),
      ),
    );
  }
}
