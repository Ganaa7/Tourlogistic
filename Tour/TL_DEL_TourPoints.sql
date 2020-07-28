USE TourLogistic
GO

DROP PROC TL_DEL_TourPoints
GO

CREATE PROC TL_DEL_TourPoints(
	@IsTour				CHAR(1),
	@TourRecID			NUMERIC(18),
	@PointNum			INT ) AS
BEGIN
	IF @IsTour = 'N'	
		DELETE FROM tlReqPoints WHERE RequestRecID = @TourRecID AND PointNum = @PointNum

END
GO

--EXEC TL_DEL_TourPoints 1987022100003, 3
GO

/*
SELECT * FROM tlTourPoints
SELECT * FROM tlTourRoutes

SELECT * FROM tlPointRegistrations
132
SELECT * FROM tlRoutes WHERE PointDA = 119

SELECT * FROM tlTransports

SELECT * FROM tlTourRoutes

*/