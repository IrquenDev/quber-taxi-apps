import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:quber_taxi/common/pages/login/dialogs/forgot_password_dialog.dart';
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
    // Always hide keyboard
    FocusScope.of(context).unfocus();
    // Skip if form has invalid data
    if (!_formKey.currentState!.validate()) return;
    // Check connection
    if (runtime.hasConnection(context)) {
      // Enable loading state
      setState(() => _isLoading = true);
      // Get form data
      final phone = _normalizePhoneNumber(_phoneTFController.text);
      final password = _passwordTFController.text;
      final localization = AppLocalizations.of(context)!;
      // Depending on appProfile, decide who we need to authenticate and set the next route
      http.Response? response;
      String route;
      if (runtime.isClientMode) {
        response = await _authService.loginClient(phone, password);
        route = ClientRoutes.home;
      } else if (runtime.isDriverMode) {
        response = await _authService.loginDriver(phone, password);
        route = DriverRoutes.home;
      } else {
        response = await _authService.loginAdmin(phone, password);
        route = AdminRoutes.settings;
      }
      // Cancel loading state
      setState(() => _isLoading = false);
      // Handle response
      if (!mounted) return;
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
    } else {
      showToast(context: context, message: "Por favor verifique su conexión a internet", durationInSeconds: 4);
    }
  }

  void _showErrorToast(String message) {
    showToast(context: context, message: message, durationInSeconds: 4);
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    // Header Text
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints){
                            double fontsize = constraints.maxWidth * 0.2;
                            return Text(
                              localization.welcomeTitle,
                              textAlign: TextAlign.center,
                              style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSecondary,
                              fontSize: fontsize,
                            ),
                            );
                          },
                        ),

                      ),
                    ),
                    // Form
                    Expanded(
                      flex: 6,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: 20.0,
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
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
                            // Password Field
                            TextFormField(
                              controller: _passwordTFController,
                              obscureText: _obscureText,
                              maxLength: 20,
                              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                              errorBuilder: (context, value) => Text(
                                value,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                              ),
                              decoration: InputDecoration(
                                hintText: localization.enterPassword,
                                hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                                fillColor: Colors.white.withValues(alpha: 0.7),
                                filled: true,
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              ),
                              validator: Workflow<String?>()
                                  .step(RequiredStep(errorMessage: localization.requiredField))
                                  .withDefault((_) => null)
                                  .proceed,
                            ),
                            // Login Button
                            _isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: () => _handleLogin(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        localization.loginButton,
                                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
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
                                style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                            // Create New Account
                            if (runtime.isClientMode || runtime.isDriverMode)
                              TextButton(
                                onPressed: () => context.push(CommonRoutes.requestFaceId),
                                child: Text(
                                  localization.createAccountLogin,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
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
          )
        ],
      ),
    );
  }
}
