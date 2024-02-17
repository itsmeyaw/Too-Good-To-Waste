import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../dto/user_item_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper.internal();

  factory DBHelper() => _instance;

  DBHelper.internal();

  static Database? _db;

  //Avoid errors cause by flutter upgrade.

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db ??= await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "dbhelper.db");

    return openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
          await db.execute(
              'CREATE TABLE foods(id TEXT PRIMARY KEY, name TEXT, category TEXT, buy_date INTEGER, expiry_date INTEGER, quantity_type TEXT, quantity_num REAL, state TEXT, consume_state REAL)');
        });
  }


  //Define the function that inserts food into the 'foods' table
  Future<void> insertFood(UserItem food) async {
    //Get a refenrence to the database

    Database dbHelper = await db;

    //In this case, the quantity for this food should be added. How????
    //Or the backend should judge if the newly request tobe added food already exists in database
    await dbHelper.insert('foods', food.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //Define method that retrieves all the foods from food table
  Future<List> queryAll(String object) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.
    if (object == "foods") {
      final List<Map<String, dynamic>> maps = await dbHelper.query('foods');
      //Convert the List<Map<String, dynamic> into a List<Food>

      return List.generate(maps.length, (i) {
        return UserItem(
          id: maps[i]['id'],
          name: maps[i]['name'],
          category: maps[i]['category'],
          buyDate: maps[i]['buy_date'],
          expiryDate: maps[i]['expiry_date'],
          quantityType: maps[i]['quantity_type'],
          quantityNum: maps[i]['quantity_num'],
          consumeState: maps[i]['consume_state'],
          state: maps[i]['state'],
        );
      });
    } 
    return List.empty();
  }

  Future<List> queryOne(String object, String id) async {
    //Get a reference to the database.
    Database dbHelper = await db;

    //Query table for all the foods.
    if (object == "foods") {
      final List<Map<String, dynamic>> maps = await dbHelper
          .rawQuery('SELECT * FROM foods WHERE id = ?', [id]);
      //Convert the List<Map<String, dynamic> into a List<Food>

      //shoud be only one row, how to simplfy the code?
      return List.generate(maps.length, (i) {
        return UserItem(
          id: maps[0]['id'],
          name: maps[0]['name'],
          category: maps[0]['category'],
          buyDate: maps[0]['buy_date'],
          expiryDate: maps[0]['expiry_date'],
          quantityNum: maps[0]['quantity_num'],
          quantityType: maps[0]['quantity_type'],
          state: maps[0]['state'],
          consumeState: maps[0]['consume_state'],
        );
      });
    } 
    return List.empty();
  }

  //Define method that retrieves one column if all the foods from food table
  Future<List<String>> getAllFoodStringValues(String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps =
        await dbHelper.query('foods', columns: [value]);

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsname = List<String>.generate(maps.length, (i) => maps[i][value]);

    return foodsname;
  }

  //Define method that retrieves all the foods from food table
  Future<List<int>> getAllFoodIntValues(String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps =
        await dbHelper.query('foods', columns: [value]);

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsname = List<int>.generate(maps.length, (i) => maps[i][value]);

    return foodsname;
  }

  Future<String> getOneFoodValue(String id, String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: '"id" = ?', whereArgs: [id]);

    //Convert the List<Map<String, dynamic> into a String
    var foodname = maps[0][value];
    //var foodname = Food.fromMap(maps.first);

    return foodname;
  }

  Future<int> getOneFoodIntValue(String name, String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: '"name" = ?', whereArgs: [name]);

    //Convert the List<Map<int, dynamic> into a String
    var foodname = maps[0][value];
    //var foodname = Food.fromMap(maps.first);

    return foodname;
  }

  Future<double> getOneFoodDoubleValue(String name, String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: '"name" = ?', whereArgs: [name]);

    //Convert the List<Map<int, dynamic> into a String
    var foodname = maps[0][value];
    //var foodname = Food.fromMap(maps.first);

    return foodname;
  }

  Future<List<UserItem>> queryByCategory(String category) async {
    //Get the refernce to the database
    Database dbHelper = await db;

    //final List<Map<String, dynamic>> maps = await dbHelper.query('foods',columns: ['name', 'expiretime', 'boughttime', 'quantitynum', 'quantitytype', 'state', 'consumestate'], where: '$category = ?', whereArgs: [category]);
    final List<Map<String, dynamic>> maps = await dbHelper
        .rawQuery('SELECT * FROM foods WHERE category = ?', [category]);

    //Convert the List<Map<String, dynamic> into a List

    return List.generate(maps.length, (i) {
      return UserItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        buyDate: maps[i]['buy_date'],
        expiryDate: maps[i]['expiry_date'],
        quantityNum: maps[i]['quantity_num'],
        quantityType: maps[i]['quantity_type'],
        state: maps[i]['state'],
        consumeState: maps[i]['consume_state'],
      );
    });
  }

  //Define method that retrieves all the foods from food table
  //value = 
  Future<List<String>> getAllUncosumedFoodStringValues(String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: 'consume_state < 1');

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodstring = List<String>.generate(maps.length, (i) => maps[i][value]);

    return foodstring;
  }

  //Define method that retrieves all the foods from food table
  Future<List<String>> getAllGoodFoodStringValues(
      String value, String state) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: 'state = ?', whereArgs: [state]);

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodstring = List<String>.generate(maps.length, (i) => maps[i][value]);

    return foodstring;
  }

  Future<List<Map<String, dynamic>>> getAllWastedFoodList() async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    List<Map<String, dynamic>> maps = await dbHelper
        .query('foods', where: 'state = ?', whereArgs: ['wasted']);
    print('########################3$maps########################');

    return maps;
  }

  //Define method that retrieves all the foods from food table
  Future<List<double>> getAllUncosumedFoodDoubleValues(String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: 'consume_state < 1.0');

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsdouble = List<double>.generate(maps.length, (i) => maps[i][value]);

    return foodsdouble;
  }

  //Define method that retrieves all the foods with certain state from food table
  Future<List<double>> getAllGoodFoodDoubleValues(String value, String state) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: '"state" = ?', whereArgs: [state]);

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsdouble = List<double>.generate(maps.length, (i) => maps[i][value]);

    return foodsdouble;
  }

  //Define method that retrieves all the foods from food table
  Future<List<int>> getAllUncosumedFoodIntValues(String value) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: 'consume_state < 1.0');

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsint = List<int>.generate(maps.length, (i) => maps[i][value]);

    return foodsint;
  }

  //Define method that retrieves all the foods with certain state from food table
  Future<List<int>> getAllGoodFoodIntValues(String value, String state) async {
    //Get a reference to the database.
    Database dbHelper = await db;
    //Query table for all the foods.

    final List<Map<String, dynamic>> maps = await dbHelper.query('foods',
        columns: [value], where: '"state" = ?', whereArgs: [state]);

    //Convert the List<Map<String, dynamic> into a List<String>
    var foodsint = List<int>.generate(maps.length, (i) => maps[i][value]);

    return foodsint;
  }

  Future<List<UserItem>> queryAllUnconsumedFood() async {
    //Get the refernce to the database
    Database dbHelper = await db;

    //final List<Map<String, dynamic>> maps = await dbHelper.query('foods',columns: ['name', 'expiretime', 'boughttime', 'quantitynum', 'quantitytype', 'state', 'consumestate'], where: '$category = ?', whereArgs: [category]);
    final List<Map<String, dynamic>> maps = await dbHelper
        .rawQuery('SELECT * FROM foods WHERE consume_state < ?', [1]);

    //Convert the List<Map<String, dynamic> into a List

    return List.generate(maps.length, (i) {
      return UserItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        buyDate: maps[i]['buy_date'],
        expiryDate: maps[i]['expiry_date'],
        quantityNum: maps[i]['quantity_num'],
        quantityType: maps[i]['quantity_type'],
        state: maps[i]['state'],
        consumeState: maps[i]['consume_state'],
      );
    });
  }

  Future<List<UserItem>> queryAllGoodFood(String state) async {
    //Get the refernce to the database
    Database dbHelper = await db;

    //final List<Map<String, dynamic>> maps = await dbHelper.query('foods',columns: ['name', 'expiretime', 'boughttime', 'quantitynum', 'quantitytype', 'state', 'consumestate'], where: '$category = ?', whereArgs: [category]);
    final List<Map<String, dynamic>> maps =
        await dbHelper.rawQuery('SELECT * FROM foods WHERE state = ?', [state]);

    //Convert the List<Map<String, dynamic> into a List

    return List.generate(maps.length, (i) {
      return UserItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        category: maps[i]['category'],
        buyDate: maps[i]['buy_date'],
        expiryDate: maps[i]['expiry_date'],
        quantityNum: maps[i]['quantity_num'],
        quantityType: maps[i]['quantity_type'],
        state: maps[i]['state'],
        consumeState: maps[i]['consume_state'],
      );
    });
  }

  //Define method that updates food data
  Future<void> updateFood(UserItem food) async {
    //Get the reference to the database
    Database dbHelper = await db;
    //update the food data

    await dbHelper.update(
      'foods',
      food.toJson(),
      //Ensure the food has a matching id
    );
  }

  Future<void> updateFoodWaste(String id) async {
    Database dbHelper = await db;

    await dbHelper.rawUpdate(
        'UPDATE foods SET consume_state = ?, state = ? WHERE id = ?',
        [1.0, 'wasted', id]);
    print('###############update##################');
  }

  Future<void> updateFoodConsumed(String id, String status) async {
    Database dbHelper = await db;

    await dbHelper.rawUpdate(
        'UPDATE foods SET quantity_num = ?, consume_state = ?, state = ? WHERE id = ?',
        [0.0, 1.0, status, id]);
    print('###############update##################');
  }

  Future<void> updateFoodExpiring(String id) async {
    Database dbHelper = await db;

    await dbHelper.rawUpdate(
        'UPDATE foods SET state = ? WHERE name = ?', ['expiring', id]);
    print('###############update##################');
  }

  //Define method to delete food
  Future<void> deleteFood(String id) async {
    //Get a reference to the database
    Database dbHelper = await db;

    //Remove the Food from the database
    await dbHelper.delete(
      'foods',
      //Use a 'where' clause to delete a specific food -> id or name?
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    Database dbhelper = await db;
    dbhelper.close();
  }
}