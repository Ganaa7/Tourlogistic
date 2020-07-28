USE TourLogistic
GO
DROP PROC TL_AlterTour2
GO
/*
	TourAccomodation

*/
CREATE PROC TL_AlterTour2(
	@RequestRecID			pkType
) AS
BEGIN
	DECLARE @TourRecID				pkType,
			@ReqAccRecID			pkType,
			@PaxQty					SMALLINT,
			@StaffQty				SMALLINT,
			@Date					dateType,
			@CheckInDate			dateType,
			@CheckOutDate			dateType,
			@RowID					pkType,
			@EmployeeQty			SMALLINT,
			@Cnt					SMALLINT,
			@AccomodationTypeID		idType,
			@AccProductTypeInfID	pkType,
			@AccomodationInfID		pkType,
			@GuestRecID				pkType,
			@TourPaxRecID			pkType,
			@PaxRecID				pkType,
			@TourStaffRecID			pkType,
			@TourAccRecID			pkType,
			@CateringTypeID			idType,
			@MealTypeID				idType,
			@FromDate				dateType,
			@ToDate					dateType,
			@ReqCaterRecID			pkType,
			@TourCaterRecID			pkType, 
			@RestaurantInfID		pkType
			
					
	DECLARE @tmpLodge TABLE(
		RowID		SMALLINT IDENTITY(100,1),
		Date		dateType
		)	

	DECLARE @tmpTAccomod TABLE(
			RowRecID				pkType IDENTITY(1,1),
			Date					dateType,
			AccProductTypeInfID		pkType,
			AccomodationInfID		pkType,
			AccomodationTypeID		idType,
			PaxRecID				pkType
			)

	DECLARE @tmpPaxes TABLE(
			Rowcnt		SMALLINT IDENTITY(1,1),
			PaxRecID	pkType		
			)
	
	DECLARE @tmpCatering TABLE(
			TourCaterRecID		pkType, 
			TourRecID			pkType,
			GuestRecID			pkType,
			CateringTypeID		idType, 
			RestaurantInfID		pkType, 
			Date				dateType,
			BreakFast			CHAR(1),
			Lunch				CHAR(1),
			Dinner				CHAR(1)			
			)			

	Exec CreatePkID 'tlTours', 'TourRecID', @TourRecID OUTPUT

	INSERT INTO tlTours (TourRecID, TourID, LeaderPaxRecID, TourName, TourTypeInfID, TourLevelID, TourStatusID, RequestRecID, PaxQty, StaffQty, StartDate, EndDate, Days, TotalDistance, 
			TourDate, CustomerInfID, CustomerDescF, RemarkL,  RemarkF, RemarkD, ActionDoneBy, ActionDate)
		SELECT @TourRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, LevelID, '', RequestRecID, PaxQty, EmployeeQty, StartDate, EndDate, Days, TotalDistance, 
				RequestDate, CustomerInfID, CustomerDescF, RemarkL, RemarkF, RemarkD, ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
			FROM tlRequest
			WHERE RequestRecID = @RequestRecID

	SELECT @PaxQty = PaxQty
		FROM tlRequest
		WHERE RequestRecID =  @RequestRecID

	SET NOCOUNT ON 

	WHILE @PaxQty > 0
	BEGIN
		Exec CreatePkID 'tlPaxes', 'PaxRecID', @PaxRecID OUTPUT	
		Exec CreatePkID 'tlTourPaxes', 'TourPaxRecID', @TourPaxRecID OUTPUT	

		INSERT INTO tlPaxes(PaxRecID)
			SELECT @PaxRecID 
		
		INSERT INTO tlTourPaxes(TourPaxRecID, PaxRecID, TourRecID)
			SELECT @TourPaxRecID, @PaxRecID, @TourRecID
		
		INSERT INTO @tmpPaxes(PaxRecID)	
			SELECT @PaxRecID

		SET @PaxQty = @PaxQty - 1
	END

	SELECT @PaxQty = Max(PaxQty)	
		FROM tlReqAccomodation
		WHERE RequestRecID = @RequestRecID
/*
	DECLARE rPtr CURSOR FOR
		SELECT ReqAccRecID, CheckInDate, CheckOutDate
			FROM tlReqAccomodation
			WHERE RequestRecID = @RequestRecID

	OPEN rPtr 
	FETCH NEXT FROM rPtr INTO @ReqAccRecID, @CheckInDate, @CheckOutDate
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @AccomodationTypeID = AccomodationTypeID, @AccProductTypeInfID = AccProductTypeInfID, @AccomodationInfID = AccomodationInfID
			FROM tlReqAccomodation
			WHERE ReqAccRecID = @ReqAccRecID
			
		WHILE @CheckInDate <= @CheckOutDate 
		BEGIN
			SELECT @PaxQty = Max(PaxQty)	
				FROM tlReqAccomodation
				WHERE RequestRecID = @RequestRecID

			WHILE @PaxQty > 0
			BEGIN
				SELECT @PaxRecID = PaxRecID 
					FROM @tmpPaxes
					WHERE Rowcnt = @PaxQty
				
				EXEC CreatePkID 'tlTourAccomodations', 'TourAccRecID', @TourAccRecID OUTPUT

				INSERT INTO tlTourAccomodations(TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID, Date)
						SELECT @TourAccRecID, @TourRecID, @PaxRecID, 'Y', @AccomodationInfID, @AccomodationTypeID, @AccProductTypeInfID, @CheckInDate 
					
				SET @PaxQty = @PaxQty - 1
			END	
			
			SET @CheckInDate = CONVERT(VARCHAR(23), DATEADD(dd, 1, CONVERT(DATETIME, @CheckInDate)), 111) 
		END
					
		FETCH NEXT FROM rPtr INTO @ReqAccRecID, @CheckInDate, @CheckOutDate
	END	
	CLOSE rPtr
	DEALLOCATE rPtr
	
*/
	DECLARE pCtr CURSOR FOR
		SELECT ReqCaterRecID FROM tlReqCatering
			WHERE RequestRecID = @RequestRecID 

	OPEN pCtr
	FETCH NEXT FROM pCtr INTO @ReqCaterRecID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @CateringTypeID = CateringTypeID, @MealTypeID = MealTypeID, @FromDate = FromDate, @ToDate = ToDate, @RestaurantInfID = RestaurantInfID
			FROM tlReqCatering
			WHERE ReqCaterRecID = @ReqCaterRecID 

		WHILE @FromDate <= @ToDate	
		BEGIN
			SELECT @PaxQty = MAX(Rowcnt) FROM @tmpPaxes
								
			WHILE @PaxQty > 0
			BEGIN
				SELECT @PaxRecID = PaxRecID 
					FROM @tmpPaxes
					WHERE Rowcnt = @PaxQty								
			
				IF NOT EXISTS (SELECT 1 FROM tlTourCatering 
								WHERE GuestRecID = @PaxRecID AND Date = @FromDate)	
				BEGIN
					EXEC CreatePkID 'tlTourCatering', 'TourCaterRecID', @TourCaterRecID OUTPUT
					IF (SELECT MealTypeID FROM tlReqCatering 
							WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealBreakfast'
						INSERT INTO tlTourCatering(TourCaterRecID, TourRecID, GuestRecID, CateringTypeID, RestaurantInfID, Date, BreakFast)
							SELECT @TourCaterRecID, @TourRecID, @PaxRecID, @CateringTypeID, @RestaurantInfID, @FromDate, 'Y'
					ELSE 
						IF (SELECT MealTypeID FROM tlReqCatering 
								WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealLunch'
							INSERT INTO tlTourCatering(TourCaterRecID, TourRecID, GuestRecID, CateringTypeID, RestaurantInfID, Date, Lunch)
								SELECT @TourCaterRecID, @TourRecID, @PaxRecID, @CateringTypeID, @RestaurantInfID, @FromDate, 'Y'
						ELSE 
							IF (SELECT MealTypeID FROM tlReqCatering 
									WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealDinner'
								INSERT INTO tlTourCatering(TourCaterRecID, TourRecID, GuestRecID, CateringTypeID, RestaurantInfID, Date, Dinner)
									SELECT @TourCaterRecID, @TourRecID, @PaxRecID, @CateringTypeID, @RestaurantInfID, @FromDate, 'Y'
				END			
				ELSE
				BEGIN
					IF (SELECT MealTypeID FROM tlReqCatering 
							WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealBreakfast'
						UPDATE tlTourCatering SET BreakFast = 'Y'
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate
					ELSE 
						UPDATE tlTourCatering SET BreakFast = 'N'
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate
					IF (SELECT MealTypeID FROM tlReqCatering 
							WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealLunch'
						UPDATE tlTourCatering  SET Lunch = 'Y'
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate
					ELSE 
						UPDATE tlTourCatering SET Lunch = 'N'
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate

					IF (SELECT MealTypeID FROM tlReqCatering 
							WHERE ReqCaterRecID = @ReqCaterRecID ) = 'mealDinner'
						UPDATE tlTourCatering SET Dinner = 'Y'							
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate
					ELSE 
						UPDATE tlTourCatering SET Dinner = 'N'							
							WHERE GuestRecID = @PaxRecID AND Date = @FromDate
				END
				SET @PaxQty = @PaxQty - 1
			END 
			SET @FromDate = CONVERT(VARCHAR(23), DATEADD(dd, 1, CONVERT(DATETIME, @FromDate )), 111) 	
		END

		FETCH NEXT FROM pCtr INTO @ReqCaterRecID
	END
	CLOSE pCtr
	DEALLOCATE pCtr

		SELECT * FROM @tmpCatering
	
END
GO
TL_AlterTour2 1987040200006

/*
	SELECT ReqAccRecID, PaxQty, EmployeeQty, CheckInDate, CheckOutDate
		FROM tlReqAccomodation
		WHERE RequestRecID = 1987040200006

	DELETE FROM tlTours
		WHERE TourID = 'R040206'

	SELECT * FROM tlTours
	SELECT * FROM tlPaxes

	SELECT * FROM tlTourAccomodations
	SELECT * FROM tlTourCatering
	
	SELECT * FROM tlReqCatering
		WHERE RequestRecID = 1987040200006

	SELECT * FROM tlRequest
		WHERE RequestRecID = 1987040200006

	sp_help tlReqAccomodation
	sp_help tlTourAccomodations

	SELECT * FROM tlTourCatering

*/