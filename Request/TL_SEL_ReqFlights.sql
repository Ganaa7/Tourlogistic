USE TourLogistic
GO

USE TourLogistic
GO
DROP PROC TL_SEL_ReqFlights
GO
CREATE PROC TL_SEL_ReqFlights(
	@RequestRecID	pkType,
	@RouteRecID		pkType
) AS
BEGIN
	DECLARE @PointRegisterRecID	NUMERIC(18), 
			@ArriveDate			dateType, 
			@DeptDate			dateType,
			@cnt				SMALLINT,
			@FromPointRecID		NUMERIC(18), 
			@FromDate			dateType,
			@ToPointRecID		NUMERIC(18), 
			@ToDate				dateType

	CREATE TABLE #FlRoutes(
		RowID			INT IDENTITY(1,1),
		FromPointRecID	NUMERIC(18), 
		ToPointRecID	NUMERIC(18), 
		FromDate		VARCHAR(23), 
		ToDate			VARCHAR(23),
		Distance		SMALLINT,
		RouteRecID		NUMERIC(18))

	SET @cnt=1

--	DECLARE fSet CURSOR FOR
--		SELECT PointRecID, ArriveDate, DepartDate
--			FROM tlReqPoints
--			WHERE RequestRecID=@RequestRecID
--			ORDER BY PointNum
--
--	OPEN fSet
--	FETCH NEXT FROM fSet INTO @PointRegisterRecID, @ArriveDate, @DeptDate
--	WHILE @@FETCH_STATUS=0
--		BEGIN
--		IF @cnt=1
--			BEGIN
--			SET @FromPointRecID=@PointRegisterRecID
--			SET @FromDate=@DeptDate
--			END
--		ELSE
--			BEGIN
--			SET @ToPointRecID=@PointRegisterRecID
--			SET @ToDate=@ArriveDate
--			
--			INSERT INTO #FlRoutes(FromPointRecID, ToPointRecID, FromDate, ToDate, Distance, RouteRecID)
--				VALUES(@FromPointRecID, @ToPointRecID, @FromDate, @ToDate, 0, 0)
--
--			SET @FromPointRecID=@PointRegisterRecID
--			SET @FromDate=@DeptDate
--			END
--		SET @cnt=@cnt+1
--		FETCH NEXT FROM fSet INTO @PointRegisterRecID, @ArriveDate, @DeptDate
--		END
--	CLOSE fSet
--	DEALLOCATE fSet
--
--	UPDATE A SET Distance=B.Distance, RouteRecID=B.RouteRecID
--		FROM #FlRoutes A INNER JOIN tlRoutes B ON A.FromPointRecID=B.FromPointRecID AND A.ToPointRecID=B.ToPointRecID

	SELECT A.FlightRecID, A.FlightID, H.DescriptionF [AirlineDescF], A.DescriptionF [FlightDescF], E.FromDate [DepartDate], B.DeptTime, C.DescriptionF [WeekDays], D.RouteRecID,
		CASE WHEN PaxQty IS NULL THEN 'N' ELSE 'Y' END AS GuestViewCheck,
		CASE WHEN PaxQty IS NULL THEN 0 ELSE PaxQty END AS PaxQty,
		CASE WHEN EmployeeQty IS NULL THEN 0 ELSE EmployeeQty END AS EmployeeQty, 
		CASE WHEN F.IsCargo IS NULL THEN 'N' ELSE F.IsCargo END AS IsCargo
	FROM tlFlights A
		INNER JOIN tlFlightTimes B ON A.FlightRecID = B.FlightRecID
		INNER JOIN VIEW_ssWeekDays C ON B.DayID = C.ID
		INNER JOIN tlRoutes D ON A.FromPoint = D.FromPointRecID AND A.ToPoint = D.ToPointRecID 
		INNER JOIN #FlRoutes E ON D.FromPointRecID = E.FromPointRecID AND D.ToPointRecID = E.ToPointRecID
		LEFT OUTER JOIN tlReqFlights F ON A.FlightRecID = F.FlightRecID
		INNER JOIN tlAirlines H ON A.AirlineInfID = H.AirlineInfID
	WHERE '10'+CASE WHEN DATEPART(dw, E.FromDate)-1 = 0 THEN '7' 
		ELSE CONVERT(VARCHAR(1), DATEPART(dw, E.FromDate)-1) END = C.ID
		AND D.RouteRecID = @RouteRecID
	GROUP BY A.FlightRecID, A.FlightID, H.DescriptionF, A.DescriptionF,  E.FromDate, DeptTime, C.DescriptionF, D.RouteRecID, PaxQty, EmployeeQty, F.IsCargo
END
GO
TL_SEL_ReqFlights 1987030900002, 1987022200121
--TL_SEL_ReqFlights 1987030900002, 1987022200247
/*

select * from tlFlights where fromPOint = 1987022200083

select * from tlRoutes where fromPOintRecId = 1987022200083
	

A.FlightRecID, B.DayID

SELECT *
	FROM tlFlights A
		INNER JOIN tlFlightTimes B ON A.FlightRecID = B.FlightRecID
		INNER JOIN VIEW_ssWeekDays C ON B.DayID = C.ID
		INNER JOIN tlRoutes D ON A.FromPoint = D.FromPointRecID AND A.ToPoint = D.ToPointRecID 
		INNER JOIN tlReqPoints E ON D.FromPointRecID = E.PointRecID
		INNER JOIN tlReqFlights F ON A.FlightRecID = F.FlightRecID
		INNER JOIN tlAirlines H ON A.AirlineInfID = H.AirlineInfID
	WHERE '10'+CASE WHEN DATEPART(dw, E.DepartDate)-1 = 0 THEN '7' 
		ELSE CONVERT(VARCHAR(1), DATEPART(dw, E.DepartDate)-1) END = C.ID
		AND D.RouteRecID = 1987022200247 AND E.RequestRecID = 1987030900002

	SELECT * FROM tlrEQFlights
	SELECT * FROM tlFlightTimes
	SELECT * FROM VIEW_ssWeekDays
	SELECT * FROM tlRoutes

1987030200001

	SELECT * FROM tlFlightTimes
	SELECT * FROM tlReqPoints

	SELECT A.* FROM tlFlights A
		INNER JOIN tlFlightTimes B ON A.FlightRecID = B.FlightRecID
	
	SELECT * FROM tlRoutes
		where routerecID = 1987022200247

	SELECT * FROM tlReqPoints
	SELECT * FROM VIEW_ssWeekDays
	SELECT * FROM tlPointRegistrations
		where PointNameL LIKE N'Х%'

	SELECT * FROM tlRoutes
*/
