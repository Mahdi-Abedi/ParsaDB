package model
{
	import flash.utils.Dictionary;
	
	import model.valueObject.Column;
	import model.valueObject.Table;

	public class ColumnModel
	{
		
		public var columnDic:Dictionary;
		public var columnList:Array;
		public var table:Table;
		
		//-------------- Constructor -----------
		public function ColumnModel(table:Table)
		{
			this.table = table;
			this.init();
		}
		
		private function init():void
		{
			this.columnDic = new Dictionary();
			this.columnList = new Array();
		}
		//--------------- Methods --------------
		public function has(column:Column):Boolean
		{
			return this.columnDic[column.name];
		}
		
		public function add(column:Column):void
		{
			if(column)
			{
				column.table = this.table;
				var index:uint = this.columnList.push(column);
				this.columnDic[column.name] = index;
				this.columnDic[index] = index;
			}
		}
		
		public function addList(columns:Array):void
		{
			for (var i:int = 0, len:int = columns.length ; i < len; i++) 
			{
				this.add(columns[i]);
			}
			
		}
		
		public function remove(column:Column):void
		{
			var index:int = this.columnList.indexOf(column);
			if(index >= 0 )
			{
				this.columnDic[column.name] = null;
				this.columnDic[index] = null;
				this.columnList.splice(index, 1);
			}
		}
		
		public function getByName(name:String):Column
		{
			return this.columnList[this.columnDic[name]];
		}
		
		public function getList():Array
		{
			return this.columnList;
		}
		
		public function destroy():void
		{
			for (var i:int = 0, len:int = columnList.length ; i < len; i++) 
			{
				columnList[i].destroy();
				columnList[i] = null;
			}
			
			this.table = null;
			this.columnDic = null;
			this.columnList = null;
		}
	}
}