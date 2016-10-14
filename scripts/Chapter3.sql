-- ************* Listing 3-1 ************************
SELECT c.name as 'JobName', a.policy_id, a.name as 'PolicyName', a.is_enabled
FROM msdb.dbo.syspolicy_policies a INNER JOIN
msdb.dbo.sysjobschedules b ON a.job_id = B.job_id INNER JOIN
msdb.dbo.sysjobs c ON b.job_id = c.job_id
WHERE a.execution_mode = 4

-- ************* Listing 3-2 ************************
SELECT a.name as 'PolicyName'
FROM msdb.dbo.syspolicy_policies a INNER JOIN
msdb.dbo.syspolicy_conditions b ON a.condition_id = b.condition_id INNER JOIN
msdb.dbo.syspolicy_management_facets c ON b.facet = c.name
WHERE c.execution_mode & 2 = 2

-- ************* Listing 3-3 ************************
SELECT a.name as 'PolicyName'
FROM msdb.dbo.syspolicy_policies a INNER JOIN
msdb.dbo.syspolicy_conditions b ON a.condition_id = b.condition_id INNER JOIN
msdb.dbo.syspolicy_management_facets c ON b.facet = c.name
WHERE c.execution_mode & 1 = 1

