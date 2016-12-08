USE [M3Setup]
GO
/****** Object:  StoredProcedure [dbo].[CreateEnvironmentSchema]    Script Date: 12/4/2016 2:58:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	
	--IF @Schema = 'TST'
	--	BEGIN

	--		SET @SQL = QUOTENAME(N'M3EDBTST') + N'.sys.sp_executesql'
	--		EXEC @SQL N'CREATE SCHEMA [JBGEDBTST] AUTHORIZATION [dbo]'
	
	--		SET @SQL = QUOTENAME(N'M3EDBTST') + N'.sys.sp_executesql'
	--		EXEC @SQL N'CREATE SCHEMA [MI3EDBTST] AUTHORIZATION  [dbo]'
	
	--		SET @SQL = QUOTENAME(N'M3EDBTST') + N'.sys.sp_executesql'
	--		EXEC @SQL N'CREATE SCHEMA [FATJDTATST] AUTHORIZATION  [dbo]'
			
	--	END

	--IF @Schema = 'DEV'
	--	BEGIN
	--		SET @SQL = QUOTENAME(N'M3EDBDEV') + N'.sys.sp_executesql'
	--		EXEC @SQL 'CREATE SCHEMA [JBGEDBDEV] AUTHORIZATION [dbo]'
	
	--		SET @SQL = QUOTENAME(N'M3EDBDEV') + N'.sys.sp_executesql'
	--		EXEC @SQL 'CREATE SCHEMA [MI3EDBDEV] AUTHORIZATION [dbo]'
	
	--		SET @SQL = QUOTENAME(N'M3EDBDEV') + N'.sys.sp_executesql'
	--		EXEC @SQL 'CREATE SCHEMA [FATJDTADEV] AUTHORIZATION [dbo]'
	--	END
	
	SET @SQL = ''

	CREATE TABLE #TransferTables
		(
			SchemaTransferTo VARCHAR(10),
			SchemaTransferFrom VARCHAR(10),
			TableName VARCHAR(100),
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
		FROM M3EDBTST.sys.objects o
		INNER JOIN M3EDBTST.sys.schemas s ON s.schema_id = o.schema_id
		WHERE o.[type] IN ('U','V','P','Fn')
		AND s.name = 'JBGEDBPRD'
		UNION
		SELECT
			  'MI3EDBPRD'
			, 'MI3EDB' + @Schema
			, o.name
		FROM M3EDBTST.sys.objects o
		INNER JOIN M3EDBTST.sys.schemas s ON s.schema_id = o.schema_id
		WHERE
			o.[type] IN ('U','V','P','Fn')
			AND s.name = 'MI3EDBPRD'
		UNION
		SELECT
			  'FATJDTAPRD'
			, 'FATJDTA' + @Schema
			, o.name
		FROM M3EDBTST.sys.objects o
		INNER JOIN M3EDBTST.sys.schemas s ON s.schema_id = o.schema_id
		WHERE
			o.[type] IN ('U','V','P','Fn')
			AND s.name = 'FATJDTAPRD'
			SELECT * FROM #TransferTables
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

		PRINT @sql
		
	--EXEC sp_executesql @SQL

END