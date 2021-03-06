
SELECT * FROM TourLogistic_LS...tbl_OrteAuswahl
SELECT * FROM tlLocalRegistrations
SELECT * FROM TourLogistic_LS...tbl_OrteKoordinaten

DELETE FROM tlLocalRegistrations WHERE DescriptionF = '-'

INSERT INTO tlLocalRegistrations(LocalRegistrationInfID, LocalRegistrationID, DescriptionL, DescriptionF,
		ProvinceID, ActionDoneBy, ActionDate)
	SELECT NameOrt_MGL, NameOrte,  
			ProvinceOrt, 'Admin', CONVERT(VARCHAR(23), GETDATE(), 21)
		FROM TourLogistic_LS...tbl_OrteAuswahl

	DECLARE @DescriptionL	NVARCHAR(75), 
			@DescriptionF	NVARCHAR(75), 
			@ProvinceID		NVARCHAR(30)

	DECLARE Curs CURSOR FOR
		SELECT NameOrt_MGL, NameOrte, ProvinceOrt
			FROM TourLogistic_LS...tbl_OrteAuswahl

	OPEN Curs
	FETCH NEXT FROM Curs INTO @DescriptionL, @DescriptionF, @ProvinceID

	WHILE @@FETCH_STATUS = 0
		BEGIN
		INSERT INTO tlLocalRegistrations(DescriptionL, DescriptionF,
				ProvinceID, ActionDoneBy, ActionDate)
			SELECT @DescriptionL, @DescriptionF, 
				@ProvinceID, 'Admin', CONVERT(VARCHAR(23), GETDATE(), 21)

		FETCH NEXT FROM Curs INTO @DescriptionL, @DescriptionF, @ProvinceID
		END
	CLOSE Curs
	DEALLOCATE Curs

USE TourLogistic

/*
SELECT * FROM tlPointRegistrations
SELECT * FROM tlPointTypes
*/
-- DROP PROC TL_INS_PointRegistrations	200, N'Тестлэлт', N'Testing Insert', N'Deutch', 'N', 'N', 'N', 'N', 'N', 7, '12', N'NoteL', N'NoteF', N'NoteD', -250, 100, 'gpsKoorX1', 'gpsKoorY3', 'admin'
-- TL_INS_PointRegistrations 0, N'Монгол', 'AAAAAA111', '', 'Y', 'Y', 'Y', 'Y', 'Y', 3, 21, N'', '', '', -210, 120, '-240', '100', 'Bold'
CREATE PROC TL_INS_PointRegistrations(
	@PointRegisterID			pkType,
	@PointNameL					descType,
	@PointNameF					descType,
	@PointNameD					descType,
	@IsAirport					CHAR(1),
	@IsTrainStation				CHAR(1),
	@IsAccomodation				CHAR(1),
	@IsTourPoint				CHAR(1),
	@IsFuelStation				CHAR(1),
	@ProvinceID					idType,
	@PointTypeID				idType,
	@PointNoteL					NVARCHAR(256),
	@PointNoteF					NVARCHAR(256),
	@PointNoteD					NVARCHAR(256),
	@CoordinateX				INT,
	@CoordinateY				INT,
	@GPSCoordinateX				VARCHAR(30),
	@GPSCoordinateY				VARCHAR(30),
	@ActionDoneBy				idType
) AS
BEGIN


	IF EXISTS (SELECT * FROM tlPointRegistrations WHERE PointRegisterID <> @PointRegisterID AND GPSCoordinateX = @GPSCoordinateX AND GPSCoordinateY = @GPSCoordinateY)  
		BEGIN
		SELECT 'N' AS Coordinate, A.PointNameF, B.DescriptionF AS ProvinceDescF, A.GPSCoordinateX, A.GPSCoordinateY
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			WHERE PointRegisterID <> @PointRegisterID AND GPSCoordinateX = @GPSCoordinateX AND GPSCoordinateY = @GPSCoordinateY
		END
	ELSE
		BEGIN
		IF NOT EXISTS (SELECT * FROM tlPointRegistrations WHERE PointRegisterID = @PointRegisterID)
			BEGIN
				INSERT INTO tlPointRegistrations(PointNameL, PointNameF, PointNameD,
						IsAirport, IsTrainStation, IsAccomodation,  IsTourPoint, IsFuelStation, 
						ProvinceID, PointTypeID, PointNoteL, PointNoteF, PointNoteD,
						CoordinateX, CoordinateY, GPSCoordinateX, GPSCoordinateY, ActionDoneBy, ActionDate)
					SELECT @PointNameL, @PointNameF, @PointNameD, @IsAirport, @IsTrainStation, @IsAccomodation,  @IsTourPoint, @IsFuelStation, 
						@ProvinceID, @PointTypeID, @PointNoteL, @PointNoteF, @PointNoteD, @CoordinateX, @CoordinateY, @GPSCoordinateX, @GPSCoordinateY, 
						@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 21)

				SELECT @PointRegisterID = MAX(PointRegisterID) FROM tlPointRegistrations
			END
		ELSE
			BEGIN
				UPDATE tlPointRegistrations SET PointNameL = @PointNameL, 
												PointNameF = @PointNameF,
												PointNameD = @PointNameD,
												IsAirport = @IsAirport, 
												IsTrainStation = @IsTrainStation, 
												IsAccomodation = @IsAccomodation,  
												IsTourPoint = @IsTourPoint, 
												IsFuelStation = @IsFuelStation, 
												ProvinceID = @ProvinceID, 
												PointTypeID = @PointTypeID,
												PointNoteL = @PointNoteL, 
												PointNoteF = @PointNoteF, 
												PointNoteD = @PointNoteD, 
												CoordinateX = @CoordinateX, 
												CoordinateY = @CoordinateY, 
												GPSCoordinateX = @GPSCoordinateX, 
												GPSCoordinateY = @GPSCoordinateY, 
												ActionDoneBy = @ActionDoneBy, 
												ActionDate = CONVERT(VARCHAR(23), GETDATE(), 21)
					WHERE PointRegisterID = @PointRegisterID
			END

		SELECT 'Y' AS Coordinate, A.PointNameF, B.DescriptionF AS ProvinceDescF, A.GPSCoordinateX, A.GPSCoordinateY
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			WHERE PointRegisterID = @PointRegisterID
		END
		
END

-- SELECT * FROM tlProvinces
-- SELECT * FROM tlFlightTrainPrices
-- UPDATE tlFlightTrainPrices SET FromPointID = 1
-- SELECT * FROM tlPointRegistrations
-- DROP PROC TL_DEL_PointRegistrations 197
CREATE PROC TL_DEL_PointRegistrations(
	@PointRegisterID		pkType ) AS
BEGIN
		DELETE FROM tlPointRegistrations WHERE PointRegisterID = @PointRegisterID
END

USE TourLogistic
-- DROP PROC TL_SEL_PointRegistrations 'N', 'Arv', '1'
CREATE PROC TL_SEL_PointRegistrations(
	@IsAll		CHAR(1),
	@Letter		NVARCHAR(30),
	@ProvinceID	NVARCHAR(30) ) AS
BEGIN

	IF @IsAll = 'N'
		IF @ProvinceID = '1'
		SELECT A.PointRegisterID, A.PointNameL, A.PointNameF, A.PointNameD,
				A.IsAirport, A.IsTrainStation, A.IsAccomodation,  A.IsTourPoint, A.IsFuelStation, 
				A.ProvinceID, A.PointTypeID, B.DescriptionL AS ProvinceDescL, B.DescriptionF AS ProvinceDescF, 
				B.DescriptionD AS ProvinceDescD, A.PointNoteL, A.PointNoteF, A.PointNoteD, 
				A.CoordinateX, A.CoordinateY, A.GPSCoordinateX, A.GPSCoordinateY, A.ActionDoneBy 
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			WHERE LEFT(A.PointNameF, LEN(@Letter)) = @Letter 
			ORDER BY A.PointNameF
		IF @ProvinceID <> '1'
		SELECT A.PointRegisterID, A.PointNameL, A.PointNameF, A.PointNameD,
				A.IsAirport, A.IsTrainStation, A.IsAccomodation,  A.IsTourPoint, A.IsFuelStation, 
				A.ProvinceID, A.PointTypeID, B.DescriptionL AS ProvinceDescL, B.DescriptionF AS ProvinceDescF, 
				B.DescriptionD AS ProvinceDescD, A.PointNoteL, A.PointNoteF, A.PointNoteD, 
				A.CoordinateX, A.CoordinateY, A.GPSCoordinateX, A.GPSCoordinateY, A.ActionDoneBy 
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			WHERE LEFT(A.PointNameF, LEN(@Letter)) = @Letter AND ProvinceID = @ProvinceID
			ORDER BY A.PointNameF
	IF @IsAll = 'Y'
		IF @ProvinceID = '1'	
		SELECT A.PointRegisterID, A.PointNameL, A.PointNameF, A.PointNameD,
				A.IsAirport, A.IsTrainStation, A.IsAccomodation,  A.IsTourPoint, A.IsFuelStation, 
				A.ProvinceID, A.PointTypeID, B.DescriptionL AS ProvinceDescL, B.DescriptionF AS ProvinceDescF, 
				B.DescriptionD AS ProvinceDescD, A.PointNoteL, A.PointNoteF, A.PointNoteD,
				A.CoordinateX, A.CoordinateY, A.GPSCoordinateX, A.GPSCoordinateY, A.ActionDoneBy 
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			ORDER BY A.PointNameF
		IF @ProvinceID <> '1'
		SELECT A.PointRegisterID, A.PointNameL, A.PointNameF, A.PointNameD,
				A.IsAirport, A.IsTrainStation, A.IsAccomodation,  A.IsTourPoint, A.IsFuelStation, 
				A.ProvinceID, A.PointTypeID, B.DescriptionL AS ProvinceDescL, B.DescriptionF AS ProvinceDescF, 
				B.DescriptionD AS ProvinceDescD, A.PointNoteL, A.PointNoteF, A.PointNoteD,
				A.CoordinateX, A.CoordinateY, A.GPSCoordinateX, A.GPSCoordinateY, A.ActionDoneBy 
			FROM tlPointRegistrations A INNER JOIN tlProvinces B ON A.ProvinceID = B.CodeID
			WHERE ProvinceID = @ProvinceID
			ORDER BY A.PointNameF
END
GO


/*
USE TourLogistic

SELECT * FROM tlTransportTypes
SELECT * FROM tlTransports

SELECT * FROM tlRoutes
DELETE FROM tlRoutes WHERE RouteID BETWEEN 478 AND 509
SELECT * FROM tlRouteTimes
*/
-- DROP PROC TL_INS_Routes	513, N'ayalal', N'ayalal', N'Deutch ayalal', 103, 87, 50, 'N', 'N', 'N', 'Y', 'N', 'N', N'Water Route NoteL', N' Water Route NoteF', N' Water Route NoteD'
CREATE PROC TL_INS_Routes(
	@RouteID				pkType,
	@RouteNameL				descType,
	@RouteNameF				descType,
	@RouteNameD				descType,
	@PointDA				pkType,
	@PointDB				pkType,
	@Distance				INT,
	@IsAeroRoute			CHAR(1),
	@IsRailway				CHAR(1),
	@IsAsphaltRoad			CHAR(1),
	@IsLocalityRoad			CHAR(1),
	@IsNoneRoad				CHAR(1),
	@IsWateryRoad			CHAR(1),
	@RouteNoteL				NVARCHAR(256),
	@RouteNoteF				NVARCHAR(256),
	@RouteNoteD				NVARCHAR(256) ) AS
BEGIN
	DECLARE @SecRouteID		pkType,
			@SecPointDA		pkType,
			@SecPointDB		pkType

	IF NOT EXISTS (SELECT * FROM tlRoutes WHERE RouteID = @RouteID)
		BEGIN
			INSERT INTO tlRoutes(RouteNameL, RouteNameF, RouteNameD, PointDA, PointDB, Distance, IsAeroRoute,
						IsRailway, IsAsphaltRoad, IsLocalityRoad, IsNoneRoad, IsWateryRoad,	RouteNoteL,	RouteNoteF,	RouteNoteD)
				VALUES(@RouteNameL, @RouteNameF, @RouteNameD, @PointDA, @PointDB, @Distance, @IsAeroRoute,
						@IsRailway, @IsAsphaltRoad, @IsLocalityRoad, @IsNoneRoad, @IsWateryRoad, @RouteNoteL, @RouteNoteF, @RouteNoteD)

			INSERT INTO tlRoutes(RouteNameL, RouteNameF, RouteNameD, PointDA, PointDB, Distance, IsAeroRoute,
						IsRailway, IsAsphaltRoad, IsLocalityRoad, IsNoneRoad, IsWateryRoad,	RouteNoteL,	RouteNoteF,	RouteNoteD)
				VALUES(@RouteNameL, @RouteNameF, @RouteNameD, @PointDB, @PointDA, @Distance, @IsAeroRoute,
						@IsRailway, @IsAsphaltRoad, @IsLocalityRoad, @IsNoneRoad, @IsWateryRoad, @RouteNoteL, @RouteNoteF, @RouteNoteD)
 		END
	ELSE
		BEGIN
			SELECT @SecPointDA = PointDA, @SecPointDB = PointDB FROM tlRoutes WHERE RouteID = @RouteID
			SELECT @SecRouteID = RouteID FROM tlRoutes WHERE PointDA = @SecPointDA AND PointDB = @SecPointDB
			UPDATE tlRoutes SET RouteNameL = @RouteNameL, 
								RouteNameF = @RouteNameF, 
								RouteNameD = @RouteNameD, 
								PointDA = @PointDA, 
								PointDB = @PointDB, 
								Distance = @Distance, 
								IsAeroRoute = @IsAeroRoute,
								IsRailway = @IsRailway, 
								IsAsphaltRoad = @IsAsphaltRoad, 
								IsLocalityRoad = @IsLocalityRoad, 
								IsNoneRoad = @IsNoneRoad, 
								IsWateryRoad = @IsWateryRoad,	
								RouteNoteL = @RouteNoteL,	
								RouteNoteF = @RouteNoteF,
								RouteNoteD = @RouteNoteD
				WHERE RouteID = @RouteID

			UPDATE tlRoutes SET RouteNameL = @RouteNameL, 
								RouteNameF = @RouteNameF, 
								RouteNameD = @RouteNameD, 
								PointDA = @PointDB, 
								PointDB = @PointDA, 
								Distance = @Distance, 
								IsAeroRoute = @IsAeroRoute,
								IsRailway = @IsRailway, 
								IsAsphaltRoad = @IsAsphaltRoad, 
								IsLocalityRoad = @IsLocalityRoad, 
								IsNoneRoad = @IsNoneRoad, 
								IsWateryRoad = @IsWateryRoad,	
								RouteNoteL = @RouteNoteL,	
								RouteNoteF = @RouteNoteF,
								RouteNoteD = @RouteNoteD
				WHERE RouteID = @SecRouteID
		END
END

-- DROP PROC TL_DEL_Routes 1
CREATE PROC TL_DEL_Routes(
	@RouteID		pkType ) AS
BEGIN
		DELETE FROM tlRoutes WHERE RouteID = @RouteID
END

USE TourLogistic
SELECT * FROM tlProvinces
-- DROP PROC TL_SEL_Routes 'N', 'Arv'
CREATE PROC TL_SEL_Routes(
	@IsAll		CHAR(1),
	@Letter		NVARCHAR(30) ) AS
BEGIN

	IF @IsAll = 'N'
		SELECT A.RouteID, A.RouteNameL, A.RouteNameF, A.RouteNameD, PointDA , PointDB, A.Distance, A.IsAeroRoute,
				A.IsRailway, A.IsAsphaltRoad, A.IsLocalityRoad, A.IsNoneRoad, A.IsWateryRoad, A.RouteNoteL, A.RouteNoteF, A.RouteNoteD,
				B.PointRegisterID AS APointRegisterID, B.PointNameL AS APointNameL, B.PointNameF AS APointNameF, B.PointNameD AS APointNameD,
				B.IsAirport AS AIsAirport, B.IsTrainStation AS AIsTrainStation, B.IsAccomodation AS AIsAccomodation,  
				B.IsTourPoint AS AIsTourPoint, B.IsFuelStation AS AIsFuelStation, B.ProvinceID AS AProvinceID,
				D.DescriptionL AS AProvinceDescL, D.DescriptionF AS AProvinceDescF, D.DescriptionD AS AProvinceDescD, 
				B.PointTypeID AS APointTypeID, B.PointNoteL AS APointNoteL, B.PointNoteF AS APointNoteF, B.PointNoteD AS APointNoteD, 
				B.CoordinateX AS ACoordinateX, B.CoordinateY AS ACoordinateY, B.GPSCoordinateX AS AGPSCoordinateX, 
				B.GPSCoordinateY AS AGPSCoordinateY, B.ActionDoneBy AS AActionDoneBy, B.ActionDate AS AActionDate,
				C.PointRegisterID AS BPointRegisterID, C.PointNameL AS BPointNameL, C.PointNameF AS BPointNameF, C.PointNameD AS BPointNameD,
				C.IsAirport AS BIsAirport, C.IsTrainStation AS BIsTrainStation, C.IsAccomodation AS BIsAccomodation,  
				C.IsTourPoint AS BIsTourPoint, C.IsFuelStation AS BIsFuelStation, C.ProvinceID AS BProvinceID, 
				E.DescriptionL AS BProvinceDescL, E.DescriptionF AS BProvinceDescF, E.DescriptionD AS BProvinceDescD, 
				C.PointTypeID AS BPointTypeID, C.PointNoteL AS BPointNoteL, C.PointNoteF AS BPointNoteF, C.PointNoteD AS BPointNoteD,
				C.CoordinateX AS BCoordinateX, C.CoordinateY AS BCoordinateY, C.GPSCoordinateX AS BGPSCoordinateX, 
				C.GPSCoordinateY AS BGPSCoordinateY, C.ActionDoneBy AS BActionDoneBy, C.ActionDate AS ActionDate
			FROM tlRoutes A LEFT OUTER JOIN tlPointRegistrations B ON A.PointDA = B.PointRegisterID
				LEFT OUTER JOIN tlPointRegistrations C ON A.PointDB = C.PointRegisterID
				LEFT OUTER JOIN tlProvinces D ON B.ProvinceID = D.CodeID
				LEFT OUTER JOIN tlProvinces E ON C.ProvinceID = E.CodeID
			WHERE LEFT(B.PointNameF, LEN(@Letter)) = @Letter
			ORDER BY B.PointNameF
	IF @IsAll = 'Y'
		SELECT A.RouteID, A.RouteNameL, A.RouteNameF, A.RouteNameD, PointDA , PointDB, A.Distance, A.IsAeroRoute,
				A.IsRailway, A.IsAsphaltRoad, A.IsLocalityRoad, A.IsNoneRoad, A.IsWateryRoad, A.RouteNoteL, A.RouteNoteF, A.RouteNoteD,
				B.PointRegisterID AS APointRegisterID, B.PointNameL AS APointNameL, B.PointNameF AS APointNameF, B.PointNameD AS APointNameD,
				B.IsAirport AS AIsAirport, B.IsTrainStation AS AIsTrainStation, B.IsAccomodation AS AIsAccomodation,  
				B.IsTourPoint AS AIsTourPoint, B.IsFuelStation AS AIsFuelStation, B.ProvinceID AS AProvinceID,
				D.DescriptionL AS AProvinceDescL, D.DescriptionF AS AProvinceDescF, D.DescriptionD AS AProvinceDescD, 
				B.PointTypeID AS APointTypeID, B.PointNoteL AS APointNoteL, B.PointNoteF AS APointNoteF, B.PointNoteD AS APointNoteD, 
				B.CoordinateX AS ACoordinateX, B.CoordinateY AS ACoordinateY, B.GPSCoordinateX AS AGPSCoordinateX, 
				B.GPSCoordinateY AS AGPSCoordinateY, B.ActionDoneBy AS AActionDoneBy, B.ActionDate AS AActionDate,
				C.PointRegisterID AS BPointRegisterID, C.PointNameL AS BPointNameL, C.PointNameF AS BPointNameF, C.PointNameD AS BPointNameD,
				C.IsAirport AS BIsAirport, C.IsTrainStation AS BIsTrainStation, C.IsAccomodation AS BIsAccomodation,  
				C.IsTourPoint AS BIsTourPoint, C.IsFuelStation AS BIsFuelStation, C.ProvinceID AS BProvinceID, 
				E.DescriptionL AS BProvinceDescL, E.DescriptionF AS BProvinceDescF, E.DescriptionD AS BProvinceDescD, 
				C.PointTypeID AS BPointTypeID, C.PointNoteL AS BPointNoteL, C.PointNoteF AS BPointNoteF, C.PointNoteD AS BPointNoteD,
				C.CoordinateX AS BCoordinateX, C.CoordinateY AS BCoordinateY, C.GPSCoordinateX AS BGPSCoordinateX, 
				C.GPSCoordinateY AS BGPSCoordinateY, C.ActionDoneBy AS BActionDoneBy, C.ActionDate AS ActionDate
			FROM tlRoutes A LEFT OUTER JOIN tlPointRegistrations B ON A.PointDA = B.PointRegisterID
				LEFT OUTER JOIN tlPointRegistrations C ON A.PointDB = C.PointRegisterID
				LEFT OUTER JOIN tlProvinces D ON B.ProvinceID = D.CodeID
				LEFT OUTER JOIN tlProvinces E ON C.ProvinceID = E.CodeID
			ORDER BY B.PointNameF
END
GO