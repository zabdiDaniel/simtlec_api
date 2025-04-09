import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/auth_api.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _rpeEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showEmailLogin = false;
  String _connectionStatus = 'Presiona para probar conexión';

  // Paleta de colores CFE
  static const Color cfeGreen = Color(0xFF009156);
  static const Color cfeDarkGreen = Color(0xFF006341);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _testConnection();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rpeEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      SystemNavigator.pop();
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = 'Probando conexión...';
    });
    try {
      final success = await AuthApi().testConnection();
      setState(() {
        _connectionStatus =
            success ? '✅ Conexión exitosa' : '❌ Sin conexión al servidor';
      });
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verifica tu conexión a internet'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _connectionStatus = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await AuthApi().login(
        _rpeEmailController.text.trim(),
        _passwordController.text.trim(),
        isEmail: _showEmailLogin,
      );
      if (response['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: response['user']),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: const ColorScheme.light(primary: cfeGreen),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cfeGreen, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'SIMTLEC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cfeDarkGreen,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChoiceChip(
                          'RPE',
                          !_showEmailLogin,
                          () => setState(() {
                            _showEmailLogin = false;
                            _rpeEmailController.clear();
                            _passwordController.clear();
                          }),
                        ),
                        const SizedBox(width: 16),
                        _buildChoiceChip(
                          'Email',
                          _showEmailLogin,
                          () => setState(() {
                            _showEmailLogin = true;
                            _rpeEmailController.clear();
                            _passwordController.clear();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _rpeEmailController,
                            decoration: InputDecoration(
                              labelText: _showEmailLogin ? 'Email' : 'RPE',
                              prefixIcon: Icon(
                                _showEmailLogin
                                    ? Icons.email_outlined
                                    : Icons.badge_outlined,
                                color: cfeGreen,
                              ),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            keyboardType:
                                _showEmailLogin
                                    ? TextInputType.emailAddress
                                    : TextInputType.text,
                            textCapitalization:
                                _showEmailLogin
                                    ? TextCapitalization.none
                                    : TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _showEmailLogin
                                    ? 'Ingrese su correo'
                                    : 'Ingrese su RPE';
                              }
                              if (_showEmailLogin &&
                                  !RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                return 'Correo no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: cfeGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed:
                                    () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              ),
                              labelStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            obscureText: _obscurePassword,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Ingrese su contraseña'
                                        : null,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cfeGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                      : const Text(
                                        'Ingresar',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _testConnection,
                      child: Text(
                        _connectionStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              _connectionStatus.contains('❌')
                                  ? Colors.red
                                  : cfeGreen,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Sistema de Inventario de Tabletas CFE',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ver. 1.0.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cfeGreen : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? cfeGreen : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
