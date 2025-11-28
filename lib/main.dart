import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope es necesario para que Riverpod funcione
    const ProviderScope(
      child: App(),
    ),
  );
}

