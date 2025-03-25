import 'package:casa_grande_app/Services/Usuario.server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

import '../Models/UserModel.dart';
import '../Services/Auth.Service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 Future<void> _login() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    _showErrorDialog('Por favor, complete todos los campos');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Iniciando sesión...'),
          ],
        ),
      );
    },
  );

  try {
    // Primer paso: Autenticar con Firebase Auth
    final User? user = await _authService.signInWithEmailAndPassword(
      context,
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Si la autenticación es exitosa, obtener los datos del usuario
    if (user != null) {
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();
      
      // Obtener los datos del usuario desde Firestore
      final UserModel? userModel = await _authService.getUserDataAfterAuth(user.uid);
      
      if (userModel != null && mounted) {
        // Redirigir según el cargo
        switch (userModel.cargo) {
          case 'Administrador':
            Navigator.of(context).pushReplacementNamed('/admin');
            break;
          case 'Médico':
            Navigator.of(context).pushReplacementNamed(
              '/MedicDashboard',
              arguments: userModel,
            );
            break;
          case 'Psicólogo':
            Navigator.of(context).pushReplacementNamed(
              '/PsicologoDashboard',
              arguments: userModel,
            );
            break;
          case 'Trabajador Social':
            Navigator.of(context).pushReplacementNamed(
              '/TrabajadorSocialDashboard',
              arguments: userModel,
            );
            break;
          default:
            Navigator.of(context).pushReplacementNamed('/home');
            break;
        }
      } else {
        _showErrorDialog('No se pudieron obtener los datos del usuario');
      }
    } else {
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();
      _showErrorDialog('Credenciales incorrectas');
    }
  } catch (e) {
    // Cerrar el diálogo de carga si aún está visible
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    
    if (mounted) {
      _showErrorDialog('Error al iniciar sesión: ${e.toString()}');
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores del tema moderno para centro gerontológico
    const Color primaryColor = Color(0xFF5A8BB0); // Azul calmante
    const Color accentColor = Color(0xFF7DCFB6); // Verde teal suave
    const Color backgroundColor = Color(0xFFF9F9F9); // Fondo claro
    const Color textColor = Color(0xFF2D3E50); // Texto oscuro

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo y título
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.heart_fill,
                      size: 50,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'Centro Gerontológico',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Cuidados con calidez y experiencia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6D7A8D),
                    letterSpacing: 0.2,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Campos de texto
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.systemGrey5,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Email
                          const Text(
                            'Correo electrónico',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF515C6F),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          CupertinoTextField(
                            controller: _emailController,
                            placeholder: 'ejemplo@correo.com',
                            keyboardType: TextInputType.emailAddress,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Icon(
                                CupertinoIcons.mail,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Contraseña
                          const Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF515C6F),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          CupertinoTextField(
                            controller: _passwordController,
                            placeholder: '••••••••',
                            obscureText: _obscurePassword,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            prefix: const Padding(
                              padding: EdgeInsets.only(left: 14),
                              child: Icon(
                                CupertinoIcons.lock,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                                  color: CupertinoColors.systemGrey,
                                  size: 20,
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Olvidó su contraseña
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text(
                                '¿Olvidó su contraseña?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                // Navegar a pantalla de recuperación de contraseña
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Botón de inicio de sesión
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                                  : const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tiene una cuenta?',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6D7A8D),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.only(left: 4),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                      onPressed: () {
                        // Navegar a pantalla de registro
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}