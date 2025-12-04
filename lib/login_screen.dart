// ignore_for_file: deprecated_member_use, prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_repository.dart';
import 'constants/app_strings.dart';
import 'widgets/dream_app_header.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const LoginScreen(this.toggleTheme, {super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  int _selectedIndex = -1;

  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordLinkController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGoogleLoading = false;

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
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text(AppStrings.signUpButtonDialog),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/signup');
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
  
  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      await _authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException {
      const message = AppStrings.loginErrorInvalid;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(message), backgroundColor: Colors.red),
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

  void _showLinkAccountDialog(AuthCredential credential, String email) {
    _passwordLinkController.clear();
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.linkAccountTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.linkAccountContent.replaceAll('{email}', email)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordLinkController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.passwordLabel,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.errorPasswordEmpty;
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() { _isGoogleLoading = false; }); 
            },
            child: const Text(AppStrings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = _passwordLinkController.text;
              if (password.isEmpty) return;
              
              setState(() { _isLoading = true; }); 
              
              try {
                final userCredential = await _authRepository.signIn(
                  email: email,
                  password: password,
                );
                
                if (userCredential.user != null) {
                  await userCredential.user!.linkWithCredential(credential);
                  await userCredential.user!.reload();
                }
                
                if (mounted) {
                  Navigator.pop(context); 
                }
                
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.linkAccountError),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() { 
                    _isLoading = false;
                    _isGoogleLoading = false;
                  });
                }
              }
            },
            child: const Text(AppStrings.linkAccountButton),
          ),
        ],
      ),
    );
  }

  void _handleGoogleLogin() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() { _isGoogleLoading = true; });

    try {
      await _authRepository.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'account-exists-with-different-credential') {
        final String? email = e.email;
        final AuthCredential? credential = e.credential;
        
        if (email != null && credential != null) {
          _showLinkAccountDialog(credential, email);
        }
        return; 
      } 
      else if (e.code == 'USER_CANCELLED') {
        message = AppStrings.loginErrorGoogleCancelled;
      } else {
        message = AppStrings.loginErrorGoogleFailed;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${AppStrings.errorGeneric}: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isGoogleLoading = false; });
      }
    }
  }

   @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordLinkController.dispose(); 
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
    final bool anyLoading = _isLoading || _isGoogleLoading;

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
                        AppStrings.loginTitle,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColorPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.loginWelcome,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
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
                          suffixIcon: Icon(
                            Icons.mail_outline,
                            color: hintColor,
                            size: 20,
                          ),
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
                              size: 20,
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                            activeColor: primaryAccentColor,
                          ),
                          Text(
                            AppStrings.rememberMe,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColorPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Log In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: anyLoading ? null : _handleLogin,
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
                                  AppStrings.loginButton,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(), 
                          
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14,
                                color: textColorPrimary,
                              ),
                              children: [
                                const TextSpan(text: AppStrings.noAccount),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(context, '/signup');
                                    },
                                    child: Text(
                                      AppStrings.signUpLink,
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
                        ],
                      ),
                      const SizedBox(height: 24),

                       Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orContinueWith,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColorSecondary,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: _isGoogleLoading
                                ? Container()
                                : const Icon(Icons.g_mobiledata, color: Colors.red),
                              label: _isGoogleLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(AppStrings.googleButton, style: TextStyle(color: textColorPrimary)),
                              onPressed: anyLoading ? null : _handleGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: borderColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

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