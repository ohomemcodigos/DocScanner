import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/documentos_provider.dart';

class TelaEdicao extends StatelessWidget {
  final String documentoId;
  const TelaEdicao({super.key, required this.documentoId});

  @override
  Widget build(BuildContext context) {
    final doc = context
        .read<DocumentosProvider>()
        .documentos
        .firstWhere((d) => d.id == documentoId);
    final isDark = context.watch<DocumentosProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFF1E1E1E), // Fundo escuro focado na edição
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Editar: ${doc.nome}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alterações guardadas.')));
              Navigator.pop(context);
            },
            child: const Text('Concluir',
                style: TextStyle(
                    color: Color(0xFF00C48C), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          // Área de Preview Central
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Hero(
                  tag: 'preview_${doc.id}',
                  child: doc.caminho != null &&
                          ['jpg', 'png'].contains(doc.extensao)
                      ? Image.file(File(doc.caminho!))
                      : Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(40),
                          child: Icon(Icons.picture_as_pdf,
                              size: 80, color: Colors.grey[300]),
                        ),
                ),
              ),
            ),
          ),

          // Barra de Ferramentas Inferior
          Container(
            height: 100,
            color: isDark ? const Color(0xFF1E1E1E) : Colors.black87,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                _buildFerramenta(Icons.auto_awesome, 'Filtros\n(Em breve)', () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'A integração com OpenCV_Dart será feita aqui.')));
                }),
                _buildFerramenta(Icons.crop, 'Cortar', () {}),
                _buildFerramenta(Icons.rotate_right, 'Rodar', () {}),
                _buildFerramenta(Icons.library_add, 'Nova pág.', () {}),
                _buildFerramenta(Icons.photo_library, 'Importar\nLote', () {}),
                _buildFerramenta(Icons.delete_outline, 'Apagar', () {},
                    color: const Color(0xFFFF4B4B)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFerramenta(IconData icon, String label, VoidCallback onTap,
      {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
