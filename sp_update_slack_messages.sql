USE slack_history
GO

IF EXISTS
(
   SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID( N'sp_update_slack_messages' ) AND OBJECTPROPERTY( id, N'IsProcedure' ) = 1
)
   DROP PROCEDURE sp_update_slack_messages
GO

CREATE PROCEDURE sp_update_slack_messages
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

MERGE slack_message AS original
USING (SELECT   client_msg_id AS msg_id,
				[type] AS msg_type,
				[text] AS msg_text,
				[user] AS msg_user,
				ts AS msg_ts,
				team AS msg_team,
				user_team AS msg_user_team,
				source_team AS msg_source_team,
				thread_ts AS msg_thread_ts,
				subscribed AS msg_subscribed,
				upload AS msg_upload,
				files AS msg_files,
				reply_count AS msg_reply_count,
				reply_user_count AS msg_reply_user_count,
				latest_reply AS msg_latest_reply,
				reply_users AS msg_reply_users,
				replies AS msg_replies,
				user_profile AS msg_user_profile,
				blocks AS msg_blocks,
				reactions AS msg_reactions,
				is_starred AS msg_is_starred,
				edited AS msg_edited
	   FROM OPENJSON(@JSON)
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
		)) modified
ON (original.client_msg_id = modified.msg_id)
WHEN MATCHED
	THEN UPDATE SET
		original.[type] = modified.msg_type,
		original.[text] = modified.msg_text,
		original.[user] = modified.msg_user,
		original.ts = modified.msg_ts,
		original.team = modified.msg_team,
		original.user_team = modified.msg_user_team,
		original.source_team = modified.msg_source_team,
		original.thread_ts = modified.msg_thread_ts,
		original.subscribed = modified.msg_subscribed,
		original.upload = modified.msg_upload,
		original.files = modified.msg_files,
		original.reply_count = modified.msg_reply_count,
		original.reply_user_count = modified.msg_reply_user_count,
		original.latest_reply = modified.msg_latest_reply,
		original.reply_users = modified.msg_reply_users,
		original.replies = modified.msg_replies,
		original.user_profile = modified.msg_user_profile,
		original.blocks = modified.msg_blocks,
		original.reactions = modified.msg_reactions,
		original.is_starred = modified.msg_is_starred,
		original.edited = modified.msg_edited
WHEN NOT MATCHED BY TARGET
	THEN INSERT (
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
	VALUES (
		modified.msg_id,
		modified.msg_type,
		modified.msg_text,
		modified.msg_user,
		modified.msg_ts,
		modified.msg_team,
		modified.msg_user_team,
		modified.msg_source_team,
		modified.msg_thread_ts,
		modified.msg_subscribed,
		modified.msg_upload,
		modified.msg_files,
		modified.msg_reply_count,
		modified.msg_reply_user_count,
		modified.msg_latest_reply,
		modified.msg_reply_users,
		modified.msg_replies,
		modified.msg_user_profile,
		modified.msg_blocks,
		modified.msg_reactions,
		modified.msg_is_starred,
		modified.msg_edited
	);

END
GO