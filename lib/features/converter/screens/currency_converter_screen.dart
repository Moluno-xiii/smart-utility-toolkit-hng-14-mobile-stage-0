import 'package:flutter/material.dart';
import '../models/conversion_unit.dart';
import '../models/currency_rates.dart';
import '../widgets/converter_card.dart';

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  static final List<ConversionUnit> _units = dummyRates.entries.map((entry) {
    return ConversionUnit(
      name: currencyNames[entry.key] ?? entry.key,
      symbol: entry.key,
      factorToBase: 1.0 / entry.value,
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    return ConverterCard(title: 'Currency Converter', units: _units);
  }
}
