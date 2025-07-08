import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class CreateClientAccountPage extends StatefulWidget {

  final Uint8List faceIdImage;

  const CreateClientAccountPage({super.key, required this.faceIdImage});

  @override
  State<CreateClientAccountPage> createState() => _CreateClientAccountPage();
}

class _CreateClientAccountPage extends State<CreateClientAccountPage> {

  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  XFile? _profileImage;

  @override
  Widget build(BuildContext context) {
    late final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final TextTheme textTheme = Theme.of(context).textTheme;
    late final localizations = AppLocalizations.of(context)!;
    late final iconTheme = Theme.of(context).iconTheme;
    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            spacing: 20.0,
            children: [
              // App Bar as Header
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30.0, bottom: 90, top: 20),
                    child: Row(
                      children: [
                        // Icon(Icons.arrow_back, color: colorScheme.shadow),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.createAccount,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.shadow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(AppLocalizations.of(context)!.name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              hintText: AppLocalizations.of(context)!.nameAndLastName,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              )
                            ),
                            validator: (value) => Workflow<String?>()
                                .step(RequiredStep(errorMessage: localizations.requiredField))
                                .withDefault((_) => null)
                                .proceed(value)
                        ),
                        const SizedBox(height: 20),
                        Text(AppLocalizations.of(context)!.phoneNumber,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Ej: 5564XXXX',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) => Workflow<String?>()
                                .step(RequiredStep(errorMessage: localizations.requiredField))
                                .withDefault((_) => null)
                                .proceed(value)
                        ),
                        const SizedBox(height: 20),
                        Text(AppLocalizations.of(context)!.password,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Introduzca la contraseña deseada',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) => Workflow<String?>()
                                .step(RequiredStep(errorMessage: localizations.requiredField))
                                .step(MinLengthStep(min: 6, errorMessage: "La contraseña debe tener al menos 6 caracteres"))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null)
                                .proceed(value)
                        ),
                        const SizedBox(height: 20),
                        Text(AppLocalizations.of(context)!.passwordConfirm,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Repita la contraseña deseada',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) => Workflow<String?>()
                                .step(RequiredStep(errorMessage: localizations.requiredField))
                                .step(MatchOtherStep(
                                  other: _passwordController.text,
                                  errorMessage: "Las contraseñas no coinciden"))
                                .breakOnFirstApply(true)
                                .withDefault((_) => null)
                                .proceed(value)
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Camera Button
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
                child: GestureDetector(
                  onTap: () async {
                    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if(image != null) {
                      setState(() => _profileImage = image);
                    }
                  },
                  child: _buildCircleImagePicker(colorScheme, iconTheme),
              )
            )
          ),
          // Submit Form Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  // Hide keyboard
                  FocusScope.of(context).unfocus();
                  // Validate form
                  if(!_formKey.currentState!.validate()) return;
                  // Check connection status
                  if(!isConnected) {
                    showToast(context: context, message: "Revise su conexión a internet");
                    return;
                  }
                  // Make the register request
                  final response = await AccountService().registerClient(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      password: _passwordController.text,
                      profileImage: _profileImage,
                      faceIdImage: widget.faceIdImage
                  );
                  // Avoid context's gaps
                  if(!context.mounted) return;
                  // Handle responses (depends on status code)
                  // OK
                  if(response.statusCode == 200) {
                    final json = jsonDecode(response.body);
                    final client = Client.fromJson(json);
                    // Save the user's session
                    final success = await SessionManager.instance.save(client);
                    if(success) {
                      // Avoid context's gaps
                      if(!context.mounted) return;
                      // Navigate to home safely
                      context.go(ClientRoutes.home);
                    }
                  }
                  // CONFLICT
                  else if(response.statusCode == 409) {
                    showToast(context: context, message: "El número de teléfono ya se encuentra regitrado");
                  }
                  // ANY OTHER STATUS CODE
                  else {
                    showToast(
                        context: context,
                        message: "No pudimos completar su registro. Por favor inténtelo más tarde"
                    );
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.endRegistration,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary
                  )
                )
              )
            )
          )
        ]
      )
    );
  }

  Widget _buildCircleImagePicker(ColorScheme colorScheme, IconThemeData iconTheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Circle
        CircleAvatar(
          radius: 80,
          backgroundColor: colorScheme.surfaceContainerLowest,
          foregroundImage: _profileImage != null
              ? FileImage(File(_profileImage!.path))
              : null,
          child: _profileImage == null
              ? SvgPicture.asset("assets/icons/camera.svg", width: iconTheme.size! * 3)
              : null,
        ),
        if (_profileImage != null)
          Positioned(
            top: 8.0, right: 8.0,
            child: GestureDetector(
              onTap: ()=> setState(()=> _profileImage = null),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}