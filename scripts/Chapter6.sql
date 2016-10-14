--*********Listing 6-1***************************************

SELECT CAST(serverproperty(N'Servername') AS sysname) AS [Name],
CAST((SELECT current_value
FROM msdb.dbo.syspolicy_configuration
WHERE name = 'Enabled')
AS bit) AS [Enabled],
CAST((SELECT current_value
FROM msdb.dbo.syspolicy_configuration
WHERE name = 'HistoryRetentionInDays')
AS int) AS [HistoryRetentionInDays],
CAST((SELECT current_value
FROM msdb.dbo.syspolicy_configuration
WHERE name = 'LogOnSuccess')
AS bit) AS [LogOnSuccess]

--*********Listing 6-2***************************************

SELECT sc.name AS PropertyName,
job_id,
sj.name AS JobName,
[enabled]
FROM msdb.dbo.syspolicy_configuration sc JOIN
msdb.dbo.sysjobs sj ON
CAST(current_value as uniqueidentifier) = sj.job_id
WHERE sc.name = 'PurgeHistoryJobGuid'

--*********Listing 6-3***************************************

CREATE FUNCTION fn_syspolicy_is_automation_enabled()
RETURNS bit
AS
BEGIN
DECLARE @ret bit;
SELECT @ret = CONVERT(bit, current_value)
FROM msdb.dbo.syspolicy_configuration
WHERE name = 'Enabled'
RETURN @ret;
END

--*********Listing 6-4***************************************

IF (msdb.dbo.fn_syspolicy_is_automation_enabled() != 1)
BEGIN
RAISERROR(34022, 16, 1)
END

--*********Listing 6-5***************************************

SELECT *
FROM msdb.sys.tables
WHERE name LIKE 'syspolicy%'
ORDER BY name
--*********Listing 6-6***************************************

SELECT sp.name AS Policy,
sc.name AS Condition,
spehd.target_query_expression,
spehd.execution_date,
spehd.exception_message,
spehd.exception
FROM msdb.dbo.syspolicy_policies AS sp JOIN
msdb.dbo.syspolicy_conditions AS sc
ON sp.condition_id = sc.condition_id JOIN
msdb.dbo.syspolicy_policy_execution_history AS speh
ON sp.policy_id = speh.policy_id JOIN
msdb.dbo.syspolicy_policy_execution_history_details AS spehd
ON speh.history_id = spehd.history_id
WHERE spehd.result = 0

--*********Listing 6-7***************************************

SELECT *
FROM msdb.sys.views
WHERE name LIKE 'syspolicy%'
ORDER BY name

--*********Listing 6-8***************************************

SELECT SCHEMA_NAME(schema_id) AS SchemaName,
*
FROM msdb.sys.all_objects
WHERE type = 'P' AND
name like 'sp_syspolicy%'
ORDER BY name

