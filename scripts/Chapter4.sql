-- ************* Listing 4-1 ************************
$SQLCon = New-Object System.Data.SqlClient.SqlConnection
$SQLCon.ConnectionString
= "Server = TESTLAB01\BENCHDBS04; Database = msdb;
Integrated Security = True"
$SQLCmd = New-Object System.Data.SqlClient.SqlCommand
$SQLCmd.CommandText = "SELECT [name] FROM dbo.syspolicy_policies"
$SQLCmd.Connection = $SQLCon
$SQLDataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SQLDataAdapter.SelectCommand = $SQLCmd
$DataSet = New-Object System.Data.DataSet
$SQLDataAdapter.Fill($DataSet)
$DataSet.Tables[0]
$SQLCon.Close()

-- ************* Listing 4-2 ************************
$SQLPBMConnection = new-object Microsoft.SQLServer.Management.Sdk.Sfc.SqlStoreConnection("server= TESTLAB01\BENCHDBS04;
Trusted_Connection=true");
$SQLPolicyStore = new-object Microsoft.SqlServer.Management.DMF.PolicyStore($SQLPBMConnection);
foreach ($Policy in $SQLPolicyStore.Policies)
{
$Policy.Name
}

-- ************* Listing 4-3 ************************
$SQLPBMConnection = new-object Microsoft.SQLServer.Management.Sdk.Sfc.SqlStoreConnection("server=TESTLAB01\BENCHDBS04; Trusted_Connection=true");
$SQLPolicyStore = new-object Microsoft.SqlServer.Management.DMF.PolicyStore($SQLPBMConnection);
$SQLPolicyStore | get-member

-- ************* Listing 4-4 ************************
Set-Location "C:\Program Files\Microsoft SQL Server\100\Tools\Policies\DatabaseEngine\1033"
Invoke-PolicyEvaluation -Policy "Database Auto Shrink.xml" -TargetServer "TESTLAB01\BENCHDBS04"

-- ************* Listing 4-5 ************************
Set-Location "C:\Program Files\Microsoft SQL Server\100\Tools\Policies\DatabaseEngine\1033"
Invoke-PolicyEvaluation -Policy "Database Auto Shrink.xml" -TargetServer "TESTLAB\BENCHDBS01"
-OutputXML > C:\AutoShrink.xml

-- ************* Listing 4-6 ************************
<DMF:ResultDetail type="string"><Operator><?char 13?> <TypeClass>Bool</TypeClass><?char 13?> <OpType>EQ</OpType><?char 13?> <ResultObjType>System.Boolean</ResultObjType><?char 13?> <ResultValue>True</ResultValue><?char 13?> <Count>2</Count><?char 13?> <Attribute><?char 13?> <TypeClass>Unsupported</TypeClass><?char 13?> <Name>AutoShrink</Name><?char 13?> <ResultObjType>System.Boolean</ResultObjType><?char 13?> <ResultValue>False</ResultValue><?char 13?> </Attribute><?char 13?> <Function><?char 13?> <TypeClass>Bool</TypeClass><?char 13?> <FunctionType>False</FunctionType><?char 13?> <ReturnType>Bool</ReturnType><?char 13?> <ResultObjType>System.Boolean</ResultObjType><?char 13?> <ResultValue>False</ResultValue><?char 13?> <Count>0</Count><?char 13?> </Function><?char 13?> </Operator></DMF:ResultDetail>
<DMF:TargetQueryExpression type="string">SQLSERVER:\SQL\TESTLAB01\BENCHDBS01\Databases\Northwind</DMF:TargetQueryExpression>
<DMF:ID type="long">1</DMF:ID>
<DMF:Result type="boolean">true</DMF:Result>

-- ************* Listing 4-7 ************************
Set-Location SQLSERVER:\SQLPolicy\TESTLAB01\BENCHDBS04\Policies
Get-ChildItem | Where-Object {$_.Name -eq "Database Auto Shrink"} |
Invoke-PolicyEvaluation -TargetServer "TESTLAB01\BENCHDBS04"

-- ************* Listing 4-8 ************************
Set-Location "C:\Program Files\Microsoft SQL Server\100\Tools\Policies\DatabaseEngine\1033"
Invoke-PolicyEvaluation -Policy "Database Auto Shrink.xml", "Database Auto Close.xml" -TargetServer "TESTLAB01\BENCHDBS04"

-- ************* Listing 4-9 ************************
Set-Location "C:\Program Files\Microsoft SQL Server\100\Tools\Policies\DatabaseEngine\1033"
$AllPolicies = get-childitem -Name
foreach ( $Policy in $AllPolicies)
{
$PolicyInCategory = select-string "Microsoft Best Practices: Maintenance" $Policy
If ($PolicyInCategory -ine $null)
{
Invoke-PolicyEvaluation -Policy $policy -TargetServer "TESTLAB01\BENCHDBS04"
}
}

-- ************* Listing 4-10 ************************
Set-Location SQLSERVER:\SQLPolicy\TESTLAB01\BENCHDBS04\Policies
Get-ChildItem | Where-Object {$_.PolicyCategory -eq "Microsoft Best Practices: Maintenance"}
| Invoke-PolicyEvaluation -TargetServer "TESTLAB01\BENCHDBS04"

-- ************* Listing 4-11 ************************
USE PBMResults
CREATE TABLE [dbo].[PolicyHistory_staging](
[PolicyHistoryID] [int] IDENTITY(1,1) NOT NULL,
[EvalServer] [nvarchar](100) NULL,
[EvalDateTime] [datetime] NULL,
[EvalPolicy] [nvarchar](max) NULL,
[EvalResults] [xml] NULL,
CONSTRAINT [PK_PolicyHistory_staging] PRIMARY KEY CLUSTERED
(
[PolicyHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PolicyHistory_staging] ADD CONSTRAINT [DF_PolicyHistory_EvalDateTime] DEFAULT (getdate()) FOR [EvalDateTime]
GO

-- ************* Listing 4-12 ************************
$TargetServer = "TESTLAB01\BENCHDBS04"
$OutputXML = "C:\PowerShell\EvaluationDetails\AutoShrink.xml"
$PolicyName = "Database Auto Shrink"
$ServerInstance = "TESTLAB01\BENCHDBS04"
$Database = "PBMResults"
Set-Location "C:\Program Files\Microsoft SQL Server\100\Tools\Policies\DatabaseEngine\1033"
Invoke-PolicyEvaluation -Policy "Database Auto Shrink.xml" -TargetServer $TargetServer -OutputXML > $OutputXML
$PolicyResult = Get-Content $OutputXML;
$EvalResults = $PolicyResult -replace "'", "''"
$QueryText = "INSERT INTO PolicyHistory_staging (EvalServer, EvalPolicy, EvalResults)
VALUES(N'$TargetServer', N'$PolicyName', N'$EvalResults')"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $QueryText

-- ************* Listing 4-13 ************************
CREATE VIEW [dbo].[vw_PolicyResults] AS
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/DMF/2007/08' AS XMLNS)
SELECT EvalServer, EvalDateTime, EvalPolicy,
ResultNodes.NodeDetails.value('(../XMLNS:TargetQueryExpression)[1]', 'nvarchar(150)') AS EvaluatedObject,
(CASE
WHEN
ResultNodes.NodeDetails.value('(../XMLNS:Result)[1]', 'nvarchar(150)')= 'FALSE' AND
NodeDetails.value('(../XMLNS:Exception)[1]', 'nvarchar(max)') = ''
THEN 0
WHEN ResultNodes.NodeDetails.value('(../XMLNS:Result)[1]', 'nvarchar(150)')= 'FALSE' AND
NodeDetails.value('(../XMLNS:Exception)[1]', 'nvarchar(max)')<> ''
THEN 99
ELSE 1
END) AS PolicyResult
FROM dbo.PolicyHistory_staging CROSS APPLY
EvalResults.nodes('
declare default element namespace "http://schemas.microsoft.com/sqlserver/DMF/2007/08";
//TargetQueryExpression') AS ResultNodes(NodeDetails)
GO

-- ************* Listing 4-14 ************************
function PopulateStagingTable($ServerVariable, $DBVariable, $EvalServer, $EvalPolicy, $EvalResults)fa
{
$EvalResults = $EvalResults -replace "'", "''"
$EvalPolicy = $EvalPolicy -replace "'", "''"
$QueryText = "INSERT INTO PolicyHistory_staging (EvalServer, EvalPolicy, EvalResults)
VALUES(N'$EvalServer', '$EvalPolicy', N'$EvalResults')"
Invoke-Sqlcmd -ServerInstance $ServerVariable -Database $DBVariable -Query $QueryText
}
$PBMResultsInstance = "TESTLAB01\BENCHDBS04"
$HistoryDatabase = "PBMResults"
$PolicyInstance = $PBMResultsInstance
$CMSGroup = 'SQLSERVER:\SQLRegistration\Central Management Server Group\' + (Encode-SqlName $PolicyInstance) + '\AllServers\'
$PolicyOutputLocation = "C:\PowerShell\EvaluationDetails\"
$PolicyCategory = "Microsoft Best Practices: Maintenance"
$PolicyStoreConnection = new-object Microsoft.SQlServer.Management.Sdk.Sfc.SqlStoreConnection("server=$PolicyInstance;Trusted_Connection=true");
$PolicyStore = new-object Microsoft.SqlServer.Management.DMF.PolicyStore($PolicyStoreConnection);
$InstanceListFromCMS = dir $CMSGroup -recurse | where-object { $_.Mode.Equals("-") } | select-object Name -Unique
del C:\PowerShell\EvaluationDetails\*
foreach ($InstanceName in $InstanceListFromCMS)
{
foreach ($Policy in $PolicyStore.Policies)
{
if ($Policy.PolicyCategory -eq $PolicyCategory)
{
$PolicyNameFriendly = (Encode-SqlName $Policy.Name)
$InstanceNameFriendly = (Encode-SqlName $InstanceName.Name)
$OutputFile = $PolicyOutputLocation + ("{0}_{1}.xml" -f $InstanceNameFriendly, $PolicyNameFriendly);
Invoke-PolicyEvaluation -Policy $policy -TargetServerName $InstanceName.Name -OutputXML > $OutputFile;
$PolicyResult = Get-Content $OutputFile;
PopulateStagingTable $PBMResultsInstance $HistoryDatabase $InstanceName.Name $Policy.Name $PolicyResult;
}
}
}
