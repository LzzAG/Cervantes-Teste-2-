import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/log_repository.dart';
import '../models/log_operacao.dart';

final _formato = DateFormat('dd/MM/yyyy HH:mm:ss');

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final _repository = LogRepository();
  late Future<List<LogOperacao>> _futuro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futuro = _repository.listar();
    });
  }

  Color _cor(BuildContext context, String operacao) {
    final scheme = Theme.of(context).colorScheme;
    switch (operacao) {
      case 'INSERT':
        return Colors.green;
      case 'UPDATE':
        return Colors.orange;
      default:
        return scheme.error;
    }
  }

  String _operacao(String operacao) {
    switch (operacao) {
      case 'INSERT':
        return 'Inclusão';
      case 'UPDATE':
        return 'Alteração';
      default:
        return 'Exclusão';
    }
  }

  String _tabela(String tabela) {
    return tabela == 'sala' ? 'Sala' : 'Agendamento';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LogOperacao>>(
      future: _futuro,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('Nenhuma operação registrada'));
        }
        return RefreshIndicator(
          onRefresh: () async => _carregar(),
          child: ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final log = logs[indice];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _cor(context, log.operacao),
                  child: const Icon(Icons.history, color: Colors.white, size: 20),
                ),
                title: Text('${_operacao(log.operacao)} em ${_tabela(log.tabela)}'),
                subtitle: Text(_formato.format(log.dataHora)),
              );
            },
          ),
        );
      },
    );
  }
}
