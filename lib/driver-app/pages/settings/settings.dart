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

import '../../../common/models/driver.dart';
import '../../../common/models/taxi.dart';
import '../../../common/services/account_service.dart';
import '../../../config/api_config.dart';
import '../../../utils/image/image_utils.dart';
import '../../../utils/runtime.dart';
import '../../../utils/workflow/core/workflow.dart';
import '../../../utils/workflow/impl/form_validations.dart';

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
  bool get _shouldUpdateImage =>_taxi.imageUrl != null;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _taxi = _driver.taxi;
    _nameTFController = TextEditingController(text: _driver.name);
    print(_driver.name);
    print(_taxi.imageUrl);
    _plateTFController = TextEditingController(text: _taxi.plate);
    _phoneTFController = TextEditingController(text: _driver.phone);
    _seatTFController = TextEditingController(text: _taxi.seats.toString());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [

          Container(color: colorScheme.onSecondary),

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
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ]
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
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          color: colorScheme.onSecondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildCircleImage(),
                                  _buildLabeledField(AppLocalizations.of(context)!.nameDriver, _nameTFController),
                                  _buildLabeledField(AppLocalizations.of(context)!.carRegistration, _plateTFController),
                                  _buildLabeledFieldNum(AppLocalizations.of(context)!.phoneNumberDriver, _phoneTFController),
                                  _buildLabeledFieldNum(AppLocalizations.of(context)!.numberOfSeats, _seatTFController),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildGuardarButton(_formKey, localization.save),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card 2: Balance
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.onSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBalanceBox(),
                      ),
                    ),
                  ),

                  // Card 3: Passwords
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.onSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                          child: Form(
                              key: _passwordFormKey,
                              child: Column(
                                  spacing: 12.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPasswordField(
                                        label: localization.passwordLabel,
                                        visible: passwordVisible,
                                        onToggle: (v) => setState(() => passwordVisible = v),
                                        controller: _passwordController,
                                        validator: Workflow<String?>()
                                            .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                            .step(MinLengthStep(min: 6, errorMessage: "Requiere al menos 6 caracteres"))
                                            .breakOnFirstApply(true)
                                            .withDefault((_) => null)
                                            .proceed
                                    ),
                                    _buildPasswordField(
                                        label: localization.confirmPasswordLabel,
                                        visible: confirmPasswordVisible,
                                        onToggle: (v) => setState(() => confirmPasswordVisible = v),
                                        controller: _confirmPasswordController,
                                        validator: Workflow<String?>()
                                            .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                            .step(MatchOtherStep(
                                            other: _passwordController.text,
                                            errorMessage: "Las contraseñas no coinciden"
                                        ))
                                            .breakOnFirstApply(true)
                                            .withDefault((_) => null)
                                            .proceed
                                    ),
                                    OutlinedButton(
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          if(hasConnection(context)) {
                                            if (_passwordFormKey.currentState!
                                                .validate()) {
                                              final response = await
                                              _accountService
                                                  .updateDriverPassword(
                                                  _driver.id,
                                                  _passwordController.text
                                              );
                                              if(!context.mounted) return;
                                              if(response.statusCode == 200) {
                                                _passwordController.clear();
                                                _confirmPasswordController.clear();
                                                showToast(context: context,
                                                    message: localization.updatePasswordSuccess);
                                              }
                                              else {
                                                showToast(
                                                    context: context,
                                                    message: localization.somethingWentWrong
                                                );
                                              }
                                            }
                                          } else {
                                            showToast(context: context, message: localization.checkConnection);
                                          }
                                        },
                                        child: Text(AppLocalizations.of(context)!.saveButtonPanel))
                                  ]
                              )
                          )
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Card(
                      color: colorScheme.onSecondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            icon: Icons.drive_eta_outlined,
                            text: localization.aboutUs,
                            onTap: () => context.push(CommonRoutes.aboutUs)
                          ),

                          Divider(height: 1, color: Colors.grey.shade200, indent: 12, endIndent: 12),

                          _buildMenuItem(
                            icon: Icons.code,
                            text: localization.aboutDeveloper,
                            onTap: () => context.push(CommonRoutes.aboutDev)
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),

                    child: _buildLogoutItem(
                      text: localization.logout,
                      icon: Icons.logout,
                      textColor: colorScheme.errorContainer,
                      iconColor: colorScheme.errorContainer,
                        onTap: () async {
                          await SessionManager.instance.clear();
                          if(!context.mounted) return;
                          context.go(CommonRoutes.login);
                        }
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
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back), onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.myAccount,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.shadow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if(_isProcessingImage)
            Positioned.fill(child: Center(child: CircularProgressIndicator()))
        ],
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Colors.white54,
                    width: 0.1
                )
            ),
          ),
            validator: (value) => Workflow<String?>()
                .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                .withDefault((_) => null)
                .proceed(value)
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLabeledFieldNum(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Colors.white54,
                      width: 0.1
                  )
              ),
            ),
            validator: (value) => Workflow<String?>()
                .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                .withDefault((_) => null)
                .proceed(value)
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGuardarButton(GlobalKey<FormState> formKey, String text) {
    final localization = AppLocalizations.of(context)!;
    return SizedBox(
      width: 180,
      child: ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if(hasConnection(context)) {
              if (_formKey.currentState!.validate()) {
                final seats = int.tryParse(_seatTFController.text) ?? 0;
                final response = await _accountService.updateDriver(
                    _driver.id,
                    _nameTFController.text,
                    _phoneTFController.text,
                    seats,
                    _plateTFController.text,
                    _profileImage,
                    _shouldUpdateImage
                );
                if(!context.mounted) return;
                if(response.statusCode == 200) {
                  final driver = Driver.fromJson(jsonDecode(response.body));
                  // Update session's data
                  SessionManager.instance.save(driver);
                  _profileImage = null;
                  showToast(context: context, message: "Datos actualizados");
                }
                else if(response.statusCode == 409) {
                  showToast(
                      context: context,
                      message: "El número de teléfono ya se encuentra registrado"
                  );
                }
                else {
                  showToast(
                      context: context,
                      message: localization.somethingWentWrong
                  );
                }
              }
            } else {
              showToast(context: context, message: localization.checkConnection);
            }
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
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
            fontSize: 18,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 8),
        _buildBalanceRow(AppLocalizations.of(context)!.quberCredits, "${_driver.credit} CUP", null),
        const SizedBox(height: 8),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        _buildBalanceRow(AppLocalizations.of(context)!.nextPay, _driver.paymentDate != null ? DateFormat('dd/MM/yyyy').format(_driver.paymentDate!) : '-', null),
        const SizedBox(height: 12),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
        _buildBalanceRow(AppLocalizations.of(context)!.valuation, _driver.rating.toString(), "assets/icons/yelow_star.svg"),
      ],
    );
  }

  Widget _buildBalanceRow(String label, String value, String? iconPath) {
    // Solo aplicamos la lógica de estrellas si es la fila de valoración
    if (label == "Valoración acumulada:") {
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

    // Para las demás filas mantenemos el comportamiento original
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
        if (iconPath != null)
          SvgPicture.asset(iconPath, height: 20),
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
          // Estrella amarilla completa
          return SvgPicture.asset(
            'assets/icons/yelow_star.svg',
            height: 20,
          );
        } else {
          // Estrella gris (vacía)
          return SvgPicture.asset(
            'assets/icons/gray_star.svg',
            height: 20,
          );
        }
      }),
    );
  }



  Widget _buildPasswordField({
    required String label,
    required bool visible,
    required Function(bool) onToggle,
    required TextEditingController controller,
    required String? Function(String?) validator
  }) {
    final localization = AppLocalizations.of(context)!;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Text(label),
          TextFormField(
            controller: controller,
            obscureText: !visible,
            decoration: InputDecoration(
              hintText: localization.hintPassword,
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? Colors.grey[600],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [

            SizedBox(width: 180),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
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
  Widget _buildCircleImage() {
    return Stack(
        alignment: Alignment.bottomRight,
        children: [
          ClipOval(
              child: SizedBox(
                  height: 160, width: 160,
                  child: _profileImage != null
                      ? Image.file(File(_profileImage!.path), fit: BoxFit.cover)
                      : _taxi.imageUrl != null
                      ? Image.network("${ApiConfig().baseUrl}/${_taxi.imageUrl}", fit: BoxFit.cover)
                      : ColoredBox(color: randomColor())
              )
          ),
          Positioned(
              bottom: 8.0, right: 8.0,
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
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(Icons.add_a_photo)
                ),
              )
          )
        ]
    );
  }
}