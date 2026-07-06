import 'package:flutter/material.dart';

import '../data/sala_repository.dart';
import '../erros.dart';
import '../models/sala.dart';

class SalasScreen extends StatefulWidget {
  const SalasScreen({super.key});

  @override
  State<SalasScreen> createState() => _SalasScreenState();
}

class _SalasScreenState extends State<SalasScreen> {
  final _repository = SalaRepository();
  late Future<List<Sala>> _futuro;

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

  Future<void> _abrirFormulario([Sala? sala]) async {
    final salvou = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioSala(repository: _repository, sala: sala),
    );
    if (salvou == true) _carregar();
  }

  Future<void> _excluir(Sala sala) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir sala'),
        content: Text('Deseja excluir a sala "${sala.nome}"?'),
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
      await _repository.excluir(sala.id!);
      _carregar();
    } catch (erro) {
      if (mounted) _avisar(mensagemErro(erro));
    }
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Sala>>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final salas = snapshot.data ?? [];
          if (salas.isEmpty) {
            return const Center(child: Text('Nenhuma sala cadastrada'));
          }
          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              itemCount: salas.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, indice) {
                final sala = salas[indice];
                return ListTile(
                  leading: const Icon(Icons.meeting_room),
                  title: Text(sala.nome),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _abrirFormulario(sala),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _excluir(sala),
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

class _FormularioSala extends StatefulWidget {
  final SalaRepository repository;
  final Sala? sala;

  const _FormularioSala({required this.repository, this.sala});

  @override
  State<_FormularioSala> createState() => _FormularioSalaState();
}

class _FormularioSalaState extends State<_FormularioSala> {
  final _controller = TextEditingController();
  String? _erro;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.sala?.nome ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final nome = _controller.text.trim();
      if (widget.sala == null) {
        await widget.repository.inserir(Sala(nome: nome));
      } else {
        await widget.repository.atualizar(Sala(id: widget.sala!.id, nome: nome));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      setState(() => _erro = mensagemErro(erro, fallback: 'Informe o nome da sala'));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.sala == null ? 'Nova sala' : 'Editar sala'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Nome',
          errorText: _erro,
        ),
        onSubmitted: (_) => _salvar(),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
