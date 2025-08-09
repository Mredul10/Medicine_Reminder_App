import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/medicine.dart';
import '../widgets/medicine_card.dart';
import 'add_edit_medicine.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper();
  List<Medicine> meds = [];
  bool loading = true;
  bool _showSearch = false; // for showing search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    meds = await db.getAllMedicines();
    setState(() => loading = false);
  }

  Future<void> _search(String query) async {
    setState(() => loading = true);
    if (query.isEmpty) {
      meds = await db.getAllMedicines();
    } else {
      meds = await db.searchMedicinesMatchesFirst(query);
    }
    setState(() => loading = false);
  }

  Future<void> _goAdd() async {
    final res = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddEditMedicine()));
    if (res == true) _load();
  }

  Future<void> _goEdit(Medicine m) async {
    final res = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddEditMedicine(medicine: m)));
    if (res == true) _load();
  }

  Future<void> _delete(Medicine m) async {
    await db.deleteMedicine(m.id!);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${m.name} deleted')));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // so gradient shows behind the AppBar too
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: !_showSearch
                ? ClipOval(
                    child: Image.asset(
                      'assets/images/mredul.jpg',
                      fit: BoxFit.fill,
                    ),
                  )
                : null,
            title: _showSearch
                ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _search,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hey,',
                          style:
                              TextStyle(fontSize: 15, color: Colors.white70)),
                      Text('Mredul 👋',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ],
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      _load();
                    }
                  });
                },
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEF7A9A), // pink
              Color(0xFF6EC1C6), // light blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: loading
              ? Center(child: CircularProgressIndicator())
              : meds.isEmpty
                  ? Center(
                      child: Text(
                        'No medicines yet. Tap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: meds.length,
                        itemBuilder: (context, i) {
                          final m = meds[i];
                          return Dismissible(
                            key: Key('${m.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(m),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          DetailScreen(medicineId: m.id!),
                                      transitionsBuilder: (_, a, __, child) =>
                                          FadeTransition(
                                              opacity: a, child: child)))
                                  .then((_) => _load()),
                              onLongPress: () => _goEdit(m),
                              child: Hero(
                                tag: 'card-${m.id}',
                                child: medicineCardAnimated(m),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goAdd,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget medicineCardAnimated(Medicine m) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 450),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: MedicineCard(
        name: m.name,
        time: m.scheduleTimes.isNotEmpty ? m.scheduleTimes.first : '--:--',
        dosage: m.dosage,
      ),
    );
  }
}
