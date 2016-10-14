--*********Listing 5-1***************************************
--MAKE SURE TO STOP SQL SERVER AGENT BEFORE RUNNING THIS SCRIPT!
USE msdb
GO
--Enable Database Mail
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO
--Enable Service Broker
ALTER DATABASE msdb SET ENABLE_BROKER
--Add the profile
EXEC msdb.dbo.sysmail_add_profile_sp
@profile_name = 'DBA Mail Profile',
@description = 'Profile used by the database administrator to send email.'

--Add the account
EXEC msdb.dbo.sysmail_add_account_sp
@account_name = 'DBA Mail Account',
@description = 'Profile used by the database administrator to send email.',
@email_address = 'DBA@somecompany.com',
@display_name = @@SERVERNAME,
@mailserver_name = 'KEN-PC'

--Associate the account with the profile
EXEC msdb.dbo.sysmail_add_profileaccount_sp
@profile_name = 'DBA Mail Profile',
@account_name = 'DBA Mail Account',
@sequence_number = 1
Print 'Don’t Forget To Restart SQL Server Agent!'


--*********Listing 5-2***************************************
--Basic email
EXEC msdb.dbo.sp_send_dbmail
@recipients='Somebody@SomeCompany.com', --[ ; ...n ]
@subject = 'Basic Database Mail Sample',
@body= 'This is a test email.',
@profile_name = 'DBA Email Profile'


--*********Listing 5-3***************************************
USE [msdb]
GO
/****** Object: Job [DBA - CleanupMsdbMailHistory] ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

/****** Object: JobCategory [Database Maintenance] ******/
IF NOT EXISTS (SELECT name
FROM msdb.dbo.syscategories
WHERE name=N'Database Maintenance' AND
category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category
@class=N'JOB',
@type=N'LOCAL',
@name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END
DECLARE @jobId BINARY(16)
EXEC @ReturnCode = msdb.dbo.sp_add_job
@job_name=N'DBA - CleanupMsdbMailHistory',
@enabled=1,
@notify_level_eventlog=2,
@notify_level_email=2,
@notify_level_netsend=0,
@notify_level_page=0,
@delete_level=0,
@description=N'No description available.',
@category_name=N'Database Maintenance',
@owner_login_name=N'sa',
@notify_email_operator_name=N'DBASupport',
@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object: Step [Cleanup Mail History older than 30 days] ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep
@job_id=@jobId,
@step_name=N'Cleanup Mail History older than 30 days',
@step_id=1,
@cmdexec_success_code=0,
@on_success_action=1,
@on_success_step_id=0,
@on_fail_action=2,
@on_fail_step_id=0,
@retry_attempts=0,
@retry_interval=1,
@os_run_priority=0, @subsystem=N'TSQL',
@command=N'DECLARE @DeleteBeforeDate DateTime
SELECT @DeleteBeforeDate = DATEADD(d,-30, GETDATE())
EXEC msdb..sysmail_delete_mailitems_sp @sent_before = @DeleteBeforeDate
EXEC msdb..sysmail_delete_log_sp @logged_before = @DeleteBeforeDate',
@database_name=N'master',
@output_file_name=N'',
@flags=0 

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job
@job_id = @jobId,
@start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule
@job_id=@jobId,
@name=N'CleanupMsdbMailHistory',
@enabled=1,
@freq_type=8,
@freq_interval=1,
@freq_subday_type=1,
@freq_subday_interval=0,
@freq_relative_interval=0,
@freq_recurrence_factor=1,
@active_start_date=20020103,
@active_end_date=99991231,
@active_start_time=40000,
@active_end_time=235959,
@schedule_uid=N'8e6a9641-4b58-49c6-931f-fbdaaca2ada5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver
@job_id = @jobId,
@server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--*********Listing 5-4***************************************

--MAKE SURE TO **START** SQL SERVER AGENT
--BEFORE RUNNING THIS SCRIPT!!!!!!!
--Enable SQL Server Agent to use Database Mail 
-- and set fail-safe operator
EXEC master.dbo.sp_MSsetalertinfo
@failsafeoperator=N'DBASupport', --Failsafe Operator
@notificationmethod=1,
@failsafeemailaddress = N'DBA@Somecompany.com'

EXEC msdb.dbo.sp_set_sqlagent_properties
@email_save_in_sent_folder=1

EXEC master.dbo.xp_instance_regwrite
N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'UseDatabaseMail',
N'REG_DWORD', 1

EXEC master.dbo.xp_instance_regwrite
N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'DatabaseMailProfile',
N'REG_SZ',
N'DBMailProfile'
PRINT '***********Please Restart SQL Server Agent!************'

--*********Listing 5-5***************************************

USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert
@name=N'Policy Violation: On change prevent automatic',
@message_id=34050,
@enabled=1,
@include_event_description_in=1,
@notification_message=N'A policy violation has occurred. Please review for root cause.'
GO
EXEC msdb.dbo.sp_add_notification
@alert_name=N'Policy Violation: On change prevent automatic',
@operator_name=N'DBA Support',
@notification_method = 1
GO
EXEC msdb.dbo.sp_add_alert
@name=N'Policy Violation: On change prevent on demand',
@message_id=34051,
@enabled=1,
@include_event_description_in=1,
@notification_message=N'A policy violation has occurred. Please review for root cause.'
GO
EXEC msdb.dbo.sp_add_notification
@alert_name=N'Policy Violation: On change prevent on demand',
@operator_name=N'DBA Support',
@notification_method = 1
GO
EXEC msdb.dbo.sp_add_alert
@name=N'Policy Violation: Scheduled',
@message_id=34052,
@enabled=1,
@include_event_description_in=1,
@notification_message=N'A policy violation has occurred. Please review for root cause.'
GO
EXEC msdb.dbo.sp_add_notification
@alert_name=N'Policy Violation: Scheduled',
@operator_name=N'DBA Support',
@notification_method = 1
GO
EXEC msdb.dbo.sp_add_alert
@name=N'Policy Violation: On change',
@message_id=34053,
@enabled=1,
@include_event_description_in=1,
@notification_message=N'A policy violation has occurred. Please review for root cause.'
GO
EXEC msdb.dbo.sp_add_notification
@alert_name=N'Policy Violation: On change',
@operator_name=N'DBA Support',
@notification_method = 1
GO


--*********Listing 5-6***************************************
SELECT sp.name,
       speh.exception_message
FROM msdb.dbo.syspolicy_policy_execution_history speh JOIN
     msdb.dbo.syspolicy_policies sp ON
     speh.policy_id = sp.policy_id
WHERE speh.exception_message <> ''