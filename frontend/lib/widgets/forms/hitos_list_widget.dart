import 'package:flutter/material.dart';

class HitosListWidget extends StatefulWidget {
  final List<Hito> initialHitos;
  final Function(List<Hito>) onHitosChanged;

  const HitosListWidget({
    super.key,
    required this.initialHitos,
    required this.onHitosChanged,
  });

  @override
  State<HitosListWidget> createState() => _HitosListWidgetState();
}

class _HitosListWidgetState extends State<HitosListWidget> {
  late List<Hito> _hitos;

  @override
  void initState() {
    super.initState();
    _hitos = List.from(widget.initialHitos);
  }

  @override
  void didUpdateWidget(HitosListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si cambió la longitud de la lista
    if (oldWidget.initialHitos.length != widget.initialHitos.length) {
      setState(() {
        _hitos = List.from(widget.initialHitos);
      });
    }
  }

  void _addHito() {
    setState(() {
      _hitos.add(Hito(
        id: 'hito${_hitos.length + 1}',
        title: '',
        description: '',
      ));
    });
    widget.onHitosChanged(_hitos);
  }

  void _removeHito(int index) {
    if (_hitos.length > 1) {
      setState(() {
        _hitos.removeAt(index);
        // Renumerar los hitos
        for (int i = 0; i < _hitos.length; i++) {
          _hitos[i] = _hitos[i].copyWith(id: 'hito${i + 1}');
        }
      });
      widget.onHitosChanged(_hitos);
    }
  }

  void _updateHito(int index, Hito updatedHito) {
    setState(() {
      _hitos[index] = updatedHito;
    });
    widget.onHitosChanged(_hitos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resultados esperados (Hitos)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _addHito,
              icon: const Icon(Icons.add),
              tooltip: 'Agregar hito',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_hitos.length, (index) {
          return _HitoCard(
            hito: _hitos[index],
            index: index,
            onUpdate: (updatedHito) => _updateHito(index, updatedHito),
            onRemove: () => _removeHito(index),
            canRemove: _hitos.length > 1,
          );
        }),
      ],
    );
  }
}

class _HitoCard extends StatefulWidget {
  final Hito hito;
  final int index;
  final Function(Hito) onUpdate;
  final VoidCallback onRemove;
  final bool canRemove;

  const _HitoCard({
    required this.hito,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.canRemove,
  });

  @override
  State<_HitoCard> createState() => _HitoCardState();
}

class _HitoCardState extends State<_HitoCard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.hito.title);
    _descriptionController = TextEditingController(text: widget.hito.description);
  }

  @override
  void didUpdateWidget(_HitoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo actualizar si el hito cambió y no estamos editando
    if (oldWidget.hito.id != widget.hito.id) {
      _titleController.text = widget.hito.title;
      _descriptionController.text = widget.hito.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.hito.id.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.canRemove)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar hito',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del hito',
                hintText: 'Ej: Análisis y Diseño + Infraestructura Base',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onUpdate(widget.hito.copyWith(title: value));
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción del hito',
                hintText: 'Describe las tareas y entregables de este hito',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                widget.onUpdate(widget.hito.copyWith(description: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Hito {
  final String id;
  final String title;
  final String description;

  const Hito({
    required this.id,
    required this.title,
    required this.description,
  });

  Hito copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return Hito(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory Hito.fromJson(Map<String, dynamic> json) {
    return Hito(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hito &&
        other.id == id &&
        other.title == title &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ description.hashCode;
  }
}
