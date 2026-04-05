import 'package:flutter/material.dart';
import '../../data/repositories/materia_repository_impl.dart';
import '../../domain/models/materia.dart';
import '../widgets/materia_card.dart';

class LecturasScreen extends StatefulWidget {
  const LecturasScreen({super.key});

  @override
  State<LecturasScreen> createState() => _LecturasScreenState();
}

class _LecturasScreenState extends State<LecturasScreen> {
  final MateriaRepositoryImpl _repository = MateriaRepositoryImpl();
  List<Materia> _materias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    try {
      final materias = await _repository.getMaterias();
      setState(() {
        _materias = materias;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _agregarMateria() async {
    final TextEditingController nombreCtrl = TextEditingController();
    final TextEditingController paginasCtrl = TextEditingController();
    final TextEditingController velocidadCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Materia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            TextField(controller: paginasCtrl, decoration: const InputDecoration(labelText: 'Total de páginas'), keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            TextField(controller: velocidadCtrl, decoration: const InputDecoration(labelText: 'Páginas por hora'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (result == true) {
      if (nombreCtrl.text.isEmpty) {
        _mostrarSnackbar('El nombre es obligatorio');
        return;
      }
      final int? paginas = int.tryParse(paginasCtrl.text);
      final int? velocidad = int.tryParse(velocidadCtrl.text);
      if (paginas == null || paginas <= 0) {
        _mostrarSnackbar('Total de páginas debe ser un número positivo');
        return;
      }
      if (velocidad == null || velocidad <= 0) {
        _mostrarSnackbar('Velocidad debe ser un número positivo');
        return;
      }

      try {
        final materia = Materia(
          nombre: nombreCtrl.text,
          paginasTotales: paginas,
          velocidadPaginasPorHora: velocidad,
        );
        await _repository.addMateria(materia);
        await _cargarMaterias();
        _mostrarSnackbar('Materia agregada correctamente');
      } catch (e) {
        _mostrarSnackbar('Error al guardar la materia');
      }
    }
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _editarMateria(Materia materia) async {
    final TextEditingController nombreCtrl = TextEditingController(text: materia.nombre);
    final TextEditingController paginasCtrl = TextEditingController(text: materia.paginasTotales.toString());
    final TextEditingController velocidadCtrl = TextEditingController(text: materia.velocidadPaginasPorHora.toString());
    int paginasLeidas = materia.paginasLeidas;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setStateDialog) => AlertDialog(
          title: const Text('Editar Materia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
              const SizedBox(height: 8),
              TextField(controller: paginasCtrl, decoration: const InputDecoration(labelText: 'Total de páginas'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: velocidadCtrl, decoration: const InputDecoration(labelText: 'Páginas por hora'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Páginas leídas: '),
                  Expanded(
                    child: Slider(
                      value: paginasLeidas.toDouble(),
                      min: 0,
                      max: materia.paginasTotales.toDouble(),
                      divisions: materia.paginasTotales > 0 ? materia.paginasTotales : 1,
                      onChanged: (value) {
                        setStateDialog(() {
                          paginasLeidas = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$paginasLeidas'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                if (nombreCtrl.text.isEmpty) {
                  _mostrarSnackbar('El nombre es obligatorio');
                  return;
                }
                final int? paginas = int.tryParse(paginasCtrl.text);
                final int? velocidad = int.tryParse(velocidadCtrl.text);
                if (paginas == null || paginas <= 0 || velocidad == null || velocidad <= 0) {
                  _mostrarSnackbar('Datos inválidos');
                  return;
                }
                materia.nombre = nombreCtrl.text;
                materia.paginasTotales = paginas;
                materia.velocidadPaginasPorHora = velocidad;
                materia.paginasLeidas = paginasLeidas;
                await _repository.updateMateria(materia);
                await _cargarMaterias();
                Navigator.pop(ctx2);
                _mostrarSnackbar('Materia actualizada');
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarMateria(Materia materia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text('¿Eliminar "${materia.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _repository.deleteMateria(materia.id!);
      await _cargarMaterias();
      _mostrarSnackbar('Materia eliminada');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: _materias.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay materias agregadas'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _agregarMateria,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Materia'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _materias.length,
              itemBuilder: (context, index) {
                final materia = _materias[index];
                return MateriaCard(
                  materia: materia,
                  onEdit: () => _editarMateria(materia),
                  onLongPress: () => _eliminarMateria(materia),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarMateria,
        child: const Icon(Icons.add),
      ),
    );
  }
}