import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> database() async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'reciidar.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            apellido TEXT,
            usuario TEXT UNIQUE,
            correo TEXT,
            clave TEXT,
            telefono TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE donaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreUsuario TEXT,
            nombreProducto TEXT,
            descripcion TEXT,
            telefono TEXT,
            foto TEXT,
            ubicacion TEXT,
            estado TEXT DEFAULT 'Pendiente',
            fechaRecojo TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE evaluaciones (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreUsuario TEXT,
            estrellas INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE evaluaciones_admin (
            usuario TEXT PRIMARY KEY,
            estrellas INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreProducto TEXT,
            descripcion TEXT,
            precio REAL,
            estado TEXT DEFAULT 'Disponible',
            foto TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE ventas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombreUsuario TEXT,
            nombreCompleto TEXT,
            correo TEXT,
            telefono TEXT,
            distrito TEXT,
            direccion TEXT,
            urbanizacion TEXT,
            latitud REAL,
            longitud REAL,
            productoId INTEGER,
            estadoVenta TEXT DEFAULT 'Pendiente',
            fecha TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE productos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreProducto TEXT,
              descripcion TEXT,
              precio REAL,
              estado TEXT DEFAULT 'Disponible',
              foto TEXT
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE ventas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombreUsuario TEXT,
              nombreCompleto TEXT,
              correo TEXT,
              telefono TEXT,
              distrito TEXT,
              direccion TEXT,
              urbanizacion TEXT,
              latitud REAL,
              longitud REAL,
              productoId INTEGER,
              estadoVenta TEXT DEFAULT 'Pendiente',
              fecha TEXT
            )
          ''');
        }
      },
    );
  }

  // ----------------- Usuarios ------------------

  static Future<void> insertarUsuarioConDatos({
    required String nombre,
    required String apellido,
    required String usuario,
    required String correo,
    required String clave,
    required String telefono,
  }) async {
    final db = await database();
    await db.insert('usuarios', {
      'nombre': nombre,
      'apellido': apellido,
      'usuario': usuario,
      'correo': correo,
      'clave': clave,
      'telefono': telefono,
    });
  }

  static Future<Map<String, dynamic>?> verificarCredencialesYObtenerUsuario(
      String usuario, String clave) async {
    final db = await database();
    final resultado = await db.query(
      'usuarios',
      where: 'usuario = ? AND clave = ?',
      whereArgs: [usuario, clave],
    );
    return resultado.isNotEmpty ? resultado.first : null;
  }

  static Future<bool> existeUsuario(String usuario) async {
    final db = await database();
    final resultado = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [usuario],
    );
    return resultado.isNotEmpty;
  }

  static Future<List<Map<String, dynamic>>> obtenerTodosLosUsuarios() async {
    final db = await database();
    return await db.query('usuarios');
  }

  static Future<void> eliminarUsuarioPorNombreUsuario(String usuario) async {
    final db = await database();
    await db.delete('usuarios', where: 'usuario = ?', whereArgs: [usuario]);
  }

  static Future<void> eliminarProductosPorNombreUsuario(String usuario) async {
    final db = await database();
    await db.delete('donaciones', where: 'nombreUsuario = ?', whereArgs: [usuario]);
  }

  // ----------------- Donaciones ------------------

  static Future<void> insertarDonacion({
    required String nombreUsuario,
    required String nombreProducto,
    required String descripcion,
    required String telefono,
    required String foto,
    required String ubicacion,
  }) async {
    final db = await database();
    await db.insert('donaciones', {
      'nombreUsuario': nombreUsuario,
      'nombreProducto': nombreProducto,
      'descripcion': descripcion,
      'telefono': telefono,
      'foto': foto,
      'ubicacion': ubicacion,
      'estado': 'Pendiente',
    });
  }

  static Future<List<Map<String, dynamic>>> obtenerDonaciones() async {
    final db = await database();
    return await db.query('donaciones');
  }

  static Future<List<Map<String, dynamic>>> obtenerDonacionesPorUsuario(String usuario) async {
    final db = await database();
    return await db.query('donaciones', where: 'nombreUsuario = ?', whereArgs: [usuario]);
  }

  static Future<List<Map<String, dynamic>>> obtenerDonacionesConUsuarios() async {
    final db = await database();
    return await db.rawQuery('''
      SELECT d.*, u.nombre, u.apellido, u.usuario
      FROM donaciones d
      JOIN usuarios u ON d.nombreUsuario = u.usuario
    ''');
  }

  static Future<void> actualizarEstadoYFechaRecojo({
    required int id,
    required String estado,
    required String fechaRecojo,
  }) async {
    final db = await database();
    await db.update(
      'donaciones',
      {
        'estado': estado,
        'fechaRecojo': fechaRecojo,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> eliminarDonacionPorId(int id) async {
    final db = await database();
    await db.delete('donaciones', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- Evaluaciones usuario ------------------

  static Future<void> insertarEvaluacion(String nombreUsuario, int estrellas) async {
    final db = await database();
    await db.insert('evaluaciones', {
      'nombreUsuario': nombreUsuario,
      'estrellas': estrellas,
    });
  }

  static Future<bool> usuarioYaEvaluado(String nombreUsuario) async {
    final db = await database();
    final result = await db.query(
      'evaluaciones',
      where: 'nombreUsuario = ?',
      whereArgs: [nombreUsuario],
    );
    return result.isNotEmpty;
  }

  static Future<double?> obtenerPromedioEvaluacion(String nombreUsuario) async {
    final db = await database();
    final result = await db.rawQuery('''
      SELECT AVG(estrellas) as promedio
      FROM evaluaciones
      WHERE nombreUsuario = ?
    ''', [nombreUsuario]);
    return result.isNotEmpty && result.first['promedio'] != null
        ? (result.first['promedio'] as num).toDouble()
        : null;
  }

  // ----------------- Evaluaciones admin ------------------

  static Future<void> evaluarUsuarioPorAdmin(String usuario, int estrellas) async {
    final db = await database();
    await db.insert(
      'evaluaciones_admin',
      {'usuario': usuario, 'estrellas': estrellas},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> adminYaEvaluoUsuario(String usuario) async {
    final db = await database();
    final result = await db.query(
      'evaluaciones_admin',
      where: 'usuario = ?',
      whereArgs: [usuario],
    );
    return result.isNotEmpty;
  }

  static Future<double?> obtenerEvaluacionDeAdmin(String usuario) async {
    final db = await database();
    final result = await db.query(
      'evaluaciones_admin',
      where: 'usuario = ?',
      whereArgs: [usuario],
    );
    return result.isNotEmpty ? (result.first['estrellas'] as num).toDouble() : null;
  }

  static Future<List<Map<String, dynamic>>> obtenerRankingEvaluacionAdmin() async {
    final db = await database();
    return await db.rawQuery('''
      SELECT ea.usuario AS usuario, ea.estrellas AS estrellas, u.nombre, u.apellido
      FROM evaluaciones_admin ea
      JOIN usuarios u ON ea.usuario = u.usuario
      ORDER BY ea.estrellas DESC
    ''');
  }

  // ----------------- Productos ------------------

  static Future<List<Map<String, dynamic>>> obtenerTodosLosProductos() async {
    final db = await database();
    return await db.query('productos', orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> obtenerProductosDisponibles() async {
    final db = await database();
    return await db.query(
      'productos',
      where: 'estado = ?',
      whereArgs: ['Disponible'],
      orderBy: 'id DESC',
    );
  }

  static Future<void> insertarProductoCatalogo({
    required String nombreProducto,
    required String descripcion,
    required double precio,
    String estado = 'Disponible',
    required String foto,
  }) async {
    final db = await database();
    await db.insert('productos', {
      'nombreProducto': nombreProducto,
      'descripcion': descripcion,
      'precio': precio,
      'estado': estado,
      'foto': foto,
    });
  }

  static Future<void> actualizarProducto(Map<String, dynamic> producto) async {
    final db = await database();
    await db.update(
      'productos',
      producto,
      where: 'id = ?',
      whereArgs: [producto['id']],
    );
  }

  static Future<void> actualizarEstadoProducto(int id, String nuevoEstado) async {
    final db = await database();
    await db.update(
      'productos',
      {'estado': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> eliminarProducto(int id) async {
    final db = await database();
    await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- Ventas ------------------

  static Future<void> insertarVenta(Map<String, dynamic> venta) async {
    final db = await database();
    await db.insert('ventas', venta);
  }

  static Future<List<Map<String, dynamic>>> obtenerVentas() async {
    final db = await database();
    return await db.query('ventas', orderBy: 'id DESC');
  }

  static Future<void> actualizarEstadoVenta(int id, String nuevoEstado) async {
    final db = await database();
    await db.update(
      'ventas',
      {'estadoVenta': nuevoEstado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> eliminarVenta(int id) async {
    final db = await database();
    await db.delete('ventas', where: 'id = ?', whereArgs: [id]);
  }

  // ----------------- Ventas con nombreProducto, precio y foto ------------------

  static Future<List<Map<String, dynamic>>> obtenerVentasConNombreProducto() async {
    final db = await database();
    return await db.rawQuery('''
      SELECT 
        v.*, 
        p.nombreProducto, 
        p.precio, 
        p.foto 
      FROM ventas v
      LEFT JOIN productos p ON v.productoId = p.id
      ORDER BY v.id DESC
    ''');
  }
}