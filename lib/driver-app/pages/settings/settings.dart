import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  State<DriverSettingsPage> createState() => _DriverAccountSettingPage();
}

class _DriverAccountSettingPage extends State<DriverSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  // Form field controllers
  final _nameController = TextEditingController(text: "Raúl Gómez");
  final _carRegistrationController = TextEditingController(text: "P56739U");
  final _phoneController = TextEditingController(text: "55555555");
  final _emailController = TextEditingController(text: "raulg@gmail.com");
  final _seatsController = TextEditingController(text: "4");

  @override
  void dispose() {
    _nameController.dispose();
    _carRegistrationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _seatsController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Container(color: colorScheme.surface),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Card 1: Personal Information
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          color: colorScheme.surfaceContainerLowest,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 120, left: 16, right: 16, bottom: 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildLabeledField(
                                    AppLocalizations.of(context)!.nameDriver,
                                    _nameController,
                                    isRequired: true,
                                    maxLimit: 50,
                                  ),
                                  _buildLabeledField(
                                    AppLocalizations.of(context)!
                                        .carRegistration,
                                    _carRegistrationController,
                                    isRequired: true,
                                    maxLimit: 7,
                                  ),
                                  _buildLabeledField(
                                    AppLocalizations.of(context)!
                                        .phoneNumberDriver,
                                    _phoneController,
                                    isRequired: true,
                                    maxLimit: 8,
                                  ),
                                  _buildLabeledField(
                                    AppLocalizations.of(context)!.email,
                                    _emailController,
                                    isRequired: true,
                                    maxLimit: 50,
                                    isEmail: true,
                                  ),
                                  _buildLabeledField(
                                    AppLocalizations.of(context)!.numberOfSeats,
                                    _seatsController,
                                    isRequired: true,
                                    maxLimit: 3,
                                    isNumeric: true,
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildGuardarButton(
                                      _formKey,
                                      AppLocalizations.of(context)!
                                          .saveInformation,
                                      onSave: _savePersonalInfo,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Image
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                  AssetImage('assets/images/driver.png'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 33,
                                    height: 33,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerLowest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/icons/camera.svg",
                                      color: colorScheme.onSurfaceVariant,
                                      fit: BoxFit.scaleDown,
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

                  // Card 2: Balance
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.surfaceContainerLowest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBalanceBox(),
                      ),
                    ),
                  ),

                  // Card 3: Passwords
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.surfaceContainerLowest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            children: [
                              _buildLabeledPassword(
                                AppLocalizations.of(context)!.passwordDriver,
                                _passwordController,
                                isRequired: true,
                                maxLimit: 20,
                              ),
                              _buildLabeledPassword(
                                AppLocalizations.of(context)!
                                    .passwordConfirmDriver,
                                _confirmPasswordController,
                                isRequired: true,
                                isConfirmation: true,
                                originalPassword: _passwordController.text,
                                maxLimit: 20,
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildGuardarButton(
                                  _passwordFormKey,
                                  AppLocalizations.of(context)!.saveInformation,
                                  onSave: _savePassword,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Menu Items
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.surfaceContainerLowest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            icon: Icons.drive_eta_outlined,
                            text: AppLocalizations.of(context)!.aboutUsDriver,
                            onTap: () => context.push(CommonRoutes.aboutUs),
                          ),
                          Divider(
                              height: 1,
                              color: colorScheme.outlineVariant,
                              indent: 12,
                              endIndent: 12),
                          _buildMenuItem(
                            icon: Icons.code,
                            text: AppLocalizations.of(context)!.aboutDevDriver,
                            onTap: () => context.push(CommonRoutes.aboutDev),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Logout Button
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: _buildLogoutItem(
                      text: AppLocalizations.of(context)!.logout,
                      icon: Icons.logout,
                      textColor: colorScheme.error,
                      iconColor: colorScheme.error,
                      onTap: () async {
                        await SessionManager.instance.clear();
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
            left: 30,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 80,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colorScheme.onPrimaryContainer),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.myAccount,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField(
      String label,
      TextEditingController controller, {
        bool isRequired = false,
        bool isEmail = false,
        bool isNumeric = false,
        int? maxLimit,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLength: maxLimit,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink(),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio';
            }
            if (isEmail &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Ingrese un email válido';
            }
            if (isNumeric && !RegExp(r'^[0-9]+$').hasMatch(value!)) {
              return 'Ingrese solo números';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGuardarButton(
      GlobalKey<FormState> formKey,
      String text, {
        required VoidCallback onSave,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 180,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            onSave();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$text correctamente"),
                backgroundColor: colorScheme.tertiaryContainer,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(AppLocalizations.of(context)!.requiredLabel),
                backgroundColor: colorScheme.errorContainer,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceBox() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.balance,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        _buildBalanceRow(
            AppLocalizations.of(context)!.quberCredits, "1600 CUP", null),
        const SizedBox(height: 8),
        Divider(
          color: colorScheme.outlineVariant,
          thickness: 0.5,
        ),
        _buildBalanceRow(
            AppLocalizations.of(context)!.nextPay, "16/4/2025", null),
        const SizedBox(height: 12),
        Divider(
          color: colorScheme.outlineVariant,
          thickness: 0.5,
        ),
        _buildBalanceRow(AppLocalizations.of(context)!.valuation, "4.0",
            "assets/icons/yelow_star.svg"),
      ],
    );
  }

  Widget _buildBalanceRow(String label, String value, String? iconPath) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (label == AppLocalizations.of(context)!.valuation) {
      final rating = double.tryParse(value) ?? 0.0;
      return Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _buildStarRating(rating),
          Text(
            " $value",
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (iconPath != null) SvgPicture.asset(iconPath, height: 20),
        Text(
          " $value",
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
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
          return SvgPicture.asset(
            'assets/icons/yelow_star.svg',
            height: 20,
          );
        } else {
          return SvgPicture.asset(
            'assets/icons/gray_star.svg',
            height: 20,
          );
        }
      }),
    );
  }

  Widget _buildLabeledPassword(
      String label,
      TextEditingController controller, {
        bool isRequired = false,
        bool isConfirmation = false,
        String originalPassword = '',
        int? maxLimit,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLength: maxLimit,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) =>
          const SizedBox.shrink(),
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio';
            }
            if (isConfirmation && value != originalPassword) {
              return 'Las contraseñas no coinciden';
            }
            if (value != null && value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: textColor ?? colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 180),
            Expanded(
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  color: textColor ?? colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              icon,
              size: 20,
              color: iconColor ?? colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  void _savePersonalInfo() {
    // Here you would typically save to your backend/database
    print('Saved personal info:');
    print('Name: ${_nameController.text}');
    print('Car Registration: ${_carRegistrationController.text}');
    print('Phone: ${_phoneController.text}');
    print('Email: ${_emailController.text}');
    print('Seats: ${_seatsController.text}');
  }

  void _savePassword() {
    // Here you would typically save the new password
    print('Password changed to: ${_passwordController.text}');
    // Clear the password fields after saving
    _passwordController.clear();
    _confirmPasswordController.clear();
  }
}