USE slack_history

Declare @JSON varchar(max)
DECLARE @input_file NVARCHAR(MAX)
DECLARE @sql nvarchar(MAX)
DECLARE @ParmDefinition NVARCHAR(500)
DECLARE @table_schema NVARCHAR(MAX)

SET @input_file = 'C:\CHC-ClinicalNetwork Slack export Jul 2 2015 - Aug 28 2020\ancora\2017-05-16.json'
SET @sql = 'SELECT @JSON_OUT=BulkColumn FROM OPENROWSET (BULK ''' + @input_file + ''', SINGLE_CLOB) import'
SET @ParmDefinition = N'@JSON_OUT NVARCHAR(MAX) OUTPUT'

IF OBJECT_ID('dbo.slack_message', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_message; 
  
--
-- Convert message.json file
--
EXEC sp_executesql @sql, @ParmDefinition, @JSON_OUT = @JSON OUTPUT;

SELECT * INTO slack_message
FROM OPENJSON (@JSON)
WITH 
(
    client_msg_id	NVARCHAR(50),
	[type]			NVARCHAR(10),
	[text]			NVARCHAR(MAX),
	[user]			NVARCHAR(50),
	ts				NVARCHAR(50),
	team			NVARCHAR(50),
	user_team		NVARCHAR(50),
	source_team		NVARCHAR(50),
	thread_ts		NVARCHAR(50),
	subscribed		BIT,
	upload			BIT,
	files			NVARCHAR(MAX) AS JSON,
	reply_count		INT,
	reply_user_count	INT,
	latest_reply	NVARCHAR(50),
	reply_users		NVARCHAR(MAX) AS JSON,
	replies			NVARCHAR(MAX) AS JSON,
	user_profile	NVARCHAR(MAX) AS JSON,
	blocks			NVARCHAR(MAX) AS JSON,
	edited			NVARCHAR(MAX) AS JSON
)