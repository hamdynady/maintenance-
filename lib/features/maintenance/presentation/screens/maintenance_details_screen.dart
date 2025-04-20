import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MaintenanceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> maintenanceRecord;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  MaintenanceDetailsScreen({super.key, required this.maintenanceRecord});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الصيانة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              'المعلومات الأساسية',
              [
                _buildDetailRow('الاسم', maintenanceRecord['name']),
                _buildDetailRow(
                    'رقم الهاتف', maintenanceRecord['phone_number']),
                _buildDetailRow('العنوان', maintenanceRecord['address']),
                _buildDetailRow(
                  'تاريخ الصيانة',
                  _dateFormat.format(
                      DateTime.parse(maintenanceRecord['maintenance_date'])),
                ),
                _buildDetailRow('الحالة', maintenanceRecord['status']),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'معلومات المنتج',
              [
                _buildDetailRow(
                    'الاسم بالعربية', maintenanceRecord['arabic_name']),
                _buildDetailRow(
                    'الاسم بالإنجليزية', maintenanceRecord['english_name']),
                _buildDetailRow('المصنع', maintenanceRecord['manufacturer']),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              'معلومات الصيانة',
              [
                _buildDetailRow('قطع الغيار',
                    maintenanceRecord['spare_parts'] ?? 'لا يوجد'),
                _buildDetailRow(
                    'التقرير', maintenanceRecord['report'] ?? 'لا يوجد'),
              ],
            ),
            if (maintenanceRecord['report_image'] != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                'صورة التقرير',
                [
                  Center(
                    child: Image.file(
                      File(maintenanceRecord['report_image']),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('لا يمكن عرض الصورة'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
