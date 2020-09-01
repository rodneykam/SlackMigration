USE slack_history
GO

IF EXISTS
(
   SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID( N'sp_create_slack_channel_table' ) AND OBJECTPROPERTY( id, N'IsProcedure' ) = 1
)
   DROP PROCEDURE sp_create_slack_channel_table
GO

CREATE PROCEDURE sp_create_slack_channel_table
	@input_file NVARCHAR(MAX)	
AS
BEGIN
Declare @JSON varchar(max)
DECLARE @sql nvarchar(MAX)
DECLARE @ParmDefinition NVARCHAR(500)

SET @sql = 'SELECT @JSON_OUT=BulkColumn FROM OPENROWSET (BULK ''' + @input_file + ''', SINGLE_CLOB) import'
SET @ParmDefinition = N'@JSON_OUT NVARCHAR(MAX) OUTPUT'

IF OBJECT_ID('dbo.slack_channel', 'U') IS NOT NULL 
  DROP TABLE dbo.slack_channel; 

--
-- Migrate channel.json file
--
EXEC sp_executesql @sql, @ParmDefinition, @JSON_OUT = @JSON OUTPUT;

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
END
GO