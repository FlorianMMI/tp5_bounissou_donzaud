import 'dart:ui';
import 'package:flutter/material.dart';

class WeatherInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color? iconColor;
  final String dataType;
  const WeatherInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
    this.iconColor,
    required this.dataType,
  });

  /// Retourne une couleur dynamique basée sur le type et la valeur
  Color _getDynamicColor() {
    final numValue = double.tryParse(value) ?? 0;

    switch (dataType) {
      case 'humidity':
        // Bleu clair à bleu foncé (30-100%)
        if (numValue < 30) return Colors.orange.withOpacity(0.3);
        if (numValue < 60) return Colors.lightBlue.withOpacity(0.3);
        return Colors.blue.withOpacity(0.4);

      case 'precipitation':
        // Transparent à bleu foncé (0-50mm)
        if (numValue < 1) return Colors.grey.withOpacity(0.2);
        if (numValue < 5) return Colors.lightBlue.withOpacity(0.3);
        return Colors.blue.shade700.withOpacity(0.5);

      case 'precipProbability':
        // Gris à bleu (0-100%)
        if (numValue < 30) return Colors.grey.withOpacity(0.2);
        if (numValue < 70) return Colors.blueGrey.withOpacity(0.3);
        return Colors.blue.withOpacity(0.4);

      case 'wind':
        // Vert à rouge (0-100 km/h)
        if (numValue < 20) return Colors.green.withOpacity(0.2);
        if (numValue < 40) return Colors.yellow.withOpacity(0.3);
        if (numValue < 60) return Colors.orange.withOpacity(0.3);
        return Colors.red.withOpacity(0.4);

      case 'pressure':
        // Bleu à rouge (pression standard autour de 1013 hPa)
        if (numValue < 1000) return Colors.blue.withOpacity(0.3);
        if (numValue < 1020) return Colors.green.withOpacity(0.2);
        return Colors.orange.withOpacity(0.3);

      case 'uvIndex':
        // Vert à violet (0-11+)
        if (numValue < 3) return Colors.green.withOpacity(0.2);
        if (numValue < 6) return Colors.yellow.withOpacity(0.3);
        if (numValue < 8) return Colors.orange.withOpacity(0.3);
        if (numValue < 11) return Colors.red.withOpacity(0.4);
        return Colors.purple.withOpacity(0.5);

      case 'visibility':
        // Rouge à vert (0-10+ km)
        if (numValue < 1) return Colors.red.withOpacity(0.4);
        if (numValue < 5) return Colors.orange.withOpacity(0.3);
        return Colors.green.withOpacity(0.2);

      case 'cloudCover':
        // Transparent à gris foncé (0-100%)
        if (numValue < 25) return Colors.blue.shade200.withOpacity(0.2);
        if (numValue < 50) return Colors.grey.withOpacity(0.2);
        if (numValue < 75) return Colors.grey.withOpacity(0.3);
        return Colors.grey.shade700.withOpacity(0.4);

      default:
        return Colors.white.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getDynamicColor(),
                  _getDynamicColor().withOpacity(0.5),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 36,
                  color: iconColor ?? Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (unit != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          unit!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
