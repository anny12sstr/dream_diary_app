// ignore_for_file: deprecated_member_use, prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors_in_immutables, unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_repository.dart'; 
import 'constants/app_strings.dart';
import 'widgets/dream_app_header.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SignUpScreen(this.toggleTheme, {super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  int _selectedIndex = -1; 

  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _nameController = TextEditingController(); 
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController(); 
  bool _isLoading = false; 

  void _showAccountOptions() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.accountOptionsTitle), 
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text(AppStrings.loginButton), 
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushReplacementNamed(context, '/login'); 
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text(AppStrings.signUpButtonDialog), 
            onTap: () {
              Navigator.pop(context); 
            },
          ),
        ],
      ),
    ),
  );
}

  void _onNavigate(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.authRequiredTitle),
        content: const Text(AppStrings.authRequiredContent), 
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.okButton),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    setState(() { _isLoading = true; });

    try {
      await _authRepository.signUp(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim(), 
      );

      if (mounted) { 
        Navigator.pushReplacementNamed(context, '/verify_email');
      }

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = AppStrings.signUpErrorWeakPassword; 
      } else if (e.code == 'email-already-in-use') {
        message = AppStrings.signUpErrorEmailInUse; 
      } else {
        message = '${AppStrings.signUpErrorGeneric}: ${e.message}'; 
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('${AppStrings.errorGeneric}: $e'), backgroundColor: Colors.red),
         );
       }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryAccentColor = const Color(0xFF8B5CF6);
    final textColorPrimary = const Color(0xFF374151); 
    final textColorSecondary = const Color(0xFF6B7280); 
    final borderColor = const Color(0xFFE5E7EB); 
    final hintColor = const Color(0xFF9CA3AF); 

    return Scaffold(
      appBar: DreamAppHeader(
        selectedIndex: _selectedIndex,
        onNavigate: _onNavigate,
        onAccountOptions: _showAccountOptions,
      ),
      backgroundColor: isLight ? const Color(0xFFF9FAFB) : theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form( 
                  key: _formKey, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.signUpTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name Field
                      Text(
                        AppStrings.nameLabel, 
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField( 
                        controller: _nameController, 
                        decoration: InputDecoration(
                          hintText: AppStrings.nameHint, 
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryAccentColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.errorNameEmpty; 
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      Text(
                        AppStrings.emailLabel, 
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: AppStrings.emailHint, 
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryAccentColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.errorEmailEmpty;
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return AppStrings.errorEmailInvalid; 
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        AppStrings.passwordLabel, 
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, 
                        decoration: InputDecoration(
                          hintText: AppStrings.passwordHint,
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: primaryAccentColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: hintColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.errorPasswordEmpty; 
                          }
                          if (value.length < 6) {
                            return AppStrings.errorPasswordLength; 
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryAccentColor, 
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox( 
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  AppStrings.signUpButton, 
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: textColorPrimary,
                            ),
                            children: [
                              const TextSpan(text: AppStrings.hasAccount), 
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: Text(
                                    AppStrings.loginLink, 
                                    style: TextStyle(
                                      color: Colors.blue.shade600, 
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ), 
              ),
            ),
          ),

          // Кнопка зміни теми
          Positioned(
            top: 24,
            right: 24,
            child: GestureDetector(
              onTap: widget.toggleTheme,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFFCD34D) : Colors.purple.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLight ? Colors.purple.shade700 : Colors.white,
                    width: 2),
                ),
                child: Icon(
                  isLight ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                  color: isLight ? Colors.purple.shade700 : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}