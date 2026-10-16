import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState
    extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  final passwordController =
      TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> resetPassword() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Semua field wajib diisi'),
        ),
      );
      return;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Konfirmasi password tidak sama'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final result =
        await AuthService.resetPassword(
      email: emailController.text,
      password: passwordController.text,
      passwordConfirmation:
          confirmPasswordController.text,
    );

    setState(() {
      loading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Password berhasil diubah',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                'Reset password gagal',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg-sky.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.20),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.all(24),
                child: Container(
                  padding:
                      const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius:
                        BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.15),
                        blurRadius: 20,
                        offset:
                            const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Color(0xFF1976D2),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "RESET PASSWORD",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF1976D2),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Masukkan email dan password baru",
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextField(
                        controller:
                            emailController,
                        keyboardType:
                            TextInputType
                                .emailAddress,
                        decoration:
                            InputDecoration(
                          hintText: "Email",
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color:
                                Color(0xFF1976D2),
                          ),
                          filled: true,
                          fillColor:
                              Colors.grey.shade100,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(16),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            passwordController,
                        obscureText:
                            obscurePassword,
                        decoration:
                            InputDecoration(
                          hintText:
                              "Password Baru",
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color:
                                Color(0xFF1976D2),
                          ),
                          suffixIcon:
                              IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor:
                              Colors.grey.shade100,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(16),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            obscureConfirmPassword,
                        decoration:
                            InputDecoration(
                          hintText:
                              "Konfirmasi Password",
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color:
                                Color(0xFF1976D2),
                          ),
                          suffixIcon:
                              IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons
                                      .visibility_off
                                  : Icons
                                      .visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor:
                              Colors.grey.shade100,
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(16),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : resetPassword,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(
                                  0xFF1976D2,
                                ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                        16,
                                      ),
                            ),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                )
                              : const Text(
                                  'RESET PASSWORD',
                                  style:
                                      TextStyle(
                                        color:
                                            Colors
                                                .white,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        child: const Text(
                          'Kembali ke Login',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}