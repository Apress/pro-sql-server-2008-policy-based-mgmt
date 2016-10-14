-- ************* Listing 7-1 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition
@name=N'Database Has Less than 10 Pct Free Space',
@description=N'',
@facet=N'Database',
@expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>GT</OpType>
<Count>2</Count>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>Divide</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Attribute>
<TypeClass>Numeric</TypeClass>
<Name>SpaceAvailable</Name>
</Attribute>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>Multiply</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Attribute>
<TypeClass>Numeric</TypeClass>
<Name>Size</Name>
</Attribute>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>1024</Value>
</Constant>
</Function>
</Function>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>0.2</Value>
</Constant>
</Operator>', @is_name_condition=0, @obj_name=N'',
@condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-2 ************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
@object_set_name=N'Database Has Less than 10 Pct Free Space_ObjectSet',
@facet=N'Database',
@object_set_id=@object_set_id OUTPUT
Select @object_set_id
Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
@object_set_name=N'Database Has Less than 10 Pct Free Space_ObjectSet',
@type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True,
@target_set_id=@target_set_id OUTPUT
Select @target_set_id
EXEC msdb.dbo.sp_syspolicy_add_target_set_level
@target_set_id=@target_set_id, @type_skeleton=N'Server/Database',
@level_name=N'Database', @condition_name=N'', @target_set_level_id=0
GO
Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy
@name=N'Database Has Less than 10 Pct Free Space',
@condition_name=N'Database Has Less thean 10 Pct Free Space',
@policy_category=N'AutoEvaluatePolicy', @description=N'', @help_text=N'',
@help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000',
@execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT,
@root_condition_name=N'',
@object_set=N'Database Has Less than 10 Pct Free Space_ObjectSet'
Select @policy_id
GO

-- ************* Listing 7-3 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Log Backup more than 15 minutes old', @description=N'', @facet=N'IDatabaseMaintenanceFacet', @expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>GT</OpType>
<Count>2</Count>
<Attribute>
<TypeClass>DateTime</TypeClass>
<Name>LastLogBackupDate</Name>
</Attribute>
<Function>
<TypeClass>DateTime</TypeClass>
<FunctionType>DateAdd</FunctionType>
<ReturnType>DateTime</ReturnType>
<Count>3</Count>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>minute</Value>
</Constant>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>-15</Value>
</Constant>
<Function>
<TypeClass>DateTime</TypeClass>
<FunctionType>GetDate</FunctionType>
<ReturnType>DateTime</ReturnType>
<Count>0</Count>
</Function>
</Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-4 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Databases in Full or Bulk Logged', @description=N'', @facet=N'Database', @expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>NE</OpType>
<Count>2</Count>
<Attribute>
<TypeClass>Numeric</TypeClass>
<Name>RecoveryModel</Name>
</Attribute>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>Enum</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>Microsoft.SqlServer.Management.Smo.RecoveryModel</Value>
</Constant>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>Simple</Value>
</Constant>
</Function>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-5 ************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
@object_set_name=N'Log Backups More than 15 minutes old for non Simple Recovery DBs_ObjectSet', @facet=N'IDatabaseMaintenanceFacet', @object_set_id=@object_set_id OUTPUT
Select @object_set_id
Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
@object_set_name=N'Log Backups More than 15 minutes old for non Simple Recovery DBs_ObjectSet', @type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id
EXEC msdb.dbo.sp_syspolicy_add_target_set_level @target_set_id=@target_set_id, @type_skeleton=N'Server/Database', @level_name=N'Database', @condition_name=N'Databases in Full or BulkLogged', @target_set_level_id=0
GO
Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy
@name=N'Log Backups More than 15 minutes old for non Simple Recovery DBs', @condition_name=N'Log Backup more than 15 minutes old', @policy_category=N'AutoEvaluatePolicy', @description=N'',
@help_text=N'', @help_link=N'',
@schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT,
@root_condition_name=N'',
@object_set=N'Log Backups More than 15 minutes old for non Simple Recovery DBs_ObjectSet'
Select @policy_id
GO

-- ************* Listing 7-6 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'SQL Server Agent Is Running', @description=N'', @facet=N'Server', @expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>EQ</OpType>
<Count>2</Count>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>ExecuteSql</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>numeric</Value>
</Constant>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>SELECT COUNT(*) &lt;?char 13?&gt;
FROM master.dbo.sysprocesses &lt;?char 13?&gt;
WHERE program_name = N''''SQLAgent - Generic Refresher''''</Value>
</Constant>
</Function>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>1</Value>
</Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-7 ************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
@object_set_name=N'SQL Server Agent Is Running_ObjectSet', @facet=N'Server',
@object_set_id=@object_set_id OUTPUT
Select @object_set_id
Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
@object_set_name=N'SQL Server Agent Is Running_ObjectSet', @type_skeleton=N'Server',
@type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id
GO
Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'SQL Server Agent Is Running',
@condition_name=N'SQL Server Agent Is Running', @policy_category=N'AutoEvaluatePolicy',
@description=N'', @help_text=N'', @help_link=N'',
@schedule_uid=N'00000000-0000-0000-0000-000000000000',
@execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT,
@root_condition_name=N'', @object_set=N'SQL Server Agent Is Running_ObjectSet'
Select @policy_id
GO

-- ************* Listing 7-8 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition
@name=N'SQL Server Agent Jobs With No Notification On Failure',
@description=N'', @facet=N'Server', @expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>EQ</OpType>
<Count>2</Count>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>ExecuteSql</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>numeric</Value>
</Constant>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>SELECT COUNT(*) &lt;?char 13?&gt;
FROM msdb.dbo.sysjobs&lt;?char 13?&gt;
WHERE name NOT LIKE ''''%TestDatabaseMail%'''' AND&lt;?char 13?&gt;
[enabled] = 1 AND&lt;?char 13?&gt;
notify_level_email NOT IN (1,2,3)</Value>
</Constant>
</Function>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>0</Value>
</Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-9 ************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
@object_set_name=N'SQL ServerAgent Jobs With No Notification On Failure_ObjectSet',
@facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id
Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
@object_set_name=N'SQL ServerAgent Jobs With No Notification On Failure_ObjectSet',
@type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id
GO
Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy
@name=N'SQL Server Agent Jobs With No Notification On Failure',
@condition_name=N'SQL Server Agent Jobs With No Notification On Failure',
@policy_category=N'AutoEvaluatePolicy', @description=N'', @help_text=N'',
@help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000',
@execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT,
@root_condition_name=N'',
@object_set=N'SQL ServerAgent Jobs With No Notification On Failure_ObjectSet'
Select @policy_id
GO

-- ************* Listing 7-10 ************************
Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'Data Purity Flag Check', @description=N'', @facet=N'Database', @expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>NE</OpType>
<Count>2</Count>
<Function>
<TypeClass>Numeric</TypeClass>
<FunctionType>ExecuteSql</FunctionType>
<ReturnType>Numeric</ReturnType>
<Count>2</Count>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>numeric</Value>
</Constant>
<Constant>
<TypeClass>String</TypeClass>
<ObjType>System.String</ObjType>
<Value>DBCC TRACEON (3604);&lt;?char 13?&gt;
CREATE TABLE #DBCC ( &lt;?char 13?&gt;
ParentObject VARCHAR(255)&lt;?char 13?&gt;
, [Object] VARCHAR(255)&lt;?char 13?&gt;
, Field VARCHAR(255)&lt;?char 13?&gt;
, [Value] VARCHAR(255) &lt;?char 13?&gt;
) &lt;?char 13?&gt;
&lt;?char 13?&gt;
INSERT INTO #DBCC EXECUTE (''''DBCC DBINFO WITH TABLERESULTS'''');&lt;?char 13?&gt;
&lt;?char 13?&gt;
SELECT Value FROM #DBCC&lt;?char 13?&gt;
WHERE Field = ''''dbi_DBCCFlags''''&lt;?char 13?&gt;
&lt;?char 13?&gt;
DROP TABLE #DBCC</Value>
</Constant>
</Function>
<Constant>
<TypeClass>Numeric</TypeClass>
<ObjType>System.Double</ObjType>
<Value>0</Value>
</Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id
GO

-- ************* Listing 7-11 ************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
@object_set_name=N'Data Purity Flag Check_ObjectSet', @facet=N'Database',
@object_set_id=@object_set_id OUTPUT
Select @object_set_id
Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
@object_set_name=N'Data Purity Flag Check_ObjectSet',
@type_skeleton=N'Server/Database', @type=N'DATABASE', @enabled=True,
@target_set_id=@target_set_id OUTPUT
Select @target_set_id
EXEC msdb.dbo.sp_syspolicy_add_target_set_level
@target_set_id=@target_set_id, @type_skeleton=N'Server/Database',
@level_name=N'Database', @condition_name=N'', @target_set_level_id=0
GO
Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'Data Purity Flag Check',
@condition_name=N'Data Purity Flag Check', @policy_category=N'', @description=N'',
@help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000',
@execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT,
@root_condition_name=N'', @object_set=N'Data Purity Flag Check_ObjectSet'
Select @policy_id
GO
