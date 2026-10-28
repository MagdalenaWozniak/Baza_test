










CREATE procedure [dbo].[ONE_subs]
( 
@subscriptionID uniqueidentifier,
@parameterNameLIST nvarchar(4000), -- pipe delimeted
@parameterValueLIST nvarchar(4000), -- pipe delimeted
@ExtensionSettingNameLIST nvarchar(4000),
@ExtensionSettingValueLIST nvarchar(4000),

@exitCode int output,
@exitMessage nvarchar(255) output
)
AS

/*

DATE CREATED: 11/30/2007
AUTHOR: Matt Spilich : Heavily Modified from code from Jason L. Selburg (http://www.sqlservercentral.com/articles/Development/2824/)

PURPOSE: 
This procedure extends the functionality of the subscription feature in 
Microsoft SQL Reporting Services 2005, allowing the subscriptions to be triggered
via code. 


PARAMETERS:
@SubscriptionID = This is the GUID of the subscription for the report we want to blast. This is passed (instead of the report name to ensure uniqueness)

@parameterNameLIST nvarchar(4000), -- A pipe delimeted list of parameter names
@parameterValueLIST nvarchar(4000), -- A pipe delimeted list of values to replace those names with

-- ex. @parameterNameLIST = 'PARAM1|PARAM2|PRRAM3' where these are the parameter names defined in RS for the report
-- @parameterValueLIST = 'VALUE1|VALUE2|VALUE3' where these are the parameter values that match with each p name in the given sequance
-- 

@ExtensionSettingNameLIST nvarchar(4000),
@ExtensionSettingValueLIST nvarchar(4000), -- same as above. Here, some knowledge of what the Extenstion names the SSRS uses is required. Look at the XML, folks!

@exitCode = The returned integer value of the procedure's execution result. 
-2 'The subscription does not exist.'
-4 'A data base error occurred inserting the subscription history record.'
-5 'A data base error occurred clearing the previous subscription settings.'
-6 'A data base error occurred replacing the XML of the ExtensionSetting.' 
-7 'A data base error occurred updating the Delivery settings.'
-8 'A data base error occurred replacing the XML of the Parameter.'
-9 'A data base error occurred updating the Parameter settings.'
-10 'A data base error occurred updating the subscription history record.'
-11 'A data base error occurred resetting the previous subscription settings.'

@exitMessage = The text description of the failure or success of the procedure.

PRECONDITIONS:
The subscription being called must exist

If any of the recipients email address are outside of the report server's domain, then you may
need to contact your Network Administrator to allow email forwarding from your email server.

POST CONDITIONS:
The report is delivered or an error code and message is returned.

SECURITY REQUIREMENTS:
The user which calls this stored procedure must have execute permissions.

DEPENDANCES:
Tables:
ReportSchedule = Installed with SQL RS 2005
Subscription_History = Must be created using the following script.
---------------------------------------------------------------------
CREATE TABLE [dbo].[Custom_Subscription_History](
[nDex] [int] IDENTITY(1,1) NOT NULL,
[SubscriptionID] [uniqueidentifier] NULL,
[ScheduleName] [nvarchar](260) COLLATE Latin1_General_CI_AS_KS_WS NULL,
[parameterSettings] [varchar](8000) COLLATE Latin1_General_CI_AS_KS_WS NULL,
[deliverySettings] [varchar](8000) COLLATE Latin1_General_CI_AS_KS_WS NULL,
[dateExecuted] [datetime] NULL,
[executeStatus] [nvarchar] (260) NULL,
[dateCompleted] [datetime] NULL,
[executionTime] AS (datediff(second,[datecompleted],[dateexecuted])),
CONSTRAINT [PK_Subscription_History] PRIMARY KEY CLUSTERED 
(
[nDex] ASC
)WITH (PAD_INDEX = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
---------------------------------------------------------------------

Subscriptions = Installed with SQL RS 2005
Schedule = Installed with SQL RS 2005 

*/


DECLARE
--@subscriptionID uniqueidentifier,
@scheduleID uniqueidentifier,
@delim varchar(1),
@NODE_NAME varchar(1000),
@NODE_VALUE varchar(1000),
@SUB_DATA xml,
@UPDATE_DONE bit,
@lerror int,

@starttime datetime,
@lastruntime datetime,
@execTime datetime,
@previousDVALUES nvarchar (4000),
@previousPVALUES nvarchar (4000),

@insertID int,
@lretval int,
@rowcount int


DECLARE @PARAMS TABLE (PARAM_NAME varchar(1000), PARAM_VALUE varchar(1000))
DECLARE @EXTENSION TABLE (EXTENSION_NAME varchar(1000), EXTENSION_VALUE varchar(1000))

set @delim = '|'
set @UPDATE_DONE = 0
set @starttime = dateadd(ss,-2,getdate())

-- populate the @PARAMS table
insert into @PARAMS 
select A.value [Name], B.value [Value] from dbo.fn_Split(@parameterNameLIST,@delim) A
inner join dbo.fn_Split(@parameterValueLIST,@delim) B
on A.idx = B.idx

-- populate the @EXTENSION table
insert into @EXTENSION 
select A.value [Name], B.value [Value] from dbo.fn_Split(@ExtensionSettingNameLIST,@delim) A
inner join dbo.fn_Split(@ExtensionSettingValueLIST,@delim) B
on A.idx = B.idx


select @scheduleID = rs.ScheduleID
FROM 
ReportServer.dbo.ReportSchedule rs
WHERE rs.subscriptionID = @subscriptionID

IF @subscriptionID Is Null or @scheduleID is NULL
BEGIN
SET @exitCode = -2
SET @exitMessage = 'The subscription does not exist.'
RETURN 0
END


-- Modify the XML in the Parameters column to use the data that was passed in.
select @SUB_DATA = Parameters
, @previousDVALUES = extensionSettings
, @previousPVALUES = parameters 
from ReportServer.dbo.Subscriptions 
where SubscriptionID = @subscriptionID

set @UPDATE_DONE = 0
Declare C_PARAMS cursor for select * from @PARAMS
open C_PARAMS
fetch next from C_PARAMS into @NODE_NAME, @NODE_VALUE
WHILE @@FETCH_STATUS = 0
BEGIN

set @SUB_DATA.modify('
replace value of (/ParameterValues[1]/ParameterValue[Name=sql:variable("@NODE_NAME")][1]/Value[1]/text()[1])
with sql:variable("@NODE_VALUE") 
') 

print convert(varchar(max), @SUB_DATA)

set @UPDATE_DONE = 1

fetch next from C_PARAMS into @NODE_NAME, @NODE_VALUE
END
if @UPDATE_DONE = 1
BEGIN
update ReportServer.dbo.Subscriptions set Parameters = convert(text, convert(varchar(max), @SUB_DATA)) where subscriptionID = @subscriptionID

SELECT @lerror=@@error

IF @lerror <> 0 
BEGIN
SET @exitCode = -8
SET @exitMessage = 'A data base error occurred updating the XML of the Parameter settings.' 
RETURN IsNull(@lerror, 0)
END 
END
close C_PARAMS
deallocate C_PARAMS


-- Modify the XML in the ExtensionSettings column to use the data that was passed in.
select @SUB_DATA = ExtensionSettings from ReportServer.dbo.Subscriptions where SubscriptionID = @subscriptionID
set @UPDATE_DONE = 0
Declare C_SETTINGS cursor for select * from @EXTENSION
open C_SETTINGS
fetch next from C_SETTINGS into @NODE_NAME, @NODE_VALUE
WHILE @@FETCH_STATUS = 0
BEGIN

set @SUB_DATA.modify('
replace value of (/ParameterValues[1]/ParameterValue[Name=sql:variable("@NODE_NAME")][1]/Value[1]/text()[1])
with sql:variable("@NODE_VALUE") 
')
set @UPDATE_DONE = 1
fetch next from C_SETTINGS into @NODE_NAME, @NODE_VALUE
END
close C_SETTINGS
deallocate C_SETTINGS
if @UPDATE_DONE = 1
BEGIN
update ReportServer.dbo.Subscriptions set ExtensionSettings = convert(text, convert(varchar(max), @SUB_DATA)) where subscriptionID = @subscriptionID
print convert(text, convert(varchar(max), @SUB_DATA))
SELECT @lerror=@@error

IF @lerror <> 0 
BEGIN
SET @exitCode = -9
SET @exitMessage = 'A data base error occurred updating the XML of the ExtensionSettings settings.' 
RETURN IsNull(@lerror, 0)
END 
END


-- insert a record into the history table

SET @execTime = getdate()
INSERT dbo.[SubscriptionHistory] 
(SubscriptionID, ScheduleName, ParameterSettings, DeliverySettings, DateExecuted, ExecuteStatus) 
select subscriptionID, '', Parameters, ExtensionSettings , @execTime, 'incomplete' 
from ReportServer.dbo.Subscriptions
where subscriptionID = @subscriptionID


SELECT @lerror=@@error, @rowcount=@@rowCount

IF @lerror <> 0 OR IsNull(@rowcount, 0) = 0
BEGIN
SET @exitCode = -4 
SET @exitMessage = 'A data base error occurred inserting the subscription history record.'
RETURN IsNull(@lerror, 0)
END

-- run the job
EXEC msdb..sp_start_job @job_name = @scheduleID

-- this gives the report server time to execute the job
-- We're going to look for the report in executionlog, that's the best way to actaully wait for it to complete.
-- I don't know for sure that it will appear if there is an issue, so we'll wait up to 5 minutes in total.

--While not exists (select 
-- or 
SELECT @lastruntime = LastRunTime FROM ReportServer..Schedule WHERE ScheduleID = @scheduleID
WHILE (@starttime > @lastruntime)
BEGIN

SELECT @lastruntime = LastRunTime FROM ReportServer..Schedule WHERE ScheduleID = @scheduleID
END

/* update the history table with the completion time */
UPDATE [SubscriptionHistory] 
SET DateCompleted = getdate(), ExecuteStatus = 'completed'
WHERE SubscriptionID = @subscriptionID 
and DateExecuted = @execTime

SELECT @lerror=@@error, @rowcount=@@rowCount

IF @lerror <> 0 OR IsNull(@rowcount, 0) = 0
BEGIN
SET @exitCode = -10
SET @exitMessage = 'A data base error occurred updating the subscription history record.' 
RETURN IsNull(@lerror, 0)
END

/* reset the previous delivery and parameter values */ 
UPDATE ReportServer.dbo.Subscriptions 
SET extensionSettings = @previousDVALUES
, parameters = @previousPVALUES 
WHERE SubscriptionID = @subscriptionID

SELECT @lerror=@@error, @rowcount=@@rowCount

IF @lerror <> 0 OR IsNull(@rowcount, 0) = 0
BEGIN
SET @exitCode = -11
SET @exitMessage = 'A data base error occurred resetting the previous subscription settings.' 
RETURN IsNull(@lerror, 0)
END

/* return the result of the subscription */
SELECT @exitMessage = LastStatus 
FROM ReportServer.dbo.Subscriptions 
WHERE subscriptionID = @subscriptionID

SET @exitCode = 1
RETURN 0










