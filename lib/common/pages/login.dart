import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  var _obscureText = true;
  int _currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background_car.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_currentScreen == 0) ...[
                          Text(
                            AppLocalizations.of(context)!.welcomeTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 60,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 60),
                        ],
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: _buildCurrentScreen(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 0: return _buildInitialLogin();
      case 1: return _buildForgotPassword();
      default: return _buildInitialLogin();
    }
  }

  Widget _buildInitialLogin() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8)
              ),
              hintText: AppLocalizations.of(context)!.enterEmail,
              suffixIcon: _isEmailValid()
                  ? Padding(
                padding: EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  "assets/icons/yelow_check.svg",
                  width: 20,
                  height: 20,
                ),
              )
                  : null,
            ),
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) return AppLocalizations.of(context)!.requiredEmail;
              if (!_isValidEmail(value)) return AppLocalizations.of(context)!.invalidEmail;
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8)
              ),
              hintText: AppLocalizations.of(context)!.enterPassword,
              hintStyle: TextStyle(color: Colors.grey[600]),
              suffixIcon: IconButton(
                padding: EdgeInsets.all(12.0),
                icon: SvgPicture.asset(
                  _obscureText
                      ? "assets/icons/visibility_off.svg"
                      : "assets/icons/visibility.svg",
                  width: 20,
                  height: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return AppLocalizations.of(context)!.requiredField;
              return null;
            },
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Theme.of(context).colorScheme.secondary,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {}
              },
              child: Text(AppLocalizations.of(context)!.loginButton),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _currentScreen = 1),
            child: Text(
              AppLocalizations.of(context)!.forgotPassword,
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              AppLocalizations.of(context)!.createAccountLogin,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(30),
          margin: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8, bottom: 16, right: 60),
                child: Text(
                  AppLocalizations.of(context)!.recoverPassword,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.recoverPasswordDescription,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterEmail,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context)!.sendButton),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 35,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600]),
            onPressed: () => setState(() => _currentScreen = 0),
          ),
        ),
      ],
    );
  }

  bool _isEmailValid() => _isValidEmail(_emailController.text);

  bool _isValidEmail(String email) => RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  ).hasMatch(email);
}