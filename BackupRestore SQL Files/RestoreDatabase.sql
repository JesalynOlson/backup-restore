ALTER PROCEDURE [dbo].[RestoreDatabase]
	(
		@DatabaseName VARCHAR(10),
		@FileLocationToRestoreFrom VARCHAR(1000)
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX) = ''

	CREATE TABLE #FilesToRestore
		(
			ID INT PRIMARY KEY IDENTITY(1,1),
			FileType INT,
			Name VARCHAR(100),
			PhysicalName VARCHAR(1000)
		)

	INSERT INTO #FilesToRestore
		(
			FileType,
			Name,
			PhysicalName
		)
		SELECT
			m.[type],
			m.name,
			m.physical_name
		FROM
			sys.master_files m 
			INNER JOIN sys.databases d ON m.database_id = d.database_id
		WHERE d.name = @DatabaseName
		ORDER BY m.[file_id]

	DECLARE @StartInt INT = 1
	DECLARE @EndInt INT
	DECLARE @CurrentFileName VARCHAR(100)
	DECLARE @PhysicalName VARCHAR(1000)

	SELECT @EndInt = MAX(ID)
	FROM #FilesToRestore

	SET @SQL = 'RESTORE DATABASE [' + @DatabaseName + '] FROM DISK = N''' + @FileLocationToRestoreFrom + ''' WITH FILE = 1, REPLACE,'

	WHILE ( @StartInt <= @EndInt )
		BEGIN

			SELECT @CurrentFileName = st.Name,
				   @PhysicalName = st.PhysicalName
			FROM #FilesToRestore st
			WHERE st.ID = @StartInt

			SET @SQL = @SQL + CHAR(10) + ' MOVE N''' + @CurrentFileName + ''' TO N''' + @PhysicalName + ''','

			SET @StartInt = @StartInt + 1

		END

		SET @SQL = @SQL + CHAR(10) + 'NOUNLOAD,  STATS = 10'

		EXEC sp_executesql @SQL

END

