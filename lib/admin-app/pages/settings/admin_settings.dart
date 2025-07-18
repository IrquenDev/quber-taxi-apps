import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/admin.dart';
import 'package:quber_taxi/common/models/quber_config.dart';
import 'package:quber_taxi/common/services/admin_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart' as runtime;

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final adminService = AdminService();
  late Future<QuberConfig?> futureQuberConfigs;

  // TODO("yapmDev": @Reminder)
  // - Probably a more secure password typing
  bool get canSubmitNewPassword => _newPasswordController.text.isNotEmpty
      && (_confirmPasswordController.text == _newPasswordController.text);

  bool get canSubmitNewConfigs => _driverCreditAsString.isNotEmpty
      && _travelPriceAsString.isNotEmpty;

  String _driverCreditAsString = "";

  String _travelPriceAsString = "";

  void _loadQuberConfigs() {
    futureQuberConfigs = adminService.getQuberConfigIfExists().then((config) {
      setState(() {
        futureQuberConfigs = Future.value(config);
        _travelPriceAsString = config != null ? config.travelPrice.toString() : "";
        _driverCreditAsString = config != null ? config.driverCredit.toString() : "";
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
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
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(
                              Icons.arrow_back,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.adminSettingsTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content as Card
              Positioned.fill(
                  top: 140,
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
                                child: FutureBuilder(
                                  future: futureQuberConfigs,
                                  builder: (_, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    else {
                                      final quberConfig = snapshot.data;
                                      return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          spacing: 8.0,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.pricesSectionTitle,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            // Porcentaje de crédito
                                            Text(
                                              AppLocalizations.of(context)!.driverCreditPercentage,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                                height: 48.0,
                                                width: 92,
                                                child: TextFormField(
                                                  keyboardType: TextInputType.number,
                                                  initialValue: quberConfig != null ? quberConfig.driverCredit.toString() : "",
                                                  decoration: InputDecoration(
                                                      fillColor: theme.colorScheme.surface,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                                      )
                                                  ),
                                                  onChanged: (s) => setState(()=> _driverCreditAsString = s)
                                                )
                                            ),
                                            // Precio de viaje por KM
                                            Text(
                                              AppLocalizations.of(context)!.tripPricePerKm,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 48.0,
                                              width: 92,
                                              child: TextFormField(
                                                  keyboardType: TextInputType.number,
                                                  initialValue: quberConfig != null ? quberConfig.travelPrice.toString() : "",
                                                  decoration: InputDecoration(
                                                      fillColor: theme.colorScheme.surface,
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                                      )
                                                  ),
                                                  onChanged: (s) => setState(()=> _travelPriceAsString = s)
                                              ),
                                            ),
                                            // Botón Guardar (aligned to right)
                                            Align(
                                                alignment: Alignment.centerRight,
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      if(!runtime.hasConnection(context) || !canSubmitNewConfigs) return;
                                                      final response = await adminService.updateConfig(
                                                          travelPrice: double.parse(_travelPriceAsString),
                                                          driverCredit: double.parse(_driverCreditAsString)
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
                                                        AppLocalizations.of(context)!.saveButtonPanel,
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
                            // Sección de Contraseñas
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(dimensions.borderRadius),

                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.passwordsSectionTitle,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Nueva contraseña
                                  Text(
                                    AppLocalizations.of(context)!.newPassword,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: _newPasswordController,
                                      obscureText: !_isNewPasswordVisible,
                                      decoration: InputDecoration(
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
                                      )
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Confirme contraseña
                                  Text(
                                    AppLocalizations.of(context)!.confirmPassword,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: _confirmPasswordController,
                                      obscureText: !_isConfirmPasswordVisible,
                                      decoration: InputDecoration(
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
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Botón Guardar (aligned to right)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                        onPressed: () async {
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
                                            AppLocalizations.of(context)!.saveButtonPanel,
                                            style: theme.textTheme.labelLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
                                            )
                                        )
                                    )
                                  )
                                ]
                              )
                            ),
                            // Sección de Otras acciones
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
                                      AppLocalizations.of(context)!.otherActionsTitle,
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
                                              height: 24,

                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              AppLocalizations.of(context)!.viewAllTrips,
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
                                              AppLocalizations.of(context)!.viewAllDrivers,
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
            ]
        )
    );
  }
}