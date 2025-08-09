import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/medicine.dart';
import '../models/reminder.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // lets gradient show behind appbar
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEF7A9A), // light green
              Color(0xFF6EC1C6), // light blue
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
                          style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Colors.white),
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
                              trailing: Icon(Icons.check_circle_outline),
                            ),
                          )),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () {}, child: Text('Export PDF',style: TextStyle(color: Colors.white)))),
                          SizedBox(width: 12),
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text('Log Medication', style: TextStyle(color: Colors.white)))),
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
