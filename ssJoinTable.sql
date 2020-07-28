USE TourLogistic
GO
DROP PROC sslinktb
GO
CREATE PROC sslinktb(
	@FtbName	NVARCHAR(100),
	@StbName    NVARCHAR(100),
	@FconField  NVARCHAR(100),
	@SconField	NVARCHAR(100),
	@ConType	idType,
	@Code		idType
)AS 
BEGIN

	DECLARE @SQL NVARCHAR(MAX)
	
	IF @Code = '9953'
	BEGIN
		SELECT 'Welcome Ganaa!'

		IF LEFT(@ConType,1) = 'I' 
		BEGIN
			SET @SQL = 'SELECT * FROM '+@FtbName+' A 
							INNER JOIN '+@StbName+' B ON A.'+@FconField+' = B.'+@SconField+''
			EXEC(@SQL)
		END
		ELSE
			IF LEFT(@ConType,1) = 'L' 
			BEGIN
				SET @SQL = 'SELECT * FROM '+@FtbName+' A 
								LEFT OUTER JOIN '+@StbName+' B ON A.'+@FconField+' = B.'+@SconField+''
				EXEC(@SQL)
			END
		ELSE
			IF LEFT(@ConType,1) = 'R' 
			BEGIN
				SET @SQL = 'SELECT * FROM '+@FtbName+' A 
								RIGHT OUTER JOIN '+@StbName+' B ON A.'+@FconField+' = B.'+@SconField+''
				EXEC(@SQL)
			END
	END 
	ELSE
		SELECT 'Invalid user!!'
		
END
GO
--EXEC ssJoinTable 
