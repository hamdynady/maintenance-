import 'package:flutter/material.dart';
import 'package:maintenance2/core/services/maintenance_service.dart';
import 'package:intl/intl.dart';
import 'package:maintenance2/features/maintenance/presentation/screens/maintenance_details_screen.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen>
    with SingleTickerProviderStateMixin {
  final MaintenanceService _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _maintenanceRecords = [];
  bool _isLoading = true;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0, // Start with "قيد المعالجة" tab
    );
    _loadMaintenanceRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMaintenanceRecords() async {
    setState(() => _isLoading = true);
    try {
      final db = await _maintenanceService.database;
      final records = await db.query(
        'maintenance_records',
        orderBy: 'maintenance_date DESC',
      );
      setState(() {
        _maintenanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading records: $e')),
        );
      }
    }
  }

  Future<void> _deleteMaintenance(int id) async {
    try {
      final db = await _maintenanceService.database;
      await db.delete('maintenance_records', where: 'id = ?', whereArgs: [id]);
      await _loadMaintenanceRecords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الصيانة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting record: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الصيانة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMaintenance(id);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceList(String status) {
    final filteredRecords = _maintenanceRecords
        .where((record) => record['status'] == status)
        .toList();

    if (filteredRecords.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('لا توجد سجلات'),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(record['name'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رقم الهاتف: ${record['phone_number']}'),
                Text('العنوان: ${record['address']}'),
                Text(
                  'تاريخ الصيانة: ${_dateFormat.format(DateTime.parse(record['maintenance_date']))}',
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(record['id']),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaintenanceDetailsScreen(
                    maintenanceRecord: record,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الصيانة'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'قيد المعالجة'),
            Tab(text: 'مكتملة'),
            Tab(text: 'ملغي'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _maintenanceRecords.isEmpty
              ? const Center(child: Text('لا توجد سجلات صيانة'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMaintenanceList('قيد المعالجة'),
                    _buildMaintenanceList('مكتمل'),
                    _buildMaintenanceList('ملغي'),
                  ],
                ),
    );
  }
}
