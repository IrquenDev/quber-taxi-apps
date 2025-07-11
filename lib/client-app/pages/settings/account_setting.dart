import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  final _accountService = AccountService();
  final _client = Client.fromJson(loggedInUser);

  final _formKey = GlobalKey<FormState>();
  final _passFormKey = GlobalKey<FormState>();
  late TextEditingController _nameTFController;
  late TextEditingController _phoneTFController;
  final  _passwordTFController = TextEditingController();
  final _confirmPasswordTFController = TextEditingController();

  XFile? _profileImage;
  bool get _shouldUpdateImage => _profileImage != null || (_profileImage == null && _client.profileImageUrl != null);

  @override
  void initState() {
    super.initState();
    _nameTFController = TextEditingController(text: _client.name);
    _phoneTFController = TextEditingController(text: _client.phone);
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    final colorScheme = Theme.of(context).colorScheme;
    final radius = Theme.of(context).extension<DimensionExtension>()!.borderRadius;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: Stack(
        children: [
          // Yellow App Bar as Header
          Positioned(
            top: 0, right: 0.0, left: 0.0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ]
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back), onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Text('Ajustes',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            )
                        )
                      ]
                    )
                  )
                )
              )
            )
          ),
          // Scrollable Content
          Positioned(
            top: 100.0, left: 20.0, right: 20.0, bottom: 0.0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //  Edit Profile Info Card
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        spacing: 8.0,
                        children: [
                          // Circle Image
                          _buildCircleImage(),
                          _buildTextField('Nombre:', 'Introduzca su nombre', _nameTFController),
                          _buildTextField('Num. teléfono:', 'Introduzca su numero de teléfono', _phoneTFController),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton(
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    if(isConnected) {
                                      if (_formKey.currentState!.validate()) {
                                        final response = await _accountService.updateClient(
                                            _client.id,
                                            _nameTFController.text,
                                            _phoneTFController.text,
                                            _profileImage,
                                            _shouldUpdateImage
                                        );
                                        if(!context.mounted) return;
                                        if(response.statusCode == 200) {
                                          final client = Client.fromJson(jsonDecode(response.body));
                                          // Update session's data
                                          SessionManager.instance.save(client);
                                          _profileImage = null;
                                          showToast(context: context, message: "Hecho");
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
                                              message: "Algo salió mal, por favor inténtelo más tarde"
                                          );
                                        }
                                      }
                                    } else {
                                      showToast(context: context, message: "Revise su conexión a internet");
                                    }
                                  },
                                  child: Text(AppLocalizations.of(context)!.saveButtonPanel)
                              )
                          )
                        ]
                      ),
                    )
                  ),
                  const SizedBox(height: 16),
                  // Edit Password Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Form(
                      key: _passFormKey,
                      child: Column(
                        spacing: 12.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                              label: 'Contraseña',
                              visible: passwordVisible,
                              onToggle: (v) => setState(() => passwordVisible = v),
                              controller: _passwordTFController,
                              validator: Workflow<String?>()
                                  .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                  .step(MinLengthStep(min: 6, errorMessage: "Requiere al menos 6 caracteres"))
                                  .breakOnFirstApply(true)
                                  .withDefault((_) => null)
                                  .proceed
                          ),
                          _buildPasswordField(
                              label: 'Confirme contraseña:',
                              visible: confirmPasswordVisible,
                              onToggle: (v) => setState(() => confirmPasswordVisible = v),
                              controller: _confirmPasswordTFController,
                              validator: Workflow<String?>()
                                  .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                                  .step(MatchOtherStep(
                                    other: _passwordTFController.text,
                                    errorMessage: "Las contraseñas no coinciden"
                                  ))
                                  .breakOnFirstApply(true)
                                  .withDefault((_) => null)
                                  .proceed
                          ),
                          OutlinedButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if(isConnected) {
                                  if (_passFormKey.currentState!.validate()) {
                                    final response = await _accountService.updateClientPassword(
                                        _client.id, _passwordTFController.text
                                    );
                                    if(!context.mounted) return;
                                    if(response.statusCode == 200) {
                                      _passwordTFController.clear();
                                      _confirmPasswordTFController.clear();
                                      showToast(context: context, message: "Hecho");
                                    }
                                    else {
                                      showToast(
                                          context: context,
                                          message: "Algo salió mal, por favor inténtelo más tarde"
                                      );
                                    }
                                  }
                                } else {
                                  showToast(context: context, message: "Revise su conexión a internet");
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.saveButtonPanel))
                        ]
                      )
                    )
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8.0,
                      children: [
                        Text('Mi código de descuento:',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary
                            )
                        ),
                        Text(
                          'Invita a un amigo a usar la app y pídele que ingrese tu código al registrarse o desde Ajustes. Así recibirá un 10% de descuento en su próximo viaje.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.secondary)
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_client.referralCode)
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _client.referralCode));
                                showToast(context: context, message: "Copiado");
                              },
                            )
                          ]
                        )
                      ]
                    )
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.local_taxi),
                          title: const Text('Sobre Nosotros'),
                          onTap: () => context.push(CommonRoutes.aboutUs),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('Sobre el desarrollador'),
                          onTap: () => context.push(CommonRoutes.aboutDev),
                        ),
                      ],
                    ),
                  )
                ]
              )
            )
          )
        ]
      ),
      bottomNavigationBar: SizedBox(
        height: 56,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.errorContainer,
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              icon: Icon(Icons.logout, color: colorScheme.errorContainer),
              label: const Text('Cerrar Sesión'),
                onPressed: () async {
                  await SessionManager.instance.clear();
                  if(!context.mounted) return;
                  context.go(CommonRoutes.login);
                }
            ),
          )
        )
      )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  height: 66,
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.errorContainer,
                      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    icon: Icon(Icons.logout, color: colorScheme.errorContainer),
                    label: const Text('Cerrar Sesión'),
                    onPressed: () => context.push(CommonRoutes.login),
                  ),
                ),
              ],

            ),

          ),

          Container(
            height: 190,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.arrow_back), onPressed: () => context.pop(),
                    // ),
                    const SizedBox( width: 8,),
                    Text('Ajustes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.secondary,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
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
                  : _client.profileImageUrl != null
                  ? Image.network("${ApiConfig().baseUrl}/${_client.profileImageUrl}", fit: BoxFit.cover)
                  : ColoredBox(color: randomColor())
            )
          ),
          Positioned(
              bottom: 8.0, right: 8.0,
              child: GestureDetector(
                onTap: () async {
                  final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if(image != null) {
                    setState(() {
                      _profileImage = image;
                    });
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

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
          ),
          validator: (value) => Workflow<String?>()
              .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
              .withDefault((_) => null)
              .proceed(value)
        )
      ]
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool visible,
    required Function(bool) onToggle,
    required TextEditingController controller,
    required String? Function(String?) validator
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            hintText: 'Introduzca la contraseña deseada',
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
}