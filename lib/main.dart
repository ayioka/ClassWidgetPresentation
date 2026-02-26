import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InteractiveViewer - World Map Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const WorldMapExplorer(),
    );
  }
}

class WorldMapExplorer extends StatefulWidget {
  const WorldMapExplorer({super.key});

  @override
  State<WorldMapExplorer> createState() => _WorldMapExplorerState();
}

class _WorldMapExplorerState extends State<WorldMapExplorer>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  double _currentScale = 1.0;
  String? _selectedCity;
  late AnimationController _animController;
  Animation<Matrix4>? _animation;

  static const double canvasW = 1200;
  static const double canvasH = 700;

  static const List<Map<String, dynamic>> cities = [
    {'name': 'New York', 'x': 230.0, 'y': 210.0, 'pop': '8.3M', 'color': Colors.cyan},
    {'name': 'London', 'x': 470.0, 'y': 155.0, 'pop': '9.0M', 'color': Colors.amber},
    {'name': 'Paris', 'x': 490.0, 'y': 175.0, 'pop': '2.1M', 'color': Colors.pink},
    {'name': 'Tokyo', 'x': 920.0, 'y': 220.0, 'pop': '13.9M', 'color': Colors.greenAccent},
    {'name': 'Dubai', 'x': 660.0, 'y': 270.0, 'pop': '3.3M', 'color': Colors.orange},
    {'name': 'Sydney', 'x': 960.0, 'y': 480.0, 'pop': '5.3M', 'color': Colors.purpleAccent},
    {'name': 'São Paulo', 'x': 290.0, 'y': 440.0, 'pop': '12.3M', 'color': Colors.lime},
    {'name': 'Cairo', 'x': 560.0, 'y': 270.0, 'pop': '10.1M', 'color': Colors.deepOrange},
    {'name': 'Mumbai', 'x': 720.0, 'y': 295.0, 'pop': '20.7M', 'color': Colors.teal},
    {'name': 'Beijing', 'x': 870.0, 'y': 200.0, 'pop': '21.5M', 'color': Colors.red},
    {'name': 'Moscow', 'x': 610.0, 'y': 130.0, 'pop': '12.5M', 'color': Colors.blueAccent},
    {'name': 'Lagos', 'x': 500.0, 'y': 355.0, 'pop': '15.4M', 'color': Colors.yellow},
    {'name': 'Buenos Aires', 'x': 270.0, 'y': 510.0, 'pop': '3.1M', 'color': Colors.cyanAccent},
    {'name': 'Singapore', 'x': 840.0, 'y': 360.0, 'pop': '5.9M', 'color': Colors.lightGreen},
    {'name': 'Toronto', 'x': 200.0, 'y': 185.0, 'pop': '2.9M', 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        if (_animation != null) {
          _controller.value = _animation!.value;
          setState(() => _currentScale = _controller.value.getMaxScaleOnAxis());
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _zoomIn() => _animateScale(_currentScale * 1.4);
  void _zoomOut() => _animateScale(_currentScale / 1.4);

  void _animateScale(double targetScale) {
    targetScale = targetScale.clamp(0.4, 5.0);
    _animation = Matrix4Tween(
      begin: _controller.value.clone(),
      end: Matrix4.identity()..scale(targetScale),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.forward(from: 0);
  }

  void _reset() {
    _animateScale(1.0);
    setState(() => _selectedCity = null);
  }

  void _flyToCity(Map<String, dynamic> city) {
    const double zoom = 2.5;
    final double cx = city['x'] as double;
    final double cy = city['y'] as double;
    final size = MediaQuery.of(context).size;
    final double tx = -(cx * zoom) + size.width / 2;
    final double ty = -(cy * zoom) + size.height / 2 - 60;

    _animation = Matrix4Tween(
      begin: _controller.value.clone(),
      end: Matrix4.identity()..translate(tx, ty)..scale(zoom),
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _animController.duration = const Duration(milliseconds: 700);
    _animController.forward(from: 0);
    setState(() => _selectedCity = city['name'] as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050D1A),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _controller,
            minScale: 0.4,
            maxScale: 5.0,
            boundaryMargin: const EdgeInsets.all(300),
            onInteractionUpdate: (details) {
              setState(() => _currentScale = _controller.value.getMaxScaleOnAxis());
            },
            onInteractionStart: (_) => setState(() => _selectedCity = null),
            child: SizedBox(
              width: canvasW,
              height: canvasH,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(canvasW, canvasH),
                    painter: _MapPainter(),
                  ),
                  ...cities.map((city) {
                    final bool isSelected = _selectedCity == city['name'];
                    return Positioned(
                      left: (city['x'] as double) - 12,
                      top: (city['y'] as double) - 12,
                      child: GestureDetector(
                        onTap: () => _flyToCity(city),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: _CityMarker(
                            name: city['name'] as String,
                            population: city['pop'] as String,
                            color: city['color'] as Color,
                            isSelected: isSelected,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌍 World Map Explorer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Pinch • Pan • Tap a city', style: TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '${(_currentScale * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedCity != null)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: _CityInfoCard(
                city: cities.firstWhere((c) => c['name'] == _selectedCity),
                onClose: () => setState(() => _selectedCity = null),
              ),
            ),

          Positioned(
            bottom: 30,
            right: 16,
            child: Column(
              children: [
                _CircleButton(icon: Icons.add, tooltip: 'Zoom In', onTap: _zoomIn),
                const SizedBox(height: 8),
                _CircleButton(icon: Icons.remove, tooltip: 'Zoom Out', onTap: _zoomOut),
                const SizedBox(height: 8),
                _CircleButton(icon: Icons.center_focus_strong, tooltip: 'Reset', onTap: _reset, color: Colors.cyan),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 16,
            child: _CityQuickList(
              cities: cities,
              selectedCity: _selectedCity,
              onSelect: _flyToCity,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityMarker extends StatelessWidget {
  final String name;
  final String population;
  final Color color;
  final bool isSelected;

  const _CityMarker({required this.name, required this.population, required this.color, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSelected ? 28 : 18,
          height: isSelected ? 28 : 18,
          decoration: BoxDecoration(
            color: color.withOpacity(isSelected ? 0.3 : 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: isSelected ? 2.5 : 1.5),
            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 12, spreadRadius: 3)] : [],
          ),
          child: Center(
            child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1628).withOpacity(0.85),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.5), width: 0.5),
          ),
          child: Text(name, style: TextStyle(color: color, fontSize: 8, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
    );
  }
}

class _CityInfoCard extends StatelessWidget {
  final Map<String, dynamic> city;
  final VoidCallback onClose;

  const _CityInfoCard({required this.city, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final Color color = city['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
            child: const Icon(Icons.location_city, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(city['name'] as String, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Population: ${city['pop']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 2),
                const Text('Tap marker again or use list to fly to another city', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: onClose),
        ],
      ),
    );
  }
}

class _CityQuickList extends StatelessWidget {
  final List<Map<String, dynamic>> cities;
  final String? selectedCity;
  final void Function(Map<String, dynamic>) onSelect;

  const _CityQuickList({required this.cities, required this.selectedCity, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 90,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: cities.map((city) {
            final bool isSelected = selectedCity == city['name'];
            final Color color = city['color'] as Color;
            return GestureDetector(
              onTap: () => onSelect(city),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.25) : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? color : Colors.white24, width: isSelected ? 1.5 : 1),
                ),
                child: Text(city['name'] as String, style: TextStyle(color: isSelected ? color : Colors.white70, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _CircleButton({required this.icon, required this.tooltip, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2E),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF050D1A));

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 60) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    for (double y = 0; y < size.height; y += 60) canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      Paint()..color = Colors.cyan.withOpacity(0.15)..strokeWidth = 1.5,
    );

    final landPaint = Paint()..color = const Color(0xFF0E2340);
    final landBorderPaint = Paint()..color = const Color(0xFF1A3A5C)..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final na = Path()..moveTo(80, 100)..lineTo(320, 80)..lineTo(340, 130)..lineTo(300, 180)..lineTo(270, 260)..lineTo(210, 310)..lineTo(160, 280)..lineTo(100, 220)..lineTo(70, 160)..close();
    canvas.drawPath(na, landPaint); canvas.drawPath(na, landBorderPaint);

    final sa = Path()..moveTo(200, 330)..lineTo(310, 320)..lineTo(340, 380)..lineTo(320, 470)..lineTo(270, 540)..lineTo(230, 560)..lineTo(190, 490)..lineTo(170, 400)..close();
    canvas.drawPath(sa, landPaint); canvas.drawPath(sa, landBorderPaint);

    final eu = Path()..moveTo(430, 90)..lineTo(570, 80)..lineTo(590, 120)..lineTo(560, 180)..lineTo(500, 210)..lineTo(450, 190)..lineTo(420, 150)..close();
    canvas.drawPath(eu, landPaint); canvas.drawPath(eu, landBorderPaint);

    final af = Path()..moveTo(450, 220)..lineTo(590, 210)..lineTo(630, 250)..lineTo(620, 350)..lineTo(580, 440)..lineTo(540, 490)..lineTo(500, 480)..lineTo(460, 410)..lineTo(440, 330)..lineTo(440, 260)..close();
    canvas.drawPath(af, landPaint); canvas.drawPath(af, landBorderPaint);

    final as = Path()..moveTo(580, 80)..lineTo(980, 90)..lineTo(1000, 150)..lineTo(970, 260)..lineTo(900, 300)..lineTo(820, 320)..lineTo(720, 340)..lineTo(640, 300)..lineTo(600, 240)..lineTo(570, 180)..close();
    canvas.drawPath(as, landPaint); canvas.drawPath(as, landBorderPaint);

    final au = Path()..moveTo(880, 390)..lineTo(1020, 380)..lineTo(1060, 420)..lineTo(1040, 500)..lineTo(980, 540)..lineTo(890, 520)..lineTo(860, 460)..close();
    canvas.drawPath(au, landPaint); canvas.drawPath(au, landBorderPaint);

    final edgeGlow = Paint()..shader = RadialGradient(center: Alignment.center, radius: 1.0, colors: [Colors.transparent, Colors.cyan.withOpacity(0.04)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), edgeGlow);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.cyan.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}