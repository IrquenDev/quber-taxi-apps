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
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    // Init Inherited Customizers
    final localization = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: Image.asset("assets/images/login_background.png", fit: BoxFit.fill)),
          // Opacity Mask
          Positioned.fill(child: ColoredBox(color: colorScheme.shadow.withAlpha(200))),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Text
                  Text(
                    localization.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                  SizedBox(height: 60),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20.0,
                      children: [
                        // Phone Number TF
                        TextFormField(
                          controller: _phoneTFController,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          errorBuilder: (context, value) => Text(
                              value,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.surface
                              )
                          ),
                          decoration: InputDecoration(
                            hintText: localization.enterPhoneNumber,
                            fillColor: colorScheme.surfaceContainer,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: Workflow<String?>()
                              .step(RequiredStep(errorMessage: localization.requiredField))
                              .withDefault((_)=> null)
                              .proceed
                        ),
                        // Password TF
                        TextFormField(
                            controller: _passwordTFController,
                            obscureText: _obscureText,
                            errorBuilder: (context, value) => Text(
                                value,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.surface
                                )
                            ),
                            decoration: InputDecoration(
                                hintText: localization.enterPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                fillColor: colorScheme.surfaceContainer,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                    borderSide: BorderSide.none
                                )
                            ),
                            validator: Workflow<String?>()
                                .step(RequiredStep(errorMessage: localization.requiredField))
                                .withDefault((_)=> null)
                                .proceed
                        ),
                        // Login Button
                        SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  // Validate form
                                  if (_formKey.currentState!.validate()) {
                                    // Get form data
                                    final phone = _phoneTFController.text;
                                    final password = _passwordTFController.text;
                                    // Check connection
                                    //if(runtime.hasConnection(context)) return;
                                    // Init var
                                    http.Response? response;
                                    String route;
                                    // Depending on appProfile decides who we need to authenticate and set the next
                                    // route.
                                    if(runtime.isClientMode) {
                                      response = await _authService.loginClient(phone, password);
                                      route = ClientRoutes.home;
                                    } else if(runtime.isDriverMode) {
                                      response = await _authService.loginDriver(phone, password);
                                      response = await _authService.loginDriver(phone, password);
                                      route = DriverRoutes.home;
                                    } else {
                                      response = await _authService.loginAdmin(phone, password);
                                      route = AdminRoutes.settings;
                                    }
                                    // Handle response
                                    if(!context.mounted) return;
                                    switch (response.statusCode) {
                                      case 200: context.go(route);
                                      case 401: showToast(context: context,
                                          message: localization.incorrectPasswordMessage,
                                          duration: const Duration(seconds: 4));
                                      case 404: showToast(context: context,
                                          message: localization.phoneNotRegisteredMessage,
                                          duration: const Duration(seconds: 4));
                                      default: showToast(context: context,
                                          message: localization.unexpectedErrorLoginMessage,
                                          duration: const Duration(seconds: 4));
                                    }
                                  }
                                },
                                child: Text(
                                    localization.loginButton,
                                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                                )
                            )
                        ),
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
                        // Create New Account
                        if(runtime.isClientMode || runtime.isDriverMode)
                        TextButton(
                            onPressed: () {context.push(CommonRoutes.requestFaceId);},
                            child: Text(
                                localization.createAccountLogin,
                                style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primaryFixedDim
                                )
                            )
                        )
                      ]
                    )
                  )
                ]
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

  void _submitPhoneNumber() async {
    final phone = _phoneController.text.trim();
    final localization = AppLocalizations.of(context)!;

    if (phone.length == 8 && RegExp(r'^\d{8}$').hasMatch(phone)) {
      final response = await _authService.requestPasswordReset(phone);

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PasswordResetStepDialog(phone: phone),
        );
      } else {
        showToast(
          context: context,
          message: localization.codeSendErrorMessage,
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      showToast(
        context: context,
        message: localization.invalidPhoneMessage,
        duration: const Duration(seconds: 3),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: InputDecoration(
                counterText: '',
                hintText: localization.enterPhoneNumber,
                filled: true,
                fillColor: theme.colorScheme.onSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(localization.sendButton),
              ),
            ),
          ],
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
        duration: const Duration(seconds: 3),
      );
    } else if (response.statusCode == 400) {
      showToast(
        context: context,
        message: localization.invalidCodeMessage,
        duration: const Duration(seconds: 3),
      );
    } else {
      showToast(
        context: context,
        message: localization.unexpectedErrorMessage,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

