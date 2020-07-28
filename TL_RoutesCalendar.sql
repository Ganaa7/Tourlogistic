USE TourLogistic
GO

DROP PROC TL_RoutesCalendar
GO

CREATE PROC TL_RoutesCalendar(
	@TourRecID		pkType
) AS
BEGIN
	
	SELECT A.TourRouteRecID, A.TourRecID, A.RouteNum, A.FromPointRecID AS FromPoint, B.PointNameF AS FromPointNameF, D.DescriptionF AS FromProvinceDescF,
			A.ToPointRecID AS ToPoint, C.PointNameF AS ToPointNameF, E.DescriptionF AS ToProvinceDescF, A.AFromDate AS FromDate, A.BToDate AS ToDate, R.Distance 
		FROM tlTourRoutes	A 
			INNER JOIN tlRoutes R ON A.FromPointRecID = R.FromPointRecID AND A.ToPointRecID = R.ToPointRecID
			LEFT OUTER JOIN tlPointRegistrations B ON A.FromPointRecID = B.PointRegisterID
			LEFT OUTER JOIN tlPointRegistrations C ON A.ToPointRecID = C.PointRegisterID
			LEFT OUTER JOIN tlProvinces D ON B.ProvinceInfID = D.ProvinceInfID
			LEFT OUTER JOIN tlProvinces E ON C.ProvinceInfID = E.ProvinceInfID
		WHERE A.TourRecID = @TourRecID
		ORDER BY A.RouteNum
END
GO

EXEC TL_RoutesCalendar 1987022100002
--GO

/*
SELECT * FROM tlTourRoutes

DELETE FROM tlTourRoutes WHERE TourRouteID = 342

SELECT * FROM tlPointRegistrations

SELECT * FROM tlRoutes

SELECT * FROM tlTransports

SELECT * FROM tlProvinces

SELECT * FROM tlTourRoutes
DELETE FROM tlTourPoints


SELECT * FROM tlTourRouteTransports

DELETE FROM tlTourRouteTransports
*/