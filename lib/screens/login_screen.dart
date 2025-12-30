import 'package:bold_portfolio/login-api.dart';
import 'package:bold_portfolio/screens/ForgotPasswordScreen.dart';
import 'package:bold_portfolio/services/biometric_auth_service.dart';
import 'package:bold_portfolio/utils/mobileFormater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart';
// import 'package:flutter_svg/flutter_svg.dart';

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
  // bool _isRecaptchaVerified = false;

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
        return '$fieldName name is required';
      case -1:
        return '$fieldName name must contain only letters';
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
        false,
        "",
        "",
        "",
        '1536, 390',
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (mounted) {
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

  bool _isLoading = false;

  // Future<void> _handleGoogleSignIn() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final user = await GoogleSignInApi.login();
  //   setState(() {
  //     _isLoading = false;
  //   });
  //   print("User from google: $user");
  //   print("email ${user?['email']}");

  //   if (user != null) {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //     final success = await authProvider.login(
  //       user['email'],
  //       "",
  //       true,
  //       user['googleToken'],
  //       user['firstName'],
  //       user['lastName'],
  //       user['profilePhoto'],
  //     );

  //     if (success && mounted) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => const MainScreen()),
  //       );
  //     } else if (mounted) {
  //       // Show error toast/snackbar
  //       final errorMessage =
  //           authProvider.errorMessage ??
  //           'Login failed,Username or password is incorrect';
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(errorMessage),
  //           backgroundColor: Colors.redAccent,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Google sign-in failed.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // void _showRecaptcha() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: const Color.fromARGB(0, 242, 238, 238),
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.8,
  //       decoration: const BoxDecoration(
  //         color: Color(0xFF1A1E29),
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(16),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const Text(
  //                   'Complete reCAPTCHA',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   icon: const Icon(Icons.close, color: Colors.white),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Expanded(
  //             child: WebViewWidget(
  //               controller: WebViewController()
  //                 ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //                 ..setNavigationDelegate(
  //                   NavigationDelegate(
  //                     onPageFinished: (String url) {
  //                       // Page loaded
  //                     },
  //                   ),
  //                 )
  //                 ..addJavaScriptChannel(
  //                   'RecaptchaChannel',
  //                   onMessageReceived: (JavaScriptMessage message) {
  //                     final token = message.message;
  //                     if (token.isNotEmpty && token != 'null') {
  //                       setState(() {
  //                         _recaptchaToken = token;
  //                         _isRecaptchaVerified = true;
  //                       });
  //                       Navigator.pop(context);
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         const SnackBar(
  //                           content: Text('reCAPTCHA verified successfully!'),
  //                           backgroundColor: Colors.green,
  //                         ),
  //                       );
  //                     }
  //                   },
  //                 )
  //                 ..loadHtmlString('''
  //                   <!DOCTYPE html>
  //                   <html>
  //                   <head>
  //                       <meta name="viewport" content="width=device-width, initial-scale=1.0">
  //                       <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  //                       <style>
  //                           body {
  //                               margin: 0;
  //                               padding: 20px;
  //                               background-color: #1A1E29;
  //                               display: flex;
  //                               justify-content: center;
  //                               align-items: center;
  //                               min-height: 100vh;
  //                               font-family: Arial, sans-serif;
  //                           }
  //                           .recaptcha-container {
  //                               background: white;
  //                               padding: 20px;
  //                               border-radius: 8px;
  //                               box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  //                           }
  //                           .loading {
  //                               color: white;
  //                               text-align: center;
  //                               font-size: 16px;
  //                           }
  //                       </style>
  //                   </head>
  //                   <body>
  //                       <div class="recaptcha-container">
  //                           <div class="loading" id="loading">Loading reCAPTCHA...</div>
  //                           <div class="g-recaptcha"
  //                                data-sitekey="6Ld321YdAAAAALuFjmWlaC57ilZQQ4Gp1yQeG8e0"
  //                                data-callback="onRecaptchaSuccess"
  //                                data-expired-callback="onRecaptchaExpired"
  //                                data-error-callback="onRecaptchaError">
  //                           </div>
  //                       </div>

  //                       <script>
  //                           function onRecaptchaSuccess(token) {
  //                               document.getElementById('loading').style.display = 'none';
  //                               if (window.RecaptchaChannel) {
  //                                   window.RecaptchaChannel.postMessage(token);
  //                               }
  //                           }

  //                           function onRecaptchaExpired() {
  //                               if (window.RecaptchaChannel) {
  //                                   window.RecaptchaChannel.postMessage('expired');
  //                               }
  //                           }

  //                           function onRecaptchaError() {
  //                               if (window.RecaptchaChannel) {
  //                                   window.RecaptchaChannel.postMessage('error');
  //                               }
  //                           }

  //                           // Hide loading text when reCAPTCHA loads
  //                           window.addEventListener('load', function() {
  //                               setTimeout(function() {
  //                                   document.getElementById('loading').style.display = 'none';
  //                               }, 2000);
  //                           });
  //                       </script>
  //                   </body>
  //                   </html>
  //                 '''),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Check reCAPTCHA verification
      // if (!_isRecaptchaVerified || _recaptchaToken == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text(
      //         'Please complete reCAPTCHA verification by tapping the security button above',
      //       ),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _regPasswordController.text,
        screenSize: "426, 616",
        captchaToken: "",
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
                      Image.network(
                        'https://res.cloudinary.com/bold-pm/image/upload/Graphics/bold-portfolio-app-1.png',
                        width: 180,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 180,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                'BOLD',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
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
                            ? 'Login using your BOLD account to access your bullion portfolio'
                            : 'Create your BOLD account to track your bullion portfolio and enjoy a seamless shopping experience',
                        textAlign: TextAlign.center, // Center each line
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
                            label: RichText(
                              text: TextSpan(
                                text: 'Username or E-mail',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
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
                            label: RichText(
                              text: TextSpan(
                                text: 'Password',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
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
                        const SizedBox(height: 24),
                        IconButton(
                          onPressed: () async {
                            bool check = await BiometricAuthService()
                                .authenticateLocalUser();
                            print("Biometric Auth Result: $check");
                            if (check) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const MainScreen(),
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.fingerprint,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: _handleGoogleSignIn,
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(
                        //       vertical: 12,
                        //       horizontal: 16,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       border: Border.all(color: Colors.grey[300]!),
                        //       borderRadius: BorderRadius.circular(8),
                        //       color: Colors.white,
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         SvgPicture.network(
                        //           'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        //           width: 20,
                        //           height: 20,
                        //         ),
                        //         SizedBox(width: 8),
                        //         Text(
                        //           'Sign up with Google',
                        //           style: TextStyle(
                        //             color: Color(0xFF00C566),
                        //             fontWeight: FontWeight.w500,
                        //             fontSize: 16,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 16),
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
                          isRequired: true,
                        ),

                        const SizedBox(height: 8),
                        // if (_isRecaptchaVerified)
                        // Container(
                        //   padding: const EdgeInsets.all(12),
                        //   margin: const EdgeInsets.only(bottom: 16),
                        //   decoration: BoxDecoration(
                        //     color: Colors.green.withOpacity(0.1),
                        //     borderRadius: BorderRadius.circular(8),
                        //     border: Border.all(
                        //       color: Colors.green.withOpacity(0.3),
                        //     ),
                        //   ),
                        // child: const Row(
                        //   children: [
                        //     Icon(
                        //       Icons.check_circle,
                        //       color: Colors.green,
                        //       size: 20,
                        //     ),
                        //     SizedBox(width: 12),
                        //     Text(
                        //       'reCAPTCHA verified successfully!',
                        //       style: TextStyle(
                        //         color: Colors.green,
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              nameErrorText(value ?? '', 'Last'),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          validator: (v) => emailErrorText(v ?? ''),
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder: (context) {
                            final baseStyle = Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontSize: 16, color: Colors.black);

                            return TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(14),
                                PhoneNumberFormatter(),
                              ],
                              validator: validateMobileNumber,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Mobile No.',
                                    style: baseStyle,
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: baseStyle?.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                labelStyle: baseStyle,
                                prefixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: Colors.black,
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
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
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
                              return 'Password should be minimum 8 characters long, having\n'
                                  'at least 1 uppercase letter, 1 lowercase letter, 1 digit, and\n'
                                  '1 special character.';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            label: Builder(
                              builder: (context) {
                                final baseStyle = Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      color: Colors.black,
                                    );
                                return RichText(
                                  text: TextSpan(
                                    text: 'Password',
                                    style: baseStyle,
                                    children: const [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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
                        ),

                        const SizedBox(height: 16),

                        // reCAPTCHA Button (if not verified)
                        // if (!_isRecaptchaVerified)
                        //   Container(
                        //     width: double.infinity,
                        //     margin: const EdgeInsets.only(bottom: 16),
                        //     child: OutlinedButton.icon(
                        //       onPressed: _showRecaptcha,
                        //       icon: const Icon(
                        //         Icons.security,
                        //         color: Color(0xFF00C566),
                        //       ),
                        //       label: const Text(
                        //         'Complete reCAPTCHA Verification',
                        //         style: TextStyle(
                        //           color: Color(0xFF00C566),
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       ),
                        //       style: OutlinedButton.styleFrom(
                        //         side: const BorderSide(
                        //           color: Color(0xFF00C566),
                        //         ),
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //         ),
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 12,
                        //         ),
                        //       ),
                        //     ),
                        //   ),

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
                                "Login",
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
    double fontSize = 16,
    bool isRequired = false,
  }) {
    return Builder(
      builder: (ctx) {
        final baseStyle = Theme.of(ctx).textTheme.bodyLarge?.copyWith(
          fontSize: fontSize,
          color: Colors.black,
        );

        return TextFormField(
          controller: controller,
          validator:
              validator ?? (v) => (v == null || v.isEmpty) ? 'Required' : null,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
          decoration: InputDecoration(
            label: RichText(
              text: TextSpan(
                text: label,
                style: baseStyle,
                children: isRequired
                    ? [
                        TextSpan(
                          text: ' *',
                          style: baseStyle?.copyWith(color: Colors.red),
                        ),
                      ]
                    : [],
              ),
            ),
            prefixIcon: Icon(icon, color: Colors.black),
            filled: true,
            fillColor: const Color.fromARGB(255, 237, 239, 245),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildFieldWithRecaptcha({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Function(bool)? onFocusChange,
    bool isRequired = true,
    double fontSize = 16,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: Builder(
        builder: (ctx) {
          final baseStyle = Theme.of(ctx).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
            color: Colors.black,
          );

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            validator:
                validator ??
                (v) => (v == null || v.isEmpty) ? 'Required' : null,
            style: TextStyle(color: Colors.black, fontSize: fontSize),
            decoration: InputDecoration(
              label: RichText(
                text: TextSpan(
                  text: label,
                  style: baseStyle,
                  children: isRequired
                      ? [
                          TextSpan(
                            text: ' *',
                            style: baseStyle?.copyWith(color: Colors.red),
                          ),
                        ]
                      : [],
                ),
              ),
              prefixIcon: Icon(icon, color: Colors.black),
              // suffixIcon:
              //     _isRecaptchaVerified && focusNode == _firstNameFocusNode
              //     ? const Icon(Icons.verified, color: Colors.green)
              //     : null,
              filled: true,
              fillColor: const Color.fromARGB(255, 237, 239, 245),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}
