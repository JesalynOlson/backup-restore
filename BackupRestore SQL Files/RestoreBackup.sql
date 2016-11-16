ALTER PROCEDURE [dbo].[RestoreBackup]
	(
		@DatabaseName VARCHAR(10),
		@FileLocationToRestoreFrom VARCHAR(1000)
	)
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @SQL NVARCHAR(MAX) = ''
	
	SET @SQL = 'ALTER DATABASE ' + @DatabaseName + ' SET RESTRICTED_USER WITH ROLLBACK IMMEDIATE'
	
	EXEC sp_executesql @SQL

	EXEC dbo.InsertSetupTables @DatabaseName, 'MVXJDTA',1
	EXEC dbo.RestoreDatabase @DatabaseName, @FileLocationToRestoreFrom
	EXEC dbo.CreateEnvironmentSchema @DatabaseName
	EXEC dbo.UpdateTriggerSetting 1, @DatabaseName, 'MVXJDTA'
	EXEC dbo.InsertSetupTables @DatabaseName, 'MVXJDTA',0
	
	EXEC sp_executesql @SQL
	
	EXEC dbo.UpdateTriggerSetting 0, @DatabaseName, 'MVXJDTA'
	EXEC dbo.UpdateUserLogins @DatabaseName
	EXEC dbo.DisableCustomTriggers @DatabaseName
	EXEC dbo.DropSchemaTables @DatabaseName, 'FATJDTATST','AUDFIL'

	SET @SQL = 'ALTER DATABASE ' + @DatabaseName + ' SET MULTI_USER WITH ROLLBACK IMMEDIATE'
	
	EXEC sp_executesql @SQL
	
	SET @SQL = 'ALTER DATABASE ' + @DatabaseName + ' SET RECOVERY SIMPLE'
	
	EXEC sp_executesql @SQL

	UPDATE dbo.DatabaseHistory
	SET LastRefreshDate = GETDATE()
	WHERE DatabaseName = @DatabaseName

END