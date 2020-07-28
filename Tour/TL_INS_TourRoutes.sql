USE TourLogistic
GO
DROP PROC TL_INS_TourRoutes
GO

CREATE PROC TL_INS_TourRoutes(
	@IsTour				CHAR(1),
	@TourRecID			pkType,
	@RouteNum			INT,
	@PointRecID			NUMERIC(18),
	@ArriveDate			VARCHAR(23),
	@DeptDate			VARCHAR(23) ) AS
BEGIN

	DECLARE @RecID				pkType,
			@FromPointRecID		pkType,
			@Distance			SMALLINT,
			@DateArriveDif		dateType,
			@DateDepartDif		SMALLINT,
			@ReqRouteRecID		pkType,
			@FromArrivalDate	dateType,
			@FromDepartDate		dateType, 
			@ToArrivalDate		dateType, 
			@ToDepartDate		dateType
			
	IF @IsTour = 'Y'				
	BEGIN
		IF NOT EXISTS(SELECT * FROM tlTourRoutes WHERE TourRecID = @TourRecID)
		BEGIN
				EXEC CreatePkID 'tlTourRoutes','TourRouteRecID', @RecID OUTPUT

				INSERT INTO tlTourRoutes(TourRouteRecID, TourRecID, RouteNum, FromPointRecID, FromArrivalDate, FromDepartDate) 
					SELECT @RecID, @TourRecID, 1, @PointRecID, @ArriveDate, @DeptDate
					SELECT 'Y' AS Num
		END
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT * FROM tlTourRoutes WHERE TourRecID = @TourRecID AND RouteNum = @RouteNum)
			BEGIN
					UPDATE tlTourRoutes SET ToPointRecID = @PointRecID, ToArrivalDate = @ArriveDate, ToDepartDate = @DeptDate
						WHERE TourRecID = @TourRecID AND RouteNum = @RouteNum - 1
					IF @@RowCount > 0
					BEGIN
					--	SELECT N'123'
						EXEC CreatePkID 'tlTourRoutes','TourRouteRecID', @RecID OUTPUT
						
						INSERT INTO tlTourRoutes(TourRouteRecID, TourRecID, RouteNum, FromPointRecID, FromArrivalDate, FromDepartDate) 
							SELECT @RecID, @TourRecID, @RouteNum, @PointRecID, @ArriveDate, @DeptDate	
					--	SELECT 'Ins,Up' AS Num
					END
			END
			ELSE
				BEGIN
					UPDATE tlTourRoutes SET FromPointRecID = @PointRecID,
											FromArrivalDate = @ArriveDate,
											FromDepartDate = @DeptDate
						WHERE TourRecID = @TourRecID AND RouteNum	= @RouteNum
					SELECT 'Y' AS Num
				END
				
		END
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT * FROM tlReqRoutes WHERE RequestRecID = @TourRecID)
			BEGIN
				EXEC CreatePkID 'tlReqRoutes','ReqRouteRecID', @RecID OUTPUT

				INSERT INTO tlReqRoutes(ReqRouteRecID, RequestRecID, RouteNum, FromPointRecID, FromArrivalDate, FromDepartDate) 
					SELECT @RecID, @TourRecID, 1, @PointRecID, @ArriveDate, @DeptDate
					SELECT 'Y' AS Num
			END
		ELSE
		BEGIN
			IF NOT EXISTS (SELECT * FROM tlReqRoutes WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum)
			BEGIN
					UPDATE tlReqRoutes SET ToPointRecID = @PointRecID, ToArrivalDate = @ArriveDate, ToDepartDate = @DeptDate
						WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum - 1
				
					SELECT @FromPointRecID = FromPointRecID FROM tlReqRoutes
						WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum - 1
					
					IF @@RowCount > 0
					BEGIN
						EXEC CreatePkID 'tlReqRoutes','ReqRouteRecID', @RecID OUTPUT
	--------------------------------------------------------------------------------------------------------					
						INSERT INTO tlReqRoutes(ReqRouteRecID, RequestRecID, RouteNum, FromPointRecID, FromArrivalDate, FromDepartDate) 
							SELECT @RecID, @TourRecID, @RouteNum, @PointRecID, @ArriveDate, @DeptDate
						
						UPDATE tlReqRoutes SET ToArrivalDate = @ArriveDate,
										       ToDepartDate = @DeptDate
						WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum-1	
	---------------------------------------------------------------------------------------------------				
						SELECT 'Y' AS Num, Distance AS KM
							FROM tlRoutes
							WHERE FromPointRecID = @FromPointRecID AND ToPointRecID = @PointRecID
										
					END
			END
			ELSE
				BEGIN
----------------------------------------------------------------------------------------------------------		
--					UPDATE tlReqRoutes SET FromArrivalDate = @ArriveDate,
--										   FromDepartDate = @DeptDate
--						WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum

					UPDATE tlReqRoutes SET ToArrivalDate = @ArriveDate,
										   ToDepartDate = @DeptDate
						WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum-1
----------------------------------------------------------------------------------------------------------
					SELECT @DateDepartDif = DATEDIFF(dd, FromDepartDate, @DeptDate)
						FROM tlReqRoutes 
							WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum
				
					SELECT @DateDepartDif, FromDepartDate, @DeptDate
						FROM tlReqRoutes 
							WHERE RequestRecID = @TourRecID AND RouteNum = @RouteNum 
			
					IF @DateDepartDif > 0
					BEGIN 
					
						DECLARE rSet CURSOR FOR 
							SELECT ReqRouteRecID
								FROM tlReqRoutes
								WHERE RequestRecID = @TourRecID AND RouteNum >= @RouteNum
					
						OPEN rSet
						FETCH NEXT FROM rSet INTO @ReqRouteRecID
						WHILE @@FETCH_STATUS = 0
						BEGIN	
								SELECT @DateDepartDif = DATEDIFF(dd, FromDepartDate, @DeptDate)
									FROM tlReqRoutes
									WHERE ReqRouteRecID = @ReqRouteRecID 

								SELECT @FromArrivalDate = FromArrivalDate, @FromDepartDate = FromDepartDate, @ToArrivalDate = ToArrivalDate, @ToDepartDate = ToDepartDate 
									FROM tlReqRoutes
									WHERE ReqRouteRecID = @ReqRouteRecID
								
								SELECT @DateDepartDif AS DateDepartDif

								SELECT @FromArrivalDate FromArrivalDate, @FromDepartDate FromDepartDate, @ToArrivalDate ToArrivalDate, @ToDepartDate ToDepartDate
							
								SELECT CONVERT(VARCHAR(23), DATEADD(day, @DateDepartDif, CONVERT(DATETIME, @FromArrivalDate)), 111)

								UPDATE tlReqRoutes SET FromArrivalDate = CONVERT(VARCHAR(23), DATEADD(day, @DateDepartDif, CONVERT(DATETIME, @FromArrivalDate)), 111),
												   FromDepartDate = CONVERT(VARCHAR(23), DATEADD(day, @DateDepartDif, CONVERT(DATETIME, @FromDepartDate)), 111),
												   ToArrivalDate = CONVERT(VARCHAR(23), DATEADD(day, @DateDepartDif, CONVERT(DATETIME, @ToArrivalDate)), 111),
												   ToDepartDate = CONVERT(VARCHAR(23), DATEADD(day, @DateDepartDif, CONVERT(DATETIME, @ToDepartDate)), 111)
								WHERE ReqRouteRecID = @ReqRouteRecID 
						
							FETCH NEXT FROM rSet INTO @ReqRouteRecID
						END
						CLOSE rSet
						DEALLOCATE rSet
					END
					ELSE
						RAISERROR('Update Date is minimum from current date!', 16, 1)
				END
		END
	END
END
GO
--EXEC TL_INS_TourRoutes 'N', 1987022100007, 4, 1987022600001, '2007/03/24', '2007/03/28'
TL_INS_TourRoutes 'N',1987030900002, 4, 1987022200082, '2007/03/29', '2007/03/21'

/*
	SELECT * FROM tlReqRoutes
	
	SELECT CONVERT(DATETIME, '03/25/2007', 101)
				FROM tlReqRoutes

	UPDATE tlReqRoutes SET FromDepartDate = '2007/03'
	
	UPDATE tlReqRoutes SET FromArrivalDate = '2007/03/19'
		WHERE ReqRouteRecID = 1987032700004

   SELECT DATEADD(day,1, '2005/01/03')
   EXEC TL_DEL_TourRoutes 'N', 1987030900002, 5
   SELECT * FROM tlReqRoutes
   SELECT * FROM tlTours
	UPDATE tlTourRoutes SET RouteNum = 1
		WHERE TourRouteRecID = 1987032600001
	select * from tlRoutes
  DELETE FROM tlReqRoutes
	WHERE ReqRouteRecID = 1987032700006
	
	SELECT * FROM tlPointRegistrations

*/


