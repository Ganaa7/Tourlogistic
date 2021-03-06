USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_INS_TourPoints]    Script Date: 03/26/2007 15:06:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[TL_INS_TourPoints](
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
