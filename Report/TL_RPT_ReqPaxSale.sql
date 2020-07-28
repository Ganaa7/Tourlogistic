USE TourLogistic
GO
DROP PROC TL_RPT_ReqPaxSale
GO
CREATE PROC TL_RPT_ReqPaxSale(
	@RequestRecID pkType 
)AS
BEGIN
	DECLARE @CostPerGroup		amountType,
			@CostPerPax			amountType,
			@PGFlight			amountType,  -- Pergroup flight Amount price
			@PGTrain			amountType,  -- Pergroup train  Amount price
			@PGVehicles		  	amountType,  -- Pergroup flight Amount price
			@PGCityVehicle	  	amountType,  -- Pergroup flight Amount price
			@PGAccomodation	    amountType,  -- Pergroup flight Amount price
			@PGCatering		    amountType,  -- Pergroup flight Amount price		
			@PGAnimals			amountType,	 -- 	
			@PPFlight			amountType,  -- PerPax flight Amount price
			@PPTrain			amountType,  -- PerPax train  Amount price
			@PPVehicles		  	amountType,  -- PerPax flight Amount price
			@PPCityVehicle	  	amountType,  -- PerPax flight Amount price
			@PPAccomodation	    amountType,  -- PerPax flight Amount price
			@PPCatering		    amountType,  -- PerPax flight Amount price		
			@PPAnimals			amountType,	 -- 	
			@status				INT
	
	------------- PerGroup Price -----------------------------------------------------------------
	
	SELECT @PGFlight = SUM(SaleAmountL) 
		FROM tlReqFlights WHERE RequestRecID = @RequestRecID
	
	SELECT @PGTrain = SUM(SaleAmountL)
		FROM tlReqTrains 
		WHERE RequestRecID = @RequestRecID
	
	SELECT @PGVehicles = SUM(RentPrice) 
		FROM tlReqVehicles WHERE RequestRecID = @RequestRecID
		
	SELECT @PGCityVehicle = SUM(RentPriceAmount)
		FROM tlReqCityVehicles WHERE RequestRecID = @RequestRecID

	SET @PGVehicles = @PGVehicles + @PGCityVehicle

	SELECT @PGAnimals = SUM(RentAmountL)
		FROM tlReqAnimals WHERE RequestRecID = @RequestRecID

	SELECT @PGAccomodation = SUM(SaleAmountL)
		FROM tlReqAccomodation 
		WHERE RequestRecID = @RequestRecID			

	SELECT @PGCatering = SUM(SaleAmountL)
		FROM tlReqCatering 
		WHERE RequestRecID = @RequestRecID	
	
	------------- PerPax Price -----------------------------------------------------------------
	
	SELECT @PPFlight = SUM(SaleAmountF)
		FROM tlReqFlights 
		WHERE RequestRecID = @RequestRecID
	
	SELECT @PPTrain = SUM(SaleAmountF)
		FROM tlReqTrains 
		WHERE RequestRecID = @RequestRecID
	
	SELECT @PPAccomodation = SUM(SaleAmountL)
		FROM tlReqAccomodation WHERE RequestRecID = @RequestRecID			

	SELECT @PPCatering = SUM(SaleAmountL)
		FROM tlReqCatering WHERE RequestRecID = @RequestRecID	

	------------ Sum Pax + Employees ----------------------------------------------------------

	SET @CostPerGroup = @PGFlight + @PGTrain + @PGVehicles + @PGAnimals + @PGAccomodation + @PGCatering
	
	SET @CostPerPax = @PPFlight + @PPTrain + @PPAccomodation + @PPCatering

	------------ Report's query here ---------------------------------------------------------------------
	-- 1. Tour general facts here 

	SELECT A.RequestID, A.ReqName [Request name] , A.LevelID [Level], B.DescriptionF [Tour Type], A.StartDate [Srart date], 
			EndDate [End date], Days [Qty Days], PaxQty [Qty Pax], EmployeeQty [Qty employee], @CostPerGroup GroupPax, @CostPerPax [CostPerPax]
		FROM tlRequest A 
		INNER JOIN tlTourTypes B ON A.ReqTypeInfID = B.TourTypeInfID
		WHERE RequestRecID = @RequestRecID

 	-- 2. Tour programm	here 
	
	DECLARE @sDate			dateType,
			@RowRecID		pkType,
			@PointRecID		pkType,
			@cnt			SMALLINT,
			@Rowcnt			SMALLINT,
			@Date			dateType,
			@PkID			INT,
			@result			NVARCHAR(1000),
			@MealType		idType,
			@FromPoint		pkType,
			@ToPoint		pkType,
			@FRouteNameF	NVARCHAR(500),
			@LRouteNameF	NVARCHAR(500),
			@FRouteNameD	NVARCHAR(500),		
			@LRouteNameD	NVARCHAR(500),
			@RouteNameD		NVARCHAR(500),
			@RouteNameF		NVARCHAR(500),
			@ForDate		dateType,
			@ForPointRecID	pkType,
			@Distance		SMALLINT,
			@FDistance		SMALLINT,
			@CDistnace		SMALLINT,
			@vDate			dateType,
			@vID			SMALLINT,
			@vResult		NVARCHAR(1000)
		
			
	DECLARE @Route TABLE (
		RowRecID			INT IDENTITY(100,1),
		RouteRecID			pkType,
		PointRecID			pkType,
		Date				dateType,
		FromPoint			pkType,
		ToPoint				pkType,
		RouteNameF			NVARCHAR(1000),
		RouteNameD			NVARCHAR(1000),
		Distance			SMALLINT		
		)

	DECLARE @tmpRoute TABLE (
		RowRecID			INT IDENTITY(100,1),
		PointRecID			pkType,
		RouteRecID			pkType,
		Date				dateType,
		RouteNameF			NVARCHAR(2000),
		RouteNameD			NVARCHAR(2000),
		Distance			SMALLINT
	)

	DECLARE @TmpCater TABLE(
		PkID		INT IDENTITY(100, 1),
		RecID		pkType,
		MealTypeID	idType,
		Date		dateType
		)	

	DECLARE @tmpResult TABLE(
		MealTypeID   idType,
		Date		 dateType
		)

	DECLARE @tmpVehicle TABLE(
		ID			INT IDENTITY(1,1),
		Date		dateType,
		NameF		descType,
		NameD		descType
		)
	
	SET @cnt = 1
	SET @status = 1
	
	SET NOCOUNT ON
	
	INSERT INTO @Route(PointRecID, Date)
		SELECT A.PointRecID, B.Date 
			FROM tlReqPoints A
				CROSS JOIN tlDate B
				WHERE B.Date >= A.ArriveDate AND B.Date <= A.DepartDate AND RequestRecID = @RequestRecID

	UPDATE A SET A.RouteNameF = B.PointNameF
		FROM @Route A
			INNER JOIN tlPointRegistrations B ON A.PointRecID = B.PointRegisterRecID	

--	SELECT * FROM tlReqPoints			
--	SELECT PointRecID, Date, RouteNameF FROM @Route
--
--	UPDATE A SET A.RouteRecID = B.RouteRecID
--		FROM @Route A
--			INNER JOIN tlRoutes B ON A.PointRecID = B.FromPointRecID AND A.ToPoint = B.ToPointRecID
-----------------------------------Route bolgoh heseg--------------------------------------------
	
	DECLARE rCur CURSOR FOR
		SELECT RowRecID, PointRecID, Date FROM @Route
				
	OPEN rCur 
	FETCH NEXT FROM rCur INTO @RowRecID, @PointRecID, @Date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @status = 1
		BEGIN
			SET @FromPoint = @PointRecID
			UPDATE @Route SET FromPoint = @FromPoint, ToPoint = @FromPoint
				WHERE RowRecID = @RowRecID 
		END
		ELSE
		BEGIN
			SET @ToPoint = @PointRecID
			UPDATE @Route SET FromPoint = @FromPoint, ToPoint = @ToPoint 				
				WHERE RowRecID = @RowRecID 
			SET @FromPoint = @ToPoint
		END	
		SET @status = 0
			
		FETCH NEXT FROM rCur INTO @RowRecID, @PointRecID, @Date
	END  
	CLOSE rCur 
	DEALLOCATE rCur 
	
	UPDATE A SET A.Distance = B.Distance, A.RouteRecID = B.RouteRecID
		FROM @Route A
		INNER JOIN tlRoutes B ON A.FromPoint = B.FromPointRecID AND A.ToPoint = B.ToPointRecID

--	SELECT * FROM @Route
---------------------------------------- End Route ---------------------------------------------
	SELECT * FROM @Route

	INSERT INTO @tmpRoute(Date)
		SELECT DISTINCT Date FROM @Route

	DECLARE vCur CURSOR FOR
		SELECT RowRecID FROM @Route

	OPEN vCur
	FETCH NEXT FROM vCur INTO @RowRecID
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SELECT @PointRecID = PointRecID, @RouteNameF = RouteNameF, @RouteNameD = RouteNameD, @Date = Date, @Distance = Distance 
			FROM @Route
			WHERE RowRecID = @RowRecID
		
		IF @cnt = 1
		BEGIN
			SET @ForPointRecID = @PointRecID
			SET @FRouteNameF = @RouteNameF 
			SET @FRouteNameD = @RouteNameD 
			SET @ForDate = @Date	
			SET @FDistance = @Distance 
			UPDATE @tmpRoute SET RouteNameF = @RouteNameF, RouteNameD = @RouteNameD, Distance = @FDistance 
					WHERE Date = @Date
		END
		ELSE
		BEGIN
			IF @ForPointRecID <> @PointRecID AND @ForDate = @Date	
			BEGIN
				SET @FRouteNameF = @FRouteNameF +' -> '+@RouteNameF 
				SET @FRouteNameD = @FRouteNameD +' -> '+@RouteNameD 
			
				IF (SELECT Distance FROM @tmpRoute WHERE Date = @Date) IS NOT NULL
				BEGIN
					SELECT @FDistance = Distance FROM @tmpRoute WHERE Date = @Date

					UPDATE @tmpRoute SET Distance = @FDistance + @Distance  
						WHERE Date = @Date
				END
				ELSE
					UPDATE @tmpRoute SET Distance = @Distance  
						WHERE Date = @Date
						
				IF (SELECT RouteNameF FROM @tmpRoute WHERE Date = @Date) IS NOT NULL
				BEGIN
					SELECT @LRouteNameF = RouteNameF, @LRouteNameD = RouteNameD 
						FROM @tmpRoute WHERE Date = @Date 
				
					SET @LRouteNameF = @LRouteNameF +' -> '+ @RouteNameF
					SET @LRouteNameD = @LRouteNameD +' -> '+ @RouteNameD

					UPDATE @tmpRoute SET RouteNameF = @LRouteNameF, RouteNameD = @LRouteNameD 
						WHERE Date = @Date
				END 
				ELSE	
					UPDATE @tmpRoute SET RouteNameF = @FRouteNameF, RouteNameD = @FRouteNameD 
						WHERE Date = @Date
			END
			ELSE
			BEGIN
				UPDATE @tmpRoute SET RouteNameF = @RouteNameF, RouteNameD = @RouteNameD 
					WHERE Date = @Date
				UPDATE @tmpRoute SET Distance = @Distance  
						WHERE Date = @Date

			END
			SET @ForPointRecID = @PointRecID
			SET @FRouteNameD = @RouteNameD	
			SET @FRouteNameF = @RouteNameF	
			SET @ForDate = @Date	
			SET @FDistance = @Distance 
		END

		SET @cnt = 0	
	FETCH NEXT FROM vCur INTO @RowRecID
	END
	CLOSE vCur
	DEALLOCATE vCur	

	SELECT * FROM @tmpRoute	

	INSERT INTO @TmpCater (RecID, MealTypeID, Date)
		SELECT A.ReqCaterRecID, SUBSTRING(A.MealTypeID, 5, 1), B.Date 
		FROM tlReqCatering A
		CROSS JOIN tlDate B
		WHERE A.FromDate <=	B.Date AND B.Date <= A.ToDate AND A.RequestRecID = @RequestRecID

	DECLARE tCur CURSOR FOR
		SELECT PkID FROM @TmpCater
			
	OPEN tCur
	FETCH NEXT FROM tCur INTO @PkID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @DATE = Date FROM @TmpCater 
			WHERE PkID = @PkID

		SET @result = 
		  STUFF(
			(SELECT N',' + QUOTENAME(pivot_col) AS [text()]
				FROM(SELECT MealTypeID AS pivot_col
						FROM(SELECT * FROM @TmpCater WHERE Date = @Date) AS Query
					) AS DistinctCols
				ORDER BY pivot_col
				FOR XML PATH('')
			)
			,1, 1, N'')
		
		SET @result=REPLACE(@result, '[', '')
		SET @result=REPLACE(@result, ']', '')
		
		IF NOT EXISTS (SELECT * FROM @tmpResult	
							WHERE Date = @Date )
			INSERT INTO @tmpResult VALUES(@result, @Date)

	FETCH NEXT FROM tCur INTO @PkID
	END
	
	CLOSE tCur
	DEALLOCATE tCur

	INSERT INTO @tmpVehicle(Date, NameF, NameD)
		SELECT A.Date, C.DescriptionF, C.DescriptionD
			FROM tlDate A
				CROSS JOIN tlReqVehicles B
				INNER JOIN tlTransports C ON B.TransportInfID = C.TransportInfID
			WHERE A.Date >= B.FromDate AND A.Date <= B.ToDate AND B.RequestRecID = @RequestRecID 

	SELECT * FROM @tmpVehicle

	DECLARE vCrs CURSOR FOR 
		SELECT ID, Date FROM @tmpVehicle
		
	OPEN vCrs 
	FETCH NEXT FROM vCrs INTO @vID, @vDate
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		SET @vResult = 
		  STUFF(
			(SELECT N', ' + QUOTENAME(pivot_col) AS [text()]
				FROM(SELECT NameF AS pivot_col
						FROM(SELECT * FROM @tmpVehicle WHERE Date = @vDate) AS Query
					) AS DistinctCols
				ORDER BY pivot_col
				FOR XML PATH('')
			)
			,1, 1, N'')
		
		SET @vResult=REPLACE(@vResult, '[', '')
		SET @vResult=REPLACE(@vResult, ']', '')
		
	--	IF NOT EXISTS ()
	
	SELECT @vResult
	FETCH NEXT FROM vCrs INTO @vID, @vDate
	END
--	SELECT * FROM @tmpRoute 
--	SELECT * FROM @TmpResult
--	CASE WHEN F.DescriptionF IS NULL THEN 'None' ELSE F.DescriptionF END [Lodge]
	
	SELECT A.Date, ROW_NUMBER( )OVER(ORDER BY A.Date) [Days], A.RouteNameF [Routes], MealTypeID [MealPlan],
			CASE WHEN A.Distance IS NULL THEN 0 ELSE A.Distance END Distance, C.NameF Vehicle, N'Benz' CityVehicle
		FROM @tmpRoute A
			LEFT OUTER JOIN @TmpResult B ON A.Date = B.Date
			LEFT OUTER JOIN @tmpVehicle C ON A.Date = C.Date	

END 
GO
EXEC TL_RPT_ReqPaxSale 1987030900002

/*
	SELECT * FROM @TmpResult
	SELECT * FROM @tmpDate
	SELECT * FROM tlReqRoutes

		SELECT FromPointRecID, ToPointRecID, A.RouteNum, A.FromArrivalDate, A.FromDepartDate, B.Date 
			FROM tlReqRoutes A
				CROSS JOIN tlDate B
				WHERE B.Date >= A.FromArrivalDate AND B.Date <= A.FromDepartDate

	
	SELECT A.ReqVehicleRecID, MIN(B.Date) FromDate, MAX(B.Date) ToDate
		FROM tlReqVehicles A
			INNER JOIN tlReqDate B ON A.DateRecID = B.DateRecID
		GROUP BY A.ReqVehicleRecID

	SELECT * FROM tlReqDate
	
	SELECT * FROM tlTransports

	SELECT * FROM tlReqPoints

	SELECT * FROM tlReqCatering

	SELECT * FROM tlReqFlights

	SELECT B.Date  FROM tlReqCityVehicles A
		INNER JOIN tlDate B ON LEFT(A.FromDate, 10) = B.Date 		

	SELECT * FROM tlReqCityVehicles

	SELECT * FROM tlReqVehicles 

	UPDATE tlReqVehicles SET DateRecID = 1987032400002
		WHERE ReqVehicleRecID = 1987032300004

	ALTER TABLE tlReqVehicles ADD DateRecID dateType

	SELECT * FROM tlReqAccomodation
				  
	SELECT * FROM tlTourTypes

	SELECT * FROM VIEW_ssAccomodationType
	
	SELECT * FROM tlPointRegistrations
		
	exec sp_help tlReqPoints
	
	SELECT * FROM tlReqCatering	 -- Restaurant, Une, TypeID, Meal

	SELECT * FROM tlReqCateringPrice

	SELECT * FROM tlRestaurants

	SELECT * FROM tlRequest
		
	SELECT * FROM tlReqPoints
		WHERE RequestRecID = 1987030900002

	INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID, PointNum, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide)
		SELECT * FROM #tmpPoint
			WHERE RowRecID NOT IN (SELECT RowRecID FROM tlReqPoints)

	DELETE FROM tlReqPoints
		WHERE RowRecID = 1987032100003

	SELECT * FROM tlRoutes

	SELECT * FROM tlReqVehicles
	
	SELECT * FROM tlReqFlights

	SELECT * FROM tlReqTrains

	SELECT * FROM tlReqCityVehicles
	
	SELECT * FROM tlReqAnimals

	SELECT * FROM tlTourTypes

	SELECT * FROM tlReqCatering

	SELECT * FROM tlReqAccomodation
	SELECT * FROM tlAccomodations
	SELECT * FROM tlAccomodationsPrices
	SELECT * FROM tlAccomodationsProductTypes	
	SELECT * FROM VIEW_ssAccomodationType

	SELECT SUBSTRING('mealBreakFast', 5, 1)
	EXEC SP_HELP tlReqVehicles

	SELECT * FROM tlPointRegistrations

		
*/



