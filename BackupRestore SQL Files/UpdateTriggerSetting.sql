ALTER PROCEDURE [dbo].[UpdateTriggerSetting]
	(
		@Disable BIT,
		@DatabaseName VARCHAR(10),
		@SchemaName VARCHAR(10)
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX) = ''

	CREATE TABLE #Triggers
		(
			TableName VARCHAR(100),
			ID INT IDENTITY(1,1)
		)

	SET @SQL = '
		INSERT INTO #Triggers (TableName)
			SELECT DISTINCT so.name
			FROM ' + @DatabaseName + '.sys.triggers st
			INNER JOIN ' + @DatabaseName + '.sys.objects so ON st.parent_id = so.object_id
			ORDER BY so.name'

	EXEC sp_executesql @SQL

	SET @SQL = ''

	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @CurrentTableName VARCHAR(100)

	SELECT @EndInt = MAX(ID)
	FROM #Triggers

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT @CurrentTableName = t.TableName FROM #Triggers t WHERE t.ID = @StartInt

			SET @SQL = @SQL + CHAR(10) + 'ALTER TABLE ' + @DatabaseName + '.' + @SchemaName + '.' + @CurrentTableName + CASE WHEN @Disable = 1 THEN ' DISABLE ' ELSE ' ENABLE ' END + 'TRIGGER ALL' + CHAR(10)

			SET @StartInt = @StartInt + 1

		END

	EXEC sp_executesql @SQL

END