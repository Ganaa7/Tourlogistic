USE TourLogistic
GO
DROP PROC TL_INS_TourPoints
GO

CREATE PROC TL_INS_TourPoints(
	@IsTour				char(1),
	@TourRecID			pkType,
	@PointNum			INT,
	@PointRegisterRecID	NUMERIC(18),
	@ArriveDate			VARCHAR(23),
	@DepartDate			VARCHAR(23)
) AS
BEGIN
	
	DECLARE @RecID pkType	

	SET NOCOUNT ON

	IF @IsTour = 'Y'
	BEGIN
		IF NOT EXISTS(SELECT * FROM tlTourPoints WHERE TourRecID = @TourRecID)
			BEGIN
				EXEC CreatePkID 'tlTourPoints','TourPointRecID', @RecID OUTPUT

				INSERT INTO tlTourPoints(TourPointRecID, TourRecID, PointNum, PointRegisterRecID, DepartDate, ArriveDate) 
					SELECT @RecID, @TourRecID, 1, @PointRegisterRecID, @DepartDate, @ArriveDate
					SELECT 'Y' AS Num
			END
		ELSE
			IF NOT EXISTS(SELECT * FROM tlTourPoints WHERE TourRecID = @TourRecID AND PointNum = @PointNum )
				BEGIN
					EXEC CreatePkID 'tlTourPoints','TourPointRecID', @RecID OUTPUT

					INSERT INTO tlTourPoints(TourPointRecID, TourRecID, PointNum, PointRegisterRecID, DepartDate,ArriveDate) 
						SELECT @RecID, @TourRecID, @PointNum, @PointRegisterRecID, @DepartDate, @ArriveDate
		
					SELECT 'Y' AS Num
				END		
			
			ELSE
				BEGIN
					UPDATE tlTourPoints SET PointRegisterRecID = @PointRegisterRecID, 
											DepartDate = @DepartDate, 
											ArriveDate = @ArriveDate
						WHERE TourRecID = @TourRecID AND PointNum = @PointNum 

					SELECT 'Y' AS Num
				END
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT * FROM tlReqPoints WHERE RequestRecID = @TourRecID)
			BEGIN
				EXEC CreatePkID 'tlReqPoints','RowRecID', @RecID OUTPUT

				INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointRecID, PointNum, DepartDate, ArriveDate) 
					SELECT @RecID, @TourRecID, @PointRegisterRecID, 1, @DepartDate, @ArriveDate
				SELECT 'Y' AS Num
			END
		ELSE
			IF NOT EXISTS(SELECT * FROM tlReqPoints WHERE RequestRecID = @TourRecID AND PointNum = @PointNum )
				BEGIN
					EXEC CreatePkID 'tlReqPoints','RowRecID', @RecID OUTPUT

					INSERT INTO tlReqPoints(RowRecID, RequestRecID, PointNum, PointRecID, DepartDate,ArriveDate) 
						SELECT @RecID, @TourRecID, @PointNum, @PointRegisterRecID, @DepartDate, @ArriveDate
		
					SELECT 'Y' AS Num
				END		
			
			ELSE
				BEGIN
					UPDATE tlReqPoints SET  PointRecID = @PointRegisterRecID, 
											DepartDate = @DepartDate, 
											ArriveDate = @ArriveDate
						WHERE RequestRecID = @TourRecID AND PointNum = @PointNum 

					SELECT 'Y' AS Num
				END	
	
	END
		

END
GO
exec TL_INS_TourPoints 'N',1987030900002, 1 , 1987022200074, '2007/3/12','2007/3/12'


--	EXEC TL_INS_TourPoints 'N', 1987030900003, 1, 1987022200004 , '2007/05/03', '2007/05/05'
--exec TL_INS_TourPoints 'N', 1987030900002, 5, 1987022200107, '2007/05/03', '2007/05/05'
--EXEC TL_INS_TourPoints 'N', 1987030900002, 6, 1987022200082, '2007/05/03', '2007/05/05'
--EXEC TL_INS_TourPoints 'N', 1987030900002, 5, '2007/05/03', '2007/05/05'
/*
	SELECT * FROM tlReqPoints
	@IsTour				char(1),
	@TourRecID			pkType,
	@PointNum			INT,
	@PointRegisterRecID	NUMERIC(18),
	@ArriveDate			VARCHAR(23),
	@DepartDate			VARCHAR(23)
	SELECT * FROM tlPointRegistrations
	SELECT * FROM tlTourPoints
	SELECT * FROM tlRequest
	SELECT * FROM tlReqPoints
 1987030900002


*/