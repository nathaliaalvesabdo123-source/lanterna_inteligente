import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const LanternaApp());
}

class LanternaApp extends StatelessWidget {
  const LanternaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lanterna Inteligente',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Paleta.dourado,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Paleta.preto,
      ),
      home: const TelaLanterna(),
    );
  }
}

class Paleta {
  static const dourado = Color(0xFFFFC107);
  static const preto = Color(0xFF000000);
  static const grafite = Color(0xFF212121);
  static const chumbo = Color(0xFF424242);
  static const cinzaClaro = Color(0xFF9E9E9E);
  static const ciano = Color(0xFF26C6DA);
}

class TelaLanterna extends StatefulWidget {
  const TelaLanterna({super.key});

  @override
  State<TelaLanterna> createState() => _TelaLanternaState();
}

class _TelaLanternaState extends State<TelaLanterna> {
  bool acesa = false;
  bool autoAtivo = false;
  int contador = 0;
  Timer? _cronometro;

  void _toggleLanterna() {
    if (autoAtivo) return;
    HapticFeedback.lightImpact();
    setState(() {
      acesa = !acesa;
    });
  }

  void _toggleAuto(bool valor) {
    HapticFeedback.mediumImpact();
    setState(() {
      autoAtivo = valor;

      if (valor) {
        acesa = true;
        contador = 15;
        _comecarContagem();
      } else {
        _cronometro?.cancel();
        contador = 0;
      }
    });
  }

  void _comecarContagem() {
    _cronometro?.cancel();
    _cronometro = Timer.periodic(const Duration(seconds: 1), (t) {
      if (contador > 1) {
        setState(() {
          contador--;
        });
      } else {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          acesa = false;
          autoAtivo = false;
          contador = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _cronometro?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: acesa ? Colors.white : Paleta.preto,
      body: SafeArea(
        child: Column(
          children: [
            _cabecalho(),
            const SizedBox(height: 16),
            _areaLuz(),
            const Spacer(),
            _cardAuto(),
            const SizedBox(height: 32),
            _botaoPower(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LANTERNA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: acesa ? Colors.black : Colors.white,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            acesa ? '● sistema ativo' : '○ sistema inativo',
            style: TextStyle(
              fontSize: 13,
              color: acesa ? Paleta.dourado : Paleta.cinzaClaro,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _areaLuz() {
    return Expanded(
      flex: 3,
      child: Center(
        child: AnimatedScale(
          scale: acesa ? 1.0 : 0.75,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: acesa
                    ? [
                        Paleta.dourado,
                        Paleta.dourado.withOpacity(0.6),
                        Colors.transparent,
                      ]
                    : [
                        Paleta.chumbo,
                        Paleta.grafite,
                        Colors.transparent,
                      ],
              ),
            ),
            child: Center(
              child: AnimatedOpacity(
                opacity: acesa ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  acesa ? Icons.wb_sunny : Icons.nightlight_round,
                  size: 70,
                  color: acesa ? Colors.white : Paleta.cinzaClaro,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardAuto() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: autoAtivo ? Paleta.ciano.withOpacity(0.15) : Paleta.grafite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: autoAtivo ? Paleta.ciano : Paleta.chumbo,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: autoAtivo ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: Icon(
                Icons.brightness_auto,
                color: autoAtivo ? Paleta.ciano : Paleta.cinzaClaro,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PILOTO AUTOMÁTICO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: autoAtivo ? Paleta.ciano : Colors.white,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    autoAtivo
                        ? 'Apagando em $contador segundo${contador == 1 ? '' : 's'}'
                        : 'Toque para ativar',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Paleta.cinzaClaro,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: autoAtivo,
              activeColor: Paleta.ciano,
              activeTrackColor: Paleta.ciano.withOpacity(0.5),
              onChanged: _toggleAuto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoPower() {
    return GestureDetector(
      onTap: _toggleLanterna,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: acesa
              ? const LinearGradient(
                  colors: [Paleta.dourado, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Paleta.chumbo, Paleta.grafite],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: acesa ? Paleta.dourado : Paleta.chumbo,
            width: 3,
          ),
        ),
        child: Icon(
          Icons.power_settings_new,
          size: 48,
          color: acesa ? Colors.black : Paleta.cinzaClaro,
        ),
      ),
    );
  }
}