import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _phoneTFController = TextEditingController();
  final _passwordTFController = TextEditingController();
  var _obscureText = true;
  var _isLoading = false;
  final _authService = AuthService();

  String _normalizePhoneNumber(String phone) {
    // Remove all spaces and trim
    String cleanPhone = phone.trim().replaceAll(' ', '');
    
    // Remove + if present
    if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }
    
    // Remove country code (53) if present
    if (cleanPhone.startsWith('53') && cleanPhone.length > 8) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    return cleanPhone;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Get form data
      final phone = _normalizePhoneNumber(_phoneTFController.text);
      final password = _passwordTFController.text;
      final localization = AppLocalizations.of(context)!;
      
      // Init variables
      http.Response? response;
      String route;
      
      // Depending on appProfile, decide who we need to authenticate and set the next route
      if(runtime.isClientMode) {
        response = await _authService.loginClient(phone, password);
        route = ClientRoutes.home;
      } else if(runtime.isDriverMode) {
        response = await _authService.loginDriver(phone, password);
        route = DriverRoutes.home;
      } else {
        response = await _authService.loginAdmin(phone, password);
        route = AdminRoutes.settings;
      }
      
      // Handle response
      if(!mounted) return;
      
      switch (response.statusCode) {
        case 200: 
          context.go(route);
          break;
        case 401: 
          _showErrorToast(localization.incorrectPasswordMessage);
          break;
        case 404: 
          _showErrorToast(localization.phoneNotRegisteredMessage);
          break;
        default: 
          _showErrorToast(localization.unexpectedErrorLoginMessage);
          break;
      }
    } catch (e) {
      if(context.mounted) {
        final localization = AppLocalizations.of(context)!;
        _showErrorToast(localization.unexpectedErrorLoginMessage);
      }
    } finally {
      if(mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showErrorToast(String message) {
    showToast(
      context: context,
      message: message,
      durationInSeconds: 4
    );
  }

  @override
  Widget build(BuildContext context) {

    // Init Inherited Customizers
    final localization = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset("assets/images/login_background.png", fit: BoxFit.fill)),
          // Opacity Mask
          Positioned.fill(child: ColoredBox(color: colorScheme.shadow.withAlpha(200))),
          // Content
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  // Header Text
                  Text(
                    localization.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  SizedBox(height: 80),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phone Number Field
                        TextFormField(
                          controller: _phoneTFController,
                          keyboardType: TextInputType.phone,
                          maxLength: 12,
                          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                          errorBuilder: (context, value) => Text(
                              value,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.surface
                              )
                          ),
                          decoration: InputDecoration(
                            hintText: localization.enterPhoneNumber,
                            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                            fillColor: Colors.white.withValues(alpha: 0.7),
                            filled: true,
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return localization.requiredField;
                            }
                            final normalizedPhone = _normalizePhoneNumber(value);
                            if (normalizedPhone.length != 8 || !RegExp(r'^\d{8}$').hasMatch(normalizedPhone)) {
                              return localization.invalidPhoneMessage;
                            }
                            return null;
                          }
                        ),
                        SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                            controller: _passwordTFController,
                            obscureText: _obscureText,
                            maxLength: 20,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                            errorBuilder: (context, value) => Text(
                                value,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.surface
                                )
                            ),
                            decoration: InputDecoration(
                                hintText: localization.enterPassword,
                                hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: colorScheme.onSurfaceVariant),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                fillColor: Colors.white.withValues(alpha: 0.7),
                                filled: true,
                                counterText: '',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                    borderSide: BorderSide.none
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            ),
                            validator: Workflow<String?>()
                                .step(RequiredStep(errorMessage: localization.requiredField))
                                .withDefault((_)=> null)
                                .proceed
                        ),
                        SizedBox(height: 20),
                        // Login Button
                        SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                                onPressed: _isLoading ? null : () => _handleLogin(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading 
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                      ),
                                    )
                                  : Text(
                                      localization.loginButton,
                                      style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                                    )
                            )
                        ),
                        SizedBox(height: 8),
                        // Forgot Password
                        TextButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const ForgotPasswordDialog(),
                              );
                            },
                            child: Text(
                                localization.forgotPassword,
                                style: textTheme.bodyMedium?.copyWith(color: Colors.white)
                            )
                        ),
                        SizedBox(height: 4),
                        // Create New Account
                        if(runtime.isClientMode || runtime.isDriverMode)
                        TextButton(
                            onPressed: () {context.push(CommonRoutes.requestFaceId);},
                            child: Text(
                                localization.createAccountLogin,
                                style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary
                                )
                            )
                        ),
                        SizedBox(height: 50),
                      ]
                    )
                  )
                ]
              )
            )
          )
        )
        ]
      )
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String _normalizePhoneNumber(String phone) {
    // Remove all spaces and trim
    String cleanPhone = phone.trim().replaceAll(' ', '');

    // Remove + if present
    if (cleanPhone.startsWith('+')) {
      cleanPhone = cleanPhone.substring(1);
    }
    
    // Remove country code (53) if present
    if (cleanPhone.startsWith('53') && cleanPhone.length > 8) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    return cleanPhone;
  }

  void _submitPhoneNumber() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) return;
    
    final normalizedPhone = _normalizePhoneNumber(_phoneController.text);
    final localization = AppLocalizations.of(context)!;

    final response = await _authService.requestPasswordReset(normalizedPhone);

    if (!context.mounted) return;

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PasswordResetStepDialog(phone: normalizedPhone),
      );
    } else {
      showToast(
        context: context,
        message: localization.codeSendErrorMessage,
        durationInSeconds: 3,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(localization.recoverPassword,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(localization.recoverPasswordDescription,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 12,
              decoration: InputDecoration(
                counterText: '',
                hintText: localization.enterPhoneNumber,
                filled: true,
                fillColor: theme.colorScheme.onSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localization.requiredField;
                }
                final normalizedPhone = _normalizePhoneNumber(value);
                if (normalizedPhone.length != 8 || !RegExp(r'^\d{8}$').hasMatch(normalizedPhone)) {
                  return localization.invalidPhoneMessage;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _submitPhoneNumber();
                },
                                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                    ),
                  ),
                child: Text(localization.sendButton),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class PasswordResetStepDialog extends StatefulWidget {
  final String phone;
  const PasswordResetStepDialog({super.key, required this.phone});

  @override
  State<PasswordResetStepDialog> createState() => _PasswordResetStepDialogState();
}

class _PasswordResetStepDialogState extends State<PasswordResetStepDialog> {

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _obscure = true;
  bool _obscure1 = true;

  void _submitReset() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final localization = AppLocalizations.of(context)!;

    if (code.isEmpty || password.isEmpty || confirm.isEmpty) {
      showToast(context: context, message: localization.allFieldsRequiredMessage);
      return;
    }

    if (password != confirm) {
      showToast(context: context, message: localization.passwordsDoNotMatchMessage);
      return;
    }

    final response = await _authService.resetPassword(
      phone: widget.phone,
      code: code,
      newPassword: password,
    );

    if (!context.mounted) return;
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showToast(
        context: context,
        message: localization.resetSuccessMessage,
        durationInSeconds: 3
      );
    } else if (response.statusCode == 400) {
      showToast(
        context: context,
        message: localization.invalidCodeMessage,
        durationInSeconds: 3
      );
    } else {
      showToast(
        context: context,
        message: localization.unexpectedErrorMessage,
        durationInSeconds: 3
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(localization.resetPasswordTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: localization.verificationCodeHint,
                  fillColor: theme.colorScheme.onSecondary,
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: localization.newPasswordHint,
                  fillColor: theme.colorScheme.onSecondary,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  filled: true,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  hintText: localization.confirmPasswordLabel,
                  fillColor: theme.colorScheme.onSecondary,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _submitReset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius)),
                  ),
                  child: Text(localization.resetButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

