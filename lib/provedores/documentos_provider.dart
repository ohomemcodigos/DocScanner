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
    this.oculto = false, // Valor padrão deve ser falso
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
  
  // O getter agora filtra o que a interface consegue "enxergar", ignorando os ocultos
  List<Documento> get documentos => _documentos.where((d) => !d.oculto).toList();

  Future<void> _inicializarDados() async {
    if (!kIsWeb) {
      final docsSalvos = await DatabaseHelper.instance.lerTodosDocumentos();
      
      // Revogação Passiva: Verifica se o usuário tirou a permissão nas Configurações do Android
      _permissaoAcessoArquivos = await Permission.storage.isGranted || 
                                 await Permission.manageExternalStorage.isGranted;

      if (!_permissaoAcessoArquivos) {
        // Se o app iniciar sem permissão, carrega apenas os que tiveram input explícito (manuais)
        _documentos.addAll(docsSalvos.where((d) => d.importadoManualmente));
        
        // Limpa do banco de dados qualquer arquivo que tenha ficado órfão da varredura anterior
        final autoDocs = docsSalvos.where((d) => !d.importadoManualmente).toList();
        for(var doc in autoDocs) {
           await DatabaseHelper.instance.deletarDocumento(doc.id);
        }
      } else {
        _documentos.addAll(docsSalvos);
      }
      
      notifyListeners();
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
      
      // Revogação Ativa: Usuário renegou o acesso no APP. Esquecer tudo que não foi manual.
      final idsParaRemover = _documentos
          .where((doc) => !doc.importadoManualmente)
          .map((doc) => doc.id)
          .toSet();

      // Remove da interface
      _documentos.removeWhere((doc) => !doc.importadoManualmente);
      
      // Remove do banco de dados para proteger a privacidade
      for (var id in idsParaRemover) {
        await DatabaseHelper.instance.deletarDocumento(id);
      }
    }
    notifyListeners();
  }

  // Novo método: Ocultar
  Future<void> ocultarDocumentos(Set<String> ids) async {
    for (var doc in _documentos) {
      if (ids.contains(doc.id)) {
        doc.oculto = true;
        if (!kIsWeb) {
          await DatabaseHelper.instance.atualizarOculto(doc.id, true);
        }
      }
    }
    notifyListeners();
  }

  Future<void> adicionarDocumento(Documento doc) async {
    // Restaurar Ocultos: Verifica se este caminho já existe no nosso ecossistema
    final index = _documentos.indexWhere((d) => d.caminho != null && d.caminho == doc.caminho);

    if (index != -1) {
      // O ficheiro já existe. Se estava oculto, o utilizador está a pedir para o trazer de volta à vida.
      if (_documentos[index].oculto) {
        _documentos[index].oculto = false;
        _documentos[index].importadoManualmente = true;
        notifyListeners();
        if (!kIsWeb) {
          await DatabaseHelper.instance.atualizarOculto(_documentos[index].id, false);
        }
      }
      return; // Previne que ficheiros duplicados entrem na lista
    }

    _documentos.insert(0, doc);
    notifyListeners();
    
    if (!kIsWeb) {
      await DatabaseHelper.instance.inserirDocumento(doc);
    }
  }

  Future<void> removerDocumentos(Set<String> ids) async {
    _documentos.removeWhere((doc) => ids.contains(doc.id));
    notifyListeners();
    
    if (!kIsWeb) {
      for (var id in ids) {
        await DatabaseHelper.instance.deletarDocumento(id);
      }
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
      _documentos
          .sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    } else if (criterio == 'za') {
      _documentos
          .sort((a, b) => b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
    }
    notifyListeners();
  }

  Future<void> varrerDocumentosLocais() async {
    if (kIsWeb) return;

    List<Directory> pastas = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Documents'),
    ];

    for (var pasta in pastas) {
      if (pasta.existsSync()) {
        try {
          var arquivos = pasta.listSync(recursive: false);
          for (var arquivo in arquivos) {
            if (arquivo is File) {
              String extensao = arquivo.path.split('.').last.toLowerCase();
              
              // Filtro Blindado: Apenas documentos válidos passam aqui. Mídias são ignoradas.
              if (['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(extensao)) {
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
                    importadoManualmente: false, // Flag que indica varredura automática
                    oculto: false,
                  );

                  _documentos.add(novoDoc);
                  await DatabaseHelper.instance.inserirDocumento(novoDoc);
                }
              }
            }
          }
        } catch (e) {
          debugPrint("Erro ao ler pasta: $e");
        }
      }
    }
    ordenarPor('hora');
  }
}