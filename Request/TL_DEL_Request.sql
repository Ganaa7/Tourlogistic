USE TourLogistic
GO

DROP PROC TL_DEL_Request
GO

CREATE PROC TL_DEL_Request(
	@RequestRecID	pkType) AS
BEGIN
	DELETE FROM tlRequest WHERE RequestRecID = @RequestRecID
END
GO

EXEC TL_DEL_Request 1987032200002

/*
SELECT * FROM tlRequest
SELECT * FROM tlPaxsTours
SELECT * FROM tlTours
*/
