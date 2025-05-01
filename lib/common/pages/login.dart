import 'package:flutter/material.dart';
import 'package:quber_taxi/theme/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<ColorExtension>()!;
    return Material(
      child: Stack(
        children: [
          // Background image
          Positioned.fill(child: Image.asset("images/taxi.jpg", fit: BoxFit.fitHeight)),
          // Opacity Mask
          Positioned.fill(child: ColoredBox(color: customColors.darkestColor.withAlpha(100))),
          // Main Content
          Positioned.fill(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 3),
                    // Text Header
                    Text(
                        "Bienvenido a QuberTaxi",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(color: customColors.lightestColor)
                    ),
                    Spacer(flex: 3),
                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            spacing: 20.0,
                            children: [
                              TextFormField(
                                controller: _userController,
                                validator: (inputStr) {
                                  if (inputStr == null || inputStr.isEmpty) {
                                    return "Campo requerido";
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(hintText: "Usuario"),
                              ),
                              ///TODO("yapmDev")
                              /// To avoid re-render the entire ui, extract this widget as a single component.
                              TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                      hintText: "Contraseña",
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                        onPressed: () => setState(() => _obscureText = !_obscureText),
                                      )),
                                  validator: (inputStr) {
                                    if (inputStr!.isEmpty) {
                                      return "Campo requerido";
                                    } else if (inputStr.length < 6) {
                                      return "Al menos seis caracteres";
                                    } else {
                                      return null;
                                    }
                                  }
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          FocusScope.of(context).unfocus();
                                          // continue action from here ...
                                        }
                                      },
                                      child: const Text("Iniciar Sesión"))
                              ),
                            ],
                          )
                      ),
                    ),
                    SizedBox(height: 40.0),
                    // New Account
                    Text(
                        "Crear cuenta",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: customColors.lightestColor)),
                    SizedBox(height: 12.0),
                    // Forgot password
                    Text(
                        "Olvidé mi contraseña",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: customColors.lightestColor)
                    ),
                    Spacer(flex: 4)
                  ]
              )
          )
        ]
      )
    );
  }
}