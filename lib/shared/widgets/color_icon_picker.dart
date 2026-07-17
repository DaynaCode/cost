import 'package:flutter/material.dart';

import '../utils/icon_catalog.dart';

class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colorPalette.map((colorValue) {
        final isSelected = colorValue == selectedColor;
        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 2.5)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class IconPickerGrid extends StatelessWidget {
  const IconPickerGrid({
    super.key,
    required this.selectedIconCodePoint,
    required this.onIconSelected,
    required this.color,
  });

  final int selectedIconCodePoint;
  final ValueChanged<int> onIconSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: iconCatalog.map((icon) {
        final isSelected = icon.codePoint == selectedIconCodePoint;
        return GestureDetector(
          onTap: () => onIconSelected(icon.codePoint),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : null,
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isSelected ? color : Colors.grey),
          ),
        );
      }).toList(),
    );
  }
}
