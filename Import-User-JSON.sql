USE slack_history

Declare @JSON varchar(max)
DECLARE @input_file NVARCHAR(MAX)
DECLARE @sql nvarchar(MAX)
DECLARE @ParmDefinition NVARCHAR(500)

SET @input_file = 'C:\CHC-ClinicalNetwork Slack export Jul 2 2015 - Aug 28 2020\users.json'
SET @sql = 'SELECT @JSON_OUT=BulkColumn FROM OPENROWSET (BULK ''' + @input_file + ''', SINGLE_CLOB) import'
SET @ParmDefinition = N'@JSON_OUT NVARCHAR(MAX) OUTPUT'

--
-- Delete Table before creating a new one
--
IF OBJECT_ID('dbo.slack_user', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_user; 

--
-- Migrate user.json file
--
EXEC sp_executesql @sql, @ParmDefinition, @JSON_OUT = @JSON OUTPUT;

SELECT * INTO slack_user
FROM OPENJSON (@JSON)
WITH 
(
    id			NVARCHAR(50),
	team_id		NVARCHAR(50),
	name		NVARCHAR(100),
	real_name   NVARCHAR(100) '$.profile.real_name',
	deleted		BIT,
	is_bot		BIT,
	is_app_user	BIT,
	updated		BIGINT,
	profile		NVARCHAR(MAX) AS JSON
)

PRINT 'Done!'
