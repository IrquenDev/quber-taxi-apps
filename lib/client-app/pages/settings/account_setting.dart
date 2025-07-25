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
import 'package:quber_taxi/common/widgets/cached_profile_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _accountService = AccountService();
  final _client = Client.fromJson(loggedInUser);
  late TextEditingController _nameTFController;
  late TextEditingController _phoneTFController;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  XFile? _profileImage;
  String? _initialProfileImageUrl;
  bool get _shouldUpdateImage =>
    _profileImage != null ||
    (_profileImage == null && _initialProfileImageUrl == null && _client.profileImageUrl != null);
  bool _isProcessingImage = false;
  bool _isSubmittingPersonalInfo = false;
  bool _isSubmittingPasswords = false;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _personalInfoKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameTFController = TextEditingController(text: _client.name);
    _phoneTFController = TextEditingController(text: _client.phone);
    _initialProfileImageUrl = _client.profileImageUrl;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _validateAndSavePersonalInfo() {
    setState(() {});
    if (_personalInfoFormKey.currentState!.validate()) {
      _savePersonalInfo();
    }
  }

  void _validateAndSavePasswords() {
    setState(() {});
    if (_passwordFormKey.currentState!.validate()) {
      _savePasswords();
    }
  }

  Future<void> _savePersonalInfo() async {
    final localization = AppLocalizations.of(context)!;
    if (!hasConnection(context)) {
      showToast(context: context, message: localization.checkConnection);
      return;
    }
    setState(() {
      _isSubmittingPersonalInfo = true;
    });
    try {
      final shouldUpdateImage = _shouldUpdateImage;
      final response = await _accountService.updateClient(
        _client.id,
        _nameTFController.text,
        _phoneTFController.text,
        _profileImage,
        shouldUpdateImage,
      );
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        final client = Client.fromJson(jsonDecode(response.body));
        await SessionManager.instance.save(client);
        setState(() {
          _profileImage = null;
          _initialProfileImageUrl = client.profileImageUrl;
        });
        showToast(context: context, message: localization.profileUpdatedSuccessfully);
      } else if (response.statusCode == 409) {
        showToast(context: context, message: localization.phoneAlreadyRegistered);
      } else {
        showToast(context: context, message: localization.somethingWentWrong);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context: context, message: localization.somethingWentWrong);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingPersonalInfo = false;
        });
      }
    }
  }

  Future<void> _savePasswords() async {
    final localization = AppLocalizations.of(context)!;
    if (!hasConnection(context)) {
      showToast(context: context, message: localization.checkConnection);
      return;
    }
    setState(() {
      _isSubmittingPasswords = true;
    });
    try {
      final response = await _accountService.updateClientPassword(
        _client.id,
        _passwordController.text,
      );
      if (!context.mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
        showToast(context: context, message: localization.updatePasswordSuccess);
      } else {
        showToast(context: context, message: localization.somethingWentWrong);
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context: context, message: localization.somethingWentWrong);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingPasswords = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Container(color: colorScheme.onSecondary),
          // Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(dimensions.borderRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Card 1: Personal Information
                  Container(
                    key: _personalInfoKey,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                    ),
                    child: Form(
                      key: _personalInfoFormKey,
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              key: _imageKey,
                              children: [
                                _buildCircleImagePicker(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _nameTFController,
                            label: localization.name,
                            hint: localization.nameAndLastName,
                            maxLength: 50,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneTFController,
                            label: localization.phoneNumber,
                            hint: localization.phoneNumber,
                            inputType: TextInputType.phone,
                            maxLength: 8,
                            readOnly: true,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                ),
                              ),
                              onPressed: _isSubmittingPersonalInfo ? null : _validateAndSavePersonalInfo,
                              child: _isSubmittingPersonalInfo
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimaryContainer),
                                      ),
                                    )
                                  : Text(
                                      localization.save,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 2: Passwords
                  Container(
                    key: _passwordKey,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                    ),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            controller: _passwordController,
                            label: localization.passwordLabel,
                            hint: localization.passwordHint,
                            visible: passwordVisible,
                            onToggle: (v) => setState(() => passwordVisible = v),
                            validationWorkflow: Workflow<String?>()
                                .step(RequiredStep(errorMessage: localization.requiredField))
                                .step(MinLengthStep(min: 6, errorMessage: localization.passwordMinLengthError))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null),
                          ),
                          const SizedBox(height: 24),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: localization.confirmPasswordLabel,
                            hint: localization.confirmPasswordHint,
                            visible: confirmPasswordVisible,
                            onToggle: (v) => setState(() => confirmPasswordVisible = v),
                            validationWorkflow: Workflow<String?>()
                                .step(RequiredStep(errorMessage: localization.requiredField))
                                .step(MatchOtherStep(
                                  other: _passwordController.text,
                                  errorMessage: localization.passwordsDoNotMatch,
                                ))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                                ),
                              ),
                              onPressed: _isSubmittingPasswords ? null : _validateAndSavePasswords,
                              child: _isSubmittingPasswords
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimaryContainer),
                                      ),
                                    )
                                  : Text(
                                      localization.saveButtonPanel,
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                            // Referral Code Card
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
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
                  // Card 3: About Us/Dev
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(
                          icon: Icons.local_taxi,
                          text: localization.aboutUs,
                          onTap: () => context.push(CommonRoutes.aboutUs),
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant,
                          indent: 12,
                          endIndent: 12,
                        ),
                        _buildMenuItem(
                          icon: Icons.code,
                          text: localization.aboutDeveloper,
                          onTap: () => context.push(CommonRoutes.aboutDev),
                        ),
                      ],
                    ),
                  ),
                  // Logout
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: _buildLogoutItem(
                      text: localization.logout,
                      icon: Icons.logout,
                      textColor: colorScheme.error,
                      iconColor: colorScheme.error,
                      onTap: () async {
                        await SessionManager.instance.clear();
                        if (!context.mounted) return;
                        context.go(CommonRoutes.login);
                      },
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Removed back button
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: Text(
                        localization.myAccount,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading overlay for image processing
          if (_isProcessingImage)
            Positioned.fill(
              child: Container(
                color: colorScheme.scrim.withOpacity(0.6),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? inputType,
    int? maxLength,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: inputType ?? TextInputType.text,
          controller: controller,
          maxLength: maxLength,
          readOnly: readOnly,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
          validator: (value) => Workflow<String?>()
              .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
              .withDefault((_) => null)
              .proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool visible,
    required Function(bool) onToggle,
    required Workflow<String?> validationWorkflow,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
          validator: (value) => validationWorkflow.proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => onToggle(!visible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _profileImage != null
              ? CircleAvatar(
                  radius: 80,
                  backgroundColor: colorScheme.onSecondary,
                  backgroundImage: FileImage(File(_profileImage!.path)),
                )
              : CachedProfileImage(
                  radius: 80,
                  imageUrl: _initialProfileImageUrl != null
                      ? "${ApiConfig().baseUrl}/${_initialProfileImageUrl}"
                      : null,
                  backgroundColor: colorScheme.onSecondary,
                  placeholderAsset: "assets/icons/user.svg",
                  placeholderColor: colorScheme.onSecondaryContainer,
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                (_profileImage != null || _initialProfileImageUrl != null)
                    ? "assets/icons/close.svg"
                    : "assets/icons/camera.svg",
                color: colorScheme.onSecondaryContainer,
                fit: BoxFit.scaleDown,
                width: 28, // Forces the SVG size
                height: 28,
              ),
              onPressed: () async {
                if (_profileImage != null || _client.profileImageUrl != null || _initialProfileImageUrl != null) {
                  setState(() {
                    _profileImage = null;
                    _initialProfileImageUrl = null;
                  });
                } else {
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
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Theme.of(context).extension<DimensionExtension>()!.buttonBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Theme.of(context).extension<DimensionExtension>()!.buttonBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Spacer(),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}