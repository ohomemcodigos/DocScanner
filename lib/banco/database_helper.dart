import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../provedores/documentos_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('docscanner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 2, // Aumentámos a versão para 2
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // Adicionámos o script de atualização
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE documentos (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        data TEXT NOT NULL,
        tamanho TEXT NOT NULL,
        caminho TEXT,
        extensao TEXT NOT NULL,
        favorito INTEGER NOT NULL,
        importadoManualmente INTEGER NOT NULL,
        dataReal INTEGER NOT NULL,
        oculto INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Se o utilizador já tiver o app instalado (v1), isto atualiza a tabela sem apagar dados
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE documentos ADD COLUMN oculto INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> inserirDocumento(Documento doc) async {
    final db = await instance.database;
    await db.insert(
      'documentos',
      {
        'id': doc.id,
        'nome': doc.nome,
        'data': doc.data,
        'tamanho': doc.tamanho,
        'caminho': doc.caminho,
        'extensao': doc.extensao,
        'favorito': doc.favorito ? 1 : 0,
        'importadoManualmente': doc.importadoManualmente ? 1 : 0,
        'dataReal': doc.dataReal.millisecondsSinceEpoch,
        'oculto': doc.oculto ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Documento>> lerTodosDocumentos() async {
    final db = await instance.database;
    final result = await db.query('documentos', orderBy: 'dataReal DESC');

    return result.map((json) => Documento(
      id: json['id'] as String,
      nome: json['nome'] as String,
      data: json['data'] as String,
      tamanho: json['tamanho'] as String,
      caminho: json['caminho'] as String?,
      extensao: json['extensao'] as String,
      favorito: (json['favorito'] as int) == 1,
      importadoManualmente: (json['importadoManualmente'] as int) == 1,
      dataReal: DateTime.fromMillisecondsSinceEpoch(json['dataReal'] as int),
      oculto: (json['oculto'] != null && json['oculto'] as int == 1),
    )).toList();
  }

  Future<void> deletarDocumento(String id) async {
    final db = await instance.database;
    await db.delete('documentos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> atualizarFavorito(String id, bool favorito) async {
    final db = await instance.database;
    await db.update('documentos', {'favorito': favorito ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> atualizarNome(String id, String novoNome) async {
    final db = await instance.database;
    await db.update('documentos', {'nome': novoNome}, where: 'id = ?', whereArgs: [id]);
  }

  // Novo método para ocultar ou restaurar no banco de dados
  Future<void> atualizarOculto(String id, bool oculto) async {
    final db = await instance.database;
    await db.update('documentos', {'oculto': oculto ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }
}