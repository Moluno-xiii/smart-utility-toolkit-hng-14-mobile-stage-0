import 'package:flutter/material.dart';
import '../models/conversion_unit.dart';
import '../widgets/converter_card.dart';

class WeightConverterScreen extends StatelessWidget {
  const WeightConverterScreen({super.key});

  static const List<ConversionUnit> _units = [
    ConversionUnit(name: 'Kilogram', symbol: 'kg', factorToBase: 1.0),
    ConversionUnit(name: 'Gram', symbol: 'g', factorToBase: 0.001),
    ConversionUnit(name: 'Milligram', symbol: 'mg', factorToBase: 0.000001),
    ConversionUnit(name: 'Pound', symbol: 'lb', factorToBase: 0.453592),
    ConversionUnit(name: 'Ounce', symbol: 'oz', factorToBase: 0.0283495),
    ConversionUnit(name: 'Metric Ton', symbol: 't', factorToBase: 1000.0),
  ];

  @override
  Widget build(BuildContext context) {
    return const ConverterCard(
      title: 'Weight Converter',
      icon: Icons.fitness_center,
      units: _units,
    );
  }
}
