import '../models/agendamento.dart';
import 'app_database.dart';

class AgendamentoRepository {
  Future<List<Agendamento>> listar() async {
    final db = await AppDatabase.instance.database;
    final linhas = await db.rawQuery('''
      SELECT a.*, s.nome AS sala_nome
      FROM agendamento a
      JOIN sala s ON s.id = a.sala_id
      ORDER BY a.data_inicio
    ''');
    return linhas.map(Agendamento.fromMap).toList();
  }

  Future<void> inserir(Agendamento agendamento) async {
    final db = await AppDatabase.instance.database;
    await db.insert('agendamento', agendamento.toMap());
  }

  Future<void> atualizar(Agendamento agendamento) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'agendamento',
      agendamento.toMap(),
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
  }

  Future<void> excluir(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('agendamento', where: 'id = ?', whereArgs: [id]);
  }
}
