ALTER PROCEDURE [dbo].[UpdateUserLogins]
	(
		@DatabaseName VARCHAR(10)
	)
AS
BEGIN

	DECLARE @SQL NVARCHAR(MAX) = ''

	SET @SQL = '

			DECLARE user_cursor CURSOR FORWARD_ONLY READ_ONLY
			FOR
			SELECT DISTINCT u.NAME
			FROM ' + @DatabaseName + '.dbo.sysusers u
			JOIN Master.dbo.syslogins l ON u.NAME collate database_default = l.NAME collate database_default
			WHERE u.issqluser <> 0
			
			DECLARE @user SYSNAME;
			OPEN user_cursor

			FETCH NEXT
			FROM user_cursor
			INTO @user;

			WHILE @@fetch_status = 0
			BEGIN
				IF @user <> ''dbo''
				BEGIN
					EXEC ' + @DatabaseName + '.dbo.sp_change_users_login ''Auto_Fix''
						,@user
				END

				FETCH NEXT
				FROM user_cursor
				INTO @user
			END;

			CLOSE user_cursor

			DEALLOCATE user_cursor'
		
		EXEC sp_executesql @SQL
END