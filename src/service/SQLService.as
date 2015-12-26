package service
{
	import com.probertson.data.QueuedStatement;
	import com.probertson.data.SQLRunner;
	
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import events.TableEvent;
	
	import model.CommandModel;
	import model.valueObject.Command;
	import model.valueObject.Table;
	
	import utiles.SQLCommandCreator;
	import utiles.constants.CommandType;
	
	public class SQLService
	{
		private var sqlRunner:SQLRunner;
		private var statementBatch:Vector.<QueuedStatement>;
		private var dbFile:File;
		private var commandModel:CommandModel;
		
		//--------------- Getter / Setter ----------
		private var _isExecuting:Boolean;
		public function get isExecuting():Boolean
		{
			return this._isExecuting;
		}
		
		// ------- Singleton implementation -------
		
		private static var _instance:SQLService;
		public static function getInstance():SQLService
		{
			
			return _instance || (_instance = new SQLService());
		}
		
		// ------- Constructor -------
		public function SQLService()
		{
			if (_instance != null)
			{
				throw new Error("Singleton can only be accessed through Singleton.instance");
			}
			
			this.inti();
		}
		
		//--------------- Methods --------------
		private function inti():void
		{
			this.statementBatch = new Vector.<QueuedStatement>();
			this.commandModel = CommandModel.getInstance();
		}
		
		private function initSqlRunner(table:Table):void
		{
			if(!this.dbFile || table.database.file != this.dbFile)
				this.sqlRunner = new SQLRunner(table.database.file, table.database.maxPoolSize, table.database.encryptionKey);
			
		}
		
		public function addTable(table:Table):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.createTable(table),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.CREATED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function deleteTable(table:Table):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.deleteTable(table),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.REMOVED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function emptyTable(table:Table):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.emptyTable(table),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.EMPTIED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function addRow(table:Table, value:Object):void
		{
			
			var cmd:Command = new Command(
				SQLCommandCreator.addRow(table, value),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.ROW_ADDED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
			
		}
		
		public function addRowList(table:Table, valueList:Array):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.addRowList(table, valueList),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.ROWS_LIST_ADDED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function removeRow(table:Table, rowId:uint):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.removeRow(table, rowId),
				CommandType.MODIFY,
				function(result:Vector.<SQLResult>):void{
					table.dispatchEvent( new TableEvent(TableEvent.ROW_REMOVED));
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function getAllRows(table:Table, value:Object):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.getAllRows(table, value),
				CommandType.FETCH,
				function(result:SQLResult):void{
					var e:TableEvent = new TableEvent(TableEvent.ROWS_RECIVED)
					e.data = result.data;
					table.dispatchEvent(e);
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		public function getRow(table:Table, value:Object):void
		{
			var cmd:Command = new Command(
				SQLCommandCreator.getRow(table, value),
				CommandType.FETCH,
				function(result:SQLResult):void{
					var e:TableEvent = new TableEvent(TableEvent.ROWS_RECIVED)
					e.data = result.data;
					table.dispatchEvent(e);
				},
				function(e:SQLError):void{
					trace('SQL Command:\n\t' + cmd.sql);
				}
			);
			
			this.commandModel.push(cmd);
			this.initSqlRunner(table);
			this.execute();
		}
		
		// ------- Private methods -------
		
		public function close(resultHandler:Function = null, errorHandler:Function=null):void
		{
			this.sqlRunner.close(resultHandler);
			this.sqlRunner = null;
			this.dbFile = null;
			this.statementBatch = null;
		}
		
		
		private function execute():void
		{
			if(this.isExecuting || this.commandModel.isEmpty) return;
			
			this._isExecuting = true;
			
			var cmd:Command = this.commandModel.fetch();
			if(cmd.type == CommandType.MODIFY)
			{
				statementBatch.push(new QueuedStatement(cmd.sql));
				this.sqlRunner.executeModify(
					statementBatch,
					function(result:Vector.<SQLResult>):void{
						_isExecuting = false;
						
						executeModify_complete(result);
						if(cmd.resultHandler)
							cmd.resultHandler(result);
						execute();
					},
					function(err:SQLError):void{
						error(err);
						
						if(cmd.errorHandler)
							cmd.errorHandler(err);
					},
					function(completedCount:uint, totalCount:uint):void{
						executeModify_progress(completedCount, totalCount);
						
						if(cmd.progressHandler)
							cmd.progressHandler(completedCount, totalCount);
					}
				);
			}else //CommandType.FETCH
			{
				this.sqlRunner.execute(
					cmd.sql,
					null,
					function(result:SQLResult):void{
						_isExecuting = false;
						
						execute_complete(result);
						cmd.resultHandler(result);
						execute();
					},
					null,
					function(err:SQLError):void{
						error(err);
						if(cmd.errorHandler)
							cmd.errorHandler(err);
					}
				);
				
			}
		}
		
		
		private function executeModify(statementBatch:Vector.<QueuedStatement>, resultHandler:Function, errorHandler:Function, progressHandler:Function):void
		{
			sqlRunner.executeModify(statementBatch, resultHandler, errorHandler, progressHandler);
		}

		// ------- Event handling -------
		
		private function execute_complete(result:SQLResult):void
		{
			
		}
		
		private function executeModify_complete(result:Vector.<SQLResult>):void
		{
			
		}
		
		private function error(err:SQLError):void
		{
			trace(err.message + '\n\t' + err.details);
		}
		
		private function executeModify_progress(completedCount:uint, totalCount:uint):void
		{
			
		}
	}
}
