import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
import 'package:smart_school_unified/models/fee_model.dart';
import 'package:smart_school_unified/modules/admin/providers/fee_provider.dart';
class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});
  @override
  State<FeesScreen> createState() => _FeesScreenState();
}
class _FeesScreenState extends State<FeesScreen> {
  String _selectedFilter = 'All Records';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeeProvider>().loadFeeStats();
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeeProvider>();
    final percent = provider.totalFees > 0 ? (provider.collectedFees / provider.totalFees * 100) : 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Fees Management',
          style: GoogleFonts.outfit(color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildRevenueSummary(provider, percent),
            SizedBox(height: 32.h),
            _buildCollectionProgress(percent),
            SizedBox(height: 32.h),
            _buildFilterChips(),
            SizedBox(height: 24.h),
            _buildTransactionList(provider),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showRecordPayment(context),
        backgroundColor: AppTheme.primaryIndigo,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: Text('Record Payment', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
  Widget _buildRevenueSummary(FeeProvider provider, double percent) {
    return Row(
      children: [
        Expanded(
          child: _revenueCard(
            'TOTAL TARGET',
            'Rs ${_fmt(provider.totalFees)}',
            'Term 2024-25',
            Colors.grey[50]!,
            Colors.black87,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _revenueCard(
            'COLLECTED',
            'Rs ${_fmt(provider.collectedFees)}',
            '${percent.toStringAsFixed(1)}% reached',
            AppTheme.primaryIndigo.withValues(alpha: 0.1),
            AppTheme.primaryIndigo,
          ),
        ),
      ],
    );
  }
  Widget _revenueCard(String label, String value, String sub, Color bg, Color fg) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 12.h),
          Text(value, style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: fg)),
          SizedBox(height: 4.h),
          Text(sub, style: GoogleFonts.outfit(fontSize: 10.sp, color: Colors.grey)),
        ],
      ),
    );
  }
  Widget _buildCollectionProgress(double percent) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryIndigo, AppTheme.primaryIndigo.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryIndigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Collection Rate', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
              Text('${percent.toStringAsFixed(1)}%', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10.h,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterChips() {
    final filters = ['All Records', 'Paid', 'Pending', 'Overdue'];
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryIndigo : Colors.grey[50],
                borderRadius: BorderRadius.circular(20.r),
              ),
              alignment: Alignment.center,
              child: Text(
                f,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildTransactionList(FeeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.h),
        StreamBuilder<List<FeeModel>>(
          stream: provider.getFees(
            _selectedFilter == 'All Records' ? null : _selectedFilter,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final fees = snapshot.data ?? [];
            if (fees.isEmpty) {
              return Center(child: Text('No records found', style: GoogleFonts.outfit(color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fees.length,
              itemBuilder: (context, index) => _feeTile(fees[index]),
            );
          },
        ),
      ],
    );
  }
  Widget _feeTile(FeeModel fee) {
    final isPaid = fee.status == 'paid';
    final color = isPaid ? Colors.green : (fee.status == 'overdue' ? Colors.red : Colors.orange);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.receipt_long_rounded, color: color, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fee.studentName, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                Text('${fee.className} • Roll: ${fee.rollNumber}', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Rs ${fee.amount.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)),
                child: Text(fee.status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9.sp, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
  void _showRecordPayment(BuildContext context) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    final rollCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text('Record Payment', style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),
            _buildDialogField(nameCtrl, 'Student Name', Icons.person_outline),
            SizedBox(height: 16.h),
            _buildDialogField(classCtrl, 'Class (e.g. Class 10-A)', Icons.school_outlined),
            SizedBox(height: 16.h),
            _buildDialogField(rollCtrl, 'Roll Number', Icons.numbers_rounded),
            SizedBox(height: 16.h),
            _buildDialogField(amountCtrl, 'Amount (Rs)', Icons.payments_outlined, keyboardType: TextInputType.number),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                    context.read<FeeProvider>().addFee(FeeModel(
                      id: '', studentId: '', studentName: nameCtrl.text.trim(),
                      className: classCtrl.text.trim(), rollNumber: rollCtrl.text.trim(),
                      amount: double.tryParse(amountCtrl.text) ?? 0,
                      status: 'paid', description: 'Manual payment',
                      dueDate: DateTime.now(), paidDate: DateTime.now(), createdAt: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text('Confirm Payment', style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildDialogField(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20.sp),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
      ),
    );
  }
}