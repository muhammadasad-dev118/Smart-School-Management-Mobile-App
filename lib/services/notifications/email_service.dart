import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class EmailService {
  static const String _userEmail = 'administration726@gmail.com';
  static const String _appPassword = 'npcywtljaxdgnvgo';
  final smtpServer = gmail(_userEmail, _appPassword);
  Future<bool> sendEmail({
    required String recipient,
    required String subject,
    required String htmlBody,
  }) async {
    if (!kIsWeb) {
      debugPrint('Attempting SMTP primary delivery to $recipient...');
      bool success = await _sendEmailViaSMTP(recipient, subject, htmlBody);
      if (success) {
        debugPrint('SMTP Delivery Success!');
        return true;
      }
      debugPrint('SMTP failed or not available, trying EmailJS fallback...');
    }
    return await sendEmailViaEmailJS(
      recipient: recipient,
      subject: subject,
      message: htmlBody,
    );
  }
  Future<bool> sendEmailViaEmailJS({
    required String recipient,
    required String subject,
    required String message,
    String? recipientName,
  }) async {
    const String serviceId = 'service_tiu9mna';
    const String templateId = 'template_r3ormtb';
    const String publicKey = 'oqqTLTJ40RVduqMZv';
    try {
      debugPrint('Attempting to send email to: $recipient | Subject: $subject');
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'Origin':
              'http://localhost',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': recipient,
            'to_name': recipientName ?? recipient.split('@')[0],
            'subject': subject,
            'message': message,
            'content': message,
            'msg': message,
            'from_name': 'Smart School Management',
            'reply_to': _userEmail,
            'admin_email': _userEmail,
          },
        }),
      );
      if (response.statusCode == 200) {
        debugPrint('EmailJS Success: Email sent to $recipient');
        return true;
      } else {
        debugPrint('EmailJS Error (${response.statusCode}): ${response.body}');
        if (!kIsWeb) {
          debugPrint('EmailJS failed, attempting SMTP fallback...');
          return await _sendEmailViaSMTP(recipient, subject, message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('EmailJS Exception: $e');
      if (!kIsWeb) return await _sendEmailViaSMTP(recipient, subject, message);
      return false;
    }
  }
  Future<bool> _sendEmailViaSMTP(
    String recipient,
    String subject,
    String htmlBody,
  ) async {
    try {
      final message =
          Message()
            ..from = const Address(_userEmail, 'Smart School System')
            ..recipients.add(recipient)
            ..subject = subject
            ..html = htmlBody;
      final sendReport = await send(message, smtpServer);
      debugPrint('SMTP: Message sent: $sendReport');
      return true;
    } catch (e) {
      debugPrint('SMTP Error: $e');
      return false;
    }
  }
  Future<bool> sendTeacherNotification({
    required String teacherEmail,
    required String message,
  }) async {
    final html = '''
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <h2 style="color: #4F46E5;">School Management Notification</h2>
          <p>Dear Teacher,</p>
          <p style="font-size: 16px; line-height: 1.5;">$message</p>
          <br>
          <hr>
          <p style="font-size: 12px; color: #777;">This is an automated message from Smart School Admin.</p>
      </div>
    ''';
    return sendEmail(
      recipient: teacherEmail,
      subject: 'New School Notification',
      htmlBody: html,
    );
  }
  Future<bool> sendPaymentConfirmation({
    required String studentEmail,
    required String studentName,
    required double amount,
    required String month,
  }) async {
    final html = '''
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 2px solid #3b82f6; border-radius: 12px;">
          <h2 style="color: #3b82f6;">Payment Confirmation</h2>
          <p>Dear $studentName,</p>
          <p>We have successfully processed your payment for <b>$month</b>.</p>
          <table style="width: 100%; border-collapse: collapse;">
              <tr><td style="padding: 8px; border-bottom: 1px solid #eee;"><b>Amount:</b></td><td style="padding: 8px; border-bottom: 1px solid #eee;">Rs $amount</td></tr>
              <tr><td style="padding: 8px; border-bottom: 1px solid #eee;"><b>Status:</b></td><td style="padding: 8px; border-bottom: 1px solid #eee;">Paid</td></tr>
          </table>
          <p>Thank you for your payment!</p>
      </div>
    ''';
    return sendEmail(
      recipient: studentEmail,
      subject: 'Fee Payment Received',
      htmlBody: html,
    );
  }
  Future<bool> sendStudentNotification({
    required String studentEmail,
    required String title,
    required String message,
  }) async {
    final html = '''
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
          <h2 style="color: #4F46E5;">$title</h2>
          <p>Dear Student,</p>
          <p style="font-size: 16px; line-height: 1.5;">$message</p>
          <br>
          <hr>
          <p style="font-size: 12px; color: #777;">This is an automated notice from School Management.</p>
      </div>
    ''';
    return sendEmail(recipient: studentEmail, subject: title, htmlBody: html);
  }
  Future<bool> sendMarksNotification({
    required String studentEmail,
    required String studentName,
    required String subject,
    required String marks,
    required String totalMarks,
  }) async {
    final html = '''
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 2px solid #10B981; border-radius: 12px;">
          <h2 style="color: #10B981;">Academic Result Update</h2>
          <p>Dear $studentName,</p>
          <p>Your marks for <b>$subject</b> have been uploaded.</p>
          <div style="background-color: #F3F4F6; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <p style="font-size: 24px; margin: 0; color: #065F46;"><b>$marks / $totalMarks</b></p>
          </div>
          <p>Keep up the hard work!</p>
      </div>
    ''';
    return sendEmail(
      recipient: studentEmail,
      subject: 'Marks Uploaded: $subject',
      htmlBody: html,
    );
  }
  Future<bool> sendHomeworkNotification({
    required String studentEmail,
    required String studentName,
    required String homeworkTitle,
    required String status,
    String? feedback,
  }) async {
    final html = '''
      <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #3B82F6; border-radius: 10px;">
          <h2 style="color: #3B82F6;">Homework Feedback</h2>
          <p>Dear $studentName,</p>
          <p>Your homework <b>"$homeworkTitle"</b> has been reviewed.</p>
          <p><b>Status:</b> $status</p>
          ${feedback != null && feedback.isNotEmpty ? '<p><b>Feedback:</b> $feedback</p>' : ''}
          <p>Login to the app for more details.</p>
      </div>
    ''';
    return sendEmail(
      recipient: studentEmail,
      subject: 'Homework Reviewed: $homeworkTitle',
      htmlBody: html,
    );
  }
}