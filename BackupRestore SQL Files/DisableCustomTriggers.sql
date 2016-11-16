ALTER PROCEDURE [dbo].[DisableCustomTriggers]
	(
		@DatabaseName VARCHAR(10)
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX) = ''
	
	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @CurrentTableName VARCHAR(100)
	DECLARE @SchemaName VARCHAR(10)
	DECLARE @TriggerName VARCHAR(100)

	SELECT @EndInt = MAX(ID)
	FROM dbo.TriggersToDisable

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT
				@CurrentTableName = t.TableName,
				@SchemaName = t.SchemaName,
				@TriggerName = t.TriggerName
			FROM dbo.TriggersToDisable t
			WHERE t.ID = @StartInt

			SET @SQL = @SQL + CHAR(10) + 'ALTER TABLE ' + @DatabaseName + '.' + @SchemaName + '.' + @CurrentTableName + ' DISABLE TRIGGER ' + @TriggerName + CHAR(10)

			SET @StartInt = @StartInt + 1

		END

	EXEC sp_executesql @SQL		

END