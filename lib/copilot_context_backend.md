Estoy trabajando en la rama "jdcintas". 
Mi responsabilidad es completar TODO el backend del proyecto Flutter “Mini Bloc de Notas Inteligente”.

Necesito que generes o completes el código de backend cumpliendo estos requisitos EXACTOS:

====================================
🔥 BACKEND DEL PROYECTO (MI PARTE)
====================================

Tecnologías:
- SQLite (sqflite + path)
- Riverpod (AsyncNotifier)
- Arquitectura por features
- Integración IA Google Gemini

Estructura obligatoria del backend:

lib/
 ├── core/
 │    ├── database/
 │    │     ├── app_database.dart
 │    │     └── note_dao.dart
 │    ├── models/
 │    │     └── note.dart
 │    └── services/
 │          └── ai_service.dart
 ├── features/notes/
 │    ├── data/
 │    │     └── notes_repository.dart
 │    ├── providers/
 │    │     └── notes_provider.dart

====================================
🔥 REQUISITOS DETALLADOS DEL BACKEND
====================================

1. note.dart  
   - Modelo con id, title, content  
   - toMap() y fromMap()  

2. app_database.dart  
   - Inicializa SQLite  
   - Crea la tabla “notes” con:  
        id INTEGER PRIMARY KEY AUTOINCREMENT  
        title TEXT  
        content TEXT  

3. note_dao.dart  
   Implementar CRUD completo:
   - insertNote(Note)
   - getNotes()
   - updateNote()
   - deleteNote()

4. notes_repository.dart  
   - Encapsula el DAO  
   - Exponer funciones:  
       getNotes(), addNote(), updateNote(), deleteNote()

5. notes_provider.dart (Riverpod AsyncNotifier)  
   - Cargar notas al iniciar  
   - Añadir nota  
   - Actualizar nota  
   - Borrar nota  
   - Refrescar estado automáticamente con AsyncValue  

6. ai_service.dart (Google Gemini API)  
   - Endpoint:  
     https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=API_KEY
   - Métodos:  
        summarize(String text)  
        improve(String text)  
   - Formato JSON:  
        {
          "contents": [
            {
              "parts": [
                { "text": "PROMPT + texto del usuario" }
              ]
            }
          ]
        }
   - Devolver:  
        data["candidates"][0]["content"]["parts"][0]["text"]

====================================
🔥 OBJETIVO
====================================

Generar TODO el backend funcional.
Cada archivo debe construirse siguiendo best practices, sin errores y sin duplicar código.
Usa la arquitectura por features y mantén el código limpio.

Crea cualquier método auxiliar que consideres necesario.

====================================

Genera y completa todo el backend de forma automática, siguiendo esta estructura y estos requisitos estrictos.
