USE TourLogistic
GO
DROP PROC TL_DEL_ReqAnimals
GO
CREATE PROC TL_DEL_ReqAnimals(
@ReqAnimalRecID	pkType)
AS
BEGIN

	DELETE FROM tlReqAnimals WHERE ReqAnimalRecID = @ReqAnimalRecID	

END
GO
EXEC TL_DEL_ReqAnimals 1987031400002
	
/*

	select * from tlReqAnimals

*/