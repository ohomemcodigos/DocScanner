import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import '../banco/database_helper.dart';


class Documento {
  final String id;
  String nome;
  final String data;
  final String tamanho;
  final String? caminho;
  final Uint8List? bytes;
  final String extensao;
  bool favorito;
  bool importadoManualmente;
  DateTime dataReal;
  bool oculto;

  Documento({
    required this.id,
    required this.nome,
    required this.data,
    required this.tamanho,
    this.caminho,
    this.bytes,
    required this.extensao,
    this.favorito = false,
    this.importadoManualmente = true,
    required this.dataReal,
    this.oculto = false, 
  });
}

class DocumentosProvider extends ChangeNotifier {
  final List<Documento> _documentos = [];
  bool _isDarkMode = false;
  bool _isGridView = false;
  bool _permissaoAcessoArquivos = false;

  DocumentosProvider() {
    _inicializarDados();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isGridView => _isGridView;
  bool get permissaoAcessoArquivos => _permissaoAcessoArquivos;

  List<Documento> get documentos => _documentos.where((d) => !d.oculto).toList();

  Future<void> _inicializarDados() async {
    if (!kIsWeb) {
      final docsSalvos = await DatabaseHelper.instance.lerTodosDocumentos();

      _permissaoAcessoArquivos = await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted;

      if (!_permissaoAcessoArquivos) {
        _documentos.addAll(docsSalvos.where((d) => d.importadoManualmente));
        
        final autoDocs = docsSalvos.where((d) => !d.importadoManualmente).toList();
        for (var doc in autoDocs) {
          await DatabaseHelper.instance.deletarDocumento(doc.id);
        }
      } else {
        _documentos.addAll(docsSalvos);
        
        // --- CORREÇÃO DA SINCRONIZAÇÃO FRIA AQUI ---
        // Varre silenciosamente os novos downloads sempre que o app abrir
        varrerDocumentosLocais(); 
      }

      // Garante que a ordem inicial seja sempre a mais recente
      _documentos.sort((a, b) => b.dataReal.compareTo(a.dataReal));
      notifyListeners();
    }
  }

  Future<void> recarregarDados() async {
    if (kIsWeb) return;
    try {
      final docsSalvos = await DatabaseHelper.instance.lerTodosDocumentos();
      
      _documentos.clear();
      
      if (!_permissaoAcessoArquivos) {
        _documentos.addAll(docsSalvos.where((d) => d.importadoManualmente));
      } else {
        _documentos.addAll(docsSalvos);
      }
      
      _documentos.sort((a, b) => b.dataReal.compareTo(a.dataReal));
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao recarregar dados: $e");
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleLayout() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> alternarPermissaoArquivos(bool conceder) async {
    if (kIsWeb) {
      _permissaoAcessoArquivos = false;
      notifyListeners();
      return;
    }

    if (conceder) {
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        _permissaoAcessoArquivos = true;
        await varrerDocumentosLocais();
      } else {
        _permissaoAcessoArquivos = false;
      }
    } else {
      _permissaoAcessoArquivos = false;
      
      final idsParaRemover = _documentos
          .where((doc) => !doc.importadoManualmente)
          .map((doc) => doc.id)
          .toSet();

      _documentos.removeWhere((doc) => !doc.importadoManualmente);

      for (var id in idsParaRemover) {
        await DatabaseHelper.instance.deletarDocumento(id);
      }
    }
    notifyListeners();
  }

  // ==========================================================================
  // CORREÇÃO: Clonagem da lista para proteger contra "Clear" instantâneo da UI
  // ==========================================================================
  Future<void> ocultarDocumentos(Set<String> ids) async {
    final Set<String> idsSeguros = Set.from(ids); // CLONE DE SEGURANÇA
    
    for (var doc in _documentos) {
      if (idsSeguros.contains(doc.id)) {
        doc.oculto = true;
        if (!kIsWeb) {
          await DatabaseHelper.instance.atualizarOculto(doc.id, true);
        }
      }
    }
    notifyListeners();
  }

  Future<void> adicionarDocumento(Documento doc) async {
    final index = _documentos.indexWhere((d) => d.caminho != null && d.caminho == doc.caminho);

    if (index != -1) {
      if (_documentos[index].oculto) {
        _documentos[index].oculto = false;
        _documentos[index].importadoManualmente = true;
        notifyListeners();
        
        if (!kIsWeb) {
          await DatabaseHelper.instance.atualizarOculto(_documentos[index].id, false);
        }
      }
      return;
    }

    _documentos.insert(0, doc);
    notifyListeners();
    
    if (!kIsWeb) {
      await DatabaseHelper.instance.inserirDocumento(doc);
    }
  }

  // ==========================================================================
  // CORREÇÃO: Clonagem da lista na Exclusão
  // ==========================================================================
  Future<void> removerDocumentos(Set<String> ids, {bool excluirDoDispositivo = false}) async {
    final Set<String> idsSeguros = Set.from(ids); // CLONE DE SEGURANÇA

    if (!kIsWeb && excluirDoDispositivo) {
      for (var id in idsSeguros) {
        try {
          final index = _documentos.indexWhere((d) => d.id == id);
          if (index != -1) {
            final doc = _documentos[index];
            if (doc.caminho != null) {
              final file = File(doc.caminho!);
              if (await file.exists()) {
                await file.delete(); 
              }
            }
          }
        } catch (e) {
          debugPrint("Erro ao excluir arquivo físico: $e");
        }
      }
    }

    _documentos.removeWhere((doc) => idsSeguros.contains(doc.id));
    notifyListeners();

    if (!kIsWeb) {
      for (var id in idsSeguros) {
        try {
          await DatabaseHelper.instance.deletarDocumento(id);
        } catch (e) {
          debugPrint("Erro no banco de dados ao excluir: $e");
        }
      }
      await recarregarDados();
    }
  }

  Future<void> renomearDocumento(String id, String novoNome) async {
    final index = _documentos.indexWhere((doc) => doc.id == id);

    if (index != -1) {
      _documentos[index].nome = novoNome;
      notifyListeners();
      
      if (!kIsWeb) {
        await DatabaseHelper.instance.atualizarNome(id, novoNome);
      }
    }
  }

  Future<void> alternarFavorito(String id) async {
    final index = _documentos.indexWhere((doc) => doc.id == id);

    if (index != -1) {
      _documentos[index].favorito = !_documentos[index].favorito;
      notifyListeners();
      
      if (!kIsWeb) {
        await DatabaseHelper.instance.atualizarFavorito(id, _documentos[index].favorito);
      }
    }
  }

  void ordenarPor(String criterio) {
    if (criterio == 'hora') {
      _documentos.sort((a, b) => b.dataReal.compareTo(a.dataReal));
    } else if (criterio == 'az') {
      _documentos.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    } else if (criterio == 'za') {
      _documentos.sort((a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
    }
    notifyListeners();
  }

  // ==========================================================================
  // CORREÇÃO: Varredura profunda (Subpastas) e inteligente
  // ==========================================================================
  Future<void> varrerDocumentosLocais() async {
    if (kIsWeb) return;

    List<Directory> pastas = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Documents'),
    ];

    bool encontrouNovo = false;

    for (var pasta in pastas) {
      if (pasta.existsSync()) {
        try {
          // recursive: true permite achar PDFs escondidos em subpastas como 'Telegram'
          var arquivos = pasta.listSync(recursive: true, followLinks: false);
          
          for (var arquivo in arquivos) {
            if (arquivo is File) {
              String extensao = arquivo.path.split('.').last.toLowerCase();

              if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extensao)) {
                
                // Evita duplicados verificando o caminho
                if (!_documentos.any((d) => d.caminho == arquivo.path)) {
                  int bytes = arquivo.lengthSync();
                  DateTime dataModificacao = arquivo.lastModifiedSync();

                  final novoDoc = Documento(
                    id: arquivo.path,
                    nome: arquivo.path.split('/').last,
                    data: '${dataModificacao.day.toString().padLeft(2, '0')}/${dataModificacao.month.toString().padLeft(2, '0')}/${dataModificacao.year}',
                    dataReal: dataModificacao,
                    tamanho: '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB',
                    caminho: arquivo.path,
                    extensao: extensao,
                    importadoManualmente: false, 
                    oculto: false,
                  );

                  _documentos.add(novoDoc);
                  await DatabaseHelper.instance.inserirDocumento(novoDoc);
                  encontrouNovo = true;
                }
              }
            }
          }
        } catch (e) {
          // Proteção contra falhas em pastas bloqueadas pelo Android
          debugPrint("Erro ao ler pasta ou subpasta: $e");
        }
      }
    }

    if (encontrouNovo) {
      ordenarPor('hora');
    }
  }
}