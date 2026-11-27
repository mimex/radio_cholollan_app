import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:radio_cholollan_app/main.dart';

void main() {
  testWidgets('app loads the main radio navigation', (tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Radio'), findsOneWidget);
    expect(find.text('Programas'), findsOneWidget);
    expect(find.text('Nosotros'), findsOneWidget);
    expect(find.text('Audiencias'), findsOneWidget);
    expect(find.text('Noticias y +'), findsOneWidget);
  });

  testWidgets('Audiencias has centered links separate from Nosotros', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AudienciasScreen()));

    expect(find.text('Defensoría de Audiencias'), findsOneWidget);
    expect(find.text('Código de Ética'), findsOneWidget);
    expect(find.text('Información para audiencias'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is NetworkImage &&
            (widget.image as NetworkImage).url ==
                'https://drive.google.com/thumbnail?id=1jTmLw-0Gs1bFrDyaWw-T-dIEj-yH634N&sz=w1200',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/codigo-etica.webp',
      ),
      findsOneWidget,
    );

    for (final titulo in ['Defensoría de Audiencias', 'Código de Ética']) {
      expect(
        tester.widget<Text>(find.text(titulo)).textAlign,
        TextAlign.center,
      );
    }

    await tester.pumpWidget(const MaterialApp(home: NosotrosScreen()));
    expect(find.text('Defensoría de Audiencias'), findsNothing);
    expect(find.text('Código de Ética'), findsNothing);
  });

  testWidgets('Audiencias background fills the visible screen area', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MyApp());
    await tester.tap(find.text('Audiencias'));
    await tester.pump();

    final background = tester.getSize(
      find.byKey(const ValueKey('audiencias-background')),
    );
    expect(background.height, greaterThan(700));
  });

  test('parses The Events Calendar data into app events', () {
    final payload = {
      'events': [
        {
          'title': {'rendered': 'Festival de Radio'},
          'description': {'rendered': '<p>Una gran cita de música.</p>'},
          'start_date': '2026-12-12 20:00:00',
          'url': 'https://fmcholollan.org.mx/evento/festival-de-radio/',
          'image_url':
              'https://fmcholollan.org.mx/wp-content/uploads/2026/12/festival.jpg',
        },
      ],
    };

    final eventos = eventosDesdeJson(payload);

    expect(eventos, hasLength(1));
    expect(eventos.first.titulo, 'Festival de Radio');
    expect(eventos.first.resumen, 'Una gran cita de música.');
    expect(
      eventos.first.enlace,
      'https://fmcholollan.org.mx/evento/festival-de-radio/',
    );
    expect(
      eventos.first.imagen,
      'https://fmcholollan.org.mx/wp-content/uploads/2026/12/festival.jpg',
    );
    expect(eventos.first.fecha.contains('2026'), isTrue);
  });

  test('schedule includes its configured ending minute without overlap', () {
    expect(
      isTimeOfDayInRange(
        const TimeOfDay(hour: 10, minute: 14),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 10, minute: 14),
      ),
      isTrue,
    );
    expect(
      isTimeOfDayInRange(
        const TimeOfDay(hour: 10, minute: 15),
        const TimeOfDay(hour: 10, minute: 0),
        const TimeOfDay(hour: 10, minute: 14),
      ),
      isFalse,
    );
  });

  test('live highlight only applies to the matching weekday program', () {
    final martes = ProgramShow(
      name: 'Barra Musical',
      timeRange: '00:00 - 12:00',
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 11, minute: 59),
      imageUrl: 'assets/images/barra-musical.webp',
    );
    final jueves = ProgramShow(
      name: 'Barra Musical',
      timeRange: '00:00 - 24:00',
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
      imageUrl: 'assets/images/barra-musical.webp',
    );
    final sabado = ProgramShow(
      name: 'Barra Musical',
      timeRange: '00:00 - 24:00',
      start: const TimeOfDay(hour: 0, minute: 0),
      end: const TimeOfDay(hour: 23, minute: 59),
      imageUrl: 'assets/images/barra-musical.webp',
    );

    expect(
      isLiveShowOnDay(
        displayedDay: DateTime.tuesday,
        currentDay: DateTime.tuesday,
        currentShow: martes,
        displayedShow: martes,
      ),
      isTrue,
    );
    expect(
      isLiveShowOnDay(
        displayedDay: DateTime.thursday,
        currentDay: DateTime.tuesday,
        currentShow: martes,
        displayedShow: jueves,
      ),
      isFalse,
    );
    expect(
      isLiveShowOnDay(
        displayedDay: DateTime.saturday,
        currentDay: DateTime.tuesday,
        currentShow: martes,
        displayedShow: sabado,
      ),
      isFalse,
    );
  });

  test('parses the published schedule CSV format', () {
    const csv = '''
dia,inicio,fin,nombre,descripcion,imagen
lunes,23:30,24:00:00,Barra Musical,Programación musical automática.,barra-musical.webp
miércoles,07:00,08:00,El tío Juan,"Descripción, con coma",mi-tio-juan.webp
''';

    final programacion = programacionDesdeCsv(csv);
    final programaLunes = programacion[1]!.single;
    final programaMiercoles = programacion[3]!.single;

    expect(programaLunes.start, const TimeOfDay(hour: 23, minute: 30));
    expect(programaLunes.end, const TimeOfDay(hour: 23, minute: 59));
    expect(programaMiercoles.name, 'El tío Juan');
    expect(programaMiercoles.description, 'Descripción, con coma');
    expect(programaMiercoles.imageUrl, 'assets/images/mi-tio-juan.webp');
  });

  test('CSV prepared for Sheets matches every weeklySchedule program', () async {
    final csv = await File('weekly_schedule_import.csv').readAsString();
    final importada = programacionDesdeCsv(csv);

    for (var dia = 1; dia <= 7; dia++) {
      final original = weeklySchedule[dia] ?? const <ProgramShow>[];
      final desdeCsv = importada[dia] ?? const <ProgramShow>[];
      expect(desdeCsv, hasLength(original.length), reason: 'Día $dia');

      for (var indice = 0; indice < original.length; indice++) {
        expect(desdeCsv[indice].name, original[indice].name);
        expect(desdeCsv[indice].description, original[indice].description);
        expect(await File(original[indice].imageUrl).exists(), isTrue);
        expect(
          Uri.parse(desdeCsv[indice].imageUrl).host,
          'lh3.googleusercontent.com',
        );
        expect(Uri.parse(desdeCsv[indice].imageUrl).path, startsWith('/d/'));
        expect(desdeCsv[indice].start, original[indice].start);
        expect(desdeCsv[indice].end, original[indice].end);
      }
    }

    for (final dia in [DateTime.monday, DateTime.wednesday, DateTime.friday]) {
      final memoria = importada[dia]!.singleWhere(
        (programa) =>
            programa.name == 'Memoria Colectiva | Revista Informativa',
      );
      expect(memoria.start, const TimeOfDay(hour: 7, minute: 0));
      expect(memoria.end, const TimeOfDay(hour: 7, minute: 59));
      expect(memoria.description, 'Historias para el futuro.');
      expect(
        memoria.imageUrl,
        'https://lh3.googleusercontent.com/d/1kZpW6RybRQnG7DIk0BmMVRlLr3DbHCLU',
      );
    }
  });
}
