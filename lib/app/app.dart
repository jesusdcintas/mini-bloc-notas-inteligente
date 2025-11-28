import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'router.dart';

/// Widget principal de la aplicación
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mini Bloc de Notas Inteligente',
      
      // Configuración del tema
      theme: AppTheme.lightTheme,
      
      // Configuración del router
      routerConfig: router,
      
      // Ocultar banner de debug
      debugShowCheckedModeBanner: false,
    );
  }
}
