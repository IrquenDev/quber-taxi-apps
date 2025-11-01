import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/common/pages/login/dialogs/reset_password_step_dialog.dart';
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  var _isLoading = false;

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
    // Set loading state to prevent multiple submissions
    setState(() => _isLoading = true);
    final normalizedPhone = _normalizePhoneNumber(_phoneController.text);
    final localization = AppLocalizations.of(context)!;
    final response = await _authService.requestPasswordReset(normalizedPhone);
    // Reset loading state
    setState(() => _isLoading = false);
    if (!mounted) return;
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
                  Text(
                    localization.recoverPassword,
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
              Text(
                localization.recoverPasswordDescription,
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
                  onPressed: _isLoading
                      ? null
                      : () {
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
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(localization.sendButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
