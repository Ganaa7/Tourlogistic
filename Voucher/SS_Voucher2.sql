USE TourLogistic
GO
DROP PROC SS_SEL_TourVoucher2
GO
CREATE PROC SS_SEL_TourVoucher2(
	@TourRecID			pkType
--	@AccomodationInfID	pkType
)	
AS
BEGIN

	DECLARE @SQL					NVARCHAR(4000)
	DECLARE @result					NVARCHAR(MAX),
			@SQL2					NVARCHAR(2000),
			@TourAccRecID			pkType,
			@AccProductTypeInfID	pkType,
			@AccProductTypeID		idType,
			@IsPax					CHAR(1)


--	SET @SQL2 = N'	
--		DECLARE @tmpVoucher TABLE(
--			AccomodationInfID	pkType,
--			'+@column+')'

	DECLARE @tmpVoucher TABLE(
			AccomodationInfID	pkType,
			TourRecID			pkType,
			SGL					VARCHAR(4),	
			TWN					VARCHAR(4),
			DBL					VARCHAR(4),
			Semi_SGL			VARCHAR(4),
			Semi_TWN			VARCHAR(4),
			Semi_DBL			VARCHAR(4),
			Lux_SGL				VARCHAR(4),
			Lux_TWN				VARCHAR(4),
			Lux_DBL				VARCHAR(4),
			PSGL				VARCHAR(4),
			PTWN				VARCHAR(4),
			FAM					VARCHAR(4),
	)

	DECLARE sPtr CURSOR FOR
		SELECT TourAccRecID, IsPax, AccProductTypeInfID
			FROM tlTourAccomodations
			WHERE TourRecID = @TourRecID

	OPEN sPtr
	FETCH NEXT FROM sPtr INTO @TourAccRecID, @IsPax, @AccProductTypeInfID
	WHILE @@FETCH_STATUS = 0
	BEGIN	
						
		SELECT @AccProductTypeID = 
		
	
	END

	


/*
	SELECT * FROM tlTourAccomodations 
	SELECT * FROM tlAccomodationsProductTypes
		WHERE TypeID = 'accHotel'		
*/