ALTER PROCEDURE [dbo].[InsertSetupTables]
	(
		@DatabaseName VARCHAR(10),
		@SchemaName VARCHAR(10) = 'MVXJDTA',
		@IsRefreshSetup BIT = 0
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Schema NVARCHAR(3)
	DECLARE @SQL NVARCHAR(MAX) = ''

	SELECT @Schema = CASE @DatabaseName WHEN 'M3EDBDEV' THEN 'DEV'
										WHEN 'M3EDBTST' THEN 'TST' END

	CREATE TABLE #SetupTables
		(
			TableName VARCHAR(100),
			ID INT IDENTITY(1,1)
		)
	
	INSERT INTO #SetupTables (TableName)
		SELECT t.Name
		FROM sys.tables t
			 INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
		WHERE s.Name = @Schema

	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @CurrentTableName VARCHAR(100)

	SELECT @EndInt = MAX(ID)
	FROM #SetupTables

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT @CurrentTableName = st.TableName
			FROM #SetupTables st
			WHERE st.ID = @StartInt

			SET @SQL = @SQL + CHAR(10) + 'TRUNCATE TABLE ' + CASE WHEN @IsRefreshSetup = 0 THEN @DatabaseName + '.' + @SchemaName + '.' ELSE @Schema + '.' END + @CurrentTableName + CHAR(10)
				+ 'INSERT INTO ' + CASE WHEN @IsRefreshSetup = 0 THEN @DatabaseName + '.' + @SchemaName + '.' ELSE @Schema + '.' END + @CurrentTableName + CHAR(10)
				+ 'SELECT * FROM ' + CASE WHEN @IsRefreshSetup = 1 THEN @DatabaseName + '.' + @SchemaName + '.' ELSE @Schema + '.' END + @CurrentTableName + CHAR(10)

			SET @StartInt = @StartInt + 1

		END

		PRINT @SQL
		EXEC sp_executesql @SQL

END