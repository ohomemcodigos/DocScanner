import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../provedores/documentos_provider.dart';
import '../widgets/barra_pesquisa.dart';
import '../widgets/miniatura_documento.dart';
import 'tela_edicao.dart';
import 'package:share_plus/share_plus.dart';
import 'tela_visualizador.dart';

class TelaInicio extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const TelaInicio({super.key, this.onNavigateTab});
  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  final Set<String> _selecionados = {};

  Future<void> _iniciarEscaneamento(BuildContext context) async {
    if (kIsWeb) return;
    try {
      DocumentScannerOptions options = DocumentScannerOptions(
          documentFormats: {DocumentFormat.pdf},
          mode: ScannerMode.full,
          isGalleryImport: true);
      final documentScanner = DocumentScanner(options: options);
      DocumentScanningResult result = await documentScanner.scanDocument();

      if (result.pdf != null) {
        File file = File(result.pdf!.uri);
        DateTime agora = DateTime.now();
        int bytes = await file.length();
        final novoDoc = Documento(
          id: agora.millisecondsSinceEpoch.toString(),
          nome: 'Scanner_${DateFormat('dd-MM-yyyy_HHmm').format(agora)}',
          data: DateFormat('dd MMM yyyy').format(agora),
          dataReal: agora,
          tamanho: '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB',
          caminho: file.path,
          extensao: 'pdf',
          importadoManualmente: true,
        );

        if (context.mounted) {
          context.read<DocumentosProvider>().adicionarDocumento(novoDoc);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _toggleSelecao(String id) {
    setState(() {
      if (_selecionados.contains(id)) {
        _selecionados.remove(id);
      } else {
        _selecionados.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentosProvider>();
    final listaDocumentos = provider.documentos;
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _selecionados.isNotEmpty
                ? _buildContextualBar()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: BarraPesquisa(
                      corFundo: cardColor,
                      isDark: isDark,
                      readOnly: true, 
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        }
                      },
                    ),
                  ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildActionCarousel(context, isDark),
                  ),
                  ..._buildSliversRecentes(
                      listaDocumentos, cardColor, textColor, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selecionados.isEmpty
          ? FloatingActionButton(
              heroTag: 'btn_camera_inicio',
              onPressed: () => _iniciarEscaneamento(context),
              backgroundColor: const Color(0xFF00C48C),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _buildContextualBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF1A3A6B), boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2))
      ]),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _selecionados.clear();
                });
              }),
          // CORREÇÃO: Envolver o texto em Expanded e remover Spacer
          Expanded(
            child: Text(
              '${_selecionados.length} selecionado(s)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final docs = context.read<DocumentosProvider>().documentos.where((d) => _selecionados.contains(d.id) && d.caminho != null).toList();
              if (docs.isNotEmpty) {
                final arquivos = docs.map((d) => XFile(d.caminho!)).toList();
                await SharePlus.instance.share(ShareParams(files: arquivos));
              }
            },
          ),
          IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF4B4B)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Excluir Documentos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text(
                      'Tem certeza que deseja excluir ${_selecionados.length} documento(s)?\n\nIsso apagará os arquivos fisicamente do seu dispositivo e não poderá ser desfeito.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.read<DocumentosProvider>().removerDocumentos(_selecionados, excluirDoDispositivo: true);
                          setState(() {
                            _selecionados.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Arquivos excluídos com sucesso.')),
                          );
                        },
                        child: const Text('Excluir',
                            style: TextStyle(
                                color: Color(0xFFFF4B4B),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildActionCarousel(BuildContext context, bool isDark) {
    final items = [
      _ActionItem(Icons.document_scanner, 'Digitalizar',
          const Color(0xFF00C48C), () => _iniciarEscaneamento(context)),
      _ActionItem(Icons.image, 'Importar', const Color(0xFF2E6AD4), () {
        if (widget.onNavigateTab != null) {
          widget.onNavigateTab!(1);
        }
      }),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 85,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (c, i) => _buildActionItem(items[i], isDark),
              ),
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          GestureDetector(
            onTap: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(2);
              }
            },
            child: SizedBox(
              width: 70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.transparent : Colors.grey[300]!,
                        )),
                    child: const Icon(Icons.dashboard_customize_rounded,
                        color: Color(0xFFFF4B4B), size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text('Ferramentas',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF1A3A6B)))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(_ActionItem item, bool isDark) {
    return GestureDetector(
      onTap: item.onTap,
      child: SizedBox(
          width: 64,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(item.icon, color: item.color, size: 24)),
            const SizedBox(height: 8),
            Text(item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : const Color(0xFF1A3A6B)))
          ])),
    );
  }

  List<Widget> _buildSliversRecentes(
      List<Documento> recentes, Color cardColor, Color textColor, bool isDark) {
    List<Widget> slivers = [];

    slivers.add(
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recentes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  GestureDetector(
                      onTap: () {
                        if (widget.onNavigateTab != null) {
                          widget.onNavigateTab!(1);
                        }
                      },
                      child: Row(children: [
                        Text('Exibir tudo',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500])),
                        Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey[500])
                      ]))
                ]),
          ),
        ),
      ),
    );

    if (recentes.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Container(
            color: cardColor,
            padding: const EdgeInsets.all(32),
            child: Center(
                child: Text('Nenhum documento recente.',
                    style: TextStyle(color: Colors.grey[400]))),
          ),
        ),
      );
    } else {
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyCardDelegate(
            height: 185.0,
            backgroundColor: cardColor,
            isDark: isDark,
            child: Container(
              alignment: Alignment.center,
              child: _buildExpandedRecentCard(
                  recentes[0], cardColor, textColor, isDark),
            ),
          ),
        ),
      );

      int length = recentes.length > 10 ? 10 : recentes.length;
      if (length > 1) {
        slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  color: cardColor,
                  child: _buildStandardRecentTile(
                      recentes[index + 1], textColor, isDark),
                );
              },
              childCount: length - 1,
            ),
          ),
        );
      }

      slivers.add(
        SliverToBoxAdapter(
          child: Container(
            color: cardColor,
            padding: const EdgeInsets.only(
                top: 24, bottom: 100, left: 16, right: 16),
            child: Center(
              child: Text(
                'Para mais detalhes, vá para a aba de Arquivos ou clique em Exibir tudo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  Widget _buildExpandedRecentCard(
      Documento doc, Color cardColor, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (_selecionados.isNotEmpty) {
          _toggleSelecao(doc.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _selecionados.contains(doc.id)
                ? const Color(0xFF2E6AD4).withValues(alpha: 0.1)
                : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _selecionados.contains(doc.id)
                    ? const Color(0xFF2E6AD4)
                    : (isDark ? Colors.grey[800]! : Colors.grey[200]!))),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MiniaturaDocumento(doc: doc, isDark: isDark, largura: 48, altura: 60),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(doc.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor)),
                      const SizedBox(height: 4),
                      Text('${doc.data}  |  ${doc.tamanho}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]))
                    ])),
                GestureDetector(
                    onTap: () => _toggleSelecao(doc.id),
                    child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                            _selecionados.contains(doc.id)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: _selecionados.contains(doc.id)
                                ? const Color(0xFF2E6AD4)
                                : Colors.grey[400],
                            size: 24))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildCardButton('Compartilhar', isDark, onTap: () async {
                  if (doc.caminho != null) {
                    final arquivo = XFile(doc.caminho!);
                    await SharePlus.instance.share(ShareParams(files: [arquivo], text: doc.nome));
                  }
                })),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildCardButton('Editar', isDark, highlight: true,
                        onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (c) => TelaEdicao(documentoId: doc.id)));
                })),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildCardButton('Visualizar', isDark, onTap: () {
                  if (doc.caminho != null) {
                    if (doc.extensao.toLowerCase() == 'pdf') {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (c) => TelaVisualizador(documento: doc))
                      );
                    } else {
                      OpenFilex.open(doc.caminho!);
                    }
                  }
                })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardRecentTile(Documento doc, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (_selecionados.isNotEmpty) {
          _toggleSelecao(doc.id);
        } else {
          if (doc.caminho != null) {
            if (doc.extensao.toLowerCase() == 'pdf') {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (c) => TelaVisualizador(documento: doc))
              );
            } else {
              OpenFilex.open(doc.caminho!);
            }
          }
        }
      },
      child: Container(
        color: _selecionados.contains(doc.id)
            ? const Color(0xFF2E6AD4).withValues(alpha: 0.1)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MiniaturaDocumento(doc: doc, isDark: isDark, largura: 48, altura: 60),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(doc.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text('${doc.data}  |  ${doc.tamanho}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]))
                ])),
            GestureDetector(
                onTap: () => _toggleSelecao(doc.id),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                        _selecionados.contains(doc.id)
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: _selecionados.contains(doc.id)
                            ? const Color(0xFF2E6AD4)
                            : Colors.grey[400],
                        size: 24))),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton(String text, bool isDark,
      {bool highlight = false, VoidCallback? onTap}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
                color: highlight
                    ? const Color(0xFF00C48C).withValues(alpha: 0.15)
                    : (isDark ? const Color(0xFF2C2C2E) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(text,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            highlight ? FontWeight.bold : FontWeight.w600,
                        color: highlight
                            ? const Color(0xFF00C48C)
                            : (isDark
                                ? Colors.grey[300]
                                : Colors.grey[700]))))));
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _ActionItem(this.icon, this.label, this.color, this.onTap);
}

class _StickyCardDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;
  final bool isDark;

  _StickyCardDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: isDark ? Colors.black45 : Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _StickyCardDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.height != height ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}