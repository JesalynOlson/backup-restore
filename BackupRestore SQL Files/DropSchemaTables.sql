ALTER PROCEDURE [dbo].[DropSchemaTables]
	(
		@DatabaseName VARCHAR(10),
		@SchemaName VARCHAR(10) = 'FATJDTATST',
		@TablesToExclude VARCHAR(MAX) = 'AUDFIL'
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX) = ''

	CREATE TABLE #TablesToDrop
		(
			ID INT IDENTITY(1,1),
			TableName VARCHAR(100)
		)

	SET @SQL = '
		INSERT INTO #TablesToDrop (TableName)
			SELECT DISTINCT so.name
			FROM ' + @DatabaseName + '.sys.objects so
			INNER JOIN ' + @DatabaseName + '.sys.schemas s ON so.schema_id = s.schema_id
			WHERE s.name = ''' + @SchemaName +'''
				  AND so.type = ''U''
			ORDER BY so.name'

	EXEC sp_executesql @SQL

	DELETE t
	FROM #TablesToDrop t
	WHERE t.TableName IN (@TablesToExclude)

	SET @SQL = ''

	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @CurrentTableName VARCHAR(100)

	SELECT @EndInt = MAX(ID)
	FROM #TablesToDrop

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT @CurrentTableName = t.TableName FROM #TablesToDrop t WHERE t.ID = @StartInt

			IF (@CurrentTableName IS NOT NULL )
				BEGIN

					SET @SQL = @SQL + CHAR(10) + 'DROP TABLE ' + @DatabaseName + '.' + @SchemaName + '.' + @CurrentTableName + CHAR(10)

				END

			SET @StartInt = @StartInt + 1

		END

	EXEC sp_executesql @SQL		

END