import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img; 
import '../provedores/documentos_provider.dart';

// ============================================================================
// FUNÇÕES GLOBAIS DE FILTROS (Rodam em Isolates / Processamento Paralelo)
// ============================================================================

Uint8List _processarFiltroPB(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;
  img.grayscale(image);
  return img.encodeJpg(image, quality: 90);
}

Uint8List _processarFiltroRealce(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;
  img.adjustColor(image, contrast: 1.5, brightness: 1.2);
  return img.encodeJpg(image, quality: 90);
}

Uint8List _processarFiltroSepia(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;
  img.sepia(image);
  return img.encodeJpg(image, quality: 90);
}

// ============================================================================

class TelaEdicao extends StatefulWidget {
  final String documentoId;
  const TelaEdicao({super.key, required this.documentoId});

  @override
  State<TelaEdicao> createState() => _TelaEdicaoState();
}

class _TelaEdicaoState extends State<TelaEdicao> {
  late TextEditingController _nomeController;
  
  List<Uint8List> _paginasEmMemoria = [];
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final doc = context.read<DocumentosProvider>().documentos.firstWhere((d) => d.id == widget.documentoId);
    _nomeController = TextEditingController(text: doc.nome);
    _extrairPaginas(doc);
  }

  Future<void> _extrairPaginas(Documento doc) async {
    if (doc.caminho == null) return;

    try {
      if (doc.extensao == 'pdf') {
        final document = await PdfDocument.openFile(doc.caminho!);
        final int numPaginas = document.pagesCount;
        List<Uint8List> paginasTemporarias = [];

        for (int i = 1; i <= numPaginas; i++) {
          final page = await document.getPage(i);
          final pageImage = await page.render(
            width: page.width * 2, 
            height: page.height * 2,
            format: PdfPageImageFormat.jpeg,
          );
          
          if (pageImage != null && pageImage.bytes.isNotEmpty) {
            paginasTemporarias.add(pageImage.bytes);
          }
          await page.close();
        }
        await document.close();

        if (mounted) {
          setState(() {
            _paginasEmMemoria = paginasTemporarias;
            _carregando = false;
          });
        }
      } else if (['jpg', 'png', 'jpeg'].contains(doc.extensao)) {
        final bytes = await File(doc.caminho!).readAsBytes();
        if (mounted) {
          setState(() {
            _paginasEmMemoria = [bytes];
            _carregando = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao extrair: $e");
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao ler o documento para edição.')),
        );
      }
    }
  }

  Future<void> _adicionarPaginas() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true, 
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _carregando = true);

        List<Uint8List> novasPaginas = [];
        for (var file in result.files) {
          if (file.path != null) {
            final bytes = await File(file.path!).readAsBytes();
            novasPaginas.add(bytes);
          }
        }

        setState(() {
          _paginasEmMemoria.addAll(novasPaginas);
          _carregando = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${novasPaginas.length} página(s) adicionada(s) com sucesso!')),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao adicionar páginas: $e");
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao importar as imagens.')),
        );
      }
    }
  }

  Future<void> _cortarPagina(int index, bool isDark) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/crop_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(_paginasEmMemoria[index]);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Ajustar Recorte',
            toolbarColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1A3A6B),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            activeControlsWidgetColor: const Color(0xFF2E6AD4),
          ),
          IOSUiSettings(
            title: 'Ajustar Recorte',
            cancelButtonTitle: 'Cancelar',
            doneButtonTitle: 'Confirmar',
          ),
        ],
      );

      if (croppedFile != null) {
        final newBytes = await croppedFile.readAsBytes();
        setState(() {
          _paginasEmMemoria[index] = newBytes;
        });
      }

      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      debugPrint("Erro no Cropper: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o editor de recorte.')),
        );
      }
    }
  }

  // ============================================================================
  // NOVA LÓGICA DE FILTROS: Aplicação individual ou em Lote
  // ============================================================================
  void _abrirMenuFiltros(int? indexSelecionado, bool isDark) {
    // Se o index for nulo (clicou na barra inferior), obriga a ser em todas as páginas
    bool aplicarATodas = indexSelecionado == null; 

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 24),
                  const Text('Aplicar Filtro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // TOGGLE PARA APLICAR A TODAS (Só aparece se o user clicou numa página específica e há mais de 1 pág)
                  if (indexSelecionado != null && _paginasEmMemoria.length > 1)
                    SwitchListTile(
                      activeColor: const Color(0xFF2E6AD4),
                      title: const Text('Aplicar a todas as páginas', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: aplicarATodas,
                      onChanged: (val) {
                        setModalState(() {
                          aplicarATodas = val;
                        });
                      },
                    ),
                    
                  // MENSAGEM SE CLICOU NA BARRA INFERIOR
                  if (indexSelecionado == null && _paginasEmMemoria.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('O filtro será aplicado em todas as ${_paginasEmMemoria.length} páginas.', 
                        style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                    ),

                  const Divider(height: 24),
                  
                  _buildFiltroItem(
                    icone: Icons.document_scanner,
                    corIcone: Colors.grey,
                    titulo: 'Preto e Branco',
                    subtitulo: 'Tons de cinza. Ideal para textos.',
                    onTap: () => _aplicarFiltro(indexSelecionado, _processarFiltroPB, 'Preto e Branco', aplicarATodas),
                  ),
                  const Divider(height: 24),
                  
                  _buildFiltroItem(
                    icone: Icons.auto_fix_high,
                    corIcone: const Color(0xFF00C48C),
                    titulo: 'Realce Mágico',
                    subtitulo: 'Aumenta contraste e clareia o fundo.',
                    onTap: () => _aplicarFiltro(indexSelecionado, _processarFiltroRealce, 'Realce Mágico', aplicarATodas),
                  ),
                  const Divider(height: 24),

                  _buildFiltroItem(
                    icone: Icons.filter_vintage,
                    corIcone: Colors.amber[700]!,
                    titulo: 'Tom Sépia',
                    subtitulo: 'Leitura confortável (Filtro quente).',
                    onTap: () => _aplicarFiltro(indexSelecionado, _processarFiltroSepia, 'Sépia', aplicarATodas),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildFiltroItem({required IconData icone, required Color corIcone, required String titulo, required String subtitulo, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: corIcone.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
          child: Icon(icone, color: corIcone)),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
      onTap: onTap,
    );
  }

  // O Motor que dispara o filtro (Agora suporta Lote ou Individual)
  Future<void> _aplicarFiltro(int? index, Function(Uint8List) funcaoFiltro, String nomeFiltro, bool aplicarATodas) async {
    Navigator.pop(context);
    setState(() => _carregando = true);
    
    try {
      if (aplicarATodas) {
        // Loop em todas as páginas (Demora um pouco mais, mas a tela de loading avisa o user)
        List<Uint8List> paginasFiltradas = [];
        for (var bytesOriginal in _paginasEmMemoria) {
          final newBytes = await compute(funcaoFiltro, bytesOriginal);
          paginasFiltradas.add(newBytes);
        }
        _paginasEmMemoria = paginasFiltradas;
      } else {
        // Só na página que o usuário escolheu
        if (index != null) {
          final originalBytes = _paginasEmMemoria[index];
          final newBytes = await compute(funcaoFiltro, originalBytes);
          _paginasEmMemoria[index] = newBytes;
        }
      }
      
      setState(() {
        _carregando = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filtro "$nomeFiltro" aplicado com sucesso.')));
      }
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao aplicar o filtro.')));
      }
    }
  }

  // ============================================================================
  // NOVA LÓGICA DE SALVAMENTO: Substituir ou Cópia
  // ============================================================================
  void _confirmarSalvamento(Documento docAnterior) {
    if (_paginasEmMemoria.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O documento não pode ficar vazio.')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Salvar Alterações', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Como deseja salvar este documento?\n\n'
          'Substituir irá apagar o original. Salvar como Cópia criará um novo arquivo.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _salvarFicheiro(docAnterior, substituir: false);
            },
            child: const Text('Cópia', style: TextStyle(color: Color(0xFF2E6AD4), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _salvarFicheiro(docAnterior, substituir: true);
            },
            child: const Text('Substituir', style: TextStyle(color: Color(0xFF00C48C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarFicheiro(Documento docAnterior, {required bool substituir}) async {
    setState(() => _salvando = true);

    try {
      final pdf = pw.Document();

      for (var imagemBytes in _paginasEmMemoria) {
        final image = pw.MemoryImage(imagemBytes);
        pdf.addPage(
          pw.Page(
            margin: pw.EdgeInsets.zero,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
      }

      final outputDir = await getApplicationDocumentsDirectory();
      
      // Lida com o nome (Adiciona " - Cópia" se o usuário não mudou o nome manualmente)
      String novoNomeLimpo = _nomeController.text.trim();
      if (!substituir && novoNomeLimpo == docAnterior.nome) {
         novoNomeLimpo = novoNomeLimpo.replaceAll('.pdf', '');
         novoNomeLimpo += ' - Cópia';
      }
      
      if (!novoNomeLimpo.toLowerCase().endsWith('.pdf')) {
        novoNomeLimpo += '.pdf';
      }
      
      final novoFicheiro = File('${outputDir.path}/DocScanner_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await novoFicheiro.writeAsBytes(await pdf.save());

      if (mounted) {
        final docAtualizado = Documento(
          id: novoFicheiro.path,
          nome: novoNomeLimpo,
          data: docAnterior.data,
          tamanho: '${(await novoFicheiro.length() / 1024 / 1024).toStringAsFixed(2)} MB',
          caminho: novoFicheiro.path,
          extensao: 'pdf',
          dataReal: DateTime.now(),
          importadoManualmente: true,
          favorito: docAnterior.favorito
        );
        
        await context.read<DocumentosProvider>().adicionarDocumento(docAtualizado);
        
        if (substituir) {
          await context.read<DocumentosProvider>().removerDocumentos({docAnterior.id}, excluirDoDispositivo: true);
        }

        setState(() => _salvando = false);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento salvo com sucesso!')));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _salvando = false);
      debugPrint("Erro ao salvar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao compilar o PDF.')));
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DocumentosProvider>();
    final doc = provider.documentos.firstWhere((d) => d.id == widget.documentoId);
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1A3A6B)),
        title: TextField(
          controller: _nomeController,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A3A6B), fontSize: 18, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nome do arquivo'),
        ),
        actions: [
          if (_salvando)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: () => _confirmarSalvamento(doc),
              child: const Text('Salvar', style: TextStyle(color: Color(0xFF00C48C), fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Processando...', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.transparent,
                    ),
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.all(16),
                      buildDefaultDragHandles: false, 
                      itemCount: _paginasEmMemoria.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _paginasEmMemoria.removeAt(oldIndex);
                          _paginasEmMemoria.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildPaginaCard(index, isDark, cardColor);
                      },
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFerramenta(Icons.crop, 'Cortar', isDark, () {
                          if (_paginasEmMemoria.length == 1) {
                            _cortarPagina(0, isDark);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Toque no ícone de corte diretamente na página desejada.')),
                            );
                          }
                        }),
                        _buildFerramenta(Icons.add_photo_alternate_outlined, 'Adicionar', isDark, _adicionarPaginas),
                        _buildFerramenta(Icons.auto_fix_high, 'Filtros', isDark, () {
                           // Abre para aplicar a todas (Passando index nulo)
                           _abrirMenuFiltros(null, isDark);
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildPaginaCard(int index, bool isDark, Color cardColor) {
    return ReorderableDelayedDragStartListener(
      key: ValueKey('pagina_$index'),
      index: index,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Página ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey[800])),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: Color(0xFF00C48C)),
                      tooltip: 'Filtros nesta página',
                      onPressed: () => _abrirMenuFiltros(index, isDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.crop, color: Color(0xFF2E6AD4)),
                      tooltip: 'Cortar esta página',
                      onPressed: () => _cortarPagina(index, isDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFFF4B4B)),
                      tooltip: 'Excluir esta página',
                      onPressed: () {
                        setState(() {
                          _paginasEmMemoria.removeAt(index);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            GestureDetector(
              onTap: () => _cortarPagina(index, isDark),
              child: Container(
                height: 400, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black54 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _paginasEmMemoria[index],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFerramenta(IconData icon, String label, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF1A3A6B), size: 28),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[700])),
        ],
      ),
    );
  }
}