USE slack_history

Declare @JSON varchar(max)

IF OBJECT_ID('dbo.slack_user', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_user; 
--
-- Convert user.json file
--
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'C:\CHC-ClinicalNetwork Slack export May 1 2020 - Aug 25 2020\users.json', SINGLE_CLOB) import

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
