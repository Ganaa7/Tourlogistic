USE TourLogistic
GO
DROP PROC TL_SEL_ReqFlights2
GO
CREATE PROC TL_SEL_ReqFlights2(
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

	SELECT A.FlightRecID, A.FlightID, H.DescriptionF [AirlineDescF], A.DescriptionF [FlightDescF], E.FromDepartDate [DepartDate], B.DeptTime, C.DescriptionF [WeekDays], D.RouteRecID,
		CASE WHEN PaxQty IS NULL THEN 'N' ELSE 'Y' END AS GuestViewCheck,
		CASE WHEN PaxQty IS NULL THEN 0 ELSE PaxQty END AS PaxQty,
		CASE WHEN EmployeeQty IS NULL THEN 0 ELSE EmployeeQty END AS EmployeeQty, 
		CASE WHEN F.IsCargo IS NULL THEN 'N' ELSE F.IsCargo END AS IsCargo
	FROM tlFlights A
		INNER JOIN tlFlightTimes B ON A.FlightRecID = B.FlightRecID
		INNER JOIN VIEW_ssWeekDays C ON B.DayID = C.ID
		INNER JOIN tlRoutes D ON A.FromPoint = D.FromPointRecID AND A.ToPoint = D.ToPointRecID 
		INNER JOIN tlReqRoutes E ON D.FromPointRecID = E.FromPointRecID AND D.ToPointRecID = E.ToPointRecID
		LEFT OUTER JOIN tlReqFlights F ON A.FlightRecID = F.FlightRecID
		INNER JOIN tlAirlines H ON A.AirlineInfID = H.AirlineInfID
	WHERE '10'+CASE WHEN DATEPART(dw, E.FromDepartDate)-1 = 0 THEN '7' 
		ELSE CONVERT(VARCHAR(1), DATEPART(dw, E.FromDepartDate)-1) END = C.ID
		AND D.RouteRecID = @RouteRecID
	
END 
GO
--TL_SEL_ReqFlights2 1987030900002, 1987022200121
--TL_SEL_ReqFlights 1987030900002, 1987022200247
/*

	SELECT * FROM tlFlights WHERE fromPOint = 1987022200083
	SELECT * FROM tlRoutes WHERE fromPOintRecId = 1987022200083

	SELECT * FROM tlReqRoutes
	SELECT * FROM tlFlightTimes
	SELECT * FROM VIEW_ssWeekDays
	SELECT * FROM tlRoutes

	SELECT * FROM tlFlightTimes
	SELECT * FROM tlReqPoints

	SELECT A.* FROM tlFlights A
		INNER JOIN tlFlightTimes B ON A.FlightRecID = B.FlightRecID
	
	SELECT * FROM tlRoutes
		where routerecID = 1987022200247

*/
