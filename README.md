# radio_cholollan_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Radio Cholollan 107.1 FM

## Guía para editar el calendario y recursos

## 1. ¿Dónde encontrar el calendario?

El calendario está definido en el archivo `lib/main.dart`, dentro de la variable global:

```dart
final Map<int, List<ProgramShow>> weeklySchedule = { ... };
```

* Cada clave `1` a `7` corresponde a un día de la semana (1 = lunes, …, 7 = domingo).
* Cada lista `List<ProgramShow>` contiene objetos con los datos de un programa:

  * `name`: nombre del programa
  * `timeRange`: rango de hora en formato de texto
  * `start` y `end`: objetos `TimeOfDay` que definen la validación de hora
  * `imageUrl`: URL de la imagen que aparece en la tarjeta
  * `description` (opcional): texto que aparece al tocar la tarjeta

### Ejemplo de entrada

```dart
1: [
  ProgramShow(
    name: "Barra Musical",
    timeRange: "9:00 AM - 9:30 AM",
    start: TimeOfDay(hour: 9, minute: 0),
    end:   TimeOfDay(hour: 9, minute: 30),
    imageUrl: "https://tu-cdn.com/imagenes/barra.jpg",
    description: "Breve descripción del programa",
  ),
  // …
],
```

---

## 2. Cómo editar un programa

1. **Abrir** `lib/main.dart` en tu editor de texto.
2. Ubicar la sección `weeklySchedule`.
3. Cambiar o agregar una entrada dentro del día deseado:

   * Copia y pega uno de los `ProgramShow(...)` existentes y modifica sus valores.
   * **Importante**: Mantén el formato siguiente:

     * Horas con `TimeOfDay(hour: X, minute: Y)`
     * Texto en `timeRange` debe coincidir con el rango
4. Guardar cambios y recompilar la aplicación.

---

## 3. Cómo cambiar imágenes y URLs

* Todas las imágenes deben estar en un **CDN** público (por ejemplo Cloudinary, Amazon S3, Netlify Large Media, etc.).
* Reemplaza la propiedad `imageUrl` con la URL directa al archivo GIF/PNG/JPG/WEBP.
* Evita URLs locales o rutas relativas; siempre usa `https://`.

---

## 4. Descripciones de los programas

* Para mostrar texto extra al tocar la tarjeta, asegúrate de que tu `ProgramShow` incluya el campo **description**:

  ```dart
  final String description;

  ProgramShow({
    // ...otros campos...
    required this.description,
  });
  ```

* Luego, en el bloque del programa, asigna un texto breve (máximo 2–3 líneas):

  ```dart
  description: "Descripción breve del contenido y secciones del programa.",
  ```

---

## 5. Qué **no** hacer

* **No cambiar** la estructura de la clase `ProgramShow` ni las llaves del `Map`.
* **No eliminar** el helper `isTimeOfDayInRange`, ya que destaca el programa en curso.
* **No usar** rutas de redireccionamiento o proxies; usa URLs directas seguras.

---

## 6. Compilación y despliegue web

Para generar la versión web:

```bash
flutter build web --release
```

Luego sube la carpeta `build/web` a tu hosting (drag & drop si usas Netlify, o configurando el directorio de publicación).

---
