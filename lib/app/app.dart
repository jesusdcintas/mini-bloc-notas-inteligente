import 'package:flutter/material.dart';
import 'package:mini_bloc_notas_inteligente/features/notes/presentation/pages/notes_list_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Bloc de Notas',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const NotesListPage(),
    );
  }
}
