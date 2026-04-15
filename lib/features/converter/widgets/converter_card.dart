import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/conversion_unit.dart';
import 'unit_dropdown.dart';

class ConverterCard extends StatefulWidget {
  final String title;
  final List<ConversionUnit> units;
  final IconData icon;
  final double Function(double value, ConversionUnit from, ConversionUnit to)?
  customConvert;

  const ConverterCard({
    super.key,
    required this.title,
    required this.units,
    this.icon = Icons.swap_horiz,
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(widget.icon, size: 36, color: theme.colorScheme.onPrimary),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'From',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  UnitDropdown(
                    key: ValueKey('from_${_fromUnit.symbol}'),
                    units: widget.units,
                    selectedUnit: _fromUnit,
                    label: 'Select unit',
                    onChanged: (unit) {
                      if (unit != null) {
                        setState(() => _fromUnit = unit);
                        _convert();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _swapUnits,
                        icon: const Icon(Icons.swap_vert_rounded),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'To',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  UnitDropdown(
                    key: ValueKey('to_${_toUnit.symbol}'),
                    units: widget.units,
                    selectedUnit: _toUnit,
                    label: 'Select unit',
                    onChanged: (unit) {
                      if (unit != null) {
                        setState(() => _toUnit = unit);
                        _convert();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Value',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inputController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter value',
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: theme.colorScheme.primary,
                      ),
                      suffixText: _fromUnit.symbol,
                      suffixStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onChanged: (_) => _convert(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _result.isNotEmpty
                ? Card(
                    key: ValueKey(_result),
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Result',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                Text(
                                  '$_result ${_toUnit.symbol}',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Card(
                    key: const ValueKey('empty'),
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calculate_outlined,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
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
          ),
        ],
      ),
    );
  }
}
