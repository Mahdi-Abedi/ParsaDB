package model
{
	import flash.utils.Dictionary;
	
	import model.valueObject.Database;
	import model.valueObject.Table;

	public class TableModel
	{
		
		private var tableDic:Dictionary;
		private var tableList:Array;
		private var database:Database;
		//--------------- Getter/ Setter ----------------
		
		
		//-------------- Constructor -----------
		public function TableModel(database:Database)
		{
			this.database = database;
			this.tableDic = new Dictionary();
			this.tableList = new Array();
		}
		
		//--------------- Methods --------------
		public function has(table:Table):Boolean
		{
			return this.tableDic[table.name];
		}

		public function add(table:Table):void
		{
			if(table)
			{
				var index:uint = this.tableList.push(table) - 1;
				this.tableDic[table.name] = index;
				this.tableDic[index] = index;
			}
		}
		
		public function addList(tables:Array):void
		{
			for (var i:int = 0, len:int = tables.length ; i < len; i++) 
			{
				this.add(tables[i]);
			}
			
			
		}
		public function remove(table:Table):void
		{
			var index:int = this.tableList.indexOf(table);
			if(index >= 0 )
			{
				this.tableDic[table.name] = null;
				this.tableDic[index] = null;
				this.tableList.splice(index, 1);
			}
		}
		
		public function getByName(name:String):Table
		{
			return this.tableList[this.tableDic[name]];
		}
		
		public function getList():Array
		{
			/*var tempArr:Array = new Array();
			for each (var c:Table in this.tableDic) 
			{
				tempArr.push(c);
			}
			
			return tempArr;*/
			
			return this.tableList;
		}
		
		/*public function removeAll():void
		{
			// TODO Auto Generated method stub
			
		}*/
		
		
		public function destroy():void
		{
			for (var i:int = 0, len:int = tableList.length ; i < len; i++) 
			{
				tableList[i].destroy();
				tableList[i] = null;
			}
			
			this.database = null;
			this.tableDic = null;
			this.tableList = null;
		}
	}
}