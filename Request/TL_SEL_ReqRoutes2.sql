USE TourLogistic
GO

DROP PROC TL_SEL_ReqRoutes2
GO

CREATE PROC TL_SEL_ReqRoutes2(
	@RequestRecID		pkType ) AS
BEGIN

	SELECT ROW_NUMBER( )OVER(ORDER BY A.ReqRouteRecID) AS PointNum, A.ReqRouteRecID, A.RequestRecID, B.RouteRecID, A.FromPointRecID AS FromPoint, C.PointNameF AS FromPointNameF,
			E.DescriptionF AS FromProvinceDescF, A.ToPointRecID AS ToPoint, D.PointNameF AS ToPointNameF, F.DescriptionF AS ToProvinceDescF, 
			A.FromArrivalDate, A.ToArrivalDate, B.Distance 
			FROM tlReqRoutes A
				INNER JOIN tlRoutes B ON A.FromPointRecID = B.FromPointRecID AND A.ToPointRecID = B.ToPointRecID
				INNER JOIN tlPointRegistrations C ON B.FromPointRecID = C.PointRegisterRecID
				INNER JOIN tlPointRegistrations D ON B.ToPointRecID = D.PointRegisterRecID
				INNER JOIN tlProvinces E ON C.ProvinceInfID = E.ProvinceInfID
				INNER JOIN tlProvinces F ON D.ProvinceInfID = F.ProvinceInfID
			WHERE A.RequestRecID = @RequestRecID

END
GO
EXEC TL_SEL_ReqRoutes2 1987030900002 

/*
	TL_SEL_ReqRoutes
	SELECT * FROM tlReqRoutes

*/