import '../models/sala.dart';
import 'app_database.dart';

class SalaRepository {
  Future<List<Sala>> listar() async {
    final db = await AppDatabase.instance.database;
    final linhas = await db.query('sala', orderBy: 'nome');
    return linhas.map(Sala.fromMap).toList();
  }

  Future<void> inserir(Sala sala) async {
    final db = await AppDatabase.instance.database;
    await db.insert('sala', sala.toMap());
  }

  Future<void> atualizar(Sala sala) async {
    final db = await AppDatabase.instance.database;
    await db.update('sala', sala.toMap(), where: 'id = ?', whereArgs: [sala.id]);
  }

  Future<void> excluir(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('sala', where: 'id = ?', whereArgs: [id]);
  }
}
