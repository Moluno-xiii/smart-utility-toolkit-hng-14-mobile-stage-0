import 'package:flutter/material.dart';
import '../models/conversion_unit.dart';
import '../widgets/converter_card.dart';

class TemperatureConverterScreen extends StatelessWidget {
  const TemperatureConverterScreen({super.key});

  static const List<ConversionUnit> _units = [
    ConversionUnit(name: 'Celsius', symbol: '\u00B0C', factorToBase: 1.0),
    ConversionUnit(name: 'Fahrenheit', symbol: '\u00B0F', factorToBase: 1.0),
    ConversionUnit(name: 'Kelvin', symbol: 'K', factorToBase: 1.0),
  ];

  static double _convert(double value, ConversionUnit from, ConversionUnit to) {
    double celsius;
    switch (from.name) {
      case 'Celsius':
        celsius = value;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
      case 'Kelvin':
        celsius = value - 273.15;
      default:
        celsius = value;
    }

    switch (to.name) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return (celsius * 9 / 5) + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ConverterCard(
      title: 'Temperature Converter',
      units: _units,
      customConvert: _convert,
    );
  }
}
