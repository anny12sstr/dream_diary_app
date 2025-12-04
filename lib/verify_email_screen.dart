// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'constants/app_strings.dart';
import 'services/auth_repository.dart';
import 'widgets/dream_app_header.dart';

class VerifyEmailScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const VerifyEmailScreen(this.toggleTheme, {super.key});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _isChecking = false;

  Future<void> _sendVerificationEmail() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      await _authRepository.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
            content: Text(AppStrings.verificationEmailSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('${AppStrings.errorGeneric}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() { _isChecking = true; });
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() { _isChecking = false; });
      return; 
    }

    try {
      await user.reload();
      user = FirebaseAuth.instance.currentUser; 

      if (user?.emailVerified ?? false) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.verifyEmailErrorNotConfirmed),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.verifyEmailErrorGeneric.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isChecking = false; });
      }
    }
  }

  Future<void> _signOut() async {
    await _authRepository.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final primaryAccentColor = const Color(0xFF8B5CF6);
    final textColorPrimary = const Color(0xFF374151);

    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: DreamAppHeader(
        selectedIndex: -1, 
        onNavigate: (index) {}, 
        onAccountOptions: () {}, 
      ),
      backgroundColor: isLight ? const Color(0xFFF9FAFB) : theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mark_email_read_outlined, color: primaryAccentColor, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.verifyEmailTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColorPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.verifyEmailSubtitle.replaceAll('{email}', userEmail),
                    style: TextStyle(
                      fontSize: 15,
                      color: textColorPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Зелена кнопка
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkVerificationStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isChecking ? Colors.grey : Colors.green, 
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                          : const Text(
                              AppStrings.verifyEmailCheckButton,
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Кнопка "Надіслати повторно"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton( 
                      onPressed: _isLoading ? null : _sendVerificationEmail,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryAccentColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2,))
                        : Text(
                            AppStrings.resendButton,
                            style: TextStyle(color: primaryAccentColor, fontSize: 16),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _signOut,
                    child: const Text(
                      AppStrings.verifyEmailCancelButton,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Кнопка теми
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