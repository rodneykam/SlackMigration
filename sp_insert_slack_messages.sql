USE slack_history
GO

IF EXISTS
(
   SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID( N'sp_insert_slack_messages' ) AND OBJECTPROPERTY( id, N'IsProcedure' ) = 1
)
   DROP PROCEDURE sp_insert_slack_messages
GO

CREATE PROCEDURE sp_insert_slack_messages
	@input_file NVARCHAR(MAX)	
AS
BEGIN
Declare @JSON varchar(max)
DECLARE @sql nvarchar(MAX)
DECLARE @ParmDefinition NVARCHAR(500)

SET @sql = 'SELECT @JSON_OUT=BulkColumn FROM OPENROWSET (BULK ''' + @input_file + ''', SINGLE_CLOB) import'
SET @ParmDefinition = N'@JSON_OUT NVARCHAR(MAX) OUTPUT'

--
-- Convert message.json file
--
EXEC sp_executesql @sql, @ParmDefinition, @JSON_OUT = @JSON OUTPUT;

INSERT INTO slack_message 
(
	client_msg_id,
	[type],
	[text],
	[user],
	ts,
	team,
	user_team,
	source_team,
	thread_ts,
	subscribed,
	upload,
	files,
	reply_count,
	reply_user_count,
	latest_reply,
	reply_users,
	replies,
	user_profile,
	blocks,
	reactions,
	is_starred,
	edited
)
SELECT *
FROM OPENJSON (@JSON)
WITH (
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
	reactions		NVARCHAR(MAX) AS JSON,
	is_starred		BIT,
	edited			NVARCHAR(MAX) AS JSON
)
END