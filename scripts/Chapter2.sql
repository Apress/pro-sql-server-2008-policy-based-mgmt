--*********Listing 2-1***************************************
SELECT Policy.name PolicyName,
       Policy.description PolicyDscr
FROM msdb.dbo.syspolicy_conditions Condition INNER JOIN
     msdb.dbo.syspolicy_policies Policy
       ON Condition.condition_id = Policy.condition_id
WHERE Condition.name = 'Full Recovery Model'

--*********Listing 2-3***************************************
Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set
     @object_set_name=N'Full Database Recovery Model_ObjectSet',
     @facet=N'IDatabaseMaintenanceFacet',
     @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set
     @object_set_name=N'Full Database Recovery Model_ObjectSet',
     @type_skeleton=N'Server/Database',
     @type=N'DATABASE',
     @enabled=True,
     @target_set_id=@target_set_id OUTPUT
Select @target_set_id

EXEC msdb.dbo.sp_syspolicy_add_target_set_level
     @target_set_id=@target_set_id,
     @type_skeleton=N'Server/Database',
     @level_name=N'Database',
     @condition_name=N'',
     @target_set_level_id=0
GO

Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy
     @name=N'Full Database Recovery Model',
     @condition_name=N'Full Recovery Model',
     @policy_category=N'',
     @description=N'Policy to make sure a database recovery model is set to Full',
     @help_text=N'Choosing a Recovery Model',
     @help_link=N'http://msdn.microsoft.com/en-us/library/ms175987.aspx',
     @schedule_uid=N'00000000-0000-0000-0000-000000000000',
     @execution_mode=0,
     @is_enabled=False,
     @policy_id=@policy_id OUTPUT,
     @root_condition_name=N'',
     @object_set=N'Full Database Recovery Model_ObjectSet'
Select @policy_id
GO

--*********Listing 2-4***************************************
SELECT B.name AS 'CategoryName',
       A.name AS 'PolicyName',
       B.mandate_database_subscriptions,
       A.is_enabled
FROM msdb.dbo.syspolicy_policies_internal A INNER JOIN
     msdb.dbo.syspolicy_policy_categories_internal B ON
      A.policy_category_id = B.policy_category_id
ORDER BY B.name,
         A.name
         
         
--*********Listing 2-5***************************************
DECLARE @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition
@name=N'Every database – User and System',
@description=N'Condition that allows you to evaluate both user and system databases.',
@facet=N'Database',
@expression=N'<Operator>
<TypeClass>Bool</TypeClass>
<OpType>OR</OpType>
<Count>2</Count>
<Operator>
<TypeClass>Bool</TypeClass>
<OpType>EQ</OpType>
<Count>2</Count>
<Attribute>
<TypeClass>Bool</TypeClass>
<Name>IsSystemObject</Name>
</Attribute>
<Function>
<TypeClass>Bool</TypeClass>
<FunctionType>True</FunctionType>
<ReturnType>Bool</ReturnType>
<Count>0</Count>
</Function>
</Operator>
<Operator>
<TypeClass>Bool</TypeClass>
<OpType>EQ</OpType>
<Count>2</Count>
<Attribute>
<TypeClass>Bool</TypeClass>
<Name>IsSystemObject</Name>
</Attribute>
<Function>
<TypeClass>Bool</TypeClass>
<FunctionType>False</FunctionType>
<ReturnType>Bool</ReturnType>
<Count>0</Count>
</Function>
</Operator>
</Operator>', 
@is_name_condition=0, 
@obj_name=N'', 
@condition_id=@condition_id OUTPUT

SELECT @condition_id
GO          