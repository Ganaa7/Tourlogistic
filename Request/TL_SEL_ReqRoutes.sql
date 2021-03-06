USE [TourLogistic]
GO
DROP PROC TL_SEL_ReqRoutes
GO
CREATE PROC TL_SEL_ReqRoutes(
	@RequestRecID	pkType
)AS
BEGIN
	DECLARE @PointRegisterRecID	NUMERIC(18), 
			@ArriveDate			dateType, 
			@DeptDate			dateType,
			@cnt				SMALLINT,
			@FromPointRecID		NUMERIC(18), 
			@FromDate			dateType,
			@ToPointRecID		NUMERIC(18), 
			@ToDate				dateType

	SET NOCOUNT ON

	CREATE TABLE #Routes(
		RowID			INT IDENTITY(1,1),
		FromPointRecID	NUMERIC(18), 
		ToPointRecID	NUMERIC(18), 
		FromDate		VARCHAR(23), 
		ToDate			VARCHAR(23),
		Distance		INT,
		RouteRecID		NUMERIC(18))

	SET @cnt=1

	DECLARE vSet CURSOR FOR
		SELECT PointRecID, ArriveDate, DepartDate
			FROM tlReqPoints
			WHERE RequestRecID=@RequestRecID
			ORDER BY PointNum

	OPEN vSet
	FETCH NEXT FROM vSet INTO @PointRegisterRecID, @ArriveDate, @DeptDate
	WHILE @@FETCH_STATUS=0
		BEGIN
		IF @cnt=1
			BEGIN
			SET @FromPointRecID=@PointRegisterRecID
			SET @FromDate=@DeptDate
			END
		ELSE
			BEGIN
			SET @ToPointRecID=@PointRegisterRecID
			SET @ToDate=@ArriveDate
			
			INSERT INTO #Routes(FromPointRecID, ToPointRecID, FromDate, ToDate, Distance, RouteRecID)
				VALUES(@FromPointRecID, @ToPointRecID, @FromDate, @ToDate, 0, 0)

			SET @FromPointRecID=@PointRegisterRecID
			SET @FromDate=@DeptDate
			END
		SET @cnt=@cnt+1
		FETCH NEXT FROM vSet INTO @PointRegisterRecID, @ArriveDate, @DeptDate
		END
	CLOSE vSet
	DEALLOCATE vSet

	UPDATE A SET Distance=B.Distance, RouteRecID=B.RouteRecID
		FROM #Routes A INNER JOIN tlRoutes B ON A.FromPointRecID=B.FromPointRecID AND A.ToPointRecID=B.ToPointRecID

	SET NOCOUNT OFF

	SELECT A.RowID, A.RouteRecID, @RequestRecID AS RequestRecID, 
			A.FromPointRecID AS FromPoint, B.PointNameF AS FromPointNameF, D.DescriptionF AS FromProvinceDescF,
			A.ToPointRecID AS ToPoint, C.PointNameF AS ToPointNameF, E.DescriptionF AS ToProvinceDescF, 
			A.FromDate, A.ToDate, A.Distance 
		FROM #Routes A 
			LEFT OUTER JOIN tlPointRegistrations B ON A.FromPointRecID = B.PointRegisterRecID
			LEFT OUTER JOIN tlPointRegistrations C ON A.ToPointRecID = C.PointRegisterRecID
			LEFT OUTER JOIN tlProvinces D ON B.ProvinceInfID = D.ProvinceInfID
			LEFT OUTER JOIN tlProvinces E ON C.ProvinceInfID = E.ProvinceInfID
		WHERE A.RouteRecID <> 0
		ORDER BY A.RowID
END
GO
EXEC TL_SEL_ReqRoutes 1987030900002

/*
	SELECT * FROM tlTourPoints
	SELECT * FROM tlReqPoints
	SELECT * FROM tlRoutes
	EXEC SP_HELP  tlRoutes

*/