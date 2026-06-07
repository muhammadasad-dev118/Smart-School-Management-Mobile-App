import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
import 'package:smart_school_unified/core/constants/app_constants.dart';
import 'package:smart_school_unified/models/notice_model.dart';
import 'package:smart_school_unified/services/notifications/notification_provider.dart';
class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});
  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}
class _NoticeScreenState extends State<NoticeScreen> {
  String _selectedCategory = 'All';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppNotificationProvider>().listenToNotices('admin');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notice Board',
          style: GoogleFonts.outfit(color: Colors.black, fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Stay updated with the latest campus announcements',
              style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.grey),
            ),
          ),
          SizedBox(height: 20.h),
          _buildCategoryFilter(),
          Expanded(
            child: Consumer<AppNotificationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.notices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allNotices = provider.notices;
                final notices = allNotices;
                if (notices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64.sp, color: Colors.grey[300]),
                        SizedBox(height: 16.h),
                        Text('No notices yet', style: GoogleFonts.outfit(fontSize: 16.sp, color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  itemCount: notices.length,
                  itemBuilder: (context, i) => _NoticeCard(notice: notices[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showCreateNotice(context),
        backgroundColor: AppTheme.primaryIndigo,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Notice', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
  Widget _buildCategoryFilter() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: AppConstants.noticeCategories.length,
        itemBuilder: (context, index) {
          final c = AppConstants.noticeCategories[index];
          final isSelected = _selectedCategory == c;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = c),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryIndigo : Colors.grey[50],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  c,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  void _showCreateNotice(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    String category = 'General';
    String? targetClass;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isPosting = false;
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2.r)))),
                SizedBox(height: 24.h),
                Text('Post New Notice',
                    style: GoogleFonts.outfit(
                        fontSize: 22.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 24.h),
                _buildDialogField(titleCtrl, 'Notice Title', Icons.title_rounded),
                SizedBox(height: 16.h),
                _buildDialogField(bodyCtrl, 'Description...',
                    Icons.description_outlined,
                    maxLines: 3),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration:
                      _fieldDecoration('Category', Icons.category_outlined),
                  items: ['Important', 'Academic', 'Events', 'General']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: isPosting ? null : (v) => setSheetState(() => category = v!),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  value: targetClass,
                  decoration: _fieldDecoration(
                      'Target Audience', Icons.group_outlined),
                  items: [
                    const DropdownMenuItem(
                        value: null,
                        child: Text('Everyone (Teachers & Students)')),
                    const DropdownMenuItem(
                        value: 'Teachers', child: Text('Teachers Only')),
                    const DropdownMenuItem(
                        value: 'All Students', child: Text('All Students')),
                    ...AppConstants.classes.map((c) =>
                        DropdownMenuItem(value: c, child: Text('Class: $c'))),
                  ],
                  onChanged: isPosting ? null : (v) => setSheetState(() => targetClass = v),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isPosting
                        ? null
                        : () async {
                            if (titleCtrl.text.isNotEmpty &&
                                bodyCtrl.text.isNotEmpty) {
                              setSheetState(() => isPosting = true);
                              try {
                                List<String> roles = ['admin'];
                                if (targetClass == null) {
                                  roles.addAll(['teacher', 'student']);
                                } else if (targetClass == 'Teachers') {
                                  roles.add('teacher');
                                } else if (targetClass == 'All Students') {
                                  roles.add('student');
                                } else {
                                  roles.add('student');
                                }
                                final provider = context.read<AppNotificationProvider>();
                                await provider.sendNotice(
                                      title: titleCtrl.text.trim(),
                                      message: bodyCtrl.text.trim(),
                                      sentTo: roles,
                                      category: category,
                                    );
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  setSheetState(() => isPosting = false);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: isPosting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Post Notice',
                            style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
  Widget _buildDialogField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _fieldDecoration(hint, icon),
    );
  }
  InputDecoration _fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20.sp),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
    );
  }
}
class _NoticeCard extends StatelessWidget {
  final NoticeModel notice;
  const _NoticeCard({required this.notice});
  Color get _categoryColor {
    switch (notice.category.toLowerCase()) {
      case 'important': return Colors.red;
      case 'academic': return AppTheme.primaryIndigo;
      case 'events': return Colors.orange;
      default: return Colors.blue;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(color: _categoryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Text(
                  notice.category.toUpperCase(),
                  style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.bold, color: _categoryColor),
                ),
              ),
              Text(notice.timeAgo, style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.grey)),
            ],
          ),
          if (notice.status != 'approved') ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: notice.status == 'pending' ? Colors.orange[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                notice.status.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: notice.status == 'pending' ? Colors.orange : Colors.red,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Text(notice.title, style: GoogleFonts.outfit(fontSize: 17.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(
            notice.message,
            style: GoogleFonts.outfit(fontSize: 13.sp, color: Colors.black87, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.h),
          if (notice.status == 'pending')
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<AppNotificationProvider>().updateNoticeStatus(notice.id, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Reject', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<AppNotificationProvider>().updateNoticeStatus(notice.id, 'approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text('Approve', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, size: 12.sp, color: Colors.grey),
              ),
              SizedBox(width: 8.w),
              Text('By ${notice.sentBy}', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey)),
              const Spacer(),
              Icon(Icons.arrow_forward_rounded, size: 16.sp, color: AppTheme.primaryIndigo),
            ],
          ),
        ],
      ),
    );
  }
}