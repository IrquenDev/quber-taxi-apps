import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

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
    if (!mounted) return;
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      showToast(context: context, message: localization.resetSuccessMessage, durationInSeconds: 3);
    } else if (response.statusCode == 400) {
      showToast(context: context, message: localization.invalidCodeMessage, durationInSeconds: 3);
    } else {
      showToast(context: context, message: localization.unexpectedErrorMessage, durationInSeconds: 3);
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
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
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
