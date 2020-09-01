USE [slack_history]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[sp_create_slack_channel_table]
		@input_file = N'C:\CHC-ClinicalNetwork Slack export Jul 2 2015 - Aug 28 2020\channels.json'

SELECT	'Return Value' = @return_value

GO
