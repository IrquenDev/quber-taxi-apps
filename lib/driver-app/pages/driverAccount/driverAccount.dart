import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class DriverAccountSettingPage extends StatefulWidget {
  const DriverAccountSettingPage({super.key});

  @override
  State<DriverAccountSettingPage> createState() => _DriverAccountSettingPage();
}

class _DriverAccountSettingPage extends State<DriverAccountSettingPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo general
          Container(color: Colors.white),

          // Header amarillo (fondo fijo)
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
              ),
            ),
          ),

          // Contenido desplazable que comienza debajo del header
          Positioned(
            top: 120, // Comienza más abajo para que no tape el menú
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Card 1: Información personal con imagen
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 120, left: 16, right: 16, bottom: 16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildLabeledField(AppLocalizations.of(context)!.nameDriver, "Raúl Gómez"),
                                  _buildLabeledField(AppLocalizations.of(context)!.carRegistration, "P56739U"),
                                  _buildLabeledField(AppLocalizations.of(context)!.phoneNumberDriver, "55555555"),
                                  _buildLabeledField(AppLocalizations.of(context)!.email, "raulg@gmail.com"),
                                  _buildLabeledField(AppLocalizations.of(context)!.numberOfSeats, "4"),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildGuardarButton(_formKey, "Guardar"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Imagen de perfil (posicionada para que se vea bien)
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
                                  backgroundImage: AssetImage('assets/images/driver.png'),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/icons/camera.svg",
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
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildBalanceBox(),
                      ),
                    ),
                  ),

                  // Card 3: Contraseñas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _passwordFormKey,
                          child: Column(
                            children: [
                              _buildLabeledPassword(AppLocalizations.of(context)!.passwordDriver, _passwordController),
                              _buildLabeledPassword(AppLocalizations.of(context)!.passwordConfirmDriver, _confirmPasswordController),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _buildGuardarButton(_passwordFormKey, AppLocalizations.of(context)!.saveInformation),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Espacio final
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),


          Positioned(
            top: 0,
            left: 40,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.menu, color: colorScheme.shadow),
                    const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  Widget _buildLabeledField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: hint,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGuardarButton(GlobalKey<FormState> formKey, String text) {
    return SizedBox(
      width: 180,
      child: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$text correctamente")),
            );
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
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        _buildBalanceRow(AppLocalizations.of(context)!.valuation, "4.0", "assets/icons/yelow_star.svg"),
        const SizedBox(height: 8),
        _buildBalanceRow(AppLocalizations.of(context)!.quberCredits, "1600 CUP", null),
        const SizedBox(height: 8),
        _buildBalanceRow(AppLocalizations.of(context)!.nextPay, "16/4/2025", null),
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
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          _buildStarRating(rating),
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

    // Para las demás filas mantenemos el comportamiento original
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
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



  Widget _buildLabeledPassword(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}