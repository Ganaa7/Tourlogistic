USE TourLogistic
GO

DROP PROC TL_DEL_TourRoutes
GO

CREATE PROC TL_DEL_TourRoutes(
	@IsTour				CHAR(1),
	@TourRecID			NUMERIC(18),
	@PointNum			INT ) AS
BEGIN
	IF @IsTour = 'N'	
	BEGIN
		DELETE FROM tlReqRoutes WHERE RequestRecID = @TourRecID AND RouteNum = @PointNum
		UPDATE tlReqRoutes SET ToPointRecID = NULL
			WHERE RequestRecID = @TourRecID AND RouteNum = @PointNum - 1
	END
	ELSE
		DELETE FROM tlReqRoutes WHERE RequestRecID = @TourRecID AND RouteNum = @PointNum
END
GO
EXEC TL_DEL_TourRoutes 'N', 1987030900002, 6

/*
	SELECT * FROM tlReqRoutes
*/