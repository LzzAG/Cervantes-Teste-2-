import '../models/log_operacao.dart';
import 'app_database.dart';

class LogRepository {
  Future<List<LogOperacao>> listar() async {
    final db = await AppDatabase.instance.database;
    final linhas = await db.query('log_operacao', orderBy: 'id DESC');
    return linhas.map(LogOperacao.fromMap).toList();
  }
}
