USE TourLogistic
GO
DROP PROC TL_DEL_ReqCatering
GO
CREATE PROC TL_DEL_ReqCatering(
	@ReqCaterRecID			pkType)
AS
BEGIN
	DELETE FROM tlReqCatering WHERE ReqCaterRecID = @ReqCaterRecID	
END
	TL_DEL_ReqCatering 1987031600010

/*
	SELECT * FROM tlReqCatering
*/