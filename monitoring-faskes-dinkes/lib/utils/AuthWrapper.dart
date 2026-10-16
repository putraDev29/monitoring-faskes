import 'package:flutter/material.dart';
import 'package:monitoring_faskes_dinkes/pages/dashboard_page.dart';
import 'package:monitoring_faskes_dinkes/pages/login_page.dart';
import 'package:monitoring_faskes_dinkes/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final token = snapshot.data;

        if (token != null && token.isNotEmpty) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}