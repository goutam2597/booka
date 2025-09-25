import 'package:bookapp_customer/app/app_colors.dart';
import 'package:flutter/material.dart';

class PriceRangeSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialMin;
  final double initialMax;
  final ValueChanged<RangeValues> onChanged;

  const PriceRangeSlider({
    super.key,
    this.min = 0,
    this.max = 100000,
    required this.initialMin,
    required this.initialMax,
    required this.onChanged,
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    final start = widget.initialMin.clamp(widget.min, widget.max);
    final end = widget.initialMax.clamp(widget.min, widget.max);
    _values = RangeValues(start, end);
  }

  @override
  void didUpdateWidget(covariant PriceRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final clampedStart = _values.start.clamp(widget.min, widget.max);
    final clampedEnd = _values.end.clamp(widget.min, widget.max);
    if (clampedStart != _values.start || clampedEnd != _values.end) {
      setState(() => _values = RangeValues(clampedStart, clampedEnd));
    }
  }

  int? get _divisions {
    final span = widget.max - widget.min;
    if (span <= 100) return 20;
    if (span <= 1000) return 50;
    if (span <= 10000) return 100;
    if (span <= 50000) return 100;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: RangeSlider(
            activeColor: AppColors.primaryColor,
            values: _values,
            min: widget.min,
            max: widget.max,
            divisions: _divisions,
            labels: RangeLabels(
              _formatLabel(_values.start),
              _formatLabel(_values.end),
            ),
            onChanged: (vals) {
              setState(() => _values = vals);
              widget.onChanged(vals);
            },
          ),
        ),
        const SizedBox(height: 4),
        // Numeric display row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PriceChip(label: _formatLabel(_values.start)),
              const Text('to'),
              _PriceChip(label: _formatLabel(_values.end)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLabel(double v) {
    if (v >= 1000) {
      if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
      return '\$${(v / 1000).toStringAsFixed(1)}k';
    }
    return '\$${v.toStringAsFixed(0)}';
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  const _PriceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
