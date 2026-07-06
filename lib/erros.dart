String mensagemErro(Object erro, {String fallback = 'Não foi possível concluir a operação'}) {
  final texto = erro.toString();
  if (texto.contains('UNIQUE constraint failed')) {
    return 'Já existe uma sala com esse nome';
  }
  if (texto.contains('Já existe agendamento para esta sala no período informado')) {
    return 'Já existe agendamento para esta sala no período informado';
  }
  if (texto.contains('Não é possível excluir sala com agendamento futuro')) {
    return 'Não é possível excluir sala com agendamento futuro';
  }
  if (texto.contains('FOREIGN KEY constraint failed')) {
    return 'Selecione uma sala válida';
  }
  return fallback;
}
