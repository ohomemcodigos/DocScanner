import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdfx/pdfx.dart';
import '../provedores/documentos_provider.dart';

class MiniaturaDocumento extends StatelessWidget {
  final Documento doc;
  final bool isDark;
  final double largura;
  final double altura;

  const MiniaturaDocumento({
    super.key,
    required this.doc,
    required this.isDark,
    this.largura = 48,
    this.altura = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (['jpg', 'png', 'jpeg'].contains(doc.extensao.toLowerCase()) &&
        doc.caminho != null &&
        !kIsWeb) {
      return Container(
        width: largura,
        height: altura,
        decoration: BoxDecoration(
          color: Colors.transparent, // Fundo transparente para preservar PNGs sem fundo
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!, // Ajuste sutil de borda no modo escuro
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.file(
            File(doc.caminho!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        ),
      );
    }

    if (doc.extensao.toLowerCase() == 'pdf' && doc.caminho != null && !kIsWeb) {
      return FutureBuilder<PdfDocument>(
        future: PdfDocument.openFile(doc.caminho!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<PdfPageImage?>(
              future: snapshot.data!.getPage(1).then((page) =>
                  page.render(width: page.width, height: page.height)),
              builder: (ctx, snapImg) {
                if (snapImg.hasData && snapImg.data != null) {
                  return Container(
                    width: largura,
                    height: altura,
                    decoration: BoxDecoration(
                      color: Colors.white, // PDFs preservam o fundo branco de papel
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.memory(
                        snapImg.data!.bytes,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
                return _fallbackIcon();
              },
            );
          }
          return _fallbackIcon();
        },
      );
    }

    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    final ext = doc.extensao.toLowerCase();
    
    Color iconColor;
    IconData iconData;

    if (ext == 'pdf') {
      iconColor = const Color(0xFFFF4B4B);
      iconData = Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      iconColor = const Color(0xFF2B579A); 
      iconData = Icons.description;
    } else if (['xls', 'xlsx'].contains(ext)) {
      iconColor = const Color(0xFF217346); 
      iconData = Icons.table_chart;
    } else if (['ppt', 'pptx'].contains(ext)) {
      iconColor = const Color(0xFFD24726); 
      iconData = Icons.slideshow;
    } else {
      iconColor = Colors.grey[500]!; 
      iconData = Icons.insert_drive_file;
    }

    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: Colors.white, // Ícones de arquivos Office preservam a folha branca
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 24),
      ),
    );
  }
}