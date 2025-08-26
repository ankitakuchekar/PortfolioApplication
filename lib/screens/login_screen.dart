import 'package:bold_portfolio/screens/ForgotPasswordScreen.dart';
import 'package:bold_portfolio/services/auth_service.dart';
import 'package:bold_portfolio/utils/mobileFormater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easy_recaptcha_v2/flutter_easy_recaptcha_v2.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // for register
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _regPasswordController = TextEditingController();

  // reCAPTCHA functionality
  final _firstNameFocusNode = FocusNode();
  String? _recaptchaToken;
  bool _isRecaptchaVerified = false;

  bool _obscurePassword = true;
  int _selectedTab = 0; // 0 = login , 1 = register

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _regPasswordController.dispose();
    _firstNameFocusNode.dispose();
    super.dispose();
  }

  int? validateName(String name) {
    final cleanedName = name.trim();

    if (cleanedName.isEmpty) {
      return 0; // Empty
    } else if (name.contains(' ')) {
      return 1; // Whitespace
    } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(cleanedName)) {
      return -1; // Invalid characters
    }

    return 2; // Valid
  }

  String? nameErrorText(String name, String fieldName) {
    final result = validateName(name);

    switch (result) {
      case 0:
        return '${fieldName} name is required';
      case -1:
        return '${fieldName} name must contain only letters';
      case 1:
        return 'Whitespace is not allowed';
      case 2:
        return null; // Valid
      default:
        return 'Invalid name';
    }
  }

  int? validateEmail(String email) {
    final cleanedEmail = email.trim();

    if (cleanedEmail.isEmpty) {
      return 0; // Empty email
    }

    // Stricter regex: ensures there's at least one character after @ and a valid domain
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (!regex.hasMatch(cleanedEmail)) {
      return -1; // Invalid email
    }

    return 1; // Valid
  }

  String? emailErrorText(String email) {
    final result = validateEmail(email);

    switch (result) {
      case 0:
        return 'Email is required';
      case -1:
        return 'Email must be a valid email address';
      case 1:
        return null;
      default:
        return 'Invalid email';
    }
  }

  String? validateMobileNumber(String? input) {
    if (input == null || input.trim().isEmpty) {
      return "Mobile number is required";
    }

    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 10) {
      return "Mobile number should be 10 digits.";
    }

    return null; // ✅ valid
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (mounted) {
        print("auth,${authProvider}");
        // Show error toast/snackbar
        final errorMessage =
            authProvider.errorMessage ??
            'Login failed,Username or password is incorrect';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRecaptcha() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 242, 238, 238),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1E29),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Complete reCAPTCHA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RecaptchaV2(
                apiKey: '6Ld321YdAAAAALuFjmWlaC57ilZQQ4Gp1yQeG8e0',
                onVerifiedSuccessfully: (token) async {
                  setState(() {
                    _recaptchaToken = token;
                    _isRecaptchaVerified = true;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('reCAPTCHA verified successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Check reCAPTCHA verification
      if (!_isRecaptchaVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete reCAPTCHA verification'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _regPasswordController.text,
        screenSize: "426, 616",
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 243, 245),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/bold_logo.png',
                        width: 180,
                        height: 90,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _selectedTab == 0
                            ? 'Welcome Back'
                            : 'Register with BOLD',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedTab == 0
                            ? 'Sign in to your account to continue'
                            : 'Get Started with BOLD and enjoy a seamless shopping experience',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // LOGIN FORM
                      if (_selectedTab == 0) ...[
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Username or E-mail',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 237, 239, 245),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Colors.black),
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 237, 239, 245),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C566), // Start color
                                      Color(0xFF039A5D), // End color
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot your password?',
                            style: TextStyle(color: Color(0xFF00C566)),
                          ),
                        ),

                        // After Login Button
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF4B4B4B),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = 1;
                                  _formKey.currentState?.reset();
                                });
                                Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).clearError();
                              },
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Color(0xFF00C566),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // REGISTER FORM
                      if (_selectedTab == 1) ...[
                        _buildFieldWithRecaptcha(
                          controller: _firstNameController,
                          focusNode: _firstNameFocusNode,
                          label: 'First Name',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              nameErrorText(value ?? '', 'First'),
                          // onFocusChange: (hasFocus) {
                          //   if (hasFocus && !_isRecaptchaVerified) {
                          //     _showRecaptcha();
                          //   }
                          // },
                        ),

                        const SizedBox(height: 8),
                        if (_isRecaptchaVerified)
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'reCAPTCHA verified',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              nameErrorText(value ?? '', 'Last'),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          validator: (v) => emailErrorText(v ?? ''),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(14),
                            PhoneNumberFormatter(),
                          ],
                          validator: validateMobileNumber,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Mobile No.',
                            labelStyle: const TextStyle(color: Colors.black),
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 237, 239, 245),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              errorMaxLines:
                                  3, // 👈 Allows error text to wrap into 3 lines
                            ),
                          ),
                          child: TextFormField(
                            controller: _regPasswordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }

                              final isValid =
                                  value.length >= 8 &&
                                  RegExp(r'[A-Z]').hasMatch(value) &&
                                  RegExp(r'[a-z]').hasMatch(value) &&
                                  RegExp(r'[0-9]').hasMatch(value) &&
                                  RegExp(
                                    r'[!@#$%^&*(),.?":{}|<>]',
                                  ).hasMatch(value);

                              if (!isValid) {
                                return 'Password should be minimum 8 characters long, having at least 1 uppercase letter, 1 lowercase letter, 1 digit, and 1 special character.';
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color.fromARGB(
                                255,
                                237,
                                239,
                                245,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error Message (if any)
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return authProvider.errorMessage != null
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),

                        // Register Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00C566), // Start color
                                      Color(
                                        0xFF007A4D,
                                      ), // End color (adjust as per design)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        )
                                      : const Text(
                                          "Register",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),

                        // After Register Button
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Color(0xFF4B4B4B),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = 0;
                                  _formKey.currentState?.reset();
                                });
                                Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                ).clearError();
                              },
                              child: const Text(
                                "Sign in",
                                style: TextStyle(
                                  color: Color(0xFF00C566),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator:
          validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: const Color.fromARGB(255, 237, 239, 245),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildFieldWithRecaptcha({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Function(bool)? onFocusChange,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator:
            validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon, color: Colors.black),
          suffixIcon: _isRecaptchaVerified && focusNode == _firstNameFocusNode
              ? const Icon(Icons.verified, color: Colors.green)
              : null,
          filled: true,
          fillColor: const Color.fromARGB(255, 237, 239, 245),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
