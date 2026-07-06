import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/agendamento_repository.dart';
import '../data/sala_repository.dart';
import '../erros.dart';
import '../models/agendamento.dart';
import '../models/sala.dart';

final _formato = DateFormat('dd/MM/yyyy HH:mm');

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final _repository = AgendamentoRepository();
  late Future<List<Agendamento>> _futuro;

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

  Future<void> _abrirFormulario([Agendamento? agendamento]) async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _FormularioAgendamento(agendamento: agendamento)),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _excluir(Agendamento agendamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir agendamento'),
        content: const Text('Deseja excluir este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _repository.excluir(agendamento.id!);
      _carregar();
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro(erro))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Agendamento>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final agendamentos = snapshot.data ?? [];
          if (agendamentos.isEmpty) {
            return const Center(child: Text('Nenhum agendamento cadastrado'));
          }
          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              itemCount: agendamentos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, indice) {
                final agendamento = agendamentos[indice];
                return ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(agendamento.salaNome ?? ''),
                  subtitle: Text(
                    '${_formato.format(agendamento.dataInicio)} até ${_formato.format(agendamento.dataFim)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _abrirFormulario(agendamento),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _excluir(agendamento),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FormularioAgendamento extends StatefulWidget {
  final Agendamento? agendamento;

  const _FormularioAgendamento({this.agendamento});

  @override
  State<_FormularioAgendamento> createState() => _FormularioAgendamentoState();
}

class _FormularioAgendamentoState extends State<_FormularioAgendamento> {
  final _repository = AgendamentoRepository();
  final _salaRepository = SalaRepository();
  late Future<List<Sala>> _salas;

  int? _salaId;
  DateTime? _inicio;
  DateTime? _fim;
  String? _erro;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _salas = _salaRepository.listar();
    final agendamento = widget.agendamento;
    if (agendamento != null) {
      _salaId = agendamento.salaId;
      _inicio = agendamento.dataInicio;
      _fim = agendamento.dataFim;
    }
  }

  Future<void> _selecionar(bool inicio) async {
    final referencia = inicio ? _inicio : _fim;
    final data = await showDatePicker(
      context: context,
      initialDate: referencia ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (data == null || !mounted) return;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(referencia ?? DateTime.now()),
    );
    if (hora == null) return;
    setState(() {
      final valor = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
      if (inicio) {
        _inicio = valor;
      } else {
        _fim = valor;
      }
    });
  }

  Future<void> _salvar() async {
    if (_salaId == null || _inicio == null || _fim == null) {
      setState(() => _erro = 'Preencha todos os campos');
      return;
    }
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final agendamento = Agendamento(
        id: widget.agendamento?.id,
        salaId: _salaId!,
        dataInicio: _inicio!,
        dataFim: _fim!,
      );
      if (widget.agendamento == null) {
        await _repository.inserir(agendamento);
      } else {
        await _repository.atualizar(agendamento);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      setState(() => _erro = mensagemErro(erro, fallback: 'Verifique as datas informadas'));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agendamento == null ? 'Novo agendamento' : 'Editar agendamento'),
      ),
      body: FutureBuilder<List<Sala>>(
        future: _salas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final salas = snapshot.data ?? [];
          if (salas.isEmpty) {
            return const Center(child: Text('Cadastre uma sala antes de agendar'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<int>(
                initialValue: _salaId,
                decoration: const InputDecoration(labelText: 'Sala'),
                items: salas
                    .map((sala) => DropdownMenuItem(value: sala.id, child: Text(sala.nome)))
                    .toList(),
                onChanged: (valor) => setState(() => _salaId = valor),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.play_arrow),
                title: const Text('Início'),
                subtitle: Text(_inicio == null ? 'Selecionar' : _formato.format(_inicio!)),
                onTap: () => _selecionar(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.stop),
                title: const Text('Fim'),
                subtitle: Text(_fim == null ? 'Selecionar' : _formato.format(_fim!)),
                onTap: () => _selecionar(false),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 8),
                Text(_erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
