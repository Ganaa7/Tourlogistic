USE TourLogistic
GO
DROP PROC TL_SS_SelCatering
GO
CREATE PROC TL_SS_SelCatering
AS
BEGIN
	DECLARE @CaterRecID			pkType, 
			@Date				dateType,
			@Qty				SMALLINT,
			@PaxQty				SMALLINT,
			@EmpQty				SMALLINT, 
			@ServicePrInfID		pkType,
			@MealTypeID			idType,
			@RestaurantInfID	pkType,
			@MenuTypeID			idType
			
	DECLARE @tmpCatering TABLE(
		TourRecID			NUMERIC(18),
		RestPriceRecID		NUMERIC(18),
		RestaurantInfID		NUMERIC(18),
		Date				VARCHAR(23),
		MenuTypeID			NVARCHAR(30),
		Breakfast			SMALLINT,
		Dinner				SMALLINT,
		Lunch				SMALLINT,
		PaxQty				SMALLINT,
		EmpQty				SMALLINT
	)
	
	INSERT INTO @tmpCatering(TourRecID, Date) 
		SELECT DISTINCT TourRecID, Date 
			FROM tlTourCatering
	
	DECLARE Ind	CURSOR FOR
		SELECT TourCateringRecID FROM tlTourCatering
	
	OPEN Ind
	FETCH NEXT FROM ind INTO @CaterRecID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @Date = Date, @Qty = Qty, @PaxQty = GuestQty, @EmpQty = MglQty, @ServicePrInfID = RestaurantServicePriceInfID
			FROM tlTourCatering
			WHERE TourCateringRecID = @CaterRecID 
		
		SELECT @RestaurantInfID = RestaurantInfID, @MealTypeID = MealTypeID, @MenuTypeID = MenuTypeID
			FROM tlRestaurantServicePrices	A 
			WHERE RestaurantServicePriceInfID = @ServicePrInfID

		IF @MealTypeID = 'mealBreakfast'		
			UPDATE @tmpCatering SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, BreakFast = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date 

		IF @MealTypeID = 'mealLunch'	
			UPDATE @tmpCatering SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, Lunch = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date 

		IF @MealTypeID = 'mealDinner'
			UPDATE @tmpCatering SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, Dinner = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date 

		FETCH NEXT FROM ind INTO @CaterRecID
	END 
	CLOSE Ind
	DEALLOCATE Ind

	SELECT ROW_NUMBER( ) OVER(ORDER BY Date) Num, A.Date, B.TourID, A.RestaurantInfID, C.DescriptionF [RestaurantName], A.MenuTypeID Menu, A.BreakFast, A.Lunch, A.Dinner, A.PaxQty, A.EmpQty
		FROM @tmpCatering A
			INNER JOIN tlTours B ON A.TourRecID = B.TourRecID
			INNER JOIN tlRestaurants C ON A.RestaurantInfID = C.RestaurantInfID

END
GO
EXEC TL_SS_SelCatering 
/*
	SELECT * FROM tlTourCatering
	SELECT * FROM tlRestaurantServicePrices
		INSERT INTO tlTourCatering VALUES(1987030300003, 1987022100002, 1987022600003, 123456789, '2007/02/03', 0, 0, 2, 8, 15000, 2000, 2005060700002, 20, 0,  2005060700001, 0, 0, 0, 0, 003, 0, 0, 'Y', 'Admin', CONVERT(VARCHAR(23), GETDATE(), 121) )
		INSERT INTO tlTourCatering VALUES(1987030300004, 1987022100002, 1987022600004, 123456789, '2007/02/03', 0, 0, 2, 8, 15000, 2000, 2005060700002, 20, 0,  2005060700001, 0, 0, 0, 0, 003, 0, 0, 'Y', 'Admin', CONVERT(VARCHAR(23), GETDATE(), 121) )
		update tlTourCatering set Date = '2007/02/04'
			WHERE TourCateringRecID IN (1987030300004, 1987030300003, 1987030300002)
	
	SELECT * FROM tlTours
	SELECT * FROM tlRestaurants
	SELECT * FROM tlTourCatering	
	SELECT * FROM VIEW_ssMenuType
	

*/