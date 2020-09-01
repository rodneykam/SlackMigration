USE slack_history
GO

IF EXISTS
(
   SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID( N'sp_create_slack_message_table' ) AND OBJECTPROPERTY( id, N'IsProcedure' ) = 1
)
   DROP PROCEDURE sp_create_slack_message_table
GO

CREATE PROCEDURE sp_create_slack_message_table
AS
BEGIN

IF OBJECT_ID('dbo.slack_message', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_message; 
  
CREATE TABLE slack_message
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
	files			NVARCHAR(MAX), -- AS JSON,
	reply_count		INT,
	reply_user_count	INT,
	latest_reply	NVARCHAR(50),
	reply_users		NVARCHAR(MAX), -- AS JSON,
	replies			NVARCHAR(MAX), -- AS JSON,
	user_profile	NVARCHAR(MAX), -- AS JSON,
	blocks			NVARCHAR(MAX), -- AS JSON,
	reactions		NVARCHAR(MAX), -- AS JSON,
	is_starred		NVARCHAR(MAX), -- AS JSON,
	edited			NVARCHAR(MAX)  -- AS JSON
)
END
GO