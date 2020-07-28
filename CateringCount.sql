USE TourLogistic

DROP PROC PRT_ACC
GO
CREATE PROC PRT_ACC	
AS
BEGIN

	DECLARE @tmpAccomodation TABLE(
		RowID				SMALLINT IDENTITY(1,1),
		AccProductTypeID	idType,
		Amount				SMALLINT,
		AccomodationID		idType,
		TourRecID			pkType,
		Date				dateType
		)

	DECLARE @Count				SMALLINT,
			@AccProdTypeID		idType,
			@TourRecID			pkType,
			@AccomodationID		idType,
			@Date				dateType	
	
	DECLARE Ptr CURSOR FOR
		SELECT COUNT(AccomodationProductTypeID) AS Amount, AccomodationProductTypeID, B.TourRecID, C.AccomodationID, Date
			FROM tlAccomodationsProductTypes A
				INNER JOIN tlTourAccomodations B ON A.AccomodationProductTypeInfID = B.AccProductTypeInfID
				INNER JOIN tlAccomodations C ON B.AccomodationInfID = C.AccomodationInfID 
			WHERE TypeID= 'accHotel'
			GROUP BY AccomodationProductTypeID, B.TourRecID, C.AccomodationID, Date
	
	OPEN Ptr
	FETCH NEXT FROM Ptr INTO @Count, @AccProdTypeID, @TourRecID, @AccomodationID, @Date
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO @tmpAccomodation(Amount, AccProductTypeID, AccomodationID, TourRecID, Date) 
			SELECT 0, AccomodationProductTypeID, @AccomodationID, @TourRecID, @Date
				FROM tlAccomodationsProductTypes
				WHERE TypeID= 'accHotel' 
	
		UPDATE @tmpAccomodation SET Amount = @Count
			WHERE AccProductTypeID = @AccProdTypeID AND AccomodationID = @AccomodationID AND TourRecID = @TourRecID AND Date = @Date 
		
		FETCH NEXT FROM Ptr INTO @Count, @AccProdTypeID, @TourRecID, @AccomodationID, @Date
	END
	CLOSE Ptr
	DEALLOCATE Ptr

	SELECT * FROM @tmpAccomodation 
END			
GO	
PRT_ACC