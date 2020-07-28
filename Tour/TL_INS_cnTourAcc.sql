USE TourLogistic
GO
DROP PROC TL_INS_cnTourAcc
GO
CREATE PROC TL_INS_cnTourAcc(
@TourRecID

)AS
BEGIN

	SELECT @RequestRecID = RequestRecID FROM tlTours 
			WHERE TourRecID = @TourRecID
	
		DECLARE rPtr CURSOR FOR
			SELECT ReqAccRecID FROM tlReqAccomodation
				WHERE RequestRecID = @RequestRecID AND AccomodationTypeID = 'accHotel' 

		OPEN rPtr 
		FETCH NEXT FROM rPtr INTO @ReqAccRecID
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			SELECT @AccomodationTypeID = AccomodationTypeID, @AccProductTypeInfID = AccProductTypeInfID, @AccomodationInfID = AccomodationInfID, @CheckInDate = CheckInDate, @CheckOutDate = CheckOutDate
				FROM tlReqAccomodation
				WHERE ReqAccRecID = @ReqAccRecID

			WHILE @CheckInDate <= @CheckOutDate 
			BEGIN
					IF NOT EXISTS (SELECT 1 FROM tlTourAccomodations 
										WHERE Date = @CheckInDate AND AccomodationInfID = @AccomodationInfID AND GuestRecID = @PaxRecID)
					BEGIN
						EXEC CreatePkID 'tlTourAccomodations', 'TourAccRecID', @TourAccRecID OUTPUT

						INSERT INTO tlTourAccomodations(TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID, Date)
							SELECT @TourAccRecID, @TourRecID, @PaxRecID, 'Y', @AccomodationInfID, @AccomodationTypeID, @AccProductTypeInfID, @CheckInDate 
					END
						
			SET @CheckInDate = CONVERT(VARCHAR(23), DATEADD(dd, 1, CONVERT(DATETIME, @CheckInDate)), 111) 
			END
				
			FETCH NEXT FROM rPtr INTO @ReqAccRecID
		END	
		CLOSE rPtr
		DEALLOCATE rPtr


END
GO
TL_INS_cnTourAcc

/*
	SELECT * FROM tlTourAccomodations
	SELECT * FROM tlReqAccomodation	
*/