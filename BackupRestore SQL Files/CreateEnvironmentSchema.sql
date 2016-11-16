ALTER PROCEDURE [dbo].[CreateEnvironmentSchema]
	(
		@DatabaseName VARCHAR(10)
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Schema NVARCHAR(3)
	DECLARE @SQL NVARCHAR(MAX) = ''

	SELECT @Schema = CASE WHEN @DatabaseName = 'M3EDBDEV' THEN 'DEV' ELSE 'TST' END
	
	IF @Schema = 'TST'
		BEGIN
			SET @SQL = QUOTENAME(N'M3EDBTST') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [JBGEDBTST] AUTHORICATION [dbo]'
	
			SET @SQL = QUOTENAME(N'M3EDBTST') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [MI3EDBTST] AUTHORICATION [dbo]'
	
			SET @SQL = QUOTENAME(N'FATJDTATST') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [FATJDTATST] AUTHORICATION [dbo]'
		END

	IF @Schema = 'DEV'
		BEGIN
			SET @SQL = QUOTENAME(N'M3EDBDEV') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [JBGEDBDEV] AUTHORICATION [dbo]'
	
			SET @SQL = QUOTENAME(N'M3EDBDEV') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [MI3EDBDEV] AUTHORICATION [dbo]'
	
			SET @SQL = QUOTENAME(N'FATJDTADEV') + N'sys.sp_executesql'
			EXEC @SQL 'CREATE SCHEMA [FATJDTADEV] AUTHORICATION [dbo]'
		END
	
	SET @SQL = ''

	CREATE TABLE #TransferTables
		(
			SchemaTransferTo VARCHAR(10),
			SchemaTransferFrom VARCHAR(10),
			TableName VARCHAR(10),
			ID INT IDENTITY(1,1)
		)

	INSERT INTO #TransferTables
		(
			  SchemaTransferFrom
			, SchemaTransferTo
			, TableName
		)
		SELECT
			  'JBGEDBPRD'
			, 'JBGEDB' + @Schema
			, o.name
		FROM sys.objects o
		WHERE o.[type] IN ('U','V','P','Fn')
		AND SCHEMA_NAME(SCHEMA_ID) = 'JBGEDBPRD'
		UNION
		SELECT
			  'MI3EDBPRD'
			, 'MI3EDB' + @Schema
			, o.name
		FROM sys.objects o
		WHERE
			o.[type] IN ('U','V','P','Fn')
			AND SCHEMA_NAME(SCHEMA_ID) = 'MI3EDBPRD'
		UNION
		SELECT
			  'FATJDTAPRD'
			, 'FATJDTA' + @Schema
			, o.name
		FROM sys.objects o
		WHERE
			o.[type] IN ('U','V','P','Fn')
			AND SCHEMA_NAME(SCHEMA_ID) = 'FATJDTAPRD'

	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @TableToTransfer VARCHAR(30)
	DECLARE @SchemaToTransferTo VARCHAR(30)

	SELECT @EndInt = MAX(ID) FROM #TransferTables

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT
				  @SchemaToTransferTo = tt.SchemaTransferTo
				, @TableToTransfer = tt.SchemaTransferFrom + '.' + tt.TableName
			FROM #TransferTables tt
			WHERE tt.ID = @StartInt

			SET @SQL = @SQL + CHAR(10) + 'ALTER SCHEMA ' + @SchemaToTransferTo + ' TRANSFER ' + @TableToTransfer + CHAR(10)

			SET @StartInt = @StartInt + 1

		END
		
	PRINT @SQL

	EXEC sp_executesql @SQL

END