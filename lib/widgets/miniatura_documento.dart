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
    if (['jpg', 'png', 'jpeg'].contains(doc.extensao) &&
        doc.caminho != null &&
        !kIsWeb) {
      return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(File(doc.caminho!),
              width: largura,
              height: altura,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image)));
    }

    if (doc.extensao == 'pdf' && doc.caminho != null && !kIsWeb) {
      return FutureBuilder<PdfDocument>(
        future: PdfDocument.openFile(doc.caminho!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder<PdfPageImage?>(
              future: snapshot.data!.getPage(1).then((page) =>
                  page.render(width: page.width, height: page.height)),
              builder: (ctx, snapImg) {
                if (snapImg.hasData && snapImg.data != null) {
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(snapImg.data!.bytes,
                          width: largura, height: altura, fit: BoxFit.cover));
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
    final isPdf = doc.extensao.toLowerCase() == 'pdf';
    return Container(
        width: largura,
        height: altura,
        decoration: BoxDecoration(
            color: isPdf
                ? const Color(0xFFFF4B4B).withValues(alpha: 0.1)
                : (isDark ? const Color(0xFF2C2C2E) : Colors.grey[100]),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: isDark ? Colors.transparent : Colors.grey[300]!)),
        child: Center(
            child: Icon(isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? const Color(0xFFFF4B4B) : Colors.grey[400],
                size: 24)));
  }
}