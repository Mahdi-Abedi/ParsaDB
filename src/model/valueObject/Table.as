package model.valueObject
{
	import flash.events.EventDispatcher;
	
	import events.TableEvent;
	
	import model.ColumnModel;
	
	import service.SQLService;
	
	import utiles.constants.Datatypes;

	[Event(name="created", type="events.TableEvent")]
	[Event(name="removed", type="events.TableEvent")]
	[Event(name="emptied", type="events.TableEvent")]
	[Event(name="rowAdded", type="events.TableEvent")]
	[Event(name="rowsListAdded", type="events.TableEvent")]
	[Event(name="rowRemoved", type="events.TableEvent")]
	[Event(name="rowsRecived", type="events.TableEvent")]
	[Event(name="destroyed", type="events.TableEvent")]
	
	public class Table extends EventDispatcher
	{
		private var sqlService:SQLService;
		private var columnModel:ColumnModel;
		
		public var name:String;
		
		//-------------- Setter/Getter --------------
		private var _database:Database;
		
		public function get database():Database
		{
			return _database;
		}

		public function set database(value:Database):void
		{
			_database = value;
			
			this.addForcedComumns();
		}

		public function get created():Boolean
		{
			return this.database;
		}
		
		//----------------- Constructor -----------------
		public function Table(name:String)
		{
			if(!name) throw new Error('Table name is Invalid.');
			this.name = name;
			
			this.init();
		}
		
		private function init():void
		{
			this.sqlService = SQLService.getInstance();
			this.columnModel = new ColumnModel(this);
			
		}
		//----------------- Methods -----------------
		private function addForcedComumns():void
		{
			var id:Column = new Column('id',Datatypes.INTEGER);
			id.primaryKey = true;
			id.autoIncrement = true;
			
			this.addColumn(id);
				
		}
		
		public function createColumn(name:String, type:String):void
		{
			this.columnModel.add(new Column(name, type));
		}
		
		public function addColumn(column:Column):void
		{
			this.columnModel.add(column);
		}
		
		public function removeColumn(column:Column):void
		{
			this.columnModel.remove(column);
		}
		
		public function getColumn(name:String):Column
		{
			return this.columnModel.getByName(name);
		}
		/*
		public function updateColumn(column:Column):void
		{
			
		}*/
		
		public function get columnList():Array
		{
			
			return this.columnModel.getList();
		}
		
		public function add(value:Object):void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.ROW_ADDED, 
					function():void{
						removeEventListener(TableEvent.ROW_ADDED, arguments.callee);
						
				});
				this.sqlService.addRow(this, value);
			}
			
		}
		
		public function addList(...valueList):void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.ROWS_LIST_ADDED, 
					function():void{
						removeEventListener(TableEvent.ROWS_LIST_ADDED, arguments.callee);
						
					});
				this.sqlService.addRowList(this, valueList);
			}
			
		}
		
		public function remove(rowId:uint):void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.ROW_REMOVED, 
					function():void{
						removeEventListener(TableEvent.ROW_REMOVED, arguments.callee);
						
					});
				this.sqlService.removeRow(this, rowId);
			}
		}
		
		public function findAll(value:Object):void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.ROWS_RECIVED, 
					function():void{
						removeEventListener(TableEvent.ROWS_RECIVED, arguments.callee);
						
					});
				this.sqlService.getAllRows(this, value);
			}
		}
		
		public function find(value:Object):void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.ROWS_RECIVED, 
					function():void{
						removeEventListener(TableEvent.ROWS_RECIVED, arguments.callee);
						
					});
				this.sqlService.getRow(this, value);
			}
		}
		
		public function empty():void
		{
			if(this.created)
			{
				this.addEventListener(TableEvent.EMPTIED, 
					function():void{
						removeEventListener(TableEvent.EMPTIED, arguments.callee);
						
					});
				this.sqlService.emptyTable(this)
			}
		}
		
		public function destroy():void
		{
			this.columnModel.destroy();
			this.columnModel = null;
			this.dispatchEvent( new TableEvent(TableEvent.DESTROYED));
		}
		
		override public function toString():String
		{
			var str:String = this.database.toString() ? this.database.toString() + "." : '';
			str += "[" + this.name + "]"
			return str;
		}
	}
}