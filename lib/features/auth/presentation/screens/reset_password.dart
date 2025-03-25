import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final String token =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    void resetPassword() async {
      if (token.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid reset token")));
        return;
      }

      setState(() => isLoading = true);

      try {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password successfully updated!")));

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }

      setState(() => isLoading = false);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Enter new password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : resetPassword,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
