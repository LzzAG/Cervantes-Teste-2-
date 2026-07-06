# Agendamento de Salas de Coworking

Aplicação em Flutter com banco SQLite para cadastro de salas e agendamentos, com todas as regras de negócio validadas no próprio banco de dados.

## Regras (aplicadas exclusivamente no banco)

- Nome da sala obrigatório e único.
- Todos os campos do agendamento obrigatórios, com relacionamento obrigatório à sala.
- Data/hora de fim maior que a de início.
- Sem sobreposição de agendamentos para a mesma sala.
- Sala com agendamento futuro não pode ser excluída.
- Toda operação de `INSERT`, `UPDATE` e `DELETE` nas tabelas principais é registrada em `log_operacao`.

As validações são feitas por `constraints` e `triggers` definidas em [database/schema.sql](database/schema.sql).

## Estrutura

- `database/schema.sql` — script de criação das tabelas e triggers.
- `lib/models` — modelos de dados.
- `lib/data` — abertura do banco e repositórios.
- `lib/screens` — telas de salas, agendamentos e log de operações.

## Como executar

```bash
flutter pub get
flutter run -d windows
```
