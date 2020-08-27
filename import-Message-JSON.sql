USE slack_history

Declare @JSON varchar(max)

IF OBJECT_ID('dbo.slack_message', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_message; 
--
-- Convert message.json file
--
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'C:\CHC-ClinicalNetwork Slack export May 1 2020 - Aug 25 2020\\ancora\2020-05-01.json', SINGLE_CLOB) import

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