import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';

import '../../../common/models/driver.dart';
import '../../../common/models/taxi.dart';
import '../../../common/services/account_service.dart';
import '../../../config/api_config.dart';
import '../../../utils/image/image_utils.dart';
import '../../../utils/runtime.dart';
import '../../../utils/workflow/core/workflow.dart';
import '../../../utils/workflow/impl/form_validations.dart';
import '../../../common/widgets/cached_profile_image.dart';
import '../../../utils/image/image_cache_service.dart';

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  State<DriverSettingsPage> createState() => _DriverAccountSettingPage();
}

class _DriverAccountSettingPage extends State<DriverSettingsPage> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _accountService = AccountService();
  final _driver = Driver.fromJson(loggedInUser);
  late final Taxi _taxi;
  late TextEditingController _nameTFController;
  late TextEditingController _plateTFController;
  late TextEditingController _phoneTFController;
  late TextEditingController _seatTFController;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  XFile? _profileImage;
  bool get _shouldUpdateImage => _taxi.imageUrl != null;
  bool _isProcessingImage = false;
  bool _isSubmittingPersonalInfo = false;
  bool _isSubmittingPasswords = false;

  // Error states for grouped validation
  bool _showImageError = false;
  bool _showPersonalInfoErrors = false;
  bool _showPasswordErrors = false;

  // Scroll controller and keys for error navigation
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _personalInfoKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _taxi = _driver.taxi;
    _nameTFController = TextEditingController(text: _driver.name);
    _plateTFController = TextEditingController(text: _taxi.plate);
    _phoneTFController = TextEditingController(text: _driver.phone);
    _seatTFController = TextEditingController(text: _taxi.seats.toString());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToWidget(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToFirstPersonalInfoError() {
    if (!_personalInfoFormKey.currentState!.validate()) {
      _scrollToWidget(_personalInfoKey);
    } else if (_profileImage == null && _taxi.imageUrl == null) {
      _scrollToWidget(_imageKey);
    }
  }

  void _scrollToFirstPasswordError() {
    if (!_passwordFormKey.currentState!.validate()) {
      _scrollToWidget(_passwordKey);
    }
  }

  void _validateAndSavePersonalInfo() {
    setState(() {
      _showPersonalInfoErrors = true;
      _showImageError = _profileImage == null && _taxi.imageUrl == null;
    });

    if (_personalInfoFormKey.currentState!.validate() &&
        (_profileImage != null || _taxi.imageUrl != null)) {
      _savePersonalInfo();
    } else {
      _scrollToFirstPersonalInfoError();
    }
  }

  void _validateAndSavePasswords() {
    setState(() {
      _showPasswordErrors = true;
    });

    if (_passwordFormKey.currentState!.validate()) {
      _savePasswords();
    } else {
      _scrollToFirstPasswordError();
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
      final seats = int.tryParse(_seatTFController.text) ?? 0;
      final response = await _accountService.updateDriver(
          _driver.id,
          _nameTFController.text,
          _phoneTFController.text,
          seats,
          _plateTFController.text,
          _profileImage,
          _shouldUpdateImage);

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        final driver = Driver.fromJson(jsonDecode(response.body));
        await SessionManager.instance.save(driver);

        // Clear old image from cache if a new image was uploaded
        if (_shouldUpdateImage && _taxi.imageUrl != null) {
          await ImageCacheService()
              .removeFromCache("${ApiConfig().baseUrl}/${_taxi.imageUrl}");
        }

        setState(() {
          _profileImage = null;
          _showImageError = false;
          _showPersonalInfoErrors = false;
        });
        showToast(
            context: context, message: localization.profileUpdatedSuccessfully);
      } else if (response.statusCode == 409) {
        showToast(
            context: context, message: localization.phoneAlreadyRegistered);
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
      final response = await _accountService.updateDriverPassword(
          _driver.id, _passwordController.text);

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _passwordController.clear();
          _confirmPasswordController.clear();
          _showPasswordErrors = false;
        });
        showToast(
            context: context, message: localization.updatePasswordSuccess);
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
                    bottom: Radius.circular(dimensions.borderRadius)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                          dimensions.cardBorderRadiusLarge),
                    ),
                    child: Form(
                      key: _personalInfoFormKey,
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              key: _imageKey,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final pickedImage = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedImage != null) {
                                      setState(() => _isProcessingImage = true);
                                      final compressedImage =
                                          await compressXFileToTargetSize(
                                              pickedImage, 5);
                                      setState(
                                          () => _isProcessingImage = false);
                                      if (compressedImage != null) {
                                        setState(() {
                                          _profileImage = compressedImage;
                                          _showImageError = false;
                                        });
                                      }
                                    }
                                  },
                                  child: _buildCircleImagePicker(),
                                ),
                                if (_showImageError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      localization.requiredField,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            spacing: 12.0,
                            children: [
                              _buildTextField(
                                controller: _nameTFController,
                                label: localization.nameDriver,
                                hint: localization.nameHint,
                                maxLength: 50,
                              ),
                              _buildTextField(
                                controller: _plateTFController,
                                label: localization.carRegistration,
                                hint: localization.plateHint,
                                maxLength: 7,
                              ),
                              _buildTextField(
                                controller: _phoneTFController,
                                label: localization.phoneNumberDriver,
                                hint: localization.phoneHint,
                                inputType: TextInputType.phone,
                                maxLength: 8,
                              ),
                              _buildTextField(
                                controller: _seatTFController,
                                label: localization.numberOfSeats,
                                hint: localization.seatsHint,
                                inputType: TextInputType.number,
                                maxLength: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      dimensions.buttonBorderRadius),
                                ),
                              ),
                              onPressed: _isSubmittingPersonalInfo
                                  ? null
                                  : _validateAndSavePersonalInfo,
                              child: _isSubmittingPersonalInfo
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimaryContainer),
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

                  // Card 2: Balance
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                          dimensions.cardBorderRadiusLarge),
                    ),
                    child: _buildBalanceBox(),
                  ),

                  // Card 3: Passwords
                  Container(
                    key: _passwordKey,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                          dimensions.cardBorderRadiusLarge),
                    ),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        spacing: 12.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            controller: _passwordController,
                            label: localization.passwordLabel,
                            hint: localization.passwordHint,
                            visible: passwordVisible,
                            onToggle: (v) =>
                                setState(() => passwordVisible = v),
                            validationWorkflow: Workflow<String?>()
                                .step(RequiredStep(
                                    errorMessage: localization.requiredField))
                                .step(MinLengthStep(
                                    min: 6,
                                    errorMessage:
                                        localization.passwordMinLengthError))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null),
                          ),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            label: localization.confirmPasswordLabel,
                            hint: localization.confirmPasswordHint,
                            visible: confirmPasswordVisible,
                            onToggle: (v) =>
                                setState(() => confirmPasswordVisible = v),
                            validationWorkflow: Workflow<String?>()
                                .step(RequiredStep(
                                    errorMessage: localization.requiredField))
                                .step(MatchOtherStep(
                                  other: _passwordController.text,
                                  errorMessage:
                                      localization.passwordsDoNotMatch,
                                ))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primaryContainer,
                                foregroundColor: colorScheme.onPrimaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      dimensions.buttonBorderRadius),
                                ),
                              ),
                              onPressed: _isSubmittingPasswords
                                  ? null
                                  : _validateAndSavePasswords,
                              child: _isSubmittingPasswords
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                colorScheme.onPrimaryContainer),
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

                  // Additional Options Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(
                          dimensions.cardBorderRadiusLarge),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(
                          icon: Icons.drive_eta_outlined,
                          text: localization.aboutUs,
                          onTap: () => context.push(CommonRoutes.aboutUs),
                        ),
                        Divider(
                            height: 1,
                            color: colorScheme.outlineVariant,
                            indent: 12,
                            endIndent: 12),
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
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: colorScheme.onPrimaryContainer,
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localization.myAccount,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
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
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: inputType ?? TextInputType.text,
          controller: controller,
          maxLength: maxLength,
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              const SizedBox.shrink(),
          validator: (value) => Workflow<String?>()
              .step(RequiredStep(
                  errorMessage: AppLocalizations.of(context)!.requiredField))
              .withDefault((_) => null)
              .proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
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
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          maxLength: maxLength,
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              const SizedBox.shrink(),
          validator: (value) => validationWorkflow.proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => onToggle(!visible),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(dimensions.buttonBorderRadius),
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
        // Main Circle with shadow
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
                  imageUrl: _taxi.imageUrl != null
                      ? "${ApiConfig().baseUrl}/${_taxi.imageUrl}"
                      : null,
                  backgroundColor: colorScheme.onSecondary,
                  placeholderAsset: "assets/icons/taxi.svg",
                  placeholderColor: colorScheme.onSecondaryContainer,
                ),
        ),
        // Camera icon positioned at bottom right
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
                "assets/icons/camera.svg",
                color: colorScheme.onSecondaryContainer,
                fit: BoxFit.scaleDown,
              ),
              onPressed: () async {
                final pickedImage =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedImage != null) {
                  setState(() => _isProcessingImage = true);
                  final compressedImage =
                      await compressXFileToTargetSize(pickedImage, 5);
                  setState(() => _isProcessingImage = false);
                  if (compressedImage != null) {
                    setState(() {
                      _profileImage = compressedImage;
                      _showImageError = false;
                    });
                  }
                }
              },
            ),
          ),
        ),
        // Remove button if image is selected
        if (_profileImage != null)
          Positioned(
            top: 8.0,
            right: 8.0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _profileImage = null;
                  _showImageError = false;
                });
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.error,
                child: Icon(Icons.close, color: colorScheme.onError, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.balance,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 8),
        _buildBalanceRow(AppLocalizations.of(context)!.quberCredits,
            "${_driver.credit} CUP", null),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        _buildBalanceRow(
            AppLocalizations.of(context)!.nextPay,
            _driver.paymentDate != null
                ? DateFormat('dd/MM/yyyy').format(_driver.paymentDate!)
                : '-',
            null),
        const SizedBox(height: 12),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        _buildBalanceRow(AppLocalizations.of(context)!.valuation,
            _driver.rating.toString(), "assets/icons/yelow_star.svg"),
      ],
    );
  }

  Widget _buildBalanceRow(String label, String value, String? iconPath) {
    // Apply star logic only for rating row
    if (label == AppLocalizations.of(context)!.valuation) {
      final rating = double.tryParse(value) ?? 0.0;
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          _buildStarRating(rating),
          Text(
            " $value",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      );
    }

    // For other rows maintain original behavior
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        if (iconPath != null) SvgPicture.asset(iconPath, height: 20),
        Text(
          " $value",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          // Full yellow star
          return SvgPicture.asset(
            'assets/icons/yelow_star.svg',
            height: Theme.of(context).iconTheme.size! * 0.8,
          );
        } else {
          // Empty gray star
          return SvgPicture.asset(
            'assets/icons/gray_star.svg',
            height: 20,
          );
        }
      }),
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  color: textColor ?? Colors.black87,
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
      borderRadius: BorderRadius.circular(8),
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
                  color: textColor ?? Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
