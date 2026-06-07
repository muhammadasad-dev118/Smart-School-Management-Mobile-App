import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_school_unified/modules/student/providers/auth_provider.dart';
class SessionListener extends StatelessWidget {
  final Widget child;
  const SessionListener({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        context.read<StudentAuthProvider>().updateActivity();
      },
      child: child,
    );
  }
}