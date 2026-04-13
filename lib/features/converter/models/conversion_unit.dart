class ConversionUnit {
  final String name;
  final String symbol;
  final double factorToBase;

  const ConversionUnit({
    required this.name,
    required this.symbol,
    required this.factorToBase,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionUnit &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
}
