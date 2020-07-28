USE TourLogistic
GO
DROP PROC TL_DEL_ReqCityVehicles
GO
CREATE PROC TL_DEL_ReqCityVehicles(
	@ReqVehicleRecID	pkType
) AS 
BEGIN
	
	DELETE FROM tlReqCityVehicles
		WHERE ReqVehicleRecID = @ReqVehicleRecID

END
GO
EXEC TL_DEL_ReqCityVehicles 1987031500002

/*
	SELECT * FROM tlReqVehicles

*/


	