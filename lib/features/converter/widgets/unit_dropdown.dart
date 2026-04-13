import 'package:flutter/material.dart';
import '../models/conversion_unit.dart';

class UnitDropdown extends StatelessWidget {
  final List<ConversionUnit> units;
  final ConversionUnit selectedUnit;
  final ValueChanged<ConversionUnit?> onChanged;
  final String label;

  const UnitDropdown({
    super.key,
    required this.units,
    required this.selectedUnit,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<ConversionUnit>(
      initialValue: selectedUnit,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
      items: units.map((unit) {
        return DropdownMenuItem<ConversionUnit>(
          value: unit,
          child: Text(
            '${unit.name} (${unit.symbol})',
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
