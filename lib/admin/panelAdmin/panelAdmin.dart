import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  _AdminSettingsPageState createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final TextEditingController _percentageController = TextEditingController(text: '10%');
  final TextEditingController _priceController = TextEditingController(text: '50 CUP');
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Fondo general
          Container(color: theme.colorScheme.surface),

          // Header curvado amarillo
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
                  padding: EdgeInsets.symmetric(horizontal: 46, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.menu,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
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

          // Contenido con las tarjetas
          Positioned.fill(
            top: 140,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Sección de Precios
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(dimensions.borderRadius),

                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.pricesSectionTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Porcentaje de crédito
                        Text(
                          AppLocalizations.of(context)!.driverCreditPercentage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 50,
                          width: 100,
                          child: TextField(
                            controller: _percentageController,
                            style: TextStyle(color: theme.colorScheme.onSurface),
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
                              fillColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Precio de viaje por KM
                        Text(
                          AppLocalizations.of(context)!.tripPricePerKm,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 50,
                          width: 100,
                          child: TextField(
                            controller: _priceController,
                            style: TextStyle(color: theme.colorScheme.onSurface),
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
                              fillColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Botón Guardar (aligned to right)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Acción para guardar precios
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              padding: dimensions.contentPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                              ),
                              elevation: dimensions.elevation,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.saveButtonPanel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Sección de Contraseñas
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
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
                        Container(
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
                              fillColor: theme.colorScheme.onPrimary,
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
                        Container(
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
                              fillColor: theme.colorScheme.onPrimary,
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
                            onPressed: () {
                              // Acción para guardar contraseñas
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer,
                              foregroundColor: theme.colorScheme.onPrimaryContainer,
                              padding: dimensions.contentPadding,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius),
                              ),
                              elevation: dimensions.elevation,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.saveButtonPanel,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Sección de Otras acciones
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
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
                            onTap: () {
                              // Acción para ver todos los viajes
                            },
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
                            onTap: () {
                              // Acción para ver todos los conductores
                            },
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
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}