import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'ImageEmbeddingDao.dart';

class ImageEmbeddingDatabase {
  static final ImageEmbeddingDatabase _instance = ImageEmbeddingDatabase._internal();
  static Database? _database;

  ImageEmbeddingDatabase._internal();

  factory ImageEmbeddingDatabase() {
    return _instance;
  }

  Future<Database>get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'image_embedding_database.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE image_embedding (
            id INTEGER PRIMARY KEY,
            embedding TEXT NOT NULL,
            date INTEGER NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the date column to existing databases
          await db.execute('ALTER TABLE image_embedding ADD COLUMN date INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  // Singleton DAO access
  ImageEmbeddingDao get imageEmbeddingDao {
    return ImageEmbeddingDao(_database!);
  }

  Future<void> addEmbeddingsBatch(List<List<double>> embeddings) async {
  final db = await database;
  await db.transaction((txn) async {
    for (final embedding in embeddings) {
      await txn.insert(
        'image_embeddings',
        {'embedding': embedding},  // Add other required fields
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  });
}

}
