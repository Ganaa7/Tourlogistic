USE TourLogistic
GO
DROP PROC TL_DEL_ReqAccomodations
GO
CREATE PROC TL_DEL_ReqAccomodations(
	@ReqAccRecID	pkType
) AS
BEGIN
		DELETE FROM tlReqAccomodation WHERE ReqAccRecID = @ReqAccRecID

END
GO
TL_DEL_ReqAccomodations 1987031600004

/*
	SELECT * FROM tlReqAccomodation
*/