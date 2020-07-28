USE TourLogistic
GO

DROP PROC TL_SEL_TourRoutes
GO

CREATE PROC TL_SEL_TourRoutes(
		@TourRecID	       NUMERIC(18)
) AS
BEGIN
		SELECT A.TourRouteRecID, A.TourRecID, B.PointRegisterRecID, B.PointNameF, C.ProvinceInfID, C.DescriptionF ProvinceDescF, A.RouteNum, D.Distance, 
				CoordinateX, CoordinateY, A.FromArrivalDate, A.FromDepartDate
			FROM tlTourRoutes A
				INNER JOIN tlRoutes D ON A.FromPointRecID = D.FromPointRecID AND A.ToPointRecID = D.ToPointRecID
				INNER JOIN tlPointRegistrations B ON A.FromPointRecID = B.PointRegisterRecID
				INNER JOIN tlProvinces C ON B.ProvinceInfID = C.ProvinceInfID
			WHERE A.TourRecID = @TourRecID

END
GO
EXEC TL_SEL_TourRoutes 1987022100002
/*
	SELECT * FROM tlTourRouteS A
			INNER JOIN tlRoutes D ON A.FromPointRecID = D.FromPointRecID AND A.ToPointRecID = D.ToPointRecID
	
	SELECT * FROM tlPointRegistrations
	SELECT * FROM tlRoutes
	 WHERE FromPointRecID = 1987022200079  AND ToPointRecID = 1987022200107

	SELECT * FROM tlRoutes
	 WHERE FromPointRecID = 1987022200074  AND ToPointRecID = 1987022200002
*/