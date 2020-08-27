USE slack_history

Declare @JSON varchar(max)

IF OBJECT_ID('dbo.slack_channel', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_channel; 
--
-- Convert channel.json file
--
SELECT @JSON=BulkColumn
FROM OPENROWSET (BULK 'C:\CHC-ClinicalNetwork Slack export May 1 2020 - Aug 25 2020\channels.json', SINGLE_CLOB) import

SELECT * INTO slack_channel
FROM OPENJSON (@JSON)
WITH 
(
    id			NVARCHAR(50),
	name		NVARCHAR(100),
	created     BIGINT,
	creator		NVARCHAR(50),
	is_archived	BIT,
	is_general	BIT,
	topic		NVARCHAR(255) '$.topic.value',
	purpose		NVARCHAR(255) '$.purpose.value',
	members		NVARCHAR(MAX) AS JSON,
	pins		NVARCHAR(MAX) AS JSON
)
ORDER BY name