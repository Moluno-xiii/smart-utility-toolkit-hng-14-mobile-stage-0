import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conversion_unit.dart';
import 'unit_dropdown.dart';

class ConverterCard extends StatefulWidget {
  final String title;
  final List<ConversionUnit> units;
  final double Function(double value, ConversionUnit from, ConversionUnit to)?
  customConvert;

  const ConverterCard({
    super.key,
    required this.title,
    required this.units,
    this.customConvert,
  });

  @override
  State<ConverterCard> createState() => _ConverterCardState();
}

class _ConverterCardState extends State<ConverterCard> {
  late ConversionUnit _fromUnit;
  late ConversionUnit _toUnit;
  final TextEditingController _inputController = TextEditingController();
  String _result = '';

  @override
  void initState() {
    super.initState();
    _fromUnit = widget.units[0];
    _toUnit = widget.units.length > 1 ? widget.units[1] : widget.units[0];
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = '');
      return;
    }

    double result;
    if (widget.customConvert != null) {
      result = widget.customConvert!(input, _fromUnit, _toUnit);
    } else {
      result = input * (_fromUnit.factorToBase / _toUnit.factorToBase);
    }

    setState(() {
      _result = _formatResult(result);
    });
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e10) {
      return value.toStringAsFixed(0);
    }
    final formatted = value.toStringAsFixed(4);
    return formatted
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              UnitDropdown(
                key: ValueKey('from_${_fromUnit.symbol}'),
                units: widget.units,
                selectedUnit: _fromUnit,
                label: 'From',
                onChanged: (unit) {
                  if (unit != null) {
                    setState(() => _fromUnit = unit);
                    _convert();
                  }
                },
              ),
              const SizedBox(height: 12),

              Center(
                child: IconButton.filled(
                  onPressed: _swapUnits,
                  icon: const Icon(Icons.swap_vert),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              UnitDropdown(
                key: ValueKey('to_${_toUnit.symbol}'),
                units: widget.units,
                selectedUnit: _toUnit,
                label: 'To',
                onChanged: (unit) {
                  if (unit != null) {
                    setState(() => _toUnit = unit);
                    _convert();
                  }
                },
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Enter value',
                  prefixIcon: Icon(
                    Icons.numbers,
                    color: theme.colorScheme.primary,
                  ),
                  suffixText: _fromUnit.symbol,
                ),
                onChanged: (_) => _convert(),
              ),
              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _result.isNotEmpty
                    ? Container(
                        key: ValueKey(_result),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '$_result ${_toUnit.symbol}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        key: const ValueKey('empty'),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Enter a value to convert',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
