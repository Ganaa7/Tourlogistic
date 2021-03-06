USE NomadsTourlogistic
GO
/****** Object:  StoredProcedure [dbo].[SS_SEL_GetLastRate]    Script Date: 04/26/2007 12:02:43 ******/
DROP PROC SS_SEL_GetLastRate
GO
CREATE PROCEDURE SS_SEL_GetLastRate(
	@CurrencyID		idType,
	@Date			dateType,
	@Rate			amountType OUTPUT
) AS
BEGIN
	DECLARE @InfoDBname		idType
	DECLARE @SQL			NVARCHAR(4000)
	DECLARE @DBName			VARCHAR(75)	
	
	DECLARE @tmpRate	TABLE(
		OfficalRate		amountType	)	

	SET NOCOUNT ON

	SELECT @InfoDBname = ValueL 
		FROM ssConfigurations WHERE ID = 'InfoDatabase'

	SET @SQL = N'
	IF EXISTS (SELECT name  
					FROM sys.databases WHERE name = '''+@InfoDBname+''')
	BEGIN
		IF EXISTS (SELECT DBName  
						FROM '+@InfoDBname+'..RegisteredSystems 
						WHERE Systemname = ''Diamond'')
		SELECT @DBName = DBName 
				FROM '+@InfoDBname+'..RegisteredSystems 
					WHERE Systemname = ''Diamond'' 	
	END	'

	EXEC sp_executesql @SQL, N'@DBName VARCHAR(75) OUTPUT ', @DBName OUTPUT

	IF EXISTS (SELECT name FROM sys.databases WHERE name = @DBName)
	BEGIN
		SET @SQL = N'EXEC '+@DBName+'..SS_SEL_GetOfficialRateByCurrencyID '''+@CurrencyID+''', '''+@Date+''''

		INSERT INTO @tmpRate(OfficalRate) EXEC(@SQL)

		SELECT @Rate = OfficalRate FROM @tmpRate
	END

END
GO
DECLARE @Out amountType
	EXEC SS_SEL_GetLastRate 'USD', '2007/04/26', @Out OUTPUT
SELECT @Out

/*
DECLARE @Amount amountType

SELECT @Amount = EXEC Diamond..SS_SEL_GetOfficialRateByCurrencyID 'USD', '2007/04/26'
USE NomadsTourLogistic

	SELECT DBNAME FROM NomadsDiamondInfo..RegisteredSystems
		WHERE Systemname = 'Diamond'
	
		SELECT 'YES'


	SELECT * FROM VIEW_ssCurrencies
	SELECT * FROM ssCurrencyRates
	SELECT * FROM ssConfigurations

	--EXEC DiamondInfo..SS_EXEC_ModuleQueryBySystem 'Diamond', 'SS_SEL_GetOfficialRateByCurrencyID', 

	SELECT DBName FROM DiamondInfo..RegisteredSystems WHERE Systemname = 'Diamond'

	SET @SQL = 'DBName..SS_SEL_GetOfficialRateByCurrencyID'
		USE DiamondInfo

		SELECT DBName FROM RegisteredSystems WHERE Systemname = 'Diamond'
		
		sp_help RegisteredSystems 
*/
