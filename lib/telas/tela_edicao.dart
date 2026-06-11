import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provedores/documentos_provider.dart';

class TelaEdicao extends StatefulWidget {
  final String documentoId;
  const TelaEdicao({super.key, required this.documentoId});

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    final doc = context.read<DocumentosProvider>().documentos.firstWhere((d) => d.id == widget.documentoId);
    _nomeController = TextEditingController(text: doc.nome);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.read<DocumentosProvider>().documentos.firstWhere((d) => d.id == widget.documentoId);
    final isDark = context.watch<DocumentosProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Renomear Documento', style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nomeController.text.trim().isNotEmpty) {
                await context.read<DocumentosProvider>().renomearDocumento(doc.id, _nomeController.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento renomeado com sucesso.')));
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF00C48C), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Hero(
                  tag: 'preview_${doc.id}',
                  child: doc.caminho != null && ['jpg', 'png'].contains(doc.extensao)
                      ? Image.file(File(doc.caminho!))
                      : Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(40),
                          child: Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey[300]),
                        ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.black87,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nome do Arquivo', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nomeController,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        ],
      ),
    );
  }
}