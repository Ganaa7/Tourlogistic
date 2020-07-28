USE TourLogistic
GO

SELECT * FROM tlRequest
EXEC SP_HELP tlRequest

	INSERT INTO tlRequest (RequestRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty,
				StartDate, EndDate, Days, TotalDistance, GuideInfID, RemarkL, RemarkF, RemarkD, ActionDoneBy, ActionDate)
		VALUES(1987030900002, 2, 1987030900002, 'TourReques', 1987030900001, 8, 3,
				'2007/05/01', '2007/05/05', 4, 1000, 1987030900002, '','','', 'Ganaa', CONVERT(NVARCHAR, GETDATE(), 111))
	
	INSERT INTO tlRequest (RequestRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty,
				StartDate, EndDate, Days, TotalDistance, GuideInfID, RemarkL, RemarkF, RemarkD, ActionDoneBy, ActionDate)
		VALUES(1987030900003, 2, 1987030900003, 'Tour 12', 1987030900002, 10, 4,
				'2007/05/11', '2007/05/15', 4, 800, 1987030900003, '','','', 'Ganaa', CONVERT(NVARCHAR, GETDATE(), 111))
 
	INSERT INTO tlRequest (RequestRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty,
				StartDate, EndDate, Days, TotalDistance, GuideInfID, RemarkL, RemarkF, RemarkD, ActionDoneBy, ActionDate)
		VALUES(1987030900004, 4, 1987030900004, 'TourRequired', 1987030900003, 10, 4,
				'2007/05/11', '2007/05/15', 4, 800, 1987030900003, '','','', 'Ganaa', CONVERT(NVARCHAR, GETDATE(), 111))
 
/*
	DELETE FROM tlRequest
		WHERE RequestRecID = 1987030900002
*/

SELECT * FROM tlReqPoints
	
EXEC SP_HELP tlReqPoints

	INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID, ArriveDate, DepartDate, PointNum, TransportTypeID, 
				LeaveWithGuide)
		VALUES(1987031000001, 1987030900002, 1987022200074, '2007/05/03', '2007/05/04', 1, 'CA', 'Y')

	INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID,  ArriveDate, DepartDate, PointNum, TransportTypeID, 
				LeaveWithGuide)
		VALUES(1987031000002, 1987030900002, 1987022200054, '2007/05/04', '2007/05/06', 2, 'CA', 'Y')

	INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID,  ArriveDate, DepartDate, PointNum, TransportTypeID, 
				LeaveWithGuide)
		VALUES(1987031000003, 1987030900002, 1987022200036, '2007/05/06', '2007/05/8', 3, 'CA', 'Y')

	INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID,  ArriveDate, DepartDate, PointNum, TransportTypeID, 
				LeaveWithGuide)
		VALUES(1987031000004, 1987030900002, 1987022200074, '2007/05/08', '2007/05/09', 4, 'CA', 'Y')


	SELECT * FROM tlReqPoints
	
	SELECT * FROM tlPointRegistrations
		ORDER BY PointNameL ASC
	
	SELECT * FROM tlRoutes
	
	

	DECLARE @RECID PKTYPE
	EXEC CREATEPKID 'TLREQPOINT','ROWRECID', @RECID OUTPUT
	SELECT @RECID

		INSERT INTO tlRequestPoint (RequestPointRecID, RequestRecID, PointRegisterRecID, DateFromPoint, DateToPoint, PointNum, TransportTypeID)
			VALUES(1987030900001, )