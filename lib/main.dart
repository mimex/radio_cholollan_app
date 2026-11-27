//****NO MODIFICAR***
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

// ──────────── your URL constants ──────────── SI SE PUEDE MODIFICAR
const _kShareLink = "https://radio.fmcholollan.org.mx";
const _kFacebookLink = "https://www.facebook.com/fmcholollan";
const _kInstagramLink = "https://www.instagram.com/cholollan_107.1/";
const _kWhatsappLink = "https://api.whatsapp.com/send/?phone=5212228432727";
// ──────────── NUEVO: compartir por sección ────────────
const List<String> _kSecciones = [
  'radio',
  'programas',
  'nosotros',
  'audiencias',
  'mas',
];

const Map<String, String> _kMensajesCompartir = {
  'radio': 'Escucha Radio Cholollan 107.1 FM en vivo 📻',
  'programas': 'Conoce la programación de Radio Cholollan 107.1 FM 🗓️',
  'nosotros': 'Conoce a Radio Cholollan 107.1 FM, la voz de los pueblos',
  'audiencias': 'Información de audiencias de Radio Cholollan 107.1 FM',
  'mas': 'Noticias, podcast y eventos de Radio Cholollan 107.1 FM',
};

int _seccionActual = 0;

int _indiceInicialDesdeUrl() {
  final seccion = Uri.base.queryParameters['seccion'] ?? '';
  final i = _kSecciones.indexOf(seccion);
  return i < 0 ? 0 : i;
}

void compartirSeccion() {
  final seccion = _kSecciones[_seccionActual];
  final enlace = '$_kShareLink/?seccion=$seccion';
  Share.share('${_kMensajesCompartir[seccion]}\n$enlace');
}

//──────────── your image for calendar constants ──────────── ****NO MODIFICAR***
const double _cardImageWidth = 333.0;
const double _cardImageHeight = 333.0; // or whatever you like

//****NO MODIFICAR***
Future<void> launchURL(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
    throw 'Could not launch $url';
  }
}

//****NO MODIFICAR***
Widget socialRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.share,
            size: 24,
            color: Color.fromRGBO(62, 35, 20, 0.888),
          ),
          onPressed: compartirSeccion,
        ),
        IconButton(
          icon: const Icon(
            Icons.facebook,
            size: 24,
            color: Color.fromRGBO(62, 35, 20, 0.888),
          ),
          onPressed: () => launchURL(_kFacebookLink),
        ),
        IconButton(
          icon: const Icon(
            Icons.center_focus_weak,
            size: 24,
            color: Color.fromRGBO(62, 35, 20, 0.888),
          ),
          onPressed: () => launchURL(_kInstagramLink),
        ),
        IconButton(
          icon: const Icon(
            Icons.chat_bubble,
            size: 24,
            color: Color.fromRGBO(62, 35, 20, 0.888),
          ),
          onPressed: () => launchURL(_kWhatsappLink),
        ),
      ],
    ),
  );
}

const double _cardWidth = 200;
const double _cardHeight = _cardWidth * 3 / 4; // 4:3 ratio

//****NO MODIFICAR***
class ShowCard extends StatefulWidget {
  final ProgramShow show;
  final bool isLive;

  const ShowCard({super.key, required this.show, this.isLive = false});

  @override
  _ShowCardState createState() => _ShowCardState();
}

//****NO MODIFICAR***
class _ShowCardState extends State<ShowCard> {
  bool _flipped = false;

  @override
  Widget build(BuildContext ctx) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _flipped = !_flipped),
        child: SizedBox(
          width: _cardWidth,
          child: Card(
            elevation: widget.isLive ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _flipped
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Builder(
                      builder: (_) {
                        final url = widget.show.imageUrl;
                        if (url.startsWith('http')) {
                          return Image.network(
                            url,
                            width: _cardWidth,
                            height: _cardHeight,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Image.asset(
                                  'assets/images/barra-musical.webp',
                                  width: _cardWidth,
                                  height: _cardHeight,
                                  fit: BoxFit.cover,
                                ),
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.fallback,
                          );
                        } else {
                          return Image.asset(
                            url,
                            width: _cardWidth,
                            height: _cardHeight,
                            fit: BoxFit.cover,
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.show.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
                        Text(widget.show.timeRange),
                      ],
                    ),
                  ),
                ],
              ),
              secondChild: Container(
                width: _cardWidth,
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.show.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//****NO MODIFICAR***
void main() => runApp(MyApp());

// ----------------------------------------------------------
// MODEL & SCHEDULE DATA ****NO MODIFICAR***
// ----------------------------------------------------------
class ProgramShow {
  final String name;
  final String timeRange; // e.g., "8:00 AM - 10:00 AM" for display
  final TimeOfDay start;
  final TimeOfDay end;
  final String imageUrl;
  final String description;

  ProgramShow({
    required this.name,
    required this.timeRange,
    required this.start,
    required this.end,
    required this.imageUrl,
    this.description = '',
  });
}

// Helper to determine if current time is in the range. ****NO MODIFICAR***
bool isTimeOfDayInRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
}

// CALENDAR DATA (!!!!!!! SI SE PUEDE MODIFICAR !!!!!!!!)
final Map<int, List<ProgramShow>> weeklySchedule = {
  1: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 7:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 6, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Memoria Colectiva | Revista Informativa",
      timeRange: "7:00 AM - 8:00 AM",
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/memoria-colectiva.webp",
      description: "Historias para el futuro.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "8:00 AM - 8:30 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 8, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "El tío Juan",
      timeRange: "8:30 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 30),
      end: TimeOfDay(hour: 8, minute: 59),
      imageUrl: "assets/images/mi-tio-juan.webp",
      description:
          "Historias para aprender de la sabiduría popular, acompañadas de humor y humanidad.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 AM - 9:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 9, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Radio Informaremos",
      timeRange: "9:30 AM - 10:00 AM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "assets/images/radio-informaremos.webp",
      description: "Noticias para los pueblos de México y el mundo.",
    ),
    ProgramShow(
      name: "Tlaktipak Contacto Humano con la Naturaleza",
      timeRange: "10:00 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/tlalipak.webp",
      description:
          "Programa hablado sobre la relación humana con el medio ambiente.",
    ),
    ProgramShow(
      name: "Radio Hasta Encontrarles: Las voces de la búsqueda",
      timeRange: "11:00 AM - 1:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "assets/images/radio-hasta-encontrarles.webp",
      description:
          "Mapeo sonoro a nivel nacional, para conocer las diferencias que se presentan en cada región en torno a la desaparición de personas, dar cuenta de las característica, compartir estrategias, aprendizajes y experiencias. Con este espacio buscamos contribuir a la búsqueda de verdad, justicia y no repetición.",
    ),
    ProgramShow(
      name: "La Tremenda Corte - Tres Patines",
      timeRange: "1:00 PM - 1:30 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 29),
      imageUrl: "assets/images/tremanda-corte-tres-patines.webp",
      description:
          "Con enredos verbales y tergiversando el doble sentido de las palabras, Tres Patines busca confundir al Tremendo Juez para librarse de cada condena.",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "1:30 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 30),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description:
          "Historias de los pueblos indígenas y afrodescendientes, en formato de podcast.",
    ),
    ProgramShow(
      name: "El Sabor de la Vida",
      timeRange: "2:00 PM - 3:00 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 14, minute: 59),
      imageUrl: "assets/images/el-sabor-de-la-vida.webp",
      description:
          "Recomendaciones sobre remedios naturales para mejorar nuestra salud.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "3:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 15, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Porfirio Cadena",
      timeRange: "3:30 PM - 4:00 PM",
      start: TimeOfDay(hour: 15, minute: 30),
      end: TimeOfDay(hour: 15, minute: 59),
      imageUrl: "assets/images/porfirio-cadena.webp",
      description:
          "Conoce la historia del hombre que perdió su ojo derecho tras un violento enfrentamiento con los asesinos de su padre.",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/asi-suena-cholula-lym.webp",
      description:
          "Complacencias musicales en vivo llamando o escribiendo al teléfono de la cabina de radio.",
    ),
    ProgramShow(
      name: "Cultura a través de los Pueblos",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "assets/images/cultura-a-traves-de-los-pueblos.webp",
      description:
          "Análisis y entrevistas que dan contexto sobre la vida en los pueblos indígenas, con perspectiva territorial y antropológica.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "7:00 PM - 7:15 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 19, minute: 14),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Kaliman",
      timeRange: "7:15 PM - 7:45 PM",
      start: TimeOfDay(hour: 19, minute: 15),
      end: TimeOfDay(hour: 19, minute: 44),
      imageUrl: "assets/images/kaliman.webp",
      description:
          "Sigue las aventuras del hombre increíble, un justiciero experto en artes marciales, ciencias y disciplinas mentales.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "7:45 PM - 8:00 PM",
      start: TimeOfDay(hour: 19, minute: 45),
      end: TimeOfDay(hour: 19, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Qué Tienes para Cocinar",
      timeRange: "8:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 20, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/que-tienes-para-cocinar.webp",
      description:
          "Recorridos gastronómicos y culturales, en los pueblos de la región Cholulteca y de México, a través de entrevistas y documentación.",
    ),
    ProgramShow(
      name: "Hasta Moztla",
      timeRange: "9:30 PM - 10:30 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "assets/images/hasta-moztla.webp",
      description: "Relatos nocturnos y paranormales.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 PM - 12:00 AM",
      start: TimeOfDay(hour: 22, minute: 30),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Tuesday
  2: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "00:00 AM - 12:00 PM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Wednesday
  3: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 7:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 6, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Memoria Colectiva | Revista Informativa",
      timeRange: "7:00 AM - 8:00 AM",
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/memoria-colectiva.webp",
      description: "Historias para el futuro.",
    ),
    ProgramShow(
      name: "La Tremenda Corte - Tres Patines",
      timeRange: "8:00 AM - 8:30 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 8, minute: 29),
      imageUrl: "assets/images/tremanda-corte-tres-patines.webp",
      description:
          "Con enredos verbales y tergiversando el doble sentido de las palabras, Tres Patines busca confundir al Tremendo Juez para librarse de cada condena.",
    ),
    ProgramShow(
      name: "Historias Campiranas",
      timeRange: "8:30 AM - 10:00 AM",
      start: TimeOfDay(hour: 8, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "assets/images/raices-huastecas.webp",
      description:
          "Música mexicana del género ranchero, acompañado de relatos del campo.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "El Círculo: Ecos de la Trata y el Territorio",
      timeRange: "10:30 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 30),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/el-circulo-escenario-tlaxcala.webp",
      description:
          "Abordaje de las problemáticas socioterritoriales en Tlaxcala. Una producción del medio indipendiente Escenario Tlaxcala y su consejo editorial.",
    ),
    ProgramShow(
      name: "Kaliman",
      timeRange: "11:00 PM - 11:30 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 11, minute: 29),
      imageUrl: "assets/images/kaliman.webp",
      description:
          "Sigue las aventuras del hombre increíble, un justiciero experto en artes marciales, ciencias y disciplinas mentales.",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "11:30 AM - 12:00 PM",
      start: TimeOfDay(hour: 11, minute: 30),
      end: TimeOfDay(hour: 11, minute: 59),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description:
          "Historias de los pueblos indígenas y afrodescendientes, en formato de podcast.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "12:00 PM - 1:00 PM",
      start: TimeOfDay(hour: 12, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Venerable Pan de Maíz",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "assets/images/venerable-pan-de-maiz.webp",
      description:
          "Crónicas de la historia local de Tlaxcalancingo y la región cholulteca, explicando la composición (morfología) de las palabras en náhuatl que aún ocupamos en nuestra vida cotidiana, fiestas y rituales.",
    ),
    ProgramShow(
      name: "El sabor de la Salsa",
      timeRange: "2:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "assets/images/el-sabor-de-la-salsa.webp",
      description:
          "Complacencias musicales que fusionan los ritmos africanos y caribeños con la esencia de nuestra tierra mexicana.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "3:30 PM - 3:45 PM",
      start: TimeOfDay(hour: 15, minute: 30),
      end: TimeOfDay(hour: 15, minute: 44),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "El tío Juan",
      timeRange: "3:45 PM - 4:00 PM",
      start: TimeOfDay(hour: 15, minute: 45),
      end: TimeOfDay(hour: 15, minute: 59),
      imageUrl: "assets/images/mi-tio-juan.webp",
      description:
          "Historias para aprender de la sabiduría popular, acompañadas de humor y humanidad.",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/asi-suena-cholula-lym.webp",
      description:
          "Complacencias musicales en vivo llamando o escribiendo al teléfono de la cabina de radio.",
    ),
    ProgramShow(
      name: "Contramáscaras",
      timeRange: "6:00 PM - 7:30 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 19, minute: 29),
      imageUrl: "assets/images/contramascaras.webp",
      description:
          "Entrevistas enfocadas en temas de derechos humanos y movimientos sociales, cuyo objetivo es desentrañar el rostro del poder en turno.",
    ),
    ProgramShow(
      name: "Yestli",
      timeRange: "7:30 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 30),
      end: TimeOfDay(hour: 20, minute: 59),
      imageUrl: "assets/images/yestli-sangre-nueva.webp",
      description:
          "Difusión de la música tradicional mexicana y de las expresiones culturales de los pueblos de la región cholulteca. A través de sus contenidos, promueve el conocimiento y la valoración de los usos, costumbres y tradiciones de Tlaxcalancingo, Cholula y otras comunidades con raíces indígenas.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 0),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Frecuencia Ambiental",
      timeRange: "10:00 PM - 11:00 PM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 22, minute: 59),
      imageUrl: "assets/images/frecuencia-ambiental.webp",
      description:
          "Cada programa busca democratizar el conocimiento y los saberes, abordando temas actuales sobre las problemáticas ambientales y cómo repercuten en nuestros pueblos.",
    ),
    ProgramShow(
      name: "Porfirio Cadena",
      timeRange: "11:00 PM - 11:30 PM",
      start: TimeOfDay(hour: 23, minute: 0),
      end: TimeOfDay(hour: 23, minute: 29),
      imageUrl: "assets/images/porfirio-cadena.webp",
      description:
          "Conoce la historia del hombre que perdió su ojo derecho tras un violento enfrentamiento con los asesinos de su padre.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "11:30 PM - 12:00 AM",
      start: TimeOfDay(hour: 23, minute: 30),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Thursday
  4: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 12:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Friday
  5: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 7:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 6, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Memoria Colectiva | Revista Informativa",
      timeRange: "7:00 AM - 8:00 AM",
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/memoria-colectiva.webp",
      description: "Historias para el futuro.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "8:00 AM - 9:30 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Kaliman",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "assets/images/kaliman.webp",
      description:
          "Sigue las aventuras del hombre increíble, un justiciero experto en artes marciales, ciencias y disciplinas mentales.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:00 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "11:00 AM - 1:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "assets/images/colibri.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Acciones por la Tierra",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "assets/images/acciones-por-la-tierra.webp",
      description:
          "Programa especializado en alternativas ambientales para la vida cotidiana.",
    ),
    ProgramShow(
      name: "Porfirio Cadena",
      timeRange: "2:00 PM - 2:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 14, minute: 29),
      imageUrl: "assets/images/porfirio-cadena.webp",
      description:
          "Conoce la historia del hombre que perdió su ojo derecho tras un violento enfrentamiento con los asesinos de su padre.",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "2:30 PM - 3:00 PM",
      start: TimeOfDay(hour: 14, minute: 30),
      end: TimeOfDay(hour: 14, minute: 59),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description:
          "Historias de los pueblos indígenas y afrodescendientes, en formato de podcast.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "3:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 15, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "La Tremenda Corte - Tres Patines",
      timeRange: "3:30 PM - 4:00 PM",
      start: TimeOfDay(hour: 15, minute: 30),
      end: TimeOfDay(hour: 15, minute: 59),
      imageUrl: "assets/images/tremanda-corte-tres-patines.webp",
      description:
          "Con enredos verbales y tergiversando el doble sentido de las palabras, Tres Patines busca confundir al Tremendo Juez para librarse de cada condena.",
    ),
    ProgramShow(
      name: "En Común",
      timeRange: "4:00 PM - 4:30 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 16, minute: 29),
      imageUrl: "assets/images/en-comun.webp",
      description:
          "Investigación científica y de las comunidades indígenas, rurales y urbanas de México. Su objetivo principal es promover el diálogo.",
    ),
    ProgramShow(
      name: "Periodismo de lo Posible",
      timeRange: "4:30 PM - 5:00 PM",
      start: TimeOfDay(hour: 16, minute: 30),
      end: TimeOfDay(hour: 16, minute: 59),
      imageUrl: "assets/images/periodismo-de-lo-posible.webp",
      description: "Historias de esperanza desde los territorios.",
    ),
    ProgramShow(
      name: "Tiempo de Lectura",
      timeRange: "5:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 17, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/tiempo-de-lectura.webp",
      description:
          "Conversaciones y reflexiones en torno a obras y autores de la literatura universal, nacional y local, para acercarnos a las historias, ideas y voces que habitan en los libros.",
    ),
    ProgramShow(
      name: "Icemanahuac Tlahtolnahuatl",
      timeRange: "6:00 pm - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "assets/images/icemanahuac-tlahtolnahuatl.webp",
      description:
          "Promovemos el uso de la lengua náhuatl en la región cholulteca, mediante el diálogo y la reflexión crítica fomentamos la revaloración de la cultura originaria de nuestros pueblos.",
    ),
    ProgramShow(
      name: "Mitote Ranchero",
      timeRange: "7:00 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 20, minute: 59),
      imageUrl: "assets/images/mitote-ranchero.webp",
      description:
          "Complacencias musicales dedicado exclusivamente a la música ranchera.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 21, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "El tío Juan",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "assets/images/mi-tio-juan.webp",
      description:
          "Historias para aprender de la sabiduría popular, acompañadas de humor y humanidad.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:00 PM - 12:00 AM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Saturday
  6: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 12:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],

  // Sunday
  7: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 8, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Tierra Mestiza",
      timeRange: "9:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 29),
      imageUrl: "assets/images/tierra-mestiza.webp",
      description:
          "Tierra Mestiza se encarga de difundir la música tradicional mexicana: desde el canto cardenche, el son mariachero y los minuetes, hasta las redovas, polkas y jarabes. Con el canto de nuestros pueblos, sus leyendas y tradición oral, se reaviva nuestra identidad nacional.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 AM - 2:30 PM",
      start: TimeOfDay(hour: 10, minute: 30),
      end: TimeOfDay(hour: 14, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "X - Somos chavos y chavas",
      timeRange: "2:30 PM - 3:00 PM",
      start: TimeOfDay(hour: 14, minute: 30),
      end: TimeOfDay(hour: 14, minute: 59),
      imageUrl: "assets/images/x-somos-chavxs.webp",
      description:
          "Programa dirigido a las juventudes en comunidades indígenas, abordando temas de su interés que, para la sociedad en estos territorios pueden ser tabues.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "3:00 PM - 4:00 PM",
      start: TimeOfDay(hour: 15, minute: 0),
      end: TimeOfDay(hour: 15, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Nemiliztli Tlamaliztli",
      timeRange: "4:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/perifoneo-prieto.webp",
      description:
          "Abordaje de temas científicos y académicos entrelazados con la filosofía, el arte y la biología.",
    ),
    ProgramShow(
      name: "Babel Cholollan",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "assets/images/babel.webp",
      description:
          "Música de otras latitudes acompañada del comentario de Veinte Vientos.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "7:00 PM - 8:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 19, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Raíces Huastecas",
      timeRange: "8:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 20, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/raices-huastecas.webp",
      description:
          "Difusión de sones y hupangos, pensado especialmente para las personas que migraron de la Sierra Norte a la región cholulteca.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
    ProgramShow(
      name: "Hora Nacional",
      timeRange: "10:00 PM - 10:30 AM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "assets/images/la-hora-nacional.webp",
      description:
          "Es una producción de la RTC, adjunto a la Secretaría de Gobernación, y que transmitimos por obligación. Su objetivo es ser una plataforma cultural, educativa e informativa, donde se difunde la música, tradiciones y literatura del país. También realizan entrevistas a creadores.",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 PM - 12:00 PM",
      start: TimeOfDay(hour: 22, minute: 30),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Programación musical automática.",
    ),
  ],
};
// CALENDAR DATA (!!!!!!! SI SE PUEDE MODIFICAR !!!!!!!!)

const String _kProgramacionCsvUrl =
    'https://docs.google.com/spreadsheets/d/1tChTVAQPn7uvf_63nRVn2FNC37QVPW77ckgCl1YG81Y/export?format=csv&gid=1189849038';

String _normalizarUrlImagen(String rawUrl) {
  final valor = rawUrl.trim();
  if (valor.isEmpty) {
    return 'assets/images/barra-musical.webp';
  }

  if (!valor.startsWith('http')) {
    return valor.startsWith('assets/') ? valor : 'assets/images/$valor';
  }

  final uri = Uri.tryParse(valor);
  if (uri == null) return valor;

  final host = uri.host.toLowerCase();
  if (!host.contains('google') && !host.contains('drive')) {
    return valor;
  }

  final queryId = uri.queryParameters['id'];
  if (queryId != null && queryId.isNotEmpty) {
    return 'https://lh3.googleusercontent.com/d/$queryId';
  }

  final pathSegments = uri.pathSegments;
  final indexD = pathSegments.indexOf('d');
  if (indexD >= 0 && indexD + 1 < pathSegments.length) {
    final id = pathSegments[indexD + 1];
    if (id.isNotEmpty) {
      return 'https://lh3.googleusercontent.com/d/$id';
    }
  }

  final idFromFile =
      uri.queryParameters['export'] == 'download'
          ? uri.queryParameters['id']
          : null;
  if (idFromFile != null && idFromFile.isNotEmpty) {
    return 'https://lh3.googleusercontent.com/d/$idFromFile';
  }

  return valor;
}

Future<Map<int, List<ProgramShow>>>? _programacionFutura;

Future<Map<int, List<ProgramShow>>> cargarProgramacionDesdeCsv() async {
  final respuesta = await http
      .get(Uri.parse(_kProgramacionCsvUrl))
      .timeout(const Duration(seconds: 15));
  if (respuesta.statusCode != 200) {
    throw Exception('Google Sheets respondió ${respuesta.statusCode}');
  }

  final contenido = utf8.decode(respuesta.bodyBytes).replaceFirst('\uFEFF', '');
  return programacionDesdeCsv(contenido);
}

Future<Map<int, List<ProgramShow>>> obtenerProgramacion() {
  return _programacionFutura ??= cargarProgramacionDesdeCsv().catchError(
    (_) => weeklySchedule,
  );
}

Map<int, List<ProgramShow>> programacionDesdeCsv(String contenido) {
  final filas =
      CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(contenido)
          .skipWhile(
            (fila) => fila.every((valor) => valor.toString().trim().isEmpty),
          )
          .toList();
  if (filas.isEmpty) throw const FormatException('El CSV está vacío.');

  final encabezados =
      filas.first
          .map((valor) => valor.toString().trim().toLowerCase())
          .toList();
  const requeridos = [
    'dia',
    'inicio',
    'fin',
    'nombre',
    'descripcion',
    'imagen',
  ];
  final indices = <String, int>{};
  for (final encabezado in requeridos) {
    final indice = encabezados.indexOf(encabezado);
    if (indice < 0) {
      throw FormatException('Falta la columna "$encabezado" en el CSV.');
    }
    indices[encabezado] = indice;
  }

  final programacion = <int, List<ProgramShow>>{};
  for (final fila in filas.skip(1)) {
    if (fila.every((valor) => valor.toString().trim().isEmpty)) continue;
    if (fila.length < encabezados.length) {
      throw const FormatException('Hay una fila incompleta en el CSV.');
    }

    String campo(String nombre) => fila[indices[nombre]!].toString().trim();

    final dia = _numeroDia(campo('dia'));
    final inicioTexto = campo('inicio');
    final finTexto = campo('fin');
    final inicioMinutos = _minutosDesdeCsv(inicioTexto);
    final finExclusivo = _minutosDesdeCsv(finTexto, permitir24: true);
    if (finExclusivo <= inicioMinutos) {
      throw FormatException('Horario inválido: $inicioTexto - $finTexto.');
    }

    final nombre = campo('nombre');
    if (nombre.isEmpty) {
      throw const FormatException('Falta un nombre de programa.');
    }

    final imagenCsv = campo('imagen');
    final imagen = _normalizarUrlImagen(imagenCsv);

    final finIncluido = finExclusivo - 1;
    (programacion[dia] ??= <ProgramShow>[]).add(
      ProgramShow(
        name: nombre,
        timeRange:
            '${_horaParaMostrar(inicioMinutos)} - ${_horaParaMostrar(finExclusivo)}',
        start: TimeOfDay(hour: inicioMinutos ~/ 60, minute: inicioMinutos % 60),
        end: TimeOfDay(hour: finIncluido ~/ 60, minute: finIncluido % 60),
        imageUrl: imagen,
        description: campo('descripcion'),
      ),
    );
  }

  for (final programas in programacion.values) {
    programas.sort((a, b) {
      final inicioA = a.start.hour * 60 + a.start.minute;
      final inicioB = b.start.hour * 60 + b.start.minute;
      return inicioA.compareTo(inicioB);
    });
  }
  return programacion;
}

int _numeroDia(String dia) {
  switch (dia.trim().toLowerCase()) {
    case 'lunes':
      return DateTime.monday;
    case 'martes':
      return DateTime.tuesday;
    case 'miércoles':
    case 'miercoles':
      return DateTime.wednesday;
    case 'jueves':
      return DateTime.thursday;
    case 'viernes':
      return DateTime.friday;
    case 'sábado':
    case 'sabado':
      return DateTime.saturday;
    case 'domingo':
      return DateTime.sunday;
    default:
      throw FormatException('Día no reconocido: $dia.');
  }
}

int _minutosDesdeCsv(String valor, {bool permitir24 = false}) {
  final coincidencia = RegExp(r'^(\d{1,2}):(\d{2})(?::00)?$').firstMatch(valor);
  if (coincidencia == null) {
    throw FormatException('Hora no reconocida: $valor.');
  }
  final hora = int.parse(coincidencia.group(1)!);
  final minuto = int.parse(coincidencia.group(2)!);
  if (permitir24 && hora == 24 && minuto == 0) return 24 * 60;
  if (hora > 23 || minuto > 59) throw FormatException('Hora inválida: $valor.');
  return hora * 60 + minuto;
}

String _horaParaMostrar(int minutos) {
  if (minutos == 24 * 60) return '24:00';
  return '${(minutos ~/ 60).toString().padLeft(2, '0')}:${(minutos % 60).toString().padLeft(2, '0')}';
}

//****NO MODIFICAR***
ProgramShow? getCurrentShow({Map<int, List<ProgramShow>>? programacion}) {
  final dayOfWeek = DateTime.now().weekday;
  final showsToday = (programacion ?? weeklySchedule)[dayOfWeek];
  if (showsToday == null || showsToday.isEmpty) return null;
  final now = TimeOfDay.now();
  for (final show in showsToday) {
    if (isTimeOfDayInRange(now, show.start, show.end)) {
      return show;
    }
  }
  return null;
}

bool isLiveShowOnDay({
  required int displayedDay,
  required int currentDay,
  required ProgramShow? currentShow,
  required ProgramShow displayedShow,
}) {
  return displayedDay == currentDay && identical(currentShow, displayedShow);
}

//****NO MODIFICAR***
List<ProgramShow> getTodayShows() {
  final dayOfWeek = DateTime.now().weekday;
  return weeklySchedule[dayOfWeek] ?? [];
}

// ----------------------------------------------------------
// MAIN APP //****NO MODIFICAR***
// ----------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cholollan 107.1 FM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: HomeScreen(),
    );
  }
}

//****NO MODIFICAR***
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

//****NO MODIFICAR***
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = _indiceInicialDesdeUrl();

  @override
  void initState() {
    super.initState();
    _seccionActual = _currentIndex;
  }

  final List<Widget> _screens = [
    RadioScreen(),
    ProgramasScreen(),
    NosotrosScreen(),
    AudienciasScreen(),
    MasScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _seccionActual = index;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  // Logo Radio Cholollan with click to fmcholollan.org.mx
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF1E6),
        elevation: 0,
        toolbarHeight: 92,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: const SizedBox(width: 48),
        actions: [
          (_currentIndex == 1 || _currentIndex == 3 || _currentIndex == 4)
              ? IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Color.fromRGBO(62, 35, 20, 0.888),
                ),
                tooltip: 'Compartir',
                onPressed: compartirSeccion,
              )
              : const SizedBox(width: 48),
        ],
        title: SizedBox(
          width: 333,
          child: InkWell(
            onTap: () => _launchURL("https://fmcholollan.org.mx"),
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Image.network(
                "https://fmcholollan.org.mx/wp-content/uploads/2024/04/Cholollan_Logo-Web-2024-1536x287.png",
                webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                width: 333,
                height: 62,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      // Global APP Nav Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(62, 35, 20, 1),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'Radio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Programas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nosotros'),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            label: 'Audiencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Noticias y +',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// RADIO SCREEN //****NO MODIFICAR***
// ----------------------------------------------------------
class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  Map<int, List<ProgramShow>> _programacion = weeklySchedule;
  ProgramShow? _currentShow;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isLoading = false;

  // ── Respaldo automático de audio (Play 1 | Play 2) ──
  static const List<Map<String, String>> _fuentes = [
    {'nombre': 'Play 1', 'url': 'https://radios.liberaturadio.org/fmcholollan'},
    {'nombre': 'Play 2', 'url': 'https://radios.yanapak.org/Cholollan107.1FM'},
  ];
  static const Duration _kEsperaConexion = Duration(seconds: 12);
  static const Duration _kSinAudioMaximo = Duration(seconds: 12);
  int _fuente = 0; // la que está sonando
  int _preferida = 0; // con la que se empieza al dar play
  bool _quiereAudio = false; // el usuario pidió escuchar
  bool _cambiando = false; // se está conectando o cambiando de fuente
  bool _reconectando = false;
  Timer? _vigilante;
  Duration _ultimaPos = Duration.zero;
  DateTime _ultimoAvance = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateCurrentShow();
    obtenerProgramacion().then((programacion) {
      if (!mounted) return;
      setState(() {
        _programacion = programacion;
        _currentShow = getCurrentShow(programacion: _programacion);
      });
    });
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateCurrentShow();
    });
    // Listen for processing state changes to update UI.
    _player.processingStateStream.listen((state) {
      if (!mounted) return;
      if (state == ProcessingState.ready) {
        setState(() {
          _isLoading = false;
          _isPlaying = true;
          _reconectando = false;
        });
      } else if (state == ProcessingState.idle && !_quiereAudio) {
        // Solo se apaga el botón si el usuario detuvo el audio.
        // Si fue una caída del servidor, el vigilante cambia de fuente.
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _updateCurrentShow() {
    setState(() {
      _currentShow = getCurrentShow(programacion: _programacion);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vigilante?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _recargarPagina() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await launchUrl(Uri.base.removeFragment(), webOnlyWindowName: '_self');
    } catch (e) {
      print("Error al recargar: $e");
    }
  }

  // Intenta conectar empezando por la fuente `inicio`; si falla, prueba la otra.
  Future<bool> _conectar(int inicio) async {
    for (int k = 0; k < _fuentes.length; k++) {
      final i = (inicio + k) % _fuentes.length;
      try {
        await _player
            .setUrl(_fuentes[i]['url']!)
            .timeout(_kEsperaConexion);
        if (!_quiereAudio) return false; // el usuario detuvo mientras conectaba
        _player.play().catchError((_) {}); // no se espera: en vivo nunca termina
        _ultimaPos = Duration.zero;
        _ultimoAvance = DateTime.now();
        if (mounted) {
          setState(() {
            _fuente = i;
            _isPlaying = true;
            _isLoading = false;
          });
        }
        return true;
      } catch (e) {
        print("Error con ${_fuentes[i]['nombre']}: $e");
        if (!_quiereAudio) return false;
      }
    }
    return false;
  }

  void _iniciarVigilante() {
    _vigilante?.cancel();
    _vigilante = Timer.periodic(const Duration(seconds: 3), (_) => _vigilar());
  }

  // Revisa cada 3 s que el audio siga avanzando; si no, cambia de fuente.
  Future<void> _vigilar() async {
    if (!_quiereAudio || _cambiando) return;
    final estado = _player.processingState;
    final pos = _player.position;
    if (pos != _ultimaPos) {
      _ultimaPos = pos;
      _ultimoAvance = DateTime.now();
    }
    final detenido =
        estado == ProcessingState.idle || estado == ProcessingState.completed;
    final atascado = _player.playing &&
        DateTime.now().difference(_ultimoAvance) > _kSinAudioMaximo;
    if (detenido || atascado) {
      await _cambiarDeFuente();
    }
  }

  Future<void> _cambiarDeFuente({int? destino}) async {
    if (_cambiando) return;
    _cambiando = true;
    if (mounted) setState(() => _reconectando = true);
    final siguiente = destino ?? ((_fuente + 1) % _fuentes.length);
    final ok = await _conectar(siguiente);
    if (!ok && _quiereAudio) {
      // Ninguna respondió: se vuelve a intentar en el siguiente ciclo del vigilante.
      print("Ninguna fuente respondió; se reintentará.");
    }
    _cambiando = false;
  }

  void _elegirFuente(int i) {
    setState(() => _preferida = i);
    if (_quiereAudio && i != _fuente) {
      _cambiarDeFuente(destino: i);
    }
  }

  Future<void> _togglePlay() async {
    if (!_isPlaying) {
      // User pressed play: show loading while stream loads.
      _quiereAudio = true;
      _cambiando = true;
      setState(() {
        _isLoading = true;
      });
      final ok = await _conectar(_preferida);
      _cambiando = false;
      if (ok) {
        _iniciarVigilante();
      } else if (_quiereAudio && mounted) {
        _quiereAudio = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar el audio. Intenta de nuevo en unos segundos.'),
          ),
        );
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // User pressed pause: stop the stream so that next play always starts live.
      _quiereAudio = false;
      _vigilante?.cancel();
      try {
        await _player.stop();
      } catch (e) {
        print("Error stopping stream: $e");
      }
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _reconectando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // 22% of screen height, clamped between 150 and 333.
    final double imageSize = (screenHeight * 0.33).clamp(150.0, 333.0);

    // If the phone is really short, shrink the play icon to 48; otherwise 64.
    final double playIconSize = screenHeight < 650 ? 48.0 : 64.0;

    final showName = _currentShow?.name ?? "Programación Normal";
    final showImage =
        _currentShow?.imageUrl ??
        "assets/images/barra-musical.webp";
    final showTime = _currentShow?.timeRange ?? "";
    final showDescription = _currentShow?.description ?? "";

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _recargarPagina,
          child: LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // responsive square
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: imageSize,
                              maxHeight: imageSize,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Builder(
                                  builder: (_) {
                                    if (showImage.startsWith('http')) {
                                      return Image.network(
                                        showImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => Image.asset(
                                              'assets/images/barra-musical.webp',
                                              fit: BoxFit.cover,
                                            ),
                                        webHtmlElementStrategy:
                                            WebHtmlElementStrategy.fallback,
                                      );
                                    } else {
                                      return Image.asset(
                                        showImage,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // title + time
                          Text(
                            showName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (showTime.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              showTime,
                              style: const TextStyle(color: Colors.brown),
                            ),
                          ],

                          if (showDescription.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: imageSize + 24,
                                ),
                                child: Text(
                                  showDescription,
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ] else
                            const SizedBox(height: 24),

                          // responsive play/pause
                          (_isLoading && !_isPlaying)
                              ? const CircularProgressIndicator()
                              : IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                ),
                                iconSize: playIconSize,
                                color: Colors.brown[700],
                                onPressed: _togglePlay,
                              ),

                          // Play 1 | Play 2
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < _fuentes.length; i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                ChoiceChip(
                                  label: Text(_fuentes[i]['nombre']!),
                                  selected: (_quiereAudio ? _fuente : _preferida) == i,
                                  onSelected: (_) => _elegirFuente(i),
                                  selectedColor: const Color(0xFF3E2314),
                                  backgroundColor: const Color(0xFFFFD5BE),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    color: (_quiereAudio ? _fuente : _preferida) == i
                                        ? const Color(0xFFFFB27A)
                                        : const Color(0xFF3E2314),
                                  ),
                                  showCheckmark: false,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ],
                          ),
                          if (_reconectando && _quiereAudio)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Reconectando…',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // socials
                          socialRow(),

                          // patrocinadores
                          const CarruselAnuncios(),
                          const SizedBox(height: 16),
                        ],
                      ), // 1 Column
                    ), // 2 Center
                  ), // 3 ConstrainedBox
                ), // 4 SingleChildScrollView
          ), // 5 LayoutBuilder
        ), // 6 RefreshIndicator
      ), // 7 SafeArea
    ); // 8 Container
  }
}

// ---------------- PROGRAMAS SCREEN  ----------------//****NO MODIFICAR***
class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({super.key});

  @override
  _ProgramasScreenState createState() => _ProgramasScreenState();
}

//****NO MODIFICAR***
class _ProgramasScreenState extends State<ProgramasScreen> {
  final List<String> days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  Map<int, List<ProgramShow>> _programacion = weeklySchedule;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    obtenerProgramacion().then((programacion) {
      if (!mounted) return;
      setState(() {
        _programacion = programacion;
      });
    });
    // every minute, rebuild so that isLive can switch over
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<ProgramShow> _getShowsForDay(int day) => _programacion[day] ?? [];

  int get initialTabIndex => DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: DefaultTabController(
        initialIndex: initialTabIndex,
        length: days.length,
        child: Column(
          children: [
            // ── weekday tabs ──
            Container(
              color: const Color(0xFFFFF1E6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isWide ? 980 : double.infinity,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF3EA),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.18),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.center,
                          indicatorColor: const Color(
                            0xFFF57C00,
                          ).withValues(alpha: 0.8),
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF4D2B1B),
                          unselectedLabelColor: Colors.brown.shade400,
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: isWide ? 26 : 16,
                          ),
                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color(
                                  0xFF1A73D8,
                                ).withValues(alpha: 0.20);
                              }
                              return null;
                            },
                          ),
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          physics: const BouncingScrollPhysics(),
                          tabs:
                              days
                                  .map(
                                    (d) => Container(
                                      height: isWide ? 52 : 46,
                                      alignment: Alignment.center,
                                      child: Tab(text: d),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── content for each day ──
            Expanded(
              child: TabBarView(
                children:
                    days.asMap().entries.map((entry) {
                      final weekday = entry.key + 1;
                      final shows = _getShowsForDay(weekday);

                      if (shows.isEmpty) {
                        return const Center(
                          child: Text(
                            "No hay programas para este día.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: shows.length,
                        itemBuilder: (context, idx) {
                          final show = shows[idx];
                          final current = getCurrentShow(
                            programacion: _programacion,
                          );
                          final isLive = isLiveShowOnDay(
                            displayedDay: weekday,
                            currentDay: DateTime.now().weekday,
                            currentShow: current,
                            displayedShow: show,
                          );

                          return Center(
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder:
                                      (_) => Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              show.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              show.description.isNotEmpty
                                                  ? show.description
                                                  : "Sin descripción disponible.",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                              child: SizedBox(
                                width: _cardImageWidth,
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  elevation: isLive ? 8 : 2,
                                  color:
                                      isLive
                                          ? Colors.orange.withValues(alpha: 0.2)
                                          : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: Builder(
                                          builder: (_) {
                                            final url = show.imageUrl;
                                            return url.startsWith('http')
                                                ? Image.network(
                                                  url,
                                                  width: _cardImageWidth,
                                                  height: _cardImageHeight,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        _,
                                                        __,
                                                        ___,
                                                      ) => Image.asset(
                                                        'assets/images/barra-musical.webp',
                                                        width: _cardImageWidth,
                                                        height:
                                                            _cardImageHeight,
                                                        fit: BoxFit.cover,
                                                      ),
                                                  webHtmlElementStrategy:
                                                      WebHtmlElementStrategy
                                                          .fallback,
                                                )
                                                : Image.asset(
                                                  url,
                                                  width: _cardImageWidth,
                                                  height: _cardImageHeight,
                                                  fit: BoxFit.cover,
                                                );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              show.name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              softWrap: true,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              show.timeRange,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- NOSOTROS SCREEN ----------------****NO MODIFICAR***
class NosotrosScreen extends StatelessWidget {
  const NosotrosScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust this to match your actual banner image’s aspect ratio (width/height).
    const double bannerAspectRatio = 3.5;

    return Container(
      // This gradient fills the *entire* screen behind everything.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Use ClampingScrollPhysics so the user cannot “bounce” into white space.
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                // Force the Column to be at least as tall as the viewport:
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── Banner (fixed aspect ratio) ───
                    AspectRatio(
                      aspectRatio: bannerAspectRatio,
                      child: Image.asset(
                        'assets/images/portada-nosotros.webp',
                        fit: BoxFit.cover,
                        // error handling
                        errorBuilder: (ctx, error, stack) {
                          return Container(
                            color: Colors.grey[200],
                            alignment: Alignment.center,
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── Heading ───
                    const Text(
                      'Acerca de Nosotros',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── Paragraph ───
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Somos habitantes del Valle de Cholula, y desde el año 2009 en Tlaxcalancingo, comenzamos a construir una Radio de Uso Social Indígena y Comunitaria, que escucha y camina con los pueblos de la región para amplificar sus voces, sus sueños, y sus manifestaciones. Todas y todos buscamos construir otro mundo posible.\n\n'
                        'Nacimos como una radio bocina, en 2011 comenzamos nuestro andar por el FM. En 2014 el Estado nos arrebató nuestro derecho a comunicar.\n\n'
                        'En una batalla legal contra el extinto IFT, en el año 2015 ganamos una frecuencia. Finalmente, a partir de marzo de 2021, transmitimos en el 107.1 FM con 750 watts de potencia comunal.\n\n'
                        '¡Ayúdanos a fortalecer el proyecto para que la voz de los pueblos se escuche más fuerte!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── “DONA AHORA” Button ───
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            () => _launchURL(
                              'https://donate.stripe.com/fZeeYbfAn6RKacg4gh',
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('DONA AHORA'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ─── Social Buttons Row ───
                    socialRow(),

                    // patrocinadores
                    const CarruselAnuncios(),

                    const SizedBox(height: 16),
                    // (No extra Spacer—because ConstrainedBox already makes the Column fill the screen.)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AudienciasScreen extends StatelessWidget {
  const AudienciasScreen({super.key});

  Future<void> _abrir(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  Widget _tarjeta({
    required String titulo,
    required String imagen,
    required String enlace,
    required Color color,
    double fontSize = 16,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _abrir(enlace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child:
                  imagen.startsWith('http')
                      ? Image.network(
                        imagen,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Container(color: color),
                      )
                      : Image.asset(imagen, fit: BoxFit.cover),
            ),
            Container(
              color: color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      titulo,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: fontSize + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('audiencias-background'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.clamp(0.0, 980.0);
            final horizontalPadding = constraints.maxWidth < 600 ? 16.0 : 24.0;
            final contentWidth = maxWidth - horizontalPadding * 2;
            final isWide = contentWidth >= 640;
            final anchoPorPantalla =
                isWide ? (contentWidth - 16) / 2 : contentWidth;

            // Igual que la imagen de la Radio: el tamaño también depende de la
            // altura de la pantalla. La imagen es 4:3, así que si la pantalla es
            // baja, la tarjeta se hace más angosta y se ve completa.
            final alturaPantalla = MediaQuery.of(context).size.height;
            final alturaImagen = (alturaPantalla * 0.40).clamp(110.0, 337.0);
            final cardWidth = anchoPorPantalla < alturaImagen * 4 / 3
                ? anchoPorPantalla
                : alturaImagen * 4 / 3;
            final tamanoTitulo = cardWidth < 260 ? 13.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      (constraints.maxHeight - 56)
                          .clamp(0.0, double.infinity)
                          .toDouble(),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Información para audiencias',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromRGBO(62, 35, 20, 1),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _tarjeta(
                                titulo: 'Defensoría de Audiencias',
                                imagen:
                                    'https://fmcholollan.org.mx/wp-content/uploads/2026/11/defensoria-audiencias.webp',
                                enlace:
                                    'https://fmcholollan.org.mx/defensor-de-audiencias/',
                                color: const Color(0xFF236B64),
                                fontSize: tamanoTitulo,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _tarjeta(
                                titulo: 'Código de Ética',
                                imagen:
                                    'https://fmcholollan.org.mx/wp-content/uploads/2026/11/codigo-etica.webp',
                                enlace:
                                    'https://fmcholollan.org.mx/codigo-de-etica/',
                                color: const Color(0xFFA84F2C),
                                fontSize: tamanoTitulo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // patrocinadores
                        const CarruselAnuncios(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- MAS SCREEN  ----------------//****NO MODIFICAR***
// ──────────── NUEVO: noticias desde tu WordPress ────────────
const String _kWpApi = "https://fmcholollan.org.mx/wp-json/wp/v2";
const String _kNoticiasWeb = "https://fmcholollan.org.mx/seccion/noticias/";
const String _kEventosWeb = "https://fmcholollan.org.mx/eventos/";

class Noticia {
  final String titulo;
  final String resumen;
  final String enlace;
  final String imagen;
  final String fecha;
  const Noticia({
    required this.titulo,
    required this.resumen,
    required this.enlace,
    required this.imagen,
    required this.fecha,
  });
}

class Evento {
  final String titulo;
  final String resumen;
  final String enlace;
  final String imagen;
  final String fecha;
  const Evento({
    required this.titulo,
    required this.resumen,
    required this.enlace,
    required this.imagen,
    required this.fecha,
  });
}

Future<List<Evento>> cargarEventos({int cantidad = 10}) async {
  final url = Uri.parse(
    'https://fmcholollan.org.mx/wp-json/tribe/events/v1/events?per_page=$cantidad',
  );

  final respuesta = await http.get(url).timeout(const Duration(seconds: 10));
  if (respuesta.statusCode != 200) {
    throw Exception('WordPress respondió ${respuesta.statusCode}');
  }

  return eventosDesdeJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
}

List<Evento> eventosDesdeJson(dynamic datos) {
  final resultado = <Evento>[];
  if (datos is! Map) return resultado;

  final eventos = datos['events'];
  if (eventos is! List) return resultado;

  for (final p in eventos) {
    if (p is! Map) continue;

    final titulo = _limpiarHtml(_textoRenderizado(p['title']));
    final enlace = p['url'];
    if (titulo.isEmpty || enlace is! String) continue;

    final descripcion = _limpiarHtml(_textoRenderizado(p['description']));
    final fecha = _fechaBonita(p['start_date']);

    resultado.add(
      Evento(
        titulo: titulo,
        resumen: descripcion,
        enlace: enlace,
        imagen: (p['image_url'] is String) ? p['image_url'] as String : '',
        fecha: fecha,
      ),
    );
  }

  return resultado;
}

// Pide a WordPress las últimas notas. Si algo falla, lanza un error que la pantalla muestra.
Future<List<Noticia>> cargarNoticias({int cantidad = 10}) async {
  final url = Uri.parse(
    "$_kWpApi/posts?per_page=$cantidad&_embed=wp:featuredmedia&_fields=id,date,link,title,excerpt,_links,_embedded",
  );
  final respuesta = await http.get(url).timeout(const Duration(seconds: 10));
  if (respuesta.statusCode != 200) {
    throw Exception("WordPress respondió ${respuesta.statusCode}");
  }
  return noticiasDesdeJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
}

Future<List<Noticia>> cargarNoticiasPorCategoria({
  required String slug,
  int cantidad = 10,
}) async {
  final categoriasUrl = Uri.parse('$_kWpApi/categories?slug=$slug');
  final categoriasResp = await http
      .get(categoriasUrl)
      .timeout(const Duration(seconds: 10));

  if (categoriasResp.statusCode != 200) {
    throw Exception("WordPress respondió ${categoriasResp.statusCode}");
  }

  final categorias = jsonDecode(utf8.decode(categoriasResp.bodyBytes));
  if (categorias is! List || categorias.isEmpty) {
    return const <Noticia>[];
  }

  final categoria = categorias.first;
  if (categoria is! Map || categoria['id'] == null) {
    return const <Noticia>[];
  }

  final idCategoria = categoria['id'];
  final url = Uri.parse(
    "$_kWpApi/posts?per_page=$cantidad&categories=$idCategoria&_embed=wp:featuredmedia&_fields=id,date,link,title,excerpt,_links,_embedded",
  );
  final respuesta = await http.get(url).timeout(const Duration(seconds: 10));
  if (respuesta.statusCode != 200) {
    throw Exception("WordPress respondió ${respuesta.statusCode}");
  }
  return noticiasDesdeJson(jsonDecode(utf8.decode(respuesta.bodyBytes)));
}

List<Noticia> noticiasDesdeJson(dynamic datos) {
  final resultado = <Noticia>[];
  if (datos is! List) return resultado;
  for (final p in datos) {
    if (p is! Map) continue;
    final enlace = p["link"];
    final titulo = _limpiarHtml(_textoRenderizado(p["title"]));
    if (enlace is! String || titulo.isEmpty) continue;
    resultado.add(
      Noticia(
        titulo: titulo,
        resumen: _limpiarHtml(_textoRenderizado(p["excerpt"])),
        enlace: enlace,
        imagen: _imagenDestacada(p),
        fecha: _fechaBonita(p["date"]),
      ),
    );
  }
  return resultado;
}

String _textoRenderizado(dynamic campo) {
  if (campo is Map) {
    final texto = campo["rendered"];
    if (texto is String) return texto;
  }
  return "";
}

String _imagenDestacada(Map p) {
  try {
    final incrustado = p["_embedded"];
    if (incrustado is! Map) return "";
    final lista = incrustado["wp:featuredmedia"];
    if (lista is! List || lista.isEmpty || lista.first is! Map) return "";
    final medio = lista.first as Map;
    final detalles = medio["media_details"];
    if (detalles is Map) {
      final tamanos = detalles["sizes"];
      if (tamanos is Map) {
        final mediano = tamanos["medium_large"];
        if (mediano is Map && mediano["source_url"] is String) {
          return mediano["source_url"] as String;
        }
      }
    }
    final original = medio["source_url"];
    return original is String ? original : "";
  } catch (_) {
    return "";
  }
}

String _fechaBonita(dynamic iso) {
  if (iso is! String) return "";
  final d = DateTime.tryParse(iso);
  if (d == null) return "";
  const meses = [
    "enero",
    "febrero",
    "marzo",
    "abril",
    "mayo",
    "junio",
    "julio",
    "agosto",
    "septiembre",
    "octubre",
    "noviembre",
    "diciembre",
  ];
  return "${d.day} de ${meses[d.month - 1]} de ${d.year}";
}

// Quita las etiquetas HTML y convierte los símbolos como &#8211; o &amp; en texto normal
String _limpiarHtml(String html) {
  var t = html.replaceAll(RegExp(r"<[^>]*>"), " ");
  t = t.replaceAllMapped(
    RegExp(r"&#(\d+);"),
    (m) => String.fromCharCode(int.parse(m.group(1)!)),
  );
  t = t.replaceAllMapped(
    RegExp(r"&#[xX]([0-9a-fA-F]+);"),
    (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
  );
  const nombres = {
    "&nbsp;": " ",
    "&hellip;": "…",
    "&ndash;": "–",
    "&mdash;": "—",
    "&lsquo;": "‘",
    "&rsquo;": "’",
    "&ldquo;": "“",
    "&rdquo;": "”",
    "&laquo;": "«",
    "&raquo;": "»",
    "&quot;": "\"",
    "&apos;": "'",
    "&aacute;": "á",
    "&eacute;": "é",
    "&iacute;": "í",
    "&oacute;": "ó",
    "&uacute;": "ú",
    "&Aacute;": "Á",
    "&Eacute;": "É",
    "&Iacute;": "Í",
    "&Oacute;": "Ó",
    "&Uacute;": "Ú",
    "&ntilde;": "ñ",
    "&Ntilde;": "Ñ",
    "&uuml;": "ü",
    "&Uuml;": "Ü",
    "&iexcl;": "¡",
    "&iquest;": "¿",
    "&copy;": "©",
    "&lt;": "<",
    "&gt;": ">",
    "&amp;": "&",
  };
  nombres.forEach((k, v) => t = t.replaceAll(k, v));
  return t.replaceAll(RegExp(r"\s+"), " ").trim();
}

// Pantalla "Noticias" dentro de la app
class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  late Future<List<Noticia>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = cargarNoticias();
  }

  Future<void> _recargar() async {
    final nuevo = cargarNoticias();
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {}
  }

  Future<void> _abrir(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }

  Widget _mensajeError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "No se pudieron cargar las noticias en este momento.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _abrir(_kNoticiasWeb),
              child: const Text("Abrir las noticias en el sitio"),
            ),
            TextButton(onPressed: _recargar, child: const Text("Reintentar")),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(Noticia n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _abrir(n.enlace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (n.imagen.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  n.imagen,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder:
                      (context, error, stack) =>
                          Container(color: const Color(0xFFEFD9C8)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (n.fecha.isNotEmpty)
                    Text(
                      n.fecha,
                      style: const TextStyle(fontSize: 12, color: Colors.brown),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    n.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (n.resumen.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      n.resumen,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noticias"),
        backgroundColor: const Color(0xFFFFF1E6),
        foregroundColor: const Color.fromRGBO(62, 35, 20, 1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: FutureBuilder<List<Noticia>>(
              future: _futuro,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = snap.data ?? <Noticia>[];
                if (snap.hasError || lista.isEmpty) return _mensajeError();
                return RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length + 1,
                    itemBuilder: (context, i) {
                      if (i == lista.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: OutlinedButton(
                            onPressed: () => _abrir(_kNoticiasWeb),
                            child: const Text("Ver todas las noticias"),
                          ),
                        );
                      }
                      return _tarjeta(lista[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CategoriaNoticiasScreen extends StatefulWidget {
  const CategoriaNoticiasScreen({
    super.key,
    required this.titulo,
    required this.slug,
  });

  final String titulo;
  final String slug;

  @override
  State<CategoriaNoticiasScreen> createState() =>
      _CategoriaNoticiasScreenState();
}

class _CategoriaNoticiasScreenState extends State<CategoriaNoticiasScreen> {
  late Future<List<Noticia>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = cargarNoticiasPorCategoria(slug: widget.slug);
  }

  Future<void> _recargar() async {
    final nuevo = cargarNoticiasPorCategoria(slug: widget.slug);
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {}
  }

  Future<void> _abrir(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }

  Widget _mensajeError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "No se pudieron cargar las publicaciones de ${widget.titulo.toLowerCase()} en este momento.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _recargar, child: const Text("Reintentar")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFFFFF1E6),
        foregroundColor: const Color.fromRGBO(62, 35, 20, 1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: FutureBuilder<List<Noticia>>(
              future: _futuro,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = snap.data ?? <Noticia>[];
                if (snap.hasError || lista.isEmpty) return _mensajeError();
                return RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final n = lista[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _abrir(n.enlace),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (n.imagen.isNotEmpty)
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    n.imagen,
                                    fit: BoxFit.cover,
                                    webHtmlElementStrategy:
                                        WebHtmlElementStrategy.fallback,
                                    errorBuilder:
                                        (context, error, stack) => Container(
                                          color: const Color(0xFFEFD9C8),
                                        ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (n.fecha.isNotEmpty)
                                      Text(
                                        n.fecha,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n.titulo,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (n.resumen.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        n.resumen,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = cargarEventos();
  }

  Future<void> _recargar() async {
    final nuevo = cargarEventos();
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {}
  }

  Future<void> _abrir(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }

  Widget _mensajeError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No hay eventos disponibles por el momento.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _abrir(_kEventosWeb),
              child: const Text('Abrir eventos en el sitio'),
            ),
            TextButton(onPressed: _recargar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(Evento e) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _abrir(e.enlace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (e.imagen.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  e.imagen,
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                  errorBuilder:
                      (context, error, stack) =>
                          Container(color: const Color(0xFFEFD9C8)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.fecha.isNotEmpty)
                    Text(
                      e.fecha,
                      style: const TextStyle(fontSize: 12, color: Colors.brown),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    e.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (e.resumen.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      e.resumen,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
        backgroundColor: const Color(0xFFFFF1E6),
        foregroundColor: const Color.fromRGBO(62, 35, 20, 1),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: FutureBuilder<List<Evento>>(
              future: _futuro,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lista = snap.data ?? <Evento>[];
                if (snap.hasError || lista.isEmpty) return _mensajeError();

                return RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: lista.length + 1,
                    itemBuilder: (context, i) {
                      if (i == lista.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: OutlinedButton(
                            onPressed: () => _abrir(_kEventosWeb),
                            child: const Text('Ver todos los eventos'),
                          ),
                        );
                      }
                      return _tarjeta(lista[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
        Wrap(
          spacing: 32,
          runSpacing: 32,
          alignment: WrapAlignment.center,
          children: [
            // NOTICIAS
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.asset(
                    'assets/icons/noticias.webp',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NoticiasScreen(),
                        ),
                      ),
                ),
                const Text('Noticias'),
              ],
            ),

            // PODCAST
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.asset(
                    'assets/icons/podcast.webp',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => const CategoriaNoticiasScreen(
                                titulo: 'Podcast',
                                slug: 'podcast',
                              ),
                        ),
                      ),
                ),
                const Text('Podcast'),
              ],
            ),

            // EVENTOS
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.asset(
                    'assets/icons/eventos.webp',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed: () => _launchURL(_kEventosWeb),
                ),
                const Text('Eventos'),
              ],
            ),

            // DONACIONES
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.asset(
                    'assets/icons/donaciones.webp',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed:
                      () => _launchURL(
                        'https://fmcholollan.org.mx/servicios-donacion/',
                      ),
                ),
                const Text('Donaciones'),
              ],
            ),

            // WHATSAPP
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.asset(
                    'assets/icons/whatsapp.webp',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed:
                      () => _launchURL(
                        'https://api.whatsapp.com/send/?phone=5212228432727&text=Cholollan+Radio+%F0%9F%93%BB%3A&type=phone_number&app_absent=0',
                      ),
                ),
                const Text('WhatsApp'),
              ],
            ),
          ],
        ),
              const SizedBox(height: 24),
              // patrocinadores
              const CarruselAnuncios(),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// CARRUSEL DE ANUNCIOS (se alimenta de Google Sheets)
// ----------------------------------------------------------
const String _kCarruselCsvUrl =
    'https://docs.google.com/spreadsheets/d/e/2PACX-1vR4jXuYpqyBLEo4Bjgyq2aPK7Q--rDQ3q1_-KBt8ZQoqpi5spOU1Qnn_EoXtbaySJ0NfPxGiHrhV6v7/pub?output=csv';
const Duration _kCarruselIntervalo = Duration(seconds: 4);

class AnuncioCarrusel {
  final String empresa;
  final String imagen;
  final String enlace;
  const AnuncioCarrusel({
    required this.empresa,
    required this.imagen,
    required this.enlace,
  });
}

Future<List<AnuncioCarrusel>>? _carruselFuturo;

Future<List<AnuncioCarrusel>> obtenerAnuncios() {
  return _carruselFuturo ??= _cargarAnuncios().catchError((_) {
    _carruselFuturo = null; // si falla, se reintenta la próxima vez
    return <AnuncioCarrusel>[];
  });
}

Future<List<AnuncioCarrusel>> _cargarAnuncios() async {
  final respuesta = await http
      .get(Uri.parse(_kCarruselCsvUrl))
      .timeout(const Duration(seconds: 15));
  if (respuesta.statusCode != 200) {
    throw Exception('Google Sheets respondió ${respuesta.statusCode}');
  }

  final contenido = utf8
      .decode(respuesta.bodyBytes)
      .replaceFirst('\uFEFF', '')
      .replaceAll('\r\n', '\n');

  final filas = CsvToListConverter(
    eol: '\n',
    shouldParseNumbers: false,
  ).convert(contenido);
  if (filas.length < 2) return <AnuncioCarrusel>[];

  final encabezados =
      filas.first.map((v) => v.toString().trim().toLowerCase()).toList();
  final iEmpresa = encabezados.indexOf('empresa');
  final iImagen = encabezados.indexOf('url imagen');
  final iEnlace = encabezados.indexOf('url empresa');
  if (iImagen < 0) {
    throw const FormatException('Falta la columna "url imagen".');
  }

  String celda(List<dynamic> fila, int i) =>
      (i >= 0 && i < fila.length) ? fila[i].toString().trim() : '';

  final anuncios = <AnuncioCarrusel>[];
  for (final fila in filas.skip(1)) {
    final imagen = celda(fila, iImagen);
    if (imagen.isEmpty) continue; // filas sin imagen se ignoran

    var enlace = celda(fila, iEnlace);
    if (enlace.isNotEmpty && !enlace.startsWith('http')) {
      enlace = 'https://$enlace';
    }

    anuncios.add(
      AnuncioCarrusel(
        empresa: celda(fila, iEmpresa),
        imagen: _normalizarUrlImagen(imagen),
        enlace: enlace,
      ),
    );
  }
  return anuncios;
}

class CarruselAnuncios extends StatefulWidget {
  const CarruselAnuncios({super.key});

  @override
  State<CarruselAnuncios> createState() => _CarruselAnunciosState();
}

class _CarruselAnunciosState extends State<CarruselAnuncios> {
  // ── Medidas (puedes cambiarlas aquí) ──
  static const double _kMarcoMaximo = 1024; // ancho total del carrusel
  static const double _kTamanoMaximo = 350; // el anuncio nunca pasa de 350 x 350
  static const double _kTamanoMinimo = 150; // ni baja de 150 x 150
  static const double _kFactorAltura = 0.33; // igual que la imagen de programas
  static const double _kBoton = 40; // diámetro de las flechas
  static const double _kEspacioBoton = 8; // espacio entre flecha e imagen

  PageController? _controller;
  Timer? _timer;
  List<AnuncioCarrusel> _anuncios = [];
  int _actual = 0;

  @override
  void initState() {
    super.initState();
    obtenerAnuncios().then((lista) {
      if (!mounted) return;
      setState(() {
        _anuncios = lista;
        // Empieza en una página alta para poder retroceder desde el primero
        _controller = PageController(initialPage: lista.length * 1000);
      });
      _iniciarTemporizador();
    });
  }

  void _iniciarTemporizador() {
    _timer?.cancel();
    if (_anuncios.length < 2) return; // con 1 solo anuncio no se mueve
    _timer = Timer.periodic(_kCarruselIntervalo, (_) => _mover(1, reiniciar: false));
  }

  void _mover(int direccion, {bool reiniciar = true}) {
    final c = _controller;
    if (!mounted || c == null || !c.hasClients) return;
    final pagina = (c.page?.round() ?? 0) + direccion;
    c.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    if (reiniciar) _iniciarTemporizador(); // reinicia la cuenta de 4 segundos
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Widget _tarjeta(AnuncioCarrusel anuncio, double tamano) {
    return MouseRegion(
      cursor: anuncio.enlace.isEmpty
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: anuncio.enlace.isEmpty ? null : () => launchURL(anuncio.enlace),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            anuncio.imagen,
            width: tamano,
            height: tamano,
            fit: BoxFit.cover, // cambia a BoxFit.contain si no quieres recortes
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFFFD5BE),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              child: Text(
                anuncio.empresa,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF3E2314),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonFlecha(IconData icono, int direccion, String ayuda) {
    return Tooltip(
      message: ayuda,
      child: Material(
        color: const Color(0xFF3E2314),
        elevation: 3,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFDF653E), width: 2),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _mover(direccion),
          child: SizedBox(
            width: _kBoton,
            height: _kBoton,
            child: Icon(icono, color: const Color(0xFFFFB27A), size: 28),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_anuncios.isEmpty || controller == null) return const SizedBox.shrink();

    final alturaPantalla = MediaQuery.of(context).size.height;
    final varios = _anuncios.length > 1;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMarcoMaximo),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Se adapta a la altura, igual que la imagen de programas
            double tamano = (alturaPantalla * _kFactorAltura)
                .clamp(_kTamanoMinimo, _kTamanoMaximo);

            // Si el ancho no alcanza, se reduce; las flechas pasan sobre la imagen
            final ancho = constraints.maxWidth - 24;
            final espacioFlechas = (_kBoton + _kEspacioBoton) * 2;
            final flechasAfuera = varios && ancho >= tamano + espacioFlechas;
            if (tamano > ancho) tamano = ancho;

            final visor = SizedBox(
              width: tamano,
              height: tamano,
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => setState(() => _actual = i % _anuncios.length),
                itemBuilder: (_, index) =>
                    _tarjeta(_anuncios[index % _anuncios.length], tamano),
              ),
            );

            Widget cuerpo;
            if (!varios) {
              cuerpo = visor;
            } else if (flechasAfuera) {
              cuerpo = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _botonFlecha(Icons.chevron_left, -1, 'Anterior'),
                  const SizedBox(width: _kEspacioBoton),
                  visor,
                  const SizedBox(width: _kEspacioBoton),
                  _botonFlecha(Icons.chevron_right, 1, 'Siguiente'),
                ],
              );
            } else {
              cuerpo = SizedBox(
                width: tamano,
                height: tamano,
                child: Stack(
                  children: [
                    visor,
                    Positioned(
                      left: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _botonFlecha(Icons.chevron_left, -1, 'Anterior'),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _botonFlecha(Icons.chevron_right, 1, 'Siguiente'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cuerpo,
                  if (varios)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _anuncios.length,
                          (i) => Container(
                            width: i == _actual ? 18 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: i == _actual
                                  ? const Color(0xFFDF653E)
                                  : const Color(0xFF3E2314).withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
