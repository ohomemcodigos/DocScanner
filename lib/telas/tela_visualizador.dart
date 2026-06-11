import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import '../provedores/documentos_provider.dart';

class TelaVisualizador extends StatefulWidget {
  final Documento documento;

  const TelaVisualizador({super.key, required this.documento});

  @override
  State<TelaVisualizador> createState() => _TelaVisualizadorState();
}

class _TelaVisualizadorState extends State<TelaVisualizador> {
  // Mudamos de PdfControllerPinch para PdfController (Muito mais leve e suave)
  late PdfController _pdfController;
  int _paginaAtual = 1;
  int _totalPaginas = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.documento.caminho!),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 1,
        iconTheme: IconThemeData(color: textColor),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.documento.nome,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // O AVISO DE SOMENTE LEITURA ADICIONADO AQUI
            const Text(
              'Modo de visualização apenas',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            onPressed: () async {
              if (widget.documento.caminho != null) {
                final arquivo = XFile(widget.documento.caminho!);
                await SharePlus.instance.share(ShareParams(files: [arquivo], text: widget.documento.nome));
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            // PdfView padrão em vez do Pinch. Ele destrói páginas invisíveis da RAM.
            child: PdfView(
              controller: _pdfController,
              scrollDirection: Axis.horizontal, // Desliza como as páginas de um livro
              onDocumentLoaded: (document) {
                setState(() {
                  _totalPaginas = document.pagesCount;
                });
              },
              onPageChanged: (page) {
                setState(() {
                  _paginaAtual = page;
                });
              },
            ),
          ),
          
          // BARRA INFERIOR DE NAVEGAÇÃO DE PÁGINAS
          if (_totalPaginas > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  )
                ]
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 28, color: _paginaAtual > 1 ? const Color(0xFF2E6AD4) : Colors.grey[400]),
                      onPressed: () {
                        _pdfController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                      },
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Text(
                        '$_paginaAtual / $_totalPaginas',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 28, color: _paginaAtual < _totalPaginas ? const Color(0xFF2E6AD4) : Colors.grey[400]),
                      onPressed: () {
                        _pdfController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                      },
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}