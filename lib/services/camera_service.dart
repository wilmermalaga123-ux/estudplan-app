import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<String?> tomarFotoYGuardar() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (foto == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final evidenciasDir = Directory('${appDir.path}/evidencias');
      if (!await evidenciasDir.exists()) {
        await evidenciasDir.create(recursive: true);
      }

      final nombreArchivo = '${_uuid.v4()}.jpg';
      final rutaDestino = '${evidenciasDir.path}/$nombreArchivo';
      await File(foto.path).copy(rutaDestino);

      return rutaDestino;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  Future<void> eliminarFoto(String ruta) async {
    final archivo = File(ruta);
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }
}