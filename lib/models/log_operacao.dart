class LogOperacao {
  final int id;
  final String tabela;
  final String operacao;
  final DateTime dataHora;

  const LogOperacao({
    required this.id,
    required this.tabela,
    required this.operacao,
    required this.dataHora,
  });

  factory LogOperacao.fromMap(Map<String, Object?> map) {
    return LogOperacao(
      id: map['id'] as int,
      tabela: map['tabela'] as String,
      operacao: map['operacao'] as String,
      dataHora: DateTime.parse(map['data_hora'] as String),
    );
  }
}
