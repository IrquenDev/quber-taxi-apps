import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quber_taxi/common/models/client.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';
import 'package:quber_taxi/utils/runtime.dart';
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
  bool _isProcessingImage = false;
  bool _isSubmitting = false;

  // Password visibility states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // SMS Verification
  final _authService = AuthService();

  void _validateAndSubmit() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    // Validate form
    if(!_formKey.currentState!.validate()) return;
    
    // Send verification code first, then show dialog
    await _sendVerificationCodeAndShowDialog();
  }

  Future<void> _sendVerificationCodeAndShowDialog() async {
    final localizations = AppLocalizations.of(context)!;
    
    if(!hasConnection(context)) {
      showToast(context: context, message: localizations.checkConnection);
      return;
    }

    // Show loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _authService.requestPhoneVerificationCode(_phoneController.text);
      
      if (!mounted) return;
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (response.statusCode == 200) {
        // Success - show verification dialog
        _showVerificationDialog();
      } else {
        showToast(context: context, message: localizations.sendCodeError);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        showToast(context: context, message: localizations.checkConnection);
      }
    }
  }

  Future<void> _showVerificationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final TextEditingController codeController = TextEditingController();

    // Resend code timer logic
    bool canResendCode = false;
    int resendTimeoutSeconds = 240; // 4 minutes fixed
    Timer? resendTimer;
    
    // SMS states
    bool isSendingCode = false;
    bool isVerifying = false;
    String? errorMessage;
    
    // Function to format time as mm:ss
    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    // Function to send verification code (for resend only)
    Future<void> sendVerificationCode(Function setDialogState) async {
      // Prevent multiple simultaneous calls
      if (isSendingCode) return;
      
      if(!hasConnection(context)) {
        setDialogState(() {
          errorMessage = localizations.checkConnection;
        });
        return;
      }

      setDialogState(() {
        isSendingCode = true;
        errorMessage = null;
      });

      try {
        final response = await _authService.requestPhoneVerificationCode(_phoneController.text);
        
        if (!mounted) return;
        
        setDialogState(() {
          isSendingCode = false;
          if (response.statusCode == 200) {
            errorMessage = null;
          }
          else if (response.body.contains("phone not found") ||
              response.body.contains("already registered") ||
              response.statusCode == 409) {

            errorMessage = "Este número ya está registrado.";
          } else {
            errorMessage = localizations.sendCodeError;
          }
        });
      } catch (e) {
        if (mounted) {
          setDialogState(() {
            isSendingCode = false;
            errorMessage = localizations.checkConnection;
          });
        }
      }
    }

    // Function to verify code
    Future<void> verifyCode(String code, Function setDialogState) async {
      if(!hasConnection(context)) {
        setDialogState(() {
          errorMessage = localizations.checkConnection;
        });
        return;
      }

      setDialogState(() {
        isVerifying = true;
        errorMessage = null;
      });

      try {
        final response = await _authService.verifyPhoneNumber(_phoneController.text, code);


        if(response.statusCode == 200) {
          // Success - proceed with registration
          resendTimer?.cancel();
          await _submitForm(); // already handles navigation
        } else if (response.statusCode == 400) {
          final responseBody = response.body;
          if (responseBody.contains("Invalid verification code")) {
            errorMessage = localizations.invalidVerificationCode;
          } else if (responseBody.contains("Verification code expired")) {
            errorMessage = localizations.verificationCodeExpired;
          } else {
              errorMessage = localizations.invalidVerificationCode;
          }
        } else {
          errorMessage = localizations.verifyCodeError;
        }
      } catch (e) {
        if (mounted) {
          setDialogState(() {
            isVerifying = false;
            errorMessage = localizations.checkConnection;
          });
        }
      }
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false, // Prevent back button from closing dialog
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              // Start countdown timer
              resendTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (mounted) {
                    setDialogState(() {
                      if (resendTimeoutSeconds > 0) {
                        resendTimeoutSeconds--;
                      } else {
                        canResendCode = true;
                        timer.cancel();
                      }
                    });
                  } else {
                    timer.cancel();
                  }
                });

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium),
                ),
                title: Text(
                  localizations.accountVerification,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.verificationCodeMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Loading indicator for sending code
                    if (isSendingCode) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            localizations.sendingCode,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    
                    // Error message
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      enabled: !isSendingCode && !isVerifying,
                      decoration: InputDecoration(
                        labelText: localizations.verificationCodeLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall),
                        ),
                        hintText: localizations.verificationCodeHint,
                      ),
                      maxLength: 6,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (canResendCode && !isSendingCode && !isVerifying) ? () {
                            setDialogState(() {
                              canResendCode = false;
                              // Reset timeout to 4 minutes
                              resendTimeoutSeconds = 240;
                              resendTimer?.cancel();
                              resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                if (mounted) {
                                  setDialogState(() {
                                    if (resendTimeoutSeconds > 0) {
                                      resendTimeoutSeconds--;
                                    } else {
                                      canResendCode = true;
                                      timer.cancel();
                                    }
                                  });
                                } else {
                                  timer.cancel();
                                }
                              });
                            });
                            // Send verification code again
                            sendVerificationCode(setDialogState);
                          } : null,
                          child: Text(
                            localizations.resendCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (canResendCode && !isSendingCode && !isVerifying)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        if (!canResendCode) ...[
                          const SizedBox(width: 8.0),
                          Text(
                            formatTime(resendTimeoutSeconds),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                        ),
                      ),
                      onPressed: (!isSendingCode && !isVerifying) ? () {
                        final code = codeController.text.trim();
                        if (code.isNotEmpty) {
                          verifyCode(code, setDialogState);
                        }
                      } : null,
                      child: isVerifying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(localizations.verifying),
                            ],
                          )
                        : Text(localizations.sendCode),
                    ),
                  ),
                ],
              );
            },
          ),
        )
    ).then((_) {
      // Clean up timer if dialog is closed by any other means
      resendTimer?.cancel();
      resendTimer = null;
    });
  }

  Future<void> _submitForm() async {
    final localizations = AppLocalizations.of(context)!;
    
    if(!hasConnection(context)) {
      showToast(context: context, message: localizations.checkConnection);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Make the register request
      final response = await AccountService().registerClient(
          name: _nameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          profileImage: _profileImage,
          faceIdImage: widget.faceIdImage
      );
      
      // Avoid context's gaps
      if(!mounted) return;
      
      // Handle responses (depends on status code)
      // OK
      if(response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final client = Client.fromJson(json);
        // Save the user's session
        final success = await SessionPrefsManager.instance.save(client);
        if(success) {
          // Avoid context's gaps
          if(!mounted) return;
          // Navigate to home safely
          context.go(ClientRoutes.home);
        } else {
          if(mounted) {
            showToast(context: context, message: localizations.registrationError);
          }
        }
      }
      // CONFLICT
      else if(response.statusCode == 409) {
        if(mounted) {
            Navigator.of(context).pop();
            showToast(context: context, message: localizations.phoneAlreadyRegistered);
          // showToast(context: context, message: localizations.phoneAlreadyRegistered);
        }
      }
      // ANY OTHER STATUS CODE
      else {
        if(mounted) {
          showToast(
              context: context,
              message: localizations.registrationError
          );
        }
      }
    } catch (e) {
      // Handle any network or parsing errors
      if(mounted) {
        showToast(context: context, message: localizations.registrationError);
      }
    } finally {
      if(mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  bool _areFieldsValid = false;

  void _onFieldChanged() {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final phoneValid = _phoneController.text.trim().length == 8 &&
        RegExp(r'^\d{8}$').hasMatch(_phoneController.text.trim());
    final passwordValid = _passwordController.text.length >= 6;
    final confirmPasswordValid = _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;

    final allValid =
        nameValid && phoneValid && passwordValid && confirmPasswordValid;

    if (_areFieldsValid != allValid) {
      setState(() {
        _areFieldsValid = allValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late final ColorScheme colorScheme = Theme.of(context).colorScheme;
    late final TextTheme textTheme = Theme.of(context).textTheme;
    late final localizations = AppLocalizations.of(context)!;
    late final iconTheme = Theme.of(context).iconTheme;
    return Scaffold(
        body: Stack(children: [
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
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 90, top: 20),
                child: Row(
                  children: [
                    // Icon(Icons.arrow_back, color: colorScheme.shadow),
                    const SizedBox(width: 38),
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
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.nameAndLastName,
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) => Workflow<String?>()
                            .step(RequiredStep(errorMessage: localizations.requiredField))
                            .withDefault((_) => null)
                            .proceed(value)
                    ),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.phoneNumber,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: localizations.phoneHint,
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) => Workflow<String?>()
                            .step(RequiredStep(errorMessage: localizations.requiredField))
                            .withDefault((_) => null)
                            .proceed(value)
                    ),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.password,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: localizations.passwordHint,
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) => Workflow<String?>()
                            .step(RequiredStep(errorMessage: localizations.requiredField))
                            .step(MinLengthStep(min: 6, errorMessage: localizations.passwordMinLength))
                            .breakOnFirstApply(true)
                            .withDefault((_) => null)
                            .proceed(value)
                    ),
                    const SizedBox(height: 20),
                    Text(AppLocalizations.of(context)!.passwordConfirm,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          hintText: localizations.passwordConfirm,
                          hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.requiredField;
                          }
                          if (value != _passwordController.text) {
                            return localizations.passwordsDoNotMatch;
                          }
                          return null;
                        }
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
              final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedImage != null) {
                setState(() => _isProcessingImage = true);
                final compressedImage =
                    await compressXFileToTargetSize(pickedImage, 5);
                setState(() => _isProcessingImage = false);
                if (compressedImage != null) {
                  setState(() {
                    _profileImage = compressedImage;
                  });
                }
              }
            },
            child: _buildCircleImagePicker(colorScheme, iconTheme),
          ))),
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
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _validateAndSubmit,
                  child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            AppLocalizations.of(context)!.sendingCode,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                        ],
                      )
                    : Text(
                        AppLocalizations.of(context)!.endRegistration,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary
                        )
                      )
                )
              )
            ),
            if(_isProcessingImage)
            Positioned.fill(child: Center(child: CircularProgressIndicator()))
          ]
        )
      );
    }

    Widget _buildCircleImagePicker(
        ColorScheme colorScheme, IconThemeData iconTheme) {
      return Stack(alignment: Alignment.center, children: [
        // Main Circle
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 80,
            backgroundColor: colorScheme.surfaceContainerLowest,
            foregroundImage:
                _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
            child: _profileImage == null
                ? SvgPicture.asset("assets/icons/camera.svg",
                    width: iconTheme.size! * 3,
                    colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn))
                : null,
          ),
        ),
        if (_profileImage != null)
          Positioned(
            top: 8.0,
            right: 8.0,
            child: GestureDetector(
              onTap: () => setState(() => _profileImage = null),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.error,
                child: Icon(Icons.close, color: colorScheme.onError, size: 16),
              ),
            ),
          )
      ]);
    }
  }
