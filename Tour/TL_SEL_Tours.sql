USE TourLogistic
GO

DROP PROC TL_SEL_Tours
GO

CREATE PROC TL_SEL_Tours(
	@IsTour		CHAR(1),
	@TourRecID	pkType
) AS
BEGIN
	IF @IsTour = 'N'
	BEGIN
		IF @TourRecID = 0
			SELECT RequestRecID, RequestID, LeaderPaxRecID, D.FirstName, D.LastName, ReqName, ReqTypeInfID, B.DescriptionF [RequestDesc], PaxQty,  EmployeeQty, StartDate, EndDate
				Days, TotalDistance, RemarkF, RequestDate, A.ActionDoneBy, A.ActionDate, LevelID, C.DescriptionF [LevelDescF]
			FROM tlRequest A 
			INNER JOIN tlTourTypes B ON A.ReqTypeInfID = B.TourTypeInfID
			INNER JOIN VIEW_TourLevel C ON A.LevelID = C.ID
			LEFT OUTER JOIN tlPaxs D ON A.LeaderPaxRecID = D.PaxRecID
		ELSE
		SELECT RequestRecID, RequestID, LeaderPaxRecID, D.FirstName, D.LastName, ReqName, ReqTypeInfID, B.DescriptionF [RequestDesc], PaxQty,  EmployeeQty, StartDate, EndDate
				Days, TotalDistance, RemarkF, RequestDate, A.ActionDoneBy, A.ActionDate, LevelID, C.DescriptionF [LevelDescF]
			FROM tlRequest A 
			INNER JOIN tlTourTypes B ON A.ReqTypeInfID = B.TourTypeInfID
			INNER JOIN VIEW_TourLevel C ON A.LevelID = C.ID
			LEFT OUTER JOIN tlPaxs D ON A.LeaderPaxRecID = D.PaxRecID
			WHERE RequestRecID = @TourRecID
	END 

--		IF @TourRecID = 0
--			SELECT 	TourRecID, TourID, TourName, A.TourTypeInfID, B.DescriptionL AS TourTypeDescL, B.DescriptionF AS TourTypeDescF,
--					TourLevelID, StartDate,	EndDate, Days, TourStatusID, C.DescriptionF AS TourStatusDesc, RemarkL, RemarkF,	RemarkD,	
--					TotalDistance,	CorrespondanceInfID
--			FROM tlTours A INNER JOIN tlTourTypes B ON A.TourTypeInfID = B.TourTypeInfID
--				INNER JOIN VIEW_ssTourStatus C ON A.TourStatusID = C.ID
--	ELSE
--		SELECT 	TourRecID, TourID,	TourName, A.TourTypeInfID, B.DescriptionL AS TourTypeDescL, B.DescriptionF AS TourTypeDescF,
--				TourLevelID, QtyPax, EmployeesQty, StartDate, EndDate, Days, TourStatusID, C.DescriptionF AS TourStatusDesc,RemarkL, RemarkF,	RemarkD,	
--				TotalDistance, CorrespondanceInfID
--			FROM tlTours A INNER JOIN tlTourTypes B ON A.TourTypeInfID = B.TourTypeInfID
--				INNER JOIN VIEW_ssTourStatus C ON A.TourStatusID = C.ID
--			WHERE TourRecID = @TourRecID
	
END
GO

EXEC TL_SEL_Tours 'N', 1987030900002
GO

/*
	SELECT * FROM tlPaxs

		UPDATE tlPaxs SET FirstName = 'Recardo', LastName = 'Fabricio'
			WHERE PaxRecID = 1987030300003


	UPDATE tlPaxs SET FirstName = 'Recardo', LastName = 'Fabricio'
		WHERE PaxRecID = 1987030300003

	1987022200004
	SELECT * FROM tlRequest

	SELECT * FROM tlTourTypes

	UPDATE tlRequest SET ReqTypeInfID = 1987022200004
		WHERE RequestRecID = 1987030900002

	UPDATE tlRequest SET levelID = 'A'
		WHERE RequestRecID = 1987030900002

	ALTER TABLE tlRequest DROP COLUMN GuideInfID

	SELECT * FROM tlReqAccomodation
	EXEC SP_HELP tlRequest

	SELECT * FROM VIEW_TourLevel

	INSERT INTO tlPaxsTours(PaxInfID, TourRecID)

	UPDATE tlTourTypes SET CodeID = '0'+CodeID

	SELECT * FROM tlFlightTrain
	SELECT * FROM tlCountries
	SELECT * FROM tlTourPlanningPrice
	SELECT * FROM tlAccomodationProductTypes
	SELECT * FROM tlAccProductPrices

	SELECT * FROM tlAccomodationTypes

*/
