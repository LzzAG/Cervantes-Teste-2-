import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _abrir();
  }

  Future<Database> _abrir() async {
    sqfliteFfiInit();
    final diretorio = await databaseFactoryFfi.getDatabasesPath();
    final caminho = p.join(diretorio, 'coworking.db');
    return databaseFactoryFfi.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) async {
          final script = await rootBundle.loadString('database/schema.sql');
          for (final comando in _separarComandos(script)) {
            await db.execute(comando);
          }
        },
      ),
    );
  }

  List<String> _separarComandos(String script) {
    final comandos = <String>[];
    final atual = StringBuffer();
    var nivel = 0;
    for (final linha in script.split('\n')) {
      final texto = linha.trim();
      if (texto.isEmpty) continue;
      final maiusculo = texto.toUpperCase();
      if (maiusculo == 'BEGIN') nivel++;
      atual.writeln(linha);
      if (maiusculo == 'END;') nivel--;
      if (nivel == 0 && texto.endsWith(';')) {
        comandos.add(atual.toString().trim());
        atual.clear();
      }
    }
    return comandos;
  }
}
