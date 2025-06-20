//****NO MODIFICAR***
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// ──────────── your URL constants ──────────── SI SE PUEDE MODIFICAR
const _kShareLink     = "https://radio.fmcholollan.org.mx";
const _kFacebookLink  = "https://www.facebook.com/fmcholollan";
const _kInstagramLink = "https://www.instagram.com/cholollan_107.1/";
const _kWhatsappLink  = "https://api.whatsapp.com/send/?phone=5212228432727";

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
          icon: const Icon(Icons.share, size: 24, color: Color.fromRGBO(62 , 35, 20, 0.888)),
          onPressed: () => Share.share(_kShareLink),
        ),
        IconButton(
          icon: const Icon(Icons.facebook, size: 24, color:  Color.fromRGBO(62 , 35, 20, 0.888)),
          onPressed: () => launchURL(_kFacebookLink),
        ),
        IconButton(
          icon: const Icon(Icons.center_focus_weak, size: 24, color:  Color.fromRGBO(62 , 35, 20, 0.888)),
          onPressed: () => launchURL(_kInstagramLink),
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble, size: 24, color: Color.fromRGBO(62 , 35, 20, 0.888)),
          onPressed: () => launchURL(_kWhatsappLink),
        ),
      ],
    ),
  );
}  

const double _cardWidth  = 200;
const double _cardHeight = _cardWidth * 3/4;  // 4:3 ratio
//****NO MODIFICAR***
class ShowCard extends StatefulWidget {
  final ProgramShow show;
  final bool isLive;

  const ShowCard({ Key? key, required this.show, this.isLive=false })
    : super(key:key);

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
              duration: const Duration(milliseconds:300),
              crossFadeState: _flipped
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
              firstChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Builder(builder:(_) {
                      final url = widget.show.imageUrl;
                      if (url.startsWith('http')) {
                        return Image.network(
                          url,
                          width: _cardWidth,
                          height: _cardHeight,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return Image.asset(
                          url,
                          width: _cardWidth,
                          height: _cardHeight,
                          fit: BoxFit.cover,
                        );
                      }
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.show.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize:16),
                          softWrap: true,
                        ),
                        const SizedBox(height:4),
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
  return nowMinutes >= startMinutes && nowMinutes < endMinutes;
}

// CALENDAR DATA (!!!!!!! SI SE PUEDE MODIFICAR !!!!!!!!) 
final Map<int, List<ProgramShow>> weeklySchedule = {
  1: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 8:00 AM", 
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Barra Musical",
    ),
    ProgramShow(
      name: "Noticiero Pueblos en Movimiento",
      timeRange: "8:00 AM - 9:00 AM", 
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 8, minute: 59),
      imageUrl: "assets/images/pueblos-en-movimiento.webp",
      description: "Noticias desde la voz de los Pueblos",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 AM - 9:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 9, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Radio Informaremos",
      timeRange: "9:30 AM - 10:00 AM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "assets/images/radio-informaremos.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Tlaktipak Contacto Humano con la Naturaleza",
      timeRange: "10:00 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/tlalipak.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Cultura a través de los Pueblos",
      timeRange: "11:00 AM - 12:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 11, minute: 59),
      imageUrl: "assets/images/cultura-a-traves-de-los-pueblos.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Se Necesita un Pueblo",
      timeRange: "12:00 PM - 1:00 PM",
      start: TimeOfDay(hour: 12, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "assets/images/se-necesita-un-pueblo.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Tremenda Corte - Tres Patines",
      timeRange: "1:00 PM - 1:30 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 29),
      imageUrl: "assets/images/tremanda-corte-tres-patines.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "1:30 PM - 4:00 PM", 
      start: TimeOfDay(hour: 13, minute: 30),
      end: TimeOfDay(hour: 15, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Noticias desde la voz de los Pueblos",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/asi-suena-cholula-lym.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "El RAP nos hace Inmunes",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "assets/images/el-rap-nos-hace-inmunes.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "7:00 PM - 8:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 19, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Qué Tienes para Cocinar",
      timeRange: "8:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 20, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/que-tienes-para-cocinar.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Hasta Moztla",
      timeRange: "9:30 PM - 10:30 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "assets/images/hasta-moztla.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "10:30 PM - 11:00 PM",
      start: TimeOfDay(hour: 22, minute: 30),
      end: TimeOfDay(hour: 22, minute: 59),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "11:30 PM - 12:00 AM",
      start: TimeOfDay(hour: 23, minute: 30),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Tuesday 
  2: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "6:00 AM - 12:00 PM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Wednesday
  3: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 8:00 AM", 
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Noticias desde la voz de los Pueblos",
    ),
    ProgramShow(
      name: "Noticiero Pueblos en Movimiento",
      timeRange: "8:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "assets/images/pueblos-en-movimiento.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Historias Campiranas",
      timeRange: "9:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 29),
      imageUrl: "assets/images/historias-campiranas.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 30),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Icemanahuac Tlahtolnahuatl",
      timeRange: "11:00 AM - 12:30 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 30),
      imageUrl: "assets/images/icemanahuac-tlahtolnahuatl.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "12:30 PM - 1:00 PM",
      start: TimeOfDay(hour: 12, minute: 30),
      end: TimeOfDay(hour: 13, minute: 0),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Venerable Pan de Maíz",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 14, minute: 0),
      imageUrl: "assets/images/venerable-pan-de-maiz.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "El sabor de la Salsa",
      timeRange: "2:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "assets/images/el-sabor-de-la-salsa.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Tío Juan (Radio Relatos)",
      timeRange: "3:30 PM - 4:00 PM",
      start: TimeOfDay(hour: 15, minute: 30),
      end: TimeOfDay(hour: 16, minute: 0),
      imageUrl: "assets/images/mi-tio-juan.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 18, minute: 0),
      imageUrl: "assets/images/asi-suena-cholula-lym.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Contramáscaras",
      timeRange: "6:00 PM - 7:30 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 19, minute: 30),
      imageUrl: "assets/images/contramascaras.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Yestli",
      timeRange: "7:30 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 30),
      end: TimeOfDay(hour: 21, minute: 0),
      imageUrl: "assets/images/yestli-sangre-nueva.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 21, minute: 0),
      end: TimeOfDay(hour: 21, minute: 30),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 22, minute: 0),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Frecuencia Ambiental",
      timeRange: "10:00 PM - 11:00 PM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 23, minute: 0),
      imageUrl: "assets/images/frecuencia-ambiental.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "11:00 PM - 12:00 AM",
      start: TimeOfDay(hour: 23, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Thursday 
  4: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "6:00 AM - 12:00 AM",
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Friday
  5: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "0:00 AM - 8:00 AM", 
      start: TimeOfDay(hour: 0, minute: 0),
      end: TimeOfDay(hour: 7, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Noticias desde la voz de los Pueblos",
    ),
    ProgramShow(
      name: "Noticiero Pueblos en Movimiento",
      timeRange: "8:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "assets/images/pueblos-en-movimiento.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 AM - 9:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 9, minute: 30),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Kalimán",
      timeRange: "9:30 AM - 10:00 AM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "assets/images/kaliman.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:00 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "11:00 AM - 1:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 13, minute: 0),
      imageUrl: "assets/images/asi-suena-cholula-v.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Acciones por la Tierra",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 14, minute: 0),
      imageUrl: "assets/images/acciones-por-la-tierra.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Porfirio Cadena",
      timeRange: "2:00 PM - 2:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 14, minute: 30),
      imageUrl: "assets/images/porfirio-cadena.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "2:30 PM - 4:30 PM",
      start: TimeOfDay(hour: 14, minute: 30),
      end: TimeOfDay(hour: 16, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Periodismo de lo Posible",
      timeRange: "4:30 PM - 5:00 PM",
      start: TimeOfDay(hour: 16, minute: 30),
      end: TimeOfDay(hour: 16, minute: 59),
      imageUrl: "assets/images/periodismo-de-lo-posible.webp",
      description: "Historias de esperanza desde los territorios",
    ),
    ProgramShow(
      name: "Tiempo de Lectura",
      timeRange: "5:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 17, minute: 0),
      end: TimeOfDay(hour: 18, minute: 0),
      imageUrl: "assets/images/tiempo-de-lectura.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "El Telar",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 19, minute: 59),
      imageUrl: "assets/images/el-telar.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Mitote Ranchero",
      timeRange: "7:00 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 20, minute: 59),
      imageUrl: "assets/images/mitote-ranchero.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 21, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "assets/images/canto-de-cezontles.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:00 PM - 12:00 AM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Saturday 
  6: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "6:00 AM - 12:00 AM",
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],

  // Sunday
  7: [
    ProgramShow(
      name: "Barra Musical",
      timeRange: "6:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Tierra Mestiza",
      timeRange: "9:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 30),
      imageUrl: "assets/images/tierra-mestiza.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 AM - 2:00 PM",
      start: TimeOfDay(hour: 10, minute: 30),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Conehuehue",
      timeRange: "2:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "assets/images/conehuehue.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Perifoneo Prieto Popular",
      timeRange: "3:30 PM - 6:00 PM",
      start: TimeOfDay(hour: 15, minute: 29),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "assets/images/perifoneo-prieto.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Babel Cholollan",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "assets/images/babel.webp",
      description: "Esta es una descripcions de purebala para ver que show con el show",
    ),
    ProgramShow(
      name: "Bien Estar",
      timeRange: "7:00 PM - 8:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 19, minute: 59),
      imageUrl: "assets/images/bien-estar.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Raíces Huastecas",
      timeRange: "8:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 20, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "assets/images/raices-huastecas.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "9:30 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Hora Nacional",
      timeRange: "10:00 PM - 10:30 AM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "assets/images/la-hora-nacional.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
    ProgramShow(
      name: "Barra Musical",
      timeRange: "10:30 PM - 12:00 PM",
      start: TimeOfDay(hour: 22, minute: 30),
      end: TimeOfDay(hour: 23, minute: 59),
      imageUrl: "assets/images/barra-musical.webp",
      description: "Si me estás leyendo funciona la descripcion",
    ),
  ],
};
// CALENDAR DATA (!!!!!!! SI SE PUEDE MODIFICAR !!!!!!!!) 

//****NO MODIFICAR***
ProgramShow? getCurrentShow() {
  final dayOfWeek = DateTime.now().weekday;
  final showsToday = weeklySchedule[dayOfWeek];
  if (showsToday == null || showsToday.isEmpty) return null;
  final now = TimeOfDay.now();
  for (final show in showsToday) {
    if (isTimeOfDayInRange(now, show.start, show.end)) {
      return show;
    }
  }
  return null;
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Cholollan 107.1 FM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: HomeScreen(),
    );
  }
}
//****NO MODIFICAR***
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
//****NO MODIFICAR***
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    RadioScreen(),
    ProgramasScreen(),
    NosotrosScreen(),
    MasScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
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
        title: InkWell(
          onTap: () => _launchURL("https://fmcholollan.org.mx"),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // or EdgeInsets.all(5.0)
            child: Image.network(
              "https://res.cloudinary.com/duuo73nsd/image/upload/v1742355014/Mesa_de_trabajo_1_djaxpi.png",
              width: 333,
              height: 55,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Programas'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nosotros'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// RADIO SCREEN //****NO MODIFICAR***
// ----------------------------------------------------------
class RadioScreen extends StatefulWidget {
  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  ProgramShow? _currentShow;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isLoading = false;


  @override
void initState() {
  super.initState();
  _updateCurrentShow();
  _timer = Timer.periodic(Duration(minutes: 1), (timer) {
    _updateCurrentShow();
  });
  // Listen for processing state changes to update UI.
  _player.processingStateStream.listen((state) {
    if (state == ProcessingState.ready) {
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    } else if (state == ProcessingState.idle) {
      setState(() {
        _isPlaying = false;
      });
    }
  });
}

  void _updateCurrentShow() {
    setState(() {
      _currentShow = getCurrentShow();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

 Future<void> _togglePlay() async {
  if (!_isPlaying) {
    // User pressed play: show loading while stream loads.
    setState(() {
      _isLoading = true;
    });
    try {
      await _player.setUrl('https://radios.liberaturadio.org/fmcholollan');
      await _player.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print("Error playing stream: $e");
    }
    setState(() {
      _isLoading = false;
    });
  } else {
    // User pressed pause: stop the stream so that next play always starts live.
    try {
      await _player.stop();
    } catch (e) {
      print("Error stopping stream: $e");
    }
    setState(() {
      _isPlaying = false;
    });
  }
}

  @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  // 22% of screen height, clamped between 150 and 333.
  final double imageSize =
      (screenHeight * 0.33).clamp(150.0, 333.0);

  // If the phone is really short, shrink the play icon to 48; otherwise 64.
  final double playIconSize = screenHeight < 650 ? 48.0 : 64.0;

  final showName = _currentShow?.name ?? "Programación Normal";
  final showImage = _currentShow?.imageUrl ??
      "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcohólicos_Anónimos_1920_dbbrww.jpg";
  final showTime = _currentShow?.timeRange ?? "";

  return Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
      ),
    ),
    child: SafeArea(
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
                  child: Builder(builder: (_) {
                    if (showImage.startsWith('http')) {
                      return Image.network(showImage, fit: BoxFit.cover);
                    } else {
                      return Image.asset(showImage, fit: BoxFit.cover);
                    }
                  }),
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
              Text(showTime, style: const TextStyle(color: Colors.brown)),
            ],

            const SizedBox(height: 24),

            // responsive play/pause
            _isLoading
                ? const CircularProgressIndicator()
                : IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: playIconSize,
                    color: Colors.brown[700],
                    onPressed: _togglePlay,
                  ),

            const SizedBox(height: 16),

            // socials
            socialRow(),
          ],
        ),
      ),
    ),
  );
}
}


// ---------------- PROGRAMAS SCREEN  ----------------//****NO MODIFICAR***
class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({Key? key}) : super(key: key);

  @override
  _ProgramasScreenState createState() => _ProgramasScreenState();
}
//****NO MODIFICAR***
class _ProgramasScreenState extends State<ProgramasScreen> {
  final List<String> days = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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

  List<ProgramShow> _getShowsForDay(int day) => weeklySchedule[day] ?? [];

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
              color: Colors.white,
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.brown,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,
                tabs: days.map((d) => Tab(text: d)).toList(),
              ),
            ),

            // ── content for each day ──
            Expanded(
              child: TabBarView(
                children: days.asMap().entries.map((entry) {
                  final weekday = entry.key + 1;
                  final shows   = _getShowsForDay(weekday);

                  if (shows.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay programas para este día.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: shows.length,
                    itemBuilder: (context, idx) {
                      final show    = shows[idx];
                      final current = getCurrentShow();
                      final isLive  = current != null
                          && current.start == show.start
                          && current.end   == show.end;

                      return Center(
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      show.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      show.description.isNotEmpty
                                          ? show.description
                                          : "No description available.",
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: _cardImageWidth,
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: isLive ? 8 : 2,
                              color: isLive
                                  ? Colors.orange.withOpacity(0.2)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Builder(builder:(_) {
                                      final url = show.imageUrl;
                                      return url.startsWith('http')
                                        ? Image.network(url, width: _cardImageWidth, height: _cardImageHeight, fit: BoxFit.cover)
                                        : Image.asset(url, width: _cardImageWidth, height: _cardImageHeight, fit: BoxFit.cover);
                                    }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          show.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          softWrap: true,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          show.timeRange,
                                          style:
                                              const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
  const NosotrosScreen({Key? key}) : super(key: key);

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
                        'Somos habitantes del Valle de Cholula, y desde el año 2009 en Tlaxcalancingo, comenzamos a construir una Radio de Uso Social Indígena y Comunitaria, que camina, escucha y difunde la palabra de los pueblos.\n\n'
                        'Con 745 watts de potencia comunal, transmitimos en el 107.1 FM y en el éter de los corazones que sueñan, se manifiestan y se organizan para construir otro mundo posible.\n\n'
                        '¡Ayúdanos a fortalecer el proyecto para que la voz de los pueblos se escuche más fuerte!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── “DONA AHORA” Button ───
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _launchURL(
                          'https://donate.stripe.com/fZeeYbfAn6RKacg4gh',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
// ---------------- MAS SCREEN  ----------------//****NO MODIFICAR***
class MasScreen extends StatelessWidget {
  const MasScreen({Key? key}) : super(key: key);

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
        child: Wrap(
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
                  onPressed: () => _launchURL("https://fmcholollan.org.mx/seccion/noticias/"),
                ),
                const Text('Noticias'),
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
                  onPressed: () => _launchURL(
                    'https://fmcholollan.org.mx/servicios-donacion/',
                  ),
                ),
                const Text('Donaciones'),
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
                  onPressed: () => _launchURL(
                    'https://fmcholollan.org.mx/seccion/audiovisual/audioteca/',
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
                  onPressed: () => _launchURL('https://fmcholollan.org.mx/eventos/'),
                ),
                const Text('Eventos'),
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
                  onPressed: () => _launchURL(
                    'https://api.whatsapp.com/send/?phone=5212228432727&text=Cholollan+Radio+%EF%BF%BD%3A&type=phone_number&app_absent=0',
                  ),
                ),
                const Text('WhatsApp'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}