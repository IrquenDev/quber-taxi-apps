import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  final _accountService = AccountService();
  final _client = Client.fromJson(loggedInUser);

  final _formKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();
  late TextEditingController _nameTFController;
  late TextEditingController _phoneTFController;
  final _passwordTFController = TextEditingController();
  final _confirmPasswordTFController = TextEditingController();

  XFile? _profileImage;
  bool get _shouldUpdateImage => _profileImage != null || (_profileImage == null && _client.profileImageUrl != null);
  bool _isProcessingImage = false;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _nameTFController = TextEditingController(text: _client.name);
    _phoneTFController = TextEditingController(text: _client.phone);
    _nameTFController.addListener(_onProfileFieldChanged);
    _phoneTFController.addListener(_onProfileFieldChanged);
    _passwordTFController.addListener(_onPasswordFieldChanged);
    _confirmPasswordTFController.addListener(_onPasswordFieldChanged);
  }

  bool _isProfileFieldsValid = false;
  bool _isPasswordFieldsValid = false;

  void _onProfileFieldChanged() {
    final valid = _nameTFController.text.trim().isNotEmpty &&
        _phoneTFController.text.trim().isNotEmpty &&
        _phoneTFController.text.trim().length == 8 &&
        RegExp(r'^\d{8}$').hasMatch(_phoneTFController.text.trim());
    if (_isProfileFieldsValid != valid) {
      setState(() {
        _isProfileFieldsValid = valid;
      });
    }
  }

  void _onPasswordFieldChanged() {
    final valid = _passwordTFController.text.isNotEmpty &&
        _confirmPasswordTFController.text.isNotEmpty &&
        _passwordTFController.text.length >= 6 &&
        _passwordTFController.text == _confirmPasswordTFController.text;
    if (_isPasswordFieldsValid != valid) {
      setState(() {
        _isPasswordFieldsValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = Theme.of(context).extension<DimensionExtension>()!.borderRadius;
    return Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: Stack(
            children: [
              // Yellow App Bar as Header
              Positioned(
                  top: 0,
                  right: 0.0,
                  left: 0.0,
                  child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ]
                      ),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: SafeArea(
                              child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Row(
                                      children: [
                                        const SizedBox(width: 28, height: 80),
                                        Text(AppLocalizations.of(context)!.settingsHome,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.secondary,
                                            ))
                                      ]
                                  )
                              )
                          )
                      )
                  )
              ),
              // Scrollable Content
              Positioned(
                  top: 100.0,
                  left: 20.0,
                  right: 20.0,
                  bottom: 0.0,
                  child: SingleChildScrollView(
                      child: Column(
                          children: [
                            // Edit Profile Info Card
                            Container(
                                padding: const EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                      children: [
                                        // Circle Image
                                        _buildCircleImage(),
                                        const SizedBox(height: 16),
                                        _buildTextField(AppLocalizations.of(context)!.name, AppLocalizations.of(context)!.nameAndLastName, _nameTFController),
                                        const SizedBox(height: 16),
                                        _buildTextField(AppLocalizations.of(context)!.phoneNumber, AppLocalizations.of(context)!.phoneNumber, _phoneTFController),
                                        const SizedBox(height: 16),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: OutlinedButton(
                                                onPressed: _isProfileFieldsValid && !_isSavingProfile ? () async {
                                                  FocusScope.of(context).unfocus();
                                                  setState(() {
                                                    _isSavingProfile = true;
                                                  });
                                                  if (hasConnection(context)) {
                                                    if (_formKey.currentState!.validate()) {
                                                      final response = await _accountService.updateClient(
                                                          _client.id,
                                                          _nameTFController.text,
                                                          _phoneTFController.text,
                                                          _profileImage,
                                                          _shouldUpdateImage);
                                                      if (!context.mounted) return;
                                                      if (response.statusCode == 200) {
                                                        final client = Client.fromJson(jsonDecode(response.body));
                                                        // Update session's data
                                                        SessionManager.instance.save(client);
                                                        _profileImage = null;
                                                        showToast(context: context, message: AppLocalizations.of(context)!.saveInformation);
                                                      } else if (response.statusCode == 409) {
                                                        showToast(
                                                            context: context,
                                                            message: AppLocalizations.of(context)!.phoneAlreadyRegistered);
                                                      } else {
                                                        showToast(
                                                            context: context,
                                                            message: AppLocalizations.of(context)!.somethingWentWrong);
                                                      }
                                                      setState(() {
                                                        _isSavingProfile = false;
                                                      });
                                                    }
                                                  } else {
                                                    showToast(context: context, message: AppLocalizations.of(context)!.checkConnection);
                                                    setState(() {
                                                      _isSavingProfile = false;
                                                    });
                                                  }
                                                } : null,
                                                child: Text(AppLocalizations.of(context)!.saveButtonPanel,
                                                    style: Theme.of(context).textTheme.bodyMedium
                                                        ?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)))
                                        )
                                      ]
                                  ),
                                )
                            ),
                            const SizedBox(height: 16),
                            // Edit Password Card
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                child: Form(
                                    key: _passFormKey,
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildPasswordField(
                                              label: AppLocalizations.of(context)!.passwordLabel,
                                              visible: passwordVisible,
                                              onToggle: (v) => setState(() => passwordVisible = v),
                                              controller: _passwordTFController,
                                              validator: Workflow<String?>()
                                                  .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                                  .step(MinLengthStep(min: 6, errorMessage: AppLocalizations.of(context)!.passwordMinLength))
                                                  .breakOnFirstApply(true)
                                                  .withDefault((_) => null)
                                                  .proceed),
                                          const SizedBox(height: 12),
                                          _buildPasswordField(
                                              label: AppLocalizations.of(context)!.confirmPasswordLabel,
                                              visible: confirmPasswordVisible,
                                              onToggle: (v) => setState(() => confirmPasswordVisible = v),
                                              controller: _confirmPasswordTFController,
                                              validator: Workflow<String?>()
                                                  .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                                  .step(MatchOtherStep(
                                                  other: _passwordTFController.text,
                                                  errorMessage: AppLocalizations.of(context)!.passwordsDoNotMatch))
                                                  .breakOnFirstApply(true)
                                                  .withDefault((_) => null)
                                                  .proceed),
                                          const SizedBox(height: 12),
                                          OutlinedButton(
                                              onPressed: _isPasswordFieldsValid && !_isSavingProfile ? () async {
                                                FocusScope.of(context).unfocus();
                                                if (hasConnection(context)) {
                                                  if (_passFormKey.currentState!.validate()) {
                                                    final response = await _accountService.updateClientPassword(
                                                        _client.id, _passwordTFController.text);
                                                    if (!context.mounted) return;
                                                    if (response.statusCode == 200) {
                                                      _passwordTFController.clear();
                                                      _confirmPasswordTFController.clear();
                                                      showToast(context: context, message: AppLocalizations.of(context)!.saveButtonPanel);
                                                    } else {
                                                      showToast(
                                                          context: context,
                                                          message: AppLocalizations.of(context)!.somethingWentWrong);
                                                    }
                                                  }
                                                } else {
                                                  showToast(context: context, message: AppLocalizations.of(context)!.checkConnection);
                                                }
                                              } : null,
                                              child: Text(AppLocalizations.of(context)!.saveButtonPanel,
                                                  style: Theme.of(context).textTheme.bodyMedium
                                                      ?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)))
                                        ]
                                    )
                                )
                            ),
                            const SizedBox(height: 16),
                            // Referral Code Card
                            Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!.myDiscountCode,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.secondary
                                          )
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          AppLocalizations.of(context)!.inviteFriendDiscount,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: colorScheme.outline),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Text(_client.referralCode)
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: _client.referralCode));
                                                showToast(context: context, message: AppLocalizations.of(context)!.copied);
                                              },
                                            )
                                          ]
                                      )
                                    ]
                                )
                            ),
                            const SizedBox(height: 16),
                            // About Us/Dev Card
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(radius),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.local_taxi),
                                    title: Text(AppLocalizations.of(context)!.aboutUs,
                                        style: Theme.of(context).textTheme.bodyLarge
                                            ?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                                    onTap: () => context.push(CommonRoutes.aboutUs),
                                  ),
                                  const Divider(height: 1),
                                  ListTile(
                                    leading: const Icon(Icons.code),
                                    title: Text(AppLocalizations.of(context)!.aboutDeveloper,
                                        style: Theme.of(context).textTheme.bodyLarge
                                            ?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                                    onTap: () => context.push(CommonRoutes.aboutDev),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: 56,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            foregroundColor: colorScheme.errorContainer,
                                            textStyle: Theme.of(context).textTheme.bodyLarge
                                                ?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          icon: Icon(Icons.logout, color: colorScheme.errorContainer),
                                          label: Text(AppLocalizations.of(context)!.logout),
                                          onPressed: () async {
                                            await SessionManager.instance.clear();
                                            if (!context.mounted) return;
                                            context.go(CommonRoutes.login);
                                          }
                                      ),
                                    )
                                )
                            ),
                            // Just for space, to don't hide the logout button, 'cause home's Scaffold is using extendedBody.
                            const SizedBox(height: 70),
                          ]
                      )
                  )
              ),
              if (_isProcessingImage)
                const Positioned.fill(child: Center(child: CircularProgressIndicator())),
              if (_isSavingProfile)
                Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(child: CircularProgressIndicator()),
                    ))
            ]
        )
    );
  }

  Widget _buildCircleImage() {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
              child: SizedBox(
                  height: 160,
                  width: 160,
                  child: _profileImage != null
                      ? Image.file(File(_profileImage!.path), fit: BoxFit.cover)
                      : _client.profileImageUrl != null
                      ? Image.network("${ApiConfig().baseUrl}/${_client.profileImageUrl}", fit: BoxFit.cover)
                      : ColoredBox(color: randomColor())
              )
          ),
          Positioned(
              bottom: 8.0,
              right: 8.0,
              child: GestureDetector(
                onTap: () async {
                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    setState(() => _isProcessingImage = true);
                    final compressedImage = await compressXFileToTargetSize(pickedImage, 5);
                    setState(() => _isProcessingImage = false);
                    if (compressedImage != null) {
                      setState(() {
                        _profileImage = compressedImage;
                      });
                    }
                  }
                },
                child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.surface,
                    child: const Icon(Icons.add_a_photo)
                ),
              )
          )
        ]
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
              controller: controller,
              keyboardType: label == AppLocalizations.of(context)!.phoneNumber ? TextInputType.phone : TextInputType.text,
              maxLength: label == AppLocalizations.of(context)!.phoneNumber ? 8 : null,
              decoration: InputDecoration(
                hintText: hint,
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: label == AppLocalizations.of(context)!.phoneNumber ? '' : null,
              ),
              validator: (value) {
                if (label == AppLocalizations.of(context)!.phoneNumber) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.requiredField;
                  }
                  final normalizedPhone = value.trim().replaceAll(' ', '');
                  if (normalizedPhone.length != 8 || !RegExp(r'^\d{8}$').hasMatch(normalizedPhone)) {
                    return AppLocalizations.of(context)!.invalidPhoneMessage;
                  }
                  return null;
                } else {
                  return Workflow<String?>()
                      .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                      .withDefault((_) => null)
                      .proceed(value);
                }
              }
          )
        ]
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool visible,
    required Function(bool) onToggle,
    required TextEditingController controller,
    required String? Function(String?) validator
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: !visible,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.hintPassword,
              fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: IconButton(
                icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => onToggle(!visible),
              ),
            ),
            validator: validator,
          )
        ]
    );
  }
}