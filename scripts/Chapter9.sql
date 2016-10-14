--*********Listing 9-1***************************************
DECLARE @ServiceAccount TABLE
       (Value VARCHAR(50),
        Data VARCHAR(50))
        
DECLARE @RegistryLocation VARCHAR(200)

IF CHARINDEX('\',@@SERVERNAME)=0
  SET @RegistryLocation = 'SYSTEM\CurrentControlSet\Services\MSSQLSERVER'
ELSE
BEGIN
  SET @RegistryLocation ='SYSTEM\CurrentControlSet\Services\MSSQL$' +
                          RIGHT(@@SERVERNAME,LEN(@@SERVERNAME)-
                          CHARINDEX('\',@@SERVERNAME))
END
INSERT INTO @ServiceAccount
EXEC master.dbo.xp_regread
       'HKEY_LOCAL_MACHINE' ,
       @RegistryLocation,
       'ObjectName'
       
SELECT TOP 1 Data AS ServiceAccount
FROM @ServiceAccount

--*********Listing 9-2***************************************
DECLARE @RegValues TABLE(Value VARCHAR(50), Data VARCHAR(50))
DECLARE @RegPath VARCHAR(200)
DECLARE @ObjectName VARCHAR(50)
DECLARE @RegLocation VARCHAR(50) 

--1. Get the location of the instance name in the registry
SET @RegPath = 'Software\Microsoft\Microsoft SQL Server\Instance Names\SQL\'
IF CHARINDEX('\',@@SERVERNAME) = 0
  --Not a named instance
  SET @ObjectName = 'MSSQLSERVER'
ELSE
  --Named instance
  SET @ObjectName = RIGHT(@@SERVERNAME,LEN(@@SERVERNAME) - CHARINDEX('\',@@SERVERNAME))
  
INSERT INTO @RegValues
EXEC master.dbo.xp_regread
  'HKEY_LOCAL_MACHINE',
  @RegPath,
  @ObjectName
  
SELECT @RegLocation = Data
FROM @RegValues

--2. Now get the number of error logs based on the location
SET @RegPath = 'Software\Microsoft\Microsoft SQL Server\' +
    @RegLocation + '\MSSQLServer'
    
SET @ObjectName = 'NumErrorLogs'

DELETE FROM @RegValues

INSERT INTO @RegValues
EXEC master.dbo.xp_regread
  'HKEY_LOCAL_MACHINE',
  @RegPath,
  @ObjectName
  
SELECT Data
FROM @RegValues


--*********Listing 9-3***************************************
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
-- Enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO


--*********Listing 9-4***************************************
SELECT COUNT(*)
FROM sys.server_principals
WHERE name = 'Builtin\Administrators'

--*********Listing 9-5***************************************
SELECT COUNT(*)
FROM sys.server_principals
WHERE name = 'sa' AND
      is_disabled = 1
         