USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_SEL_Rates]    Script Date: 04/05/2007 17:05:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[TL_SEL_Rates](
	@TableType		char(1),
	@TableInfID		pkType
)AS
BEGIN
	DECLARE @cnt				NUMERIC(6,2),
			@Rate				SMALLINT,
			@RateRecID			pkType,
			@TourRecID			pkType

	DECLARE @tmpRate TABLE(
		TableInfID		pkType,
		TourRecID		pkType,
		Rate			NUMERIC(6,2))

	DECLARE csr CURSOR FOR
		SELECT RateRecID 
			FROM tlRates
			WHERE TableType = @TableType AND TableInfID = @TableInfID

	OPEN csr
	FETCH NEXT FROM csr INTO @RateRecID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @TourRecID = TourRecID, @TableInfID = TableInfID
			FROM tlRates
			WHERE RateRecID = @RateRecID
			
		SELECT @cnt = Count(TourRecID), @Rate = SUM(Rate) FROM tlRates 
			WHERE TourRecID = @TourRecID AND TableInfID = @TableInfID
		
		SET @Rate = @Rate / @cnt
		
		IF NOT EXISTS (SELECT * FROM @tmpRate 
							WHERE TableInfID = @TableInfID AND TourRecID = @TourRecID)
				INSERT INTO @tmpRate VALUES(@TableInfID, @TourRecID, @Rate)
				
	FETCH NEXT FROM csr INTO @RateRecID
	END	
	CLOSE csr
	DEALLOCATE csr

	IF @TableType = 'E'
	BEGIN
		SELECT A.EmployeeInfID [InfID], D.TourName , B.TourRecID, C.FromDate, C.ToDate,
			CASE WHEN 5 >= B.Rate AND B.Rate > 4 THEN 'Y' ELSE 'N' END Excellent,
			CASE WHEN 4 >= B.Rate AND B.Rate > 3 THEN 'Y' ELSE 'N' END Good,
			CASE WHEN 3 >= B.Rate AND B.Rate > 2 THEN 'Y' ELSE 'N' END Average,
			CASE WHEN 2 >= B.Rate AND B.Rate > 1 THEN 'Y' ELSE 'N' END NotGood,
			CASE WHEN 1 >= B.Rate THEN 'Y' ELSE 'N' END Poor
			FROM tlEmployees A
			INNER JOIN @tmpRate B ON A.EmployeeInfID = B.TableInfID
			INNER JOIN tlToursEmployees C ON B.TourRecID = C.TourRecID AND B.TableInfID = C.EmployeeInfID
			INNER JOIN tlTours D ON B.TourRecID = D.TourRecID
			GROUP BY A.EmployeeInfID, D.TourName, B.TourRecID, C.FromDate, C.ToDate, B.Rate		
	END

	IF @TableType = 'R'
		BEGIN
			SELECT D.RestaurantInfID [InfID], E.TourName, A.TourRecID, C.Date,
				CASE WHEN 5 >= A.Rate AND A.Rate > 4 THEN 'Y' ELSE 'N' END Excellent,
				CASE WHEN 4 >= A.Rate AND A.Rate > 3 THEN 'Y' ELSE 'N' END Good,
				CASE WHEN 3 >= A.Rate AND A.Rate > 2 THEN 'Y' ELSE 'N' END Average,
				CASE WHEN 2 >= A.Rate AND A.Rate > 1 THEN 'Y' ELSE 'N' END NotGood,
				CASE WHEN 1 >= A.Rate THEN 'Y' ELSE 'N' END Poor
				FROM @tmpRate A
				INNER JOIN tlRestaurantServicePrices B ON A.TableInfID =  B.RestaurantInfID
				INNER JOIN tlTourCatering C ON A.TourRecID  = C.TourRecID AND B.RestaurantServicePriceInfID = C.RestaurantServicePriceInfID	
				INNER JOIN tlRestaurants D ON A.TableInfID = D.RestaurantInfID 
				INNER JOIN tlTours E ON A.TourRecID = E.TourRecID
	END

	IF @TableType = 'A'
	BEGIN
		SELECT B.AccomodationInfID [InfID], D.TourName, A.TourRecID, C.CheckInDate, C.CheckOutDate,
			CASE WHEN 5 >= A.Rate AND A.Rate > 4 THEN 'Y' ELSE 'N' END Excellent,
			CASE WHEN 4 >= A.Rate AND A.Rate > 3 THEN 'Y' ELSE 'N' END Good,
			CASE WHEN 3 >= A.Rate AND A.Rate > 2 THEN 'Y' ELSE 'N' END Average,
			CASE WHEN 2 >= A.Rate AND A.Rate > 1 THEN 'Y' ELSE 'N' END NotGood,
			CASE WHEN 1 >= A.Rate THEN 'Y' ELSE 'N' END Poor
			FROM @tmpRate A 
			INNER JOIN tlAccomodations B ON A.TableInfID = B.AccomodationInfID
			INNER JOIN tlTourAccomodations C ON A.TourRecID = C.TourRecID AND A.TableInfID = C.AccomodationInfID 
			INNER JOIN tlTours D ON A.TourRecID = D.TourRecID
			
	END
		/*
			SELECT * FROM tlEmployees A
			INNER JOIN tlEmpRateRegister B ON A.EmployeeInfID = B.EmployeeInfID
		*/
END
