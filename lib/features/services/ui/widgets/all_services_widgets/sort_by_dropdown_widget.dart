import 'package:flutter/material.dart';

class SortByDropdownWidget extends StatefulWidget {
  final String? initial;

  final ValueChanged<String>? onChanged;

  final List<String>? options;

  const SortByDropdownWidget({
    super.key,
    this.initial,
    this.onChanged,
    this.options,
  });

  @override
  State<SortByDropdownWidget> createState() => _SortByDropdownWidgetState();
}

class _SortByDropdownWidgetState extends State<SortByDropdownWidget> {
  static const List<String> _defaultOptions = <String>[
    'Relevance',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
  ];

  late List<String> _options;
  late String _selected;

  @override
  void initState() {
    super.initState();
    _options = (widget.options == null || widget.options!.isEmpty)
        ? _defaultOptions
        : widget.options!;
    final initial = widget.initial;
    _selected = (initial != null && _options.contains(initial))
        ? initial
        : _options.first;
  }

  @override
  void didUpdateWidget(covariant SortByDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options) {
      _options = (widget.options == null || widget.options!.isEmpty)
          ? _defaultOptions
          : widget.options!;
      if (!_options.contains(_selected)) {
        _selected = _options.first;
      }
    }
    if (widget.initial != null &&
        widget.initial != _selected &&
        _options.contains(widget.initial)) {
      _selected = widget.initial!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selected,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          onChanged: (String? newValue) {
            if (newValue == null) return;
            setState(() => _selected = newValue);
            widget.onChanged?.call(newValue);
          },
          items: _options
              .map(
                (value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
        ),
      ),
    );
  }
}
