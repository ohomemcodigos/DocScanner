import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../provedores/documentos_provider.dart';
import '../widgets/barra_pesquisa.dart';
import '../widgets/miniatura_documento.dart';

class TelaDocumentos extends StatefulWidget {
  const TelaDocumentos({super.key});
  @override
  State<TelaDocumentos> createState() => _TelaDocumentosState();
}

class _TelaDocumentosState extends State<TelaDocumentos> {
  final Set<String> _selecionados = {};
  String _termoBusca = '';

  final Map<String, bool> _filtros = {
    'pdf': true,
    'doc/docx': true,
    'xls/xlsx': true,
    'ppt/pptx': true,
    'jpg/png': true,
  };

  void _abrirFiltros() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true, // Permite que o menu se adapte ao tamanho da tela
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            bool todosAtivos = _filtros.values.every((v) => v);
            final isDark = context.read<DocumentosProvider>().isDarkMode;
            
            // SUBSTITUÍDO: Usamos Material em vez de Container para o Ripple Effect funcionar
            return Material(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: SingleChildScrollView( // EVITA O OVERFLOW DE 38 PIXELS
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filtrar por formato',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Selecionar Todos', style: TextStyle(fontWeight: FontWeight.w600)),
                        value: todosAtivos,
                        activeColor: const Color(0xFF2E6AD4),
                        onChanged: (val) {
                          setModalState(() {
                            _filtros.updateAll((key, value) => val ?? true);
                          });
                          setState(() {});
                        },
                      ),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      ..._filtros.keys.map((tipo) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(tipo.toUpperCase(), style: const TextStyle(fontSize: 15)),
                            value: _filtros[tipo],
                            activeColor: const Color(0xFF2E6AD4),
                            onChanged: (val) {
                              setModalState(() {
                                _filtros[tipo] = val ?? false;
                              });
                              setState(() {});
                            },
                          )),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void _abrirModalOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Permite adaptação do menu
      builder: (context) {
        final isDark = context.read<DocumentosProvider>().isDarkMode;
        
        // SUBSTITUÍDO: Usamos Material em vez de Container aqui também
        return Material(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: SingleChildScrollView( // EVITA OVERFLOW
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4)
                    ),
                  ),
                  ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF34C759).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.file_upload_outlined,
                            color: Color(0xFF34C759))),
                    title: const Text('Importar Imagens/Arquivos', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _importarManual();
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: const Color(0xFF2E6AD4).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.document_scanner_outlined,
                            color: Color(0xFF2E6AD4))),
                    title: const Text('Escanear Documento', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      _escanearNativo();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Future<void> _escanearNativo() async {
    if (kIsWeb) return;
    try {
      final docScanner = DocumentScanner(
          options: DocumentScannerOptions(
              documentFormats: {DocumentFormat.pdf},
              mode: ScannerMode.full,
              isGalleryImport: true));
      DocumentScanningResult result = await docScanner.scanDocument();
      if (result.pdf != null && mounted) {
        File file = File(result.pdf!.uri);
        DateTime agora = DateTime.now();
        context.read<DocumentosProvider>().adicionarDocumento(Documento(
              id: agora.millisecondsSinceEpoch.toString(),
              nome: 'Scan_${DateFormat('ddMMyy_HHmm').format(agora)}',
              data: DateFormat('dd MMM yyyy').format(agora),
              dataReal: agora,
              tamanho:
                  '${(await file.length() / 1024 / 1024).toStringAsFixed(2)} MB',
              caminho: file.path,
              extensao: 'pdf',
            ));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _importarManual() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'jpg', 'png']);
        
    if (result != null && mounted) {
      PlatformFile file = result.files.single;
      DateTime agora = DateTime.now();
      context.read<DocumentosProvider>().adicionarDocumento(Documento(
            id: agora.millisecondsSinceEpoch.toString(),
            nome: file.name,
            data: DateFormat('dd MMM yyyy').format(agora),
            dataReal: agora,
            tamanho: '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
            caminho: kIsWeb ? null : file.path,
            bytes: kIsWeb ? file.bytes : null,
            extensao: file.extension ?? '',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentosProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A3A6B);

    List<Documento> listaFiltrada = provider.documentos.where((doc) {
      if (_termoBusca.isNotEmpty &&
          !doc.nome.toLowerCase().contains(_termoBusca.toLowerCase())) {
        return false;
      }
      if (doc.extensao == 'pdf' && !_filtros['pdf']!) {
        return false;
      }
      if (['doc', 'docx'].contains(doc.extensao) && !_filtros['doc/docx']!) {
        return false;
      }
      if (['xls', 'xlsx'].contains(doc.extensao) && !_filtros['xls/xlsx']!) {
        return false;
      }
      if (['ppt', 'pptx'].contains(doc.extensao) && !_filtros['ppt/pptx']!) {
        return false;
      }
      if (['jpg', 'png', 'jpeg'].contains(doc.extensao) &&
          !_filtros['jpg/png']!) {
        return false;
      }
      return true;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabeçalho Dinâmico (Muda suavemente entre Pesquisa e Ações de Seleção)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _selecionados.isNotEmpty
                    ? _buildContextualBar(provider)
                    : _buildHeaderPesquisa(isDark, cardColor),
              ),

              // 2. Barra de Ferramentas (Filtros, Grid/List, Ordernar)
              _buildFerramentasRow(provider, isDark, textColor),

              // 3. Abas (Tabs) Elegantes
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 1))
                ),
                child: const TabBar(
                  labelColor: Color(0xFF2E6AD4),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF2E6AD4),
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                  tabs: [
                    Tab(text: 'Todos os Arquivos'),
                    Tab(text: 'Favoritos')
                  ],
                ),
              ),

              // 4. Conteúdo (A Lista/Grelha)
              Expanded(
                child: TabBarView(
                  children: [
                    _buildConteudo(listaFiltrada, provider.isGridView, cardColor, textColor, isDark, iconVazio: Icons.folder_open_rounded),
                    _buildConteudo(
                        listaFiltrada.where((d) => d.favorito).toList(),
                        provider.isGridView, cardColor, textColor, isDark,
                        vaziaMsg: 'Você ainda não possui favoritos.',
                        iconVazio: Icons.star_border_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _selecionados.isEmpty
            ? FloatingActionButton(
                onPressed: () => _abrirModalOpcoes(context),
                backgroundColor: const Color(0xFF2E6AD4),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
            : null,
      ),
    );
  }

  Widget _buildHeaderPesquisa(bool isDark, Color cardColor) {
    return Container(
      key: const ValueKey('header_pesquisa'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: BarraPesquisa(
        corFundo: isDark ? const Color(0xFF2C2C2E) : cardColor,
        isDark: isDark,
        comSombra: true,
        onChanged: (val) {
          setState(() {
            _termoBusca = val;
          });
        },
      ),
    );
  }

  Widget _buildContextualBar(DocumentosProvider provider) {
    return Container(
      key: const ValueKey('header_selecao'),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A6B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1A3A6B).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _selecionados.clear();
                });
              }),
          Text('${_selecionados.length} selecionados',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.visibility_off, color: Colors.white70, size: 20),
            tooltip: 'Ocultar documento',
            onPressed: () {
              provider.ocultarDocumentos(_selecionados);
              setState(() {
                _selecionados.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Documentos ocultados com sucesso.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFFF4B4B), size: 20),
            onPressed: () {
              provider.removerDocumentos(_selecionados);
              setState(() {
                _selecionados.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFerramentasRow(DocumentosProvider provider, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          ActionChip(
            label: const Row(children: [
              Text('Tipos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16)
            ]),
            backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            onPressed: _abrirFiltros,
          ),
          const Spacer(),
          IconButton(
              icon: Icon(
                  provider.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  color: Colors.grey[500], size: 22),
              onPressed: () => provider.toggleLayout()),
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded, color: Colors.grey[500], size: 22),
            onSelected: (val) => provider.ordenarPor(val),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'hora', child: Text('Mais Recentes')),
              const PopupMenuItem(value: 'az', child: Text('Nome (A - Z)')),
              const PopupMenuItem(value: 'za', child: Text('Nome (Z - A)'))
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo(List<Documento> docs, bool isGrid, Color cardColor,
      Color textColor, bool isDark,
      {String vaziaMsg = 'Nenhum arquivo encontrado.', required IconData iconVazio}) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconVazio, size: 64, color: isDark ? Colors.grey[800] : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(vaziaMsg, style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        )
      );
    }
    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.82),
        itemCount: docs.length,
        itemBuilder: (context, index) => _buildCard(
            docs[index], cardColor, textColor,
            isGrid: true, isDark: isDark),
      );
    }
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        itemBuilder: (context, index) => _buildCard(
            docs[index], cardColor, textColor,
            isGrid: false, isDark: isDark));
  }

  Widget _buildCard(Documento doc, Color cardColor, Color textColor,
      {required bool isGrid, required bool isDark}) {
    bool isSel = _selecionados.contains(doc.id);
    
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _selecionados.add(doc.id);
        });
      },
      onTap: () {
        if (_selecionados.isNotEmpty) {
          setState(() {
            isSel ? _selecionados.remove(doc.id) : _selecionados.add(doc.id);
          });
        } else {
          if (doc.caminho != null) OpenFilex.open(doc.caminho!);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
        padding: isGrid ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
            color: isSel 
                ? const Color(0xFF2E6AD4).withValues(alpha: 0.08) 
                : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSel
                    ? const Color(0xFF2E6AD4)
                    : (isDark ? Colors.grey[800]! : Colors.transparent),
                width: isSel ? 2 : 1),
            boxShadow: (!isDark && !isSel) ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
            ] : []
        ),
        child: isGrid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MiniaturaDocumento(doc: doc, isDark: isDark, largura: 54, altura: 68),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(doc.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                      GestureDetector(
                        onTap: () => context
                            .read<DocumentosProvider>()
                            .alternarFavorito(doc.id),
                        child: Icon(
                          doc.favorito ? Icons.star_rounded : Icons.star_border_rounded,
                          color: doc.favorito ? Colors.amber : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(doc.tamanho,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                ],
              )
            : Row(
                children: [
                  MiniaturaDocumento(doc: doc, isDark: isDark, largura: 48, altura: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${doc.data} • ${doc.tamanho}',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          doc.favorito ? Icons.star_rounded : Icons.star_border_rounded,
                          color: doc.favorito ? Colors.amber : Colors.grey[400],
                        ),
                        onPressed: () => context
                            .read<DocumentosProvider>()
                            .alternarFavorito(doc.id),
                      ),
                      if (isSel)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(Icons.check_circle, color: Color(0xFF2E6AD4)),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
