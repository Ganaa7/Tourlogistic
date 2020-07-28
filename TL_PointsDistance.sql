USE TourLogistic
GO

DROP PROC TL_PointsDistance
GO

CREATE PROC TL_PointsDistance(
	@PointDA	pkType,
	@PointDB	pkType) AS
BEGIN

	IF NOT EXISTS (SELECT * FROM tlRoutes WHERE PointDA = @PointDA AND PointDB = @PointDB)
		SELECT CONVERT(INT, 0) AS Distance
	ELSE
		SELECT Distance FROM tlRoutes WHERE PointDA = @PointDA AND PointDB = @PointDB
END
GO

EXEC TL_PointsDistance 174, 134
GO
/*
SELECT * FROM tlRoutes WHERE PointDA = 76
*/
