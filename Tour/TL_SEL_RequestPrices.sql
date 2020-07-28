DROP PROC  TL_SEL_RequestPrices 
GO
CREATE PROC TL_SEL_RequestPrices 
	@IsLocal CHAR(1)
AS
BEGIN
	DECLARE @IsLocal char(1)
	set @IsLocal = 'Y'

	SELECT A.*, C.CurrencyID, D.PositionID, CASE WHEN @IsLocal = 'Y' THEN B.DescriptionL ELSE B.DescriptionF END LevelDescription,
			  CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END CurrencyDescription,
			  CASE WHEN @IsLocal = 'Y' THEN D.DescriptionL ELSE D.DescriptionF END EmpPositionTypeDescription,			  
			  Status = 'UnChanged' 	FROM tlReqEmployeesPrices A 
	LEFT OUTER JOIN ssSystemConstants B ON A.LevelID = B.ID
	LEFT OUTER JOIN VIEW_ssCurrencies C ON A.CurrencyInfID = C.CurrencyInfID
	LEFT OUTER JOIN tlPositions D ON A.EmpPositionTypeInfID = D.PositionInfID			  		

	SELECT A.*, D.AccomodationProductTypeID AS AccProductTypeID, E.CurrencyID AS CurrencyIDL, F.CurrencyID AS CurrencyIDF,
			   CASE WHEN @IsLocal = 'Y' THEN B.DescriptionL ELSE B.DescriptionF END AccTypeDescription,
			   CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END LevelDescription,
			   CASE WHEN @IsLocal = 'Y' THEN D.DescriptionL ELSE D.DescriptionF END AccProductTypeDescription,
			   CASE WHEN @IsLocal = 'Y' THEN E.DescriptionL ELSE E.DescriptionF END CurrencyLDescription,
			   CASE WHEN @IsLocal = 'Y' THEN F.DescriptionL ELSE F.DescriptionF END CurrencyFDescription,			   	
			   Status = 'UnChanged' FROM tlReqAccomodationPrices A
				LEFT OUTER JOIN ssSystemConstants B ON A.AccomodationTypeID = B.ID
				LEFT OUTER JOIN ssSystemConstants C ON A.LevelID = C.ID		
				LEFT OUTER JOIN tlAccomodationsProductTypes D ON A.AccProductTypeInfID = D.AccomodationProductTypeInfID
				LEFT OUTER JOIN VIEW_ssCurrencies E ON A.CurrencyInfIDL = E.CurrencyInfID
				LEFT OUTER JOIN VIEW_ssCurrencies F ON A.CurrencyInfIDF = F.CurrencyInfID

	SELECT A.*, 

	SELECT *, Status = 'UnChanged' FROM tlReqCateringPrice
	SELECT *, Status = 'UnChanged' FROM tlReqEnterPrices
END