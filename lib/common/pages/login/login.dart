import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/routes/route_paths.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/util/runtime.dart' as runtime;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _phoneTFController = TextEditingController();
  final _passwordTFController = TextEditingController();
  var _obscureText = true;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    // Init Inherited Customizers
    final localization = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;

    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(child: Image.asset("assets/images/login_background.png", fit: BoxFit.fill)),
            // Opacity Mask
            Positioned.fill(child: ColoredBox(color: colorScheme.shadow.withAlpha(200))),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Text
                    Text(
                      localization.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                    SizedBox(height: 60),
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20.0,
                        children: [
                          // Phone Number TF
                          TextFormField(
                            controller: _phoneTFController,
                            decoration: InputDecoration(
                              hintText: localization.enterPhoneNumber,
                              fillColor: colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return localization.requiredField;
                              return null;
                            },
                          ),
                          // Password TF
                          TextFormField(
                            controller: _passwordTFController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: localization.enterPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                              fillColor: colorScheme.surfaceContainer,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                borderSide: BorderSide.none
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return localization.requiredField;
                              return null;
                            },
                          ),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () async {
                                // Validate form
                                if (_formKey.currentState!.validate()) {
                                  // Get form data
                                  final phone = _phoneTFController.text;
                                  final password = _passwordTFController.text;
                                  // Check connection
                                  if(!isConnected) return;
                                  // Init var
                                  http.Response? response;
                                  String route;
                                  // Depending on appProfile decides who we need to authenticate and set the next
                                  // route.
                                  if(runtime.isClientMode) {
                                    response = await _authService.loginClient(phone, password);
                                    route = RoutePaths.clientHome;
                                  } else {
                                    response = await _authService.loginDriver(phone, password);
                                    route = RoutePaths.driverHome;
                                  }
                                  // Handle response
                                  if(!context.mounted) return;
                                  switch (response.statusCode) {
                                    case 200: {
                                      // Get userId (Previously stored by the corresponding login method)
                                      final prefs = await SharedPreferences.getInstance();
                                      final userId = prefs.getInt("userId")!;
                                      // Set userInLogged runtime access
                                      if(runtime.isClientMode) {
                                        runtime.userInLogged = await AccountService().getClientById(userId);
                                      }
                                      else {
                                        runtime.userInLogged = await AccountService().getDriverById(userId);
                                      }
                                      // Then navigate
                                      if(!context.mounted) return;
                                      context.go(route);
                                    }
                                    case 401: showToast(context: context, message: "Credenciales Incorrrectas");
                                    case 404: showToast(context: context, message: "El número de teléfono no se "
                                        "encuentra "
                                        "registrado");
                                    default: showToast(context: context, message: "Ocurrió algo mal, por favor "
                                        "inténtelo más tarde");
                                  }
                                }
                              },
                              child: Text(
                                  localization.loginButton,
                                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                              )
                            )
                          ),
                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              // TODO("yapmDev": @Reminder)
                              // - Impl recover password logic
                            },
                            child: Text(
                                localization.forgotPassword,
                                style: textTheme.bodyMedium?.copyWith(color: Colors.white)
                            )
                          ),
                          // Create New Account
                          TextButton(
                            onPressed: () {
                              // TODO("yapmDev": @Reminder)
                              // - Go to create account (depends on app profile)
                            },
                            child: Text(
                              localization.createAccountLogin,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primaryFixedDim
                              )
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  // Widget _buildForgotPassword() {
  //   return Stack(
  //     children: [
  //       Container(
  //         padding: EdgeInsets.all(30),
  //         margin: EdgeInsets.only(top: 40),
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.8),
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Padding(
  //               padding: EdgeInsets.only(top: 8, bottom: 16, right: 60),
  //               child: Text(
  //                 AppLocalizations.of(context)!.recoverPassword,
  //                 style: TextStyle(
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ),
  //             Text(
  //               AppLocalizations.of(context)!.recoverPasswordDescription,
  //               style: TextStyle(
  //                 color: Colors.black87,
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 15,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 20),
  //             TextFormField(
  //               controller: _emailController,
  //               style: TextStyle(color: Colors.black87),
  //               decoration: InputDecoration(
  //                 hintText: AppLocalizations.of(context)!.enterPhoneNumber,
  //                 hintStyle: TextStyle(color: Colors.grey[600]),
  //                 border: OutlineInputBorder(
  //                   borderSide: BorderSide(color: Colors.grey[300]!),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(color: Colors.grey[300]!),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(color: Colors.white54),
  //                 ),
  //                 fillColor: Colors.white,
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   foregroundColor: Theme.of(context).colorScheme.secondary,
  //                   backgroundColor: Theme.of(context).colorScheme.primaryContainer,
  //                   textStyle: TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //                 onPressed: () {},
  //                 child: Text(AppLocalizations.of(context)!.sendButton),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       Positioned(
  //         top: 35,
  //         right: 0,
  //         child: IconButton(
  //           icon: Icon(Icons.close, color: Colors.grey[600]),
  //           onPressed: () => setState(() => _currentScreen = 0),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}