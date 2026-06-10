import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/documentos_provider.dart';

class TelaFerramentas extends StatelessWidget {
  const TelaFerramentas({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DocumentosProvider>().isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Ferramentas',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoria(
              'Digitalização e Melhoria',
              [
                _ToolItem(Icons.document_scanner, 'Escanear Documento',
                    const Color(0xFF00C48C)),
                _ToolItem(Icons.auto_awesome, 'Melhorar Imagem',
                    const Color(0xFF2E6AD4)), // Preparação para OpenCV
              ],
              isDark),
          const SizedBox(height: 24),
          _buildCategoria(
              'Conversão de Arquivos',
              [
                _ToolItem(Icons.description, 'PDF para Word',
                    const Color(0xFF2E6AD4)),
                _ToolItem(
                    Icons.image, 'Imagem para PDF', const Color(0xFFFF4B4B)),
                _ToolItem(Icons.table_chart, 'PDF para Excel',
                    const Color(0xFF34C759)),
                _ToolItem(
                    Icons.slideshow, 'PDF para PPT', const Color(0xFFFF9500)),
              ],
              isDark),
          const SizedBox(height: 32),

          // Aviso de atualizações futuras
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              children: [
                Icon(Icons.construction, color: Colors.grey[400], size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importação e Edição em Lote',
                          style: TextStyle(
                              color: textColor, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          'Estas e outras funcionalidades estarão disponíveis nas próximas atualizações do DocScanner.',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoria(String titulo, List<_ToolItem> tools, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[400] : Colors.grey[700])),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.8),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      color: tools[index].color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(tools[index].icon,
                      color: tools[index].color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(tools[index].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1A3A6B),
                        height: 1.1)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  _ToolItem(this.icon, this.label, this.color);
}
