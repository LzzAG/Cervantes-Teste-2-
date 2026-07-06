import 'package:intl/intl.dart';

final _formato = DateFormat('yyyy-MM-dd HH:mm:ss');

class Agendamento {
  final int? id;
  final int salaId;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? salaNome;

  const Agendamento({
    this.id,
    required this.salaId,
    required this.dataInicio,
    required this.dataFim,
    this.salaNome,
  });

  factory Agendamento.fromMap(Map<String, Object?> map) {
    return Agendamento(
      id: map['id'] as int?,
      salaId: map['sala_id'] as int,
      dataInicio: DateTime.parse(map['data_inicio'] as String),
      dataFim: DateTime.parse(map['data_fim'] as String),
      salaNome: map['sala_nome'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'sala_id': salaId,
      'data_inicio': _formato.format(dataInicio),
      'data_fim': _formato.format(dataFim),
    };
  }
}
