import 'package:flutter/material.dart';
import '../models/conversion_unit.dart';
import '../widgets/converter_card.dart';

class LengthConverterScreen extends StatelessWidget {
  const LengthConverterScreen({super.key});

  static const List<ConversionUnit> _units = [
    ConversionUnit(name: 'Meter', symbol: 'm', factorToBase: 1.0),
    ConversionUnit(name: 'Kilometer', symbol: 'km', factorToBase: 1000.0),
    ConversionUnit(name: 'Centimeter', symbol: 'cm', factorToBase: 0.01),
    ConversionUnit(name: 'Millimeter', symbol: 'mm', factorToBase: 0.001),
    ConversionUnit(name: 'Mile', symbol: 'mi', factorToBase: 1609.344),
    ConversionUnit(name: 'Yard', symbol: 'yd', factorToBase: 0.9144),
    ConversionUnit(name: 'Foot', symbol: 'ft', factorToBase: 0.3048),
    ConversionUnit(name: 'Inch', symbol: 'in', factorToBase: 0.0254),
  ];

  @override
  Widget build(BuildContext context) {
    return const ConverterCard(
      title: 'Length Converter',
      icon: Icons.straighten,
      units: _units,
    );
  }
}
