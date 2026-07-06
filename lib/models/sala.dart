class Sala {
  final int? id;
  final String nome;

  const Sala({this.id, required this.nome});

  factory Sala.fromMap(Map<String, Object?> map) {
    return Sala(
      id: map['id'] as int?,
      nome: map['nome'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
    };
  }
}
