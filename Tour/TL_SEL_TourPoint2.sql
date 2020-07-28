USE TourLogistic
GO

DROP PROC TL_SEL_TourPoints2
GO

CREATE PROC TL_SEL_TourPoints2(
	@IsTour			   CHAR(1), 
	@TourRecID	       NUMERIC(18)
) AS
BEGIN

	IF @IsTour = 'N'	
		SELECT A.ReqRouteRecID RowRecID, A.RequestRecID TourRecID, B.PointRegisterRecID, B.PointNameF, C.ProvinceInfID, C.DescriptionF ProvinceDescF, 
				A.RouteNum PointNum, E.Distance, B.CoordinateX, B.CoordinateY, A.FromArrivalDate AS ArriveDate, A.FromDepartDate AS DepartDate
			FROM tlReqRoutes A 
				INNER JOIN tlPointRegistrations B ON A.FromPointRecID = B.PointRegisterRecID
				INNER JOIN tlProvinces C ON B.ProvinceInfID = C.ProvinceInfID
				LEFT OUTER JOIN tlRoutes E ON A.FromPointRecID = E.FromPointRecID AND A.ToPointRecID = E.ToPointRecID
				WHERE A.RequestRecID = @TourRecID
			ORDER BY A.RouteNum
	ELSE
		SELECT A.TourRouteRecID RowRecID, A.TourRecID, B.PointRegisterRecID, B.PointNameF, C.ProvinceInfID, C.DescriptionF ProvinceDescF, 
				A.RouteNum PointNum, E.Distance, B.CoordinateX, B.CoordinateY, A.FromArrivalDate AS ArriveDate, A.FromDepartDate AS DepartDate
			FROM tlTourRoutes A 
				INNER JOIN tlPointRegistrations B ON A.FromPointRecID = B.PointRegisterRecID
				INNER JOIN tlProvinces C ON B.ProvinceInfID = C.ProvinceInfID
				INNER JOIN tlRoutes E ON A.FromPointRecID = E.FromPointRecID AND A.ToPointRecID = E.ToPointRecID
				WHERE A.TourRecID = @TourRecID
			ORDER BY A.RouteNum
				
END
GO
EXEC TL_SEL_TourPoints2 'N', 1987030900002
/*

	SELECT * FROM tlReqRoutes

	SELECT * FROM tlPointRegistrations
	

1987022200083
1987022200074
  SELECT * FROM tlRoutes
	WHERE FromPointRecID = 1987022200083 AND ToPointRecID = 1987022200074
*/

