import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/admin.dart';
import 'package:quber_taxi/common/models/quber_config.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _driverCreditController = TextEditingController();
  final Map<TaxiType, TextEditingController> _vehiclePriceControllers = {
    TaxiType.mototaxi: TextEditingController(),
    TaxiType.standard: TextEditingController(),
    TaxiType.familiar: TextEditingController(),
    TaxiType.comfort: TextEditingController(),
  };

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final adminService = AdminService();
  late Future<QuberConfig?> futureQuberConfigs;

  // TODO("yapmDev": @Reminder)
  // - Probably a more secure password typing
  bool get canSubmitNewPassword => _newPasswordController.text.isNotEmpty
      && (_confirmPasswordController.text == _newPasswordController.text);

  bool get canSubmitNewConfigs => _driverCreditController.text.isNotEmpty
      && _vehiclePriceControllers.values.every((priceController) => priceController.text.isNotEmpty);

  void _loadQuberConfigs() {
    futureQuberConfigs = adminService.getQuberConfigIfExists().then((config) {
      setState(() {
        futureQuberConfigs = Future.value(config);
        if (config != null) {
          _driverCreditController.text = config.driverCredit.toString();
          for (final vehicleType in TaxiType.values) {
            final price = config.travelPrice[vehicleType] ?? 50.0;
            _vehiclePriceControllers[vehicleType]!.text = price.toString();
          }
        } else {
          _driverCreditController.text = "10";
          for (final vehicleType in TaxiType.values) {
            _vehiclePriceControllers[vehicleType]!.text = "50";
          }
        }
      });
      return null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadQuberConfigs();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _driverCreditController.dispose();
    for (final controller in _vehiclePriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
        body: Stack(
            children: [
              // Curved Yellow Header
              Positioned(
                top: -100,
                left: 0,
                right: 0,
                child: Container(
                  height: 360,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(dimensions.borderRadius),
                      bottomRight: Radius.circular(dimensions.borderRadius),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                      child: Center(
                        child: Text(
                          localizations.adminSettingsTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    )
                  )
                )
              ),
              // Content as Card with ClipRRect to maintain rounded top border
              Positioned.fill(
                  top: 140,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(dimensions.borderRadius),
                      topRight: Radius.circular(dimensions.borderRadius),
                    ),
                    child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 20.0,
                            children: [
                              // Configurations Section
                              Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 0),
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: FutureBuilder(
                                      future: futureQuberConfigs,
                                      builder: (_, snapshot) {
                                        if(snapshot.connectionState == ConnectionState.waiting) {
                                          return Center(child: CircularProgressIndicator());
                                        }
                                        else {
                                          return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              spacing: 8.0,
                                              children: [
                                                Text(
                                                  localizations.pricesSectionTitle,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.onSurface,
                                                  ),
                                                ),
                                                // Credit Percentage
                                                Text(
                                                  localizations.driverCreditPercentage,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: theme.colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 120,
                                                      child: TextFormField(
                                                        keyboardType: TextInputType.number,
                                                        controller: _driverCreditController,
                                                        decoration: InputDecoration(
                                                          errorMaxLines: 3,
                                                            fillColor: theme.colorScheme.surface,
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                                            ),
                                                            hintText: "0%",
                                                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                                              color: theme.colorScheme.onSurfaceVariant,
                                                            ),
                                                        ),
                                                        validator: (value) => Workflow<String?>()
                                                            .step(RequiredStep(errorMessage: localizations.requiredField))
                                                            .step(ValidPercentageStep(errorMessage: localizations.invalidCreditPercentage))
                                                            .withDefault((_) => null)
                                                            .proceed(value),
                                                        onChanged: (s) => setState(()=> _driverCreditController.text = s)
                                                      )
                                                    ),
                                                  ],
                                                ),
                                                // Travel price per km and vehicle
                                                Text(
                                                  localizations.tripPricePerKm,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: theme.colorScheme.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                // Price fields by vehicle type
                                                ...TaxiType.values.map((vehicleType) =>
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8.0),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                            width: 80.0,
                                                            child: Text(
                                                              "${TaxiType.nameOf(vehicleType, localizations)}:",
                                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                                color: theme.colorScheme.onSurface,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        SizedBox(
                                                          width: 140,
                                                          child: TextFormField(
                                                            keyboardType: TextInputType.number,
                                                            controller: _vehiclePriceControllers[vehicleType],
                                                            decoration: InputDecoration(
                                                              errorMaxLines: 3,
                                                              fillColor: theme.colorScheme.surface,
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                                              ),
                                                              hintText: "0 CUP",
                                                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                                                color: theme.colorScheme.onSurfaceVariant,
                                                              ),
                                                            ),
                                                            validator: (value) => Workflow<String?>()
                                                                .step(RequiredStep(errorMessage: localizations.requiredField))
                                                                .step(ValidPositiveNumberStep(errorMessage: localizations.invalidPrice))
                                                                .withDefault((_) => null)
                                                                .proceed(value),
                                                            onChanged: (s) => setState(() {
                                                              _vehiclePriceControllers[vehicleType]!.text = s;
                                                            })
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 16),
                                                // Save button (aligned to right)
                                                Align(
                                                    alignment: Alignment.centerRight,
                                                    child: OutlinedButton(
                                                        onPressed: () async {
                                                          if(!_formKey.currentState!.validate()) return;
                                                          if(!runtime.hasConnection(context) || !canSubmitNewConfigs) return;
                                                          final vehiclePrices = <TaxiType, double>{};
                                                          for (final entry in _vehiclePriceControllers.entries) {
                                                            vehiclePrices[entry.key] = double.parse(entry.value.text);
                                                          }
                                                          final response = await adminService.updateConfig(
                                                              driverCredit: double.parse(_driverCreditController.text),
                                                              vehiclePrices: vehiclePrices
                                                          );
                                                          if(!context.mounted) return;
                                                          if(response.statusCode == 200) {
                                                            showToast(context: context, message: "Hecho");
                                                          } else {
                                                            showToast(context: context, message: "No se puedo cambiar la "
                                                                "configuración");
                                                          }
                                                        },
                                                        child: Text(
                                                            localizations.saveButtonPanel,
                                                            style: theme.textTheme.labelLarge?.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16
                                                            )
                                                        )
                                                    )
                                                )
                                              ]
                                          );
                                        }
                                      },
                                    )
                                ),
                              ),
                              // Password Section
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.borderRadius),

                                ),
                                child: Form(
                                  key: _passwordFormKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.passwordsSectionTitle,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      // New password
                                      Text(
                                        localizations.newPassword,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(
                                        child: TextFormField(
                                          controller: _newPasswordController,
                                          obscureText: !_isNewPasswordVisible,
                                          decoration: InputDecoration(
                                            errorMaxLines: 3,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.primary),
                                            ),
                                            contentPadding: dimensions.contentPadding,
                                            filled: true,
                                            fillColor: theme.colorScheme.surfaceContainerLowest,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                color: theme.colorScheme.onSurfaceVariant,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isNewPasswordVisible = !_isNewPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (value) => Workflow<String?>()
                                              .step(RequiredStep(errorMessage: localizations.requiredField))
                                              .step(MinLengthStep(min: 6, errorMessage: localizations.passwordMinLength))
                                              .withDefault((_) => null)
                                              .proceed(value),
                                        )
                                      ),
                                      SizedBox(height: 20),

                                      // Confirm password
                                      Text(
                                        localizations.confirmPassword,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      SizedBox(
                                        child: TextFormField(
                                          controller: _confirmPasswordController,
                                          obscureText: !_isConfirmPasswordVisible,
                                          decoration: InputDecoration(
                                            errorMaxLines: 3,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                              borderSide: BorderSide(color: theme.colorScheme.primary),
                                            ),
                                            contentPadding: dimensions.contentPadding,
                                            filled: true,
                                            fillColor: theme.colorScheme.surfaceContainerLowest,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                color: theme.colorScheme.onSurfaceVariant,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (value) => Workflow<String?>()
                                              .step(RequiredStep(errorMessage: localizations.requiredField))
                                              .step(MatchOtherStep(other: _newPasswordController.text, errorMessage: localizations.passwordsDoNotMatch))
                                              .withDefault((_) => null)
                                              .proceed(value),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                                                        // Save button (aligned to right)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton(
                                        onPressed: () async {
                                          if(!_passwordFormKey.currentState!.validate()) return;
                                          if(!runtime.hasConnection(context) || !canSubmitNewPassword) return;
                                              final admin = Admin.fromJson(runtime.loggedInUser);
                                              final response = await adminService.updatePassword(
                                                admin.id,
                                                _newPasswordController.text,
                                              );
                                              if(!context.mounted) return;
                                              if(response.statusCode == 200) {
                                                showToast(context: context, message: "Hecho");
                                              } else {
                                                showToast(context: context, message: "No se puedo cambiar la "
                                                    "contraseña");
                                              }
                                            },
                                            child: Text(
                                                localizations.saveButtonPanel,
                                                style: theme.textTheme.labelLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                )
                                            )
                                        )
                                      )
                                    ]
                                  )
                                )
                              ),
                              // Navigate to other sections
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        localizations.otherActionsTitle,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    // Ver todos los viajes con borde inferior
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: theme.colorScheme.outlineVariant,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () => context.push(AdminRoutes.tripsList),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          child: Row(
                                            children: [
                                              // Reemplaza esto con tu SVG
                                              SvgPicture.asset(
                                                'assets/icons/location_on_black.svg',
                                                width: 24,
                                                height: 24
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                localizations.viewAllTrips,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Ver todos los conductores con borde superior
                                    Container(
                                      decoration: BoxDecoration(
                                      ),
                                      child: InkWell(
                                        onTap: () => context.push(AdminRoutes.driversList),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          child: Row(
                                            children: [
                                              // Reemplaza esto con tu SVG
                                              SvgPicture.asset(
                                                'assets/icons/group.svg',
                                                width: 24,
                                                height: 24,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                localizations.viewAllDrivers,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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