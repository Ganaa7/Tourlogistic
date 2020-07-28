USE TourLogistic
GO
DROP PROC TL_DEL_ReqOthers
GO
CREATE PROC TL_DEL_ReqOthers(
	@OtherRecID	pkType	
)AS
BEGIN
	DELETE FROM tlReqOthers
		WHERE OtherRecID = @OtherRecID
END
GO
TL_DEL_ReqOthers  1987032000001
