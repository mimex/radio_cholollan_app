import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

// ----------------------------------------------------------
// MODEL & SCHEDULE DATA
// ----------------------------------------------------------
class ProgramShow {
  final String name;
  final String timeRange; // e.g., "8:00 AM - 10:00 AM" for display
  final TimeOfDay start;
  final TimeOfDay end;
  final String imageUrl;

  ProgramShow({
    required this.name,
    required this.timeRange,
    required this.start,
    required this.end,
    required this.imageUrl,
  });
}

// Helper to determine if current time is in the range.
bool isTimeOfDayInRange(TimeOfDay now, TimeOfDay start, TimeOfDay end) {
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = start.hour * 60 + start.minute;
  final endMinutes = end.hour * 60 + end.minute;
  return nowMinutes >= startMinutes && nowMinutes < endMinutes;
}

// Sample weekly schedule: keys are weekday numbers (1 = Monday, …, 7 = Sunday)
final Map<int, List<ProgramShow>> weeklySchedule = {
  // Monday (1)
  1: [
    ProgramShow(
      name: "Noticiero Pueblos en Movimiento",
      timeRange: "8:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
    ProgramShow(
      name: "Radio Informaremos",
      timeRange: "9:30 AM - 10:00 AM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Radio_Informaremos_pfl3la.jpg",
    ),
    ProgramShow(
      name: "Tlaktipak",
      timeRange: "10:00 AM - 11:00 AM",
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 10, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350784/Tlaltipak_di4pik.jpg",
    ),
    ProgramShow(
      name: "Cultura a través de los Pueblos",
      timeRange: "11:00 AM - 12:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 11, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350788/Cultura_a_trav%C3%A9s_de_los_Pueblos_ctnb7k.jpg",
    ),
    ProgramShow(
      name: "Se Necesita un Pueblo",
      timeRange: "12:00 PM - 1:00 PM",
      start: TimeOfDay(hour: 12, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350787/Se_Necesita_un_Pueblo_zdbztv.jpg",
    ),
    ProgramShow(
      name: "Tremenda Corte - Tres Patines",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350787/Tremenda_Corte_Tres_Patines_ow0b3v.jpg",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 5:30 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 30),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
    ProgramShow(
      name: "RAP",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350787/El_Rap_nos_Hace_Inmunes_dlwrha.jpg",
    ),
    ProgramShow(
      name: "Que Tienes para Cocinar",
      timeRange: "8:00 PM - 9:30 PM",
      start: TimeOfDay(hour: 20, minute: 0),
      end: TimeOfDay(hour: 21, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350787/Que_tienes_para_Cocinar_pkue2x.jpg",
    ),
    ProgramShow(
      name: "Hasta Moztla",
      timeRange: "9:30 PM - 10:30 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350790/Hasta_Moztla_nao4oq.jpg",
    ),
    ProgramShow(
      name: "Canto de Cenzontles",
      timeRange: "10:30 PM - 10:30 PM",
      start: TimeOfDay(hour: 22, minute: 30),
      end: TimeOfDay(hour: 23, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350789/Canto_de_Cenzontles_lrvjh9.jpg",
    ),
  ],
  // Tuesday (2)
  2: [
    ProgramShow(
      name: "Programa Regular",
      timeRange: "8:00 AM - 10:00 PM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 22, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
  ],
  // Wednesday (3)
  3: [
    ProgramShow(
      name: "Noticieros en Movimiento",
      timeRange: "8:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
    ProgramShow(
      name: "Historias Campiranas",
      timeRange: "9:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 30),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
    ProgramShow(
      name: "Icemanahuac Tlahtolnahuatl (Mundo de la Lengua Nahuatl)",
      timeRange: "11:00 AM - 12:30 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350786/Historias_Campiranas_chj9d7.jpg",
    ),
    ProgramShow(
      name: "Venerable Pan de Maíz",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350786/Venerable_Pan_de_Ma%C3%ADz_pstj3p.jpg",
    ),
    ProgramShow(
      name: "Tío Juan (Radio Relatos)",
      timeRange: "2:00 PM - 2:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 14, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350788/Mi_T%C3%ADo_Juan_vas4wh.jpg",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "4:00 PM - 5:59 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/As%C3%AD_Suena_Cholula_con_Danilo_El_Perico_hmwwg8.jpg",
    ),
    ProgramShow(
      name: "Contramáscaras",
      timeRange: "6:00 PM - 7:29 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 19, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
    ProgramShow(
      name: "Yestli",
      timeRange: "7:30 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 30),
      end: TimeOfDay(hour: 21, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350789/Yestli_Sangre_Nueva_miwqfj.jpg",
    ),
    ProgramShow(
      name: "Canto de Cenezontles",
      timeRange: "9:00 PM - 10:00 PM",
      start: TimeOfDay(hour: 21, minute: 0),
      end: TimeOfDay(hour: 21, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350789/Canto_de_Cenzontles_lrvjh9.jpg",
    ),
    ProgramShow(
      name: "Frecuencia Ambiental",
      timeRange: "10:00 PM - 11:00 PM",
      start: TimeOfDay(hour: 22, minute: 0),
      end: TimeOfDay(hour: 22, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Frecuencia_Ambiental_yaecy4.jpg",
    ),
  ],
  // Thursday (4)
  4: [
    ProgramShow(
      name: "Programa Regular",
      timeRange: "8:00 AM - 10:00 PM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 22, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
  ],
  // Friday (5)
  5: [
    ProgramShow(
      name: "Noticieros en Movimiento",
      timeRange: "8:00 AM - 9:00 AM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 9, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg ",
    ),
    ProgramShow(
      name: "Kalimán",
      timeRange: "9:30 AM - 1h0:00 AM",
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 9, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350784/Kaliman_tfze2z.jpg",
    ),
    ProgramShow(
      name: "Así Suena Cholula",
      timeRange: "11:00 AM - 1:00 PM",
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350784/Kaliman_tfze2z.jpg",
    ),
    ProgramShow(
      name: "Acciones por la Tierra",
      timeRange: "1:00 PM - 2:00 PM",
      start: TimeOfDay(hour: 13, minute: 0),
      end: TimeOfDay(hour: 13, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Acciones_por_la_Tierra_x4tofz.jpg",
    ),
    ProgramShow(
      name: "Porfirio Cadena (Radio Relatos)",
      timeRange: "2:00 PM - 2:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 14, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350784/Porfirio_Cadena_yv9zza.jpg",
    ),
    ProgramShow(
      name: "El Sabor de la Salsa",
      timeRange: "5:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 17, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350787/El_Sabor_de_la_Salsa_fxpmws.jpg",
    ),
    ProgramShow(
      name: "El Telar",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350790/El_Telar_gwnq1t.jpg",
    ),
    ProgramShow(
      name: "Mitote Ranchero",
      timeRange: "7:00 PM - 9:00 PM",
      start: TimeOfDay(hour: 19, minute: 0),
      end: TimeOfDay(hour: 20, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350784/Mitote_Ranchero_tqvank.jpg",
    ),
    ProgramShow(
      name: "Canto de Cenezontles",
      timeRange: "9:30 PM - 10:30 PM",
      start: TimeOfDay(hour: 21, minute: 30),
      end: TimeOfDay(hour: 22, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350789/Canto_de_Cenzontles_lrvjh9.jpg",
    ),
  ],
  // Saturday (6)
  6: [
    ProgramShow(
      name: "Programa Regular",
      timeRange: "8:00 AM - 10:00 PM",
      start: TimeOfDay(hour: 8, minute: 0),
      end: TimeOfDay(hour: 22, minute: 0),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg",
    ),
  ],
  // Sunday (7)
  7: [
    ProgramShow(
      name: "Tierra Mestiza ",
      timeRange: "9:00 AM - 10:30 AM",
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350788/Tierra_Mestiza_nb4whi.jpg",
    ),
    ProgramShow(
      name: "Conehuehue",
      timeRange: "2:00 PM - 3:30 PM",
      start: TimeOfDay(hour: 14, minute: 0),
      end: TimeOfDay(hour: 15, minute: 29),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Conehuehue_m1g5nt.jpg",
    ),
    ProgramShow(
      name: "Perifoneo Prieto Popular",
      timeRange: "4:00 PM - 5:00 PM",
      start: TimeOfDay(hour: 16, minute: 0),
      end: TimeOfDay(hour: 16, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350790/Perifoneo_Prieto_Popular_shn1uw.jpg",
    ),
    ProgramShow(
      name: "Bien Estar",
      timeRange: "5:00 PM - 6:00 PM",
      start: TimeOfDay(hour: 17, minute: 0),
      end: TimeOfDay(hour: 17, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350783/Bien-Estar_z7pfc8.jpg",
    ),
    ProgramShow(
      name: "Babel Cholollan",
      timeRange: "6:00 PM - 7:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350789/Babel_exmtl7.jpg",
    ),
    ProgramShow(
      name: "Raíces Huastecas",
      timeRange: "7:00 PM - 8:00 PM",
      start: TimeOfDay(hour: 18, minute: 0),
      end: TimeOfDay(hour: 18, minute: 59),
      imageUrl: "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Ra%C3%ADces_Huastecas_h6fuuz.jpg",
    ),
  ],
};

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

List<ProgramShow> getTodayShows() {
  final dayOfWeek = DateTime.now().weekday;
  return weeklySchedule[dayOfWeek] ?? [];
}

// ----------------------------------------------------------
// MAIN APP & HOME SCREEN
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

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
        backgroundColor: Color(0xFFFFF1E6),
        elevation: 0,
        title: InkWell(
          onTap: () => _launchURL("https://fmcholollan.org.mx"),
          child: Image.network(
            "https://res.cloudinary.com/duuo73nsd/image/upload/v1742355014/Mesa_de_trabajo_1_djaxpi.png",
            width: 333,
            height: 55,
            fit: BoxFit.contain,
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
// RADIO SCREEN (LIVE-ONLY MODE WITH LOADING ANIMATION)
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
    final showName = _currentShow?.name ?? "Programación Normal";
    final showImage = _currentShow?.imageUrl ??
        "https://res.cloudinary.com/duuo73nsd/image/upload/v1742350791/Alcoh%C3%B3licos_An%C3%B3nimos_1920_dbbrww.jpg";
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(showImage),
                          fit: BoxFit.cover,                          
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      showName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (showTime.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        showTime,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _isLoading
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                            iconSize: 64,
                            color: Colors.brown[700],
                            onPressed: _togglePlay,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------
// PROGRAMAS SCREEN 
// ----------------------------------------------------------
class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({Key? key}) : super(key: key);

  @override
  _ProgramasScreenState createState() => _ProgramasScreenState();
}

class _ProgramasScreenState extends State<ProgramasScreen> {
  // Define the days of the week (adjust labels as desired)
  final List<String> days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  // Helper to fetch schedule for a given weekday (1=Monday, etc.)
  List<ProgramShow> _getShowsForDay(int day) {
    return weeklySchedule[day] ?? [];
  }

  // The initial tab index based on the current weekday (0-based index)
  int get initialTabIndex => DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Apply gradient background.
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
            Container(
              color: Colors.white, // A solid color behind the TabBar
              child: TabBar(
                isScrollable: true,
                labelColor: Colors.brown,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.orange,
                tabs: days.map((day) => Tab(text: day)).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: days.asMap().entries.map((entry) {
                  final int dayIndex = entry.key; // 0 for Monday, etc.
                  final int weekday = dayIndex + 1; // Adjust to 1-based indexing
                  final shows = _getShowsForDay(weekday);
                  if (shows.isEmpty) {
                    return const Center(
                      child: Text(
                        "No hay programas para este día.",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: shows.length,
                    itemBuilder: (context, index) {
                      final show = shows[index];
                      // Optionally, highlight the live show on the current day.
                      final currentLive = getCurrentShow();
                      final isLive = (currentLive != null && currentLive.name == show.name);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: isLive ? 8 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              show.imageUrl,
                              width: 133,
                              height: 121,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            show.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(show.timeRange),
                          tileColor: isLive ? Colors.orange.withOpacity(0.2) : null,
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
  

// ----------------------------------------------------------
// NOSOTOROS & MAS SCREEN 
// ----------------------------------------------------------

// ---------------- NOSOTROS SCREEN  ----------------
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF1E6), Color(0xFFFFD5BE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner image
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://res.cloudinary.com/duuo73nsd/image/upload/v1742350785/Acciones_por_la_Tierra_x4tofz.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Somos habitantes del Valle de Cholula, y desde el año 2009 en Tlaxcalancingo, comenzamos a contruir una Radio de Uso Social Indígena y Comunitaria, que camina, escucha y difunde la palabra de los pueblos. Con 745 watts de potencia comunal transmitimos en el 107.1 FM y en el eter de los corazones que sueñan, se manifiestan y se organizan en busca de otro mundo posible. ¡Ayúdanos a construirlo!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _launchURL("https://donate.stripe.com/fZeeYbfAn6RKacg4gh"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('DONA AHORA'),
                      ),
                    ),
                    // Spacer pushes content to fill available height.
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
                  iconSize: 103, // So the button area matches the image size
                  icon: Image.network(
                    "https://res.cloudinary.com/duuo73nsd/image/upload/v1742601834/ICONO_NOTICIAS_CONTORNOS_NEGRO_N_p1bon8.png",
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
                  icon: Image.network(
                    "https://res.cloudinary.com/duuo73nsd/image/upload/v1742601835/Donaciones_Fm_Cholollan_N_qrfek6.png",
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed: () => _launchURL("https://fmcholollan.org.mx/servicios-donacion/"),
                ),
                const Text('Donaciones'),
              ],
            ),

            // PODCAST
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.network(
                    "https://res.cloudinary.com/duuo73nsd/image/upload/v1742601835/ICONOS_MAIZ_CONTORNO_NEGRO_N_xjfjcg.png",
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed: () => _launchURL("https://fmcholollan.org.mx/seccion/audiovisual/audioteca/"),
                ),
                const Text('Podcast'),
              ],
            ),

            // EVENTOS
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.network(
                    "https://res.cloudinary.com/duuo73nsd/image/upload/v1742601835/Eventos_Fm_Cholollan_N_ufdh7h.png",
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed: () => _launchURL("https://fmcholollan.org.mx/"),
                ),
                const Text('Eventos'),
              ],
            ),

            // WHATSAPP
            Column(
              children: [
                IconButton(
                  iconSize: 103,
                  icon: Image.network(
                    "https://res.cloudinary.com/duuo73nsd/image/upload/v1742601835/Whatsapp_Fm_Cholollan_N_gdevcg.png",
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                  onPressed: () => _launchURL("https://api.whatsapp.com/send/?phone=5212228432727&text=Cholollan+Radio+%EF%BF%BD%3A&type=phone_number&app_absent=0"),
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