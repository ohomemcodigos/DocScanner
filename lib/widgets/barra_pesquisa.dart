import 'package:flutter/material.dart';

class BarraPesquisa extends StatelessWidget {
  final Color corFundo;
  final bool isDark;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;
  final bool comSombra;

  const BarraPesquisa({
    super.key,
    required this.corFundo,
    required this.isDark,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'Pesquisar...',
    this.comSombra = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(24),
        boxShadow: comSombra && !isDark
            ? [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : [],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[400], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A3A6B),
                  fontSize: 15),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}