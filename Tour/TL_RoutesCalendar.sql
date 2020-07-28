USE TourLogistic
GO

DROP PROC TL_SEL_TourPoints
GO

CREATE PROC TL_SEL_TourPoints(
	@IsTour			   CHAR(1), 
	@TourRecID	       NUMERIC(18)
) AS
BEGIN
	DECLARE @tmpPoints TABLE(
		RowRecID			pkType,
		TourRecID			pkType,
		PointRegisterRecID	pkType,
		PointNameF			descType,
		ProvinceInfID		pkType,
		ProvinceDescF		descType,
		PointNum			SMALLINT,
		Distance			SMALLINT,
		CoordinateX			INT,
		CoordinateY			INT,
		ArriveDate			dateType,
		DepartDate			dateType,	
		TransportTypeID		idType,
		LeaveWithGuide		char(1))

	DECLARE	@FromPointID	pkType,
			@ToPointID		pkType,
			@Distance		SMALLINT,
			@Order			SMALLINT
	SET @Order = 1
	
	SET NOCOUNT ON

	IF @IsTour = 'Y'
	BEGIN
		INSERT INTO @tmpPoints(RowRecID, TourRecID, PointRegisterRecID, PointNameF, ProvinceInfID, ProvinceDescF, PointNum, CoordinateX, CoordinateY, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide)
			SELECT TourPointRecID, TourRecID, A.PointRegisterRecID, B.PointNameF, B.ProvinceInfID, C.DescriptionF, PointNum, CoordinateX, CoordinateY, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide 
				FROM tlTourPoints A
					INNER JOIN tlPointRegistrations B ON A.PointRegisterRecID = B.PointRegisterRecID
					INNER JOIN tlProvinces C ON B.ProvinceInfID = C.ProvinceInfID
				WHERE TourRecID = @TourRecID
		 
		DECLARE CURP CURSOR FOR
			SELECT PointRegisterRecID FROM tlTourPoints
				WHERE TourRecID = @TourRecID 

		OPEN CURP
		FETCH NEXT FROM CURP INTO @FromPointID
		WHILE @@FETCH_STATUS = 0	
		BEGIN
			FETCH NEXT FROM CURP INTO @ToPointID
				SET @Order = @Order + 1

			IF @FromPointID <> @ToPointID
			BEGIN
				SELECT @Distance = Distance
					FROM tlRoutes WHERE FromPointRecID = @FromPointID AND ToPointRecID = @ToPointID
		
				UPDATE @tmpPoints SET Distance = @Distance 
					WHERE PointRegisterRecID = @ToPointID AND PointNum = @Order

				SET @FromPointID = @ToPointID
			END
		END
		CLOSE CURP
		DEALLOCATE CURP
	
		UPDATE @tmpPoints SET Distance = 0
			WHERE Distance IS NULL
	END
	
	ELSE
	BEGIN
		INSERT INTO @tmpPoints(RowRecID, TourRecID, PointRegisterRecID, PointNameF, ProvinceInfID, ProvinceDescF, PointNum, CoordinateX, CoordinateY, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide)
			SELECT RowRecID, RequestRecID, A.PointRecID, B.PointNameF, B.ProvinceInfID, C.DescriptionF, PointNum, CoordinateX, CoordinateY, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide 
				FROM tlReqPoints A
					INNER JOIN tlPointRegistrations B ON A.PointRecID = B.PointRegisterRecID
					INNER JOIN tlProvinces C ON B.ProvinceInfID = C.ProvinceInfID
				WHERE RequestRecID = @TourRecID
		 
		DECLARE CURP CURSOR FOR
			SELECT PointRecID FROM tlReqPoints
				WHERE RequestRecID = @TourRecID 

		OPEN CURP
		FETCH NEXT FROM CURP INTO @FromPointID
		WHILE @@FETCH_STATUS = 0	
		BEGIN
			FETCH NEXT FROM CURP INTO @ToPointID
				SET @Order = @Order + 1

			IF @FromPointID <> @ToPointID
			BEGIN
				SELECT @Distance = Distance
					FROM tlRoutes WHERE FromPointRecID = @FromPointID AND ToPointRecID = @ToPointID
			
				UPDATE @tmpPoints SET Distance = @Distance 
					WHERE PointRegisterRecID = @ToPointID AND PointNum = @Order
	
				SET @FromPointID = @ToPointID
			END
		END
		CLOSE CURP
		DEALLOCATE CURP
	
		UPDATE @tmpPoints SET Distance = 0
			WHERE Distance IS NULL
	
	END

	SELECT 	RowRecID, TourRecID, PointRegisterRecID, PointNameF, ProvinceInfID, ProvinceDescF, PointNum, Distance, 
		CoordinateX, CoordinateY, ArriveDate, DepartDate
	    FROM @tmpPoints
END
GO
EXEC TL_SEL_TourPoints 'N', 1987030900002

GO
	/*

	SELECT * FROM tlTourPoints

	SELECT * FROM tlReqPoints

	SELECT * FROM tlProvinces

	SELECT * FROM VIEW_ssTransportType

	exec sp_help tlPointRegistrations

	SELECT * FROM tlPointRegistrations
	SELECT * FROM tlRoutes
	SELECT * FROM tlTransports

	SELECT * FROM tlRoutes

	SELECT * INTO #TMP FROM TrainsDatabase..tlTourRoutes
	 
	declare @id pkType
	EXEC CreatePkID 'tlTourRoutes', 'TourRouteRecID', @id output
	select @id

	INSERT INTO tlTourRoutes VALUES(1987022200001, 1987022100001, 1, 1987022200066, 1987022200124, '2007/02/03', '2007/03/03', NULL, NULL, NULL, NULL)
	INSERT INTO tlTourRoutes VALUES(1987022100002, 1987022100002, 2, 1987022200138, 1987022200075, '2007/03/03', '2007//03', NULL, NULL, NULL, NULL)

	USE TuushinPAYROLL

	SELECT * FROM RDREPORTS
	
*/