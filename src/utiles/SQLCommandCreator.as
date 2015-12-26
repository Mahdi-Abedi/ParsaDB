package utiles
{
	import model.valueObject.Column;
	import model.valueObject.Table;
	
	import utiles.constants.Datatypes;

	public class SQLCommandCreator
	{
		public function SQLCommandCreator()
		{
		}
		
		
		public static function createTable(table:Table):String
		{
			//CREATE TABLE IF NOT EXISTS tableName (columnName ColumnType, ...);
			var sql:String = "CREATE TABLE IF NOT EXISTS [" + table.name + "] (";
			
			var tempArr:Array = new Array();
			var str:String;
			for each (var c:Column in table.columnList) 
			{
				str = "[" +c.name + "] " + c.type;
				
				if(c.precision) str += "(" + c.size + ", " + c.precision + ")";
				else if(c.size) str += "(" + c.size + ")";
				if(c.notNull) str += " NOT NULL";
				if(c.onConflict) str += " ON CONFLICT " + c.onConflict;
				if(c.primaryKey)
				{
					str += " PRIMARY KEY";
					if(c.autoIncrement && c.type == Datatypes.INTEGER && !(c.size || c.precision))
						str += " AUTOINCREMENT";
				}
				if(c.collate) str += " COLLATE " + c.collate;
				if(c.defaultValue) str += " DEFAULT " + c.defaultValue;
				
				
				
				tempArr.push(str);
			}
			
			sql += tempArr.join(', ') + " );";
			return sql;
		}
		
		public static function deleteTable(table:Table):String
		{
			var sql:String = "DROP TABLE IF EXISTS [" + table.name + "];";
			return sql;
		}
		
		public static function emptyTable(table:Table):String
		{
			var sql:String ="DELETE FROM [" + table.name + "];";
			
			trace(sql);
			return sql;
		}
		
		public static function addRow(table:Table, value:Object):String
		{
			var sql:String = "INSERT INTO [" + table.name + "] (";
			
			var fieldNames:Array = new Array();
			var values:Array = new Array();
			for (var i:String in value) 
			{
				fieldNames.push("[" + i + "]");
				
				if(value[i] is String) value[i] = "'" + value[i] + "'";
				values.push(value[i]);
			}
			sql += fieldNames.join(', ') + " )VALUES (";
			sql += values.join(', ') + " );"
			return sql;
		}
		
		public static function addRowList(table:Table, valueList:Array):String
		{
			var sql:String = "INSERT INTO [" + table.name + "] (";
			
			var value:Object = valueList[0];
			var fieldNames:Array = new Array();
			var values:Array = new Array();
			var finalValues:Array = new Array();
			
			for (var j:String in value) 
			{
				fieldNames.push("[" + j + "]");
				
				if(value[j] is String) value[j] = "'" + value[j] + "'";
				values.push(value[j]);
			}
			sql += fieldNames.join(', ') + " ) SELECT ";
			sql += values.join(', ');
			
			for (var i:int = 1, len:int = valueList.length ; i < len; i++) 
			{
				value = valueList[i];
				values = new Array();
				
				for ( j in value) 
				{					
					if(value[j] is String) value[j] = "'" + value[j] + "'";
					values.push(value[j]);
				}
				sql += " UNION SELECT " + values.join(', ');
				
			}
			sql += ";";
			return sql;
		}
		
		public static function removeRow(table:Table, rowId:uint):String
		{
			var sql:String = "DELETE FROM [" + table.name + "] WHERE [id] = " + rowId + ";";
			return sql;
		}
		
		public static function getAllRows(table:Table, value:Object):String
		{
			var sql:String = "SELECT * FROM [" + table.name + "] WHERE ";
			var conditionList:Array = new Array();
			for (var i:String in value) 
			{
				if(value[i] is String) value[i] = "'" + value[i] + "'";
				
				
				conditionList.push("[" + i + "] = " + value[i]);
			}
			sql += conditionList.join('AND ') + " ;";
			return sql;
		}
		
		public static function getRow(table:Table, value:Object):String
		{
			var sql:String = getAllRows(table, value);
			sql = sql.substr(0, sql.length-1) + " limit 1;";
			
			return sql;
		}
	}
}