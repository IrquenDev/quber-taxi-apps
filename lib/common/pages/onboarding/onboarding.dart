import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/images/client_map_curve.png',
      'title': '¿Listo para Viajar?',
      'subtitle': 'Con solo seleccionar el municipio de destino',
      'description': 'podrá viajar de forma rápida y segura',
      'topFactor': 0.65,
    },
    {
      'image': 'assets/images/friends_phone_curve1.png',
      'title': 'Pero primero',
      'subtitle': '¿Cómo supo de nosotros?',
      'options': ['Por un amigo', 'Por un cartel', 'Por PlayStore'],
      'topFactor': 0.60,
    },
    {
      'image': 'assets/images/friends_phone_curve2.png',
      'title': '¿Tienes un código de referido?',
      'subtitle': 'Ayuda a tu amigo y gana beneficios',
      'description':
      'Introduce un código de referido para que tu amigo obtenga un descuento en su próximo viaje. Si no dispones de uno, puedes continuar.',
      'inputHint': 'Introduzca su Código de referido',
      'topFactor': 0.55,
    },
    {
      'image': 'assets/images/trip_price_curve.png',
      'title': '¿Cómo se calcula el precio del viaje?',
      'subtitle': 'Basado en la distancia y el destino',
      'description':
      'La aplicación irá calculando y mostrando el precio en tiempo real según la distancia que se va recorriendo. Así dependiendo del municipio al que te dirijas, se te mostrará al inicio un rango estimado de precio. Esto te permite hacer paradas y visitar múltiples destinos con mayor libertad.',
      'topFactor': 0.50,
    },
    {
      'image': 'assets/images/quber_points_curve.png',
      'title': 'Puntos Quber',
      'subtitle': 'Viaja y gana descuentos',
      'description':
      'Cada vez que realizas un viaje o alguien introduce tu código de referido, acumulas Puntos Quber. Estos puntos te permiten obtener descuentos en futuros viajes. ¡Viaja más y ahorra más!',
      'topFactor': 0.60,
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              final double topPadding =
                  screenHeight * (page['topFactor'] ?? 0.5);

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page['image'],
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: [
                      SizedBox(height: topPadding),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        width: double.infinity,
                        color: colorScheme.surfaceContainerLowest,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (page['title'] != null)
                              Text(
                                page['title'],
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            if (page['subtitle'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  page['subtitle'],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    color: colorScheme.primaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (page['description'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  page['description'],
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            if (page['options'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Column(
                                  children: (page['options'] as List<String>)
                                      .map((opt) {
                                    return Padding(
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme
                                              .surfaceContainerLowest,
                                          foregroundColor:
                                          colorScheme.onSurface,
                                          minimumSize:
                                          const Size.fromHeight(45),
                                        ),
                                        onPressed: () {},
                                        child: Text(opt),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            if (page['inputHint'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: page['inputHint'],
                                    fillColor:
                                    colorScheme.surfaceContainerLowest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: _prevPage,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(Icons.arrow_back, color: colorScheme.secondary),
                    ),
                  )
                else
                  const SizedBox(width: 44),

                Row(
                  children: List.generate(
                    _pages.length,
                        (dotIndex) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotIndex == _currentPage
                            ? colorScheme.primaryContainer
                            : colorScheme.primaryContainer.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _nextPage,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.arrow_forward, color: colorScheme.secondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
