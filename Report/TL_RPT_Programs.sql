USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_RPT_TourPrograms]    Script Date: 02/27/2007 10:16:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP PROC [dbo].[TL_RPT_TourPrograms]
GO
CREATE PROC [dbo].[TL_RPT_TourPrograms](
	@TourRecID			pkType ) AS
BEGIN
	DECLARE @MealTypes TABLE (
		TourRecID		NUMERIC(18),
		Date			VARCHAR(23),
		ProgramTextF	NVARCHAR(300),
		MealTypeID		NVARCHAR(30))

	DECLARE @tmp TABLE (
		DayNum			INT IDENTITY(1,1),
		TourRecID		NUMERIC(18),
		Date			VARCHAR(23),
		ProgramTextF	NVARCHAR(300),
		MealTypeIDs		NVARCHAR(150),
		AccomodDesc		NVARCHAR(75))
	
	DECLARE @result			NVARCHAR(1000),
			@Date			VARCHAR(23), 
			@ProgramTextF	NVARCHAR(300)

	SET NOCOUNT ON
	INSERT INTO @MealTypes(TourRecID, Date, ProgramTextF, MealTypeID)
		SELECT 	A.TourRecID, A.FromDate, A.ProgramTextF, C.DescriptionF
			FROM tlTourPrograms A 
				INNER JOIN tlTourCatering B ON A.TourRecID = B.TourRecID AND A.FromDate = B.Date
				INNER JOIN VIEW_ssMealType C ON B.MealTypeID = C.ID
			WHERE B.TourRecID = @TourRecID
	
	INSERT INTO @tmp(TourRecID, Date, ProgramTextF)
		SELECT DISTINCT TourRecID, Date, ProgramTextF
			FROM @MealTypes

	DECLARE CUR CURSOR FOR
		SELECT Date, ProgramTextF
			FROM @tmp
	
	OPEN CUR
	FETCH NEXT FROM CUR INTO @Date, @ProgramTextF
	WHILE @@FETCH_STATUS = 0
		BEGIN
		SET @result = 
		  STUFF(
			(SELECT N',' + QUOTENAME(pivot_col) AS [text()]
				FROM(SELECT MealTypeID AS pivot_col
						FROM(SELECT * FROM @MealTypes WHERE Date = @Date AND ProgramTextF = @ProgramTextF) AS Query
					) AS DistinctCols
				ORDER BY pivot_col
				FOR XML PATH('')
			)
			,1, 1, N'')
		
		SET @result=REPLACE(@result, '[', '')
		SET @result=REPLACE(@result, ']', '')

		UPDATE @tmp SET MealTypeIDs = @result
			WHERE Date = @Date AND ProgramTextF = @ProgramTextF
	
		SET @result = ''

		FETCH NEXT FROM CUR INTO @Date, @ProgramTextF
		END
	CLOSE CUR
	DEALLOCATE CUR

	UPDATE A SET AccomodDesc = D.DescriptionF
		FROM @tmp A INNER JOIN tlTourAccomodations B ON A.TourRecID = B.TourRecID AND A.Date = B.InDate
			INNER JOIN tlAccProductPrices C ON B.AccProductPriceInfID = C.AccProductPriceInfID
			INNER JOIN tlAccomodations D ON C.AccomodationInfID = D.AccomodationInfID
	
	SET NOCOUNT ON
	SELECT Date, DATENAME(dw, DATE) WeekDay, DayNum, ProgramTextF, MealTypeIDs, AccomodDesc
		FROM @tmp

END
GO
EXEC TL_RPT_TourPrograms 1987022100002
/*

SELECT 	A.TourRecID, A.FromDate, A.ProgramTextF, B.MealTypeID
	FROM tlTourPrograms A 
	INNER JOIN tlTourCatering B ON A.TourRecID = B.TourRecID AND A.FromDate = B.Date
			WHERE B.TourRecID = @TourRecID
you look different too
that's whatis  

SELECT DATENAME(dw, DATE) FROM tlTourCatering

SELECT * FROM tlTourPrograms
SELECT * FROM VIEW_ssMealType

SELECT * FROM tlPrograms
SELECT * FROM tlTourPoints
SELECT * FROM tlTourCatering

SELECT * FROM tlRestaurantServicePrices

SELECT * FROM tlTourAccomodations

SELECT * FROM VIEW_ssMealType
SELECT * FROM tlToursEmployees

SELECT * FROM tlAccProductPrices
SELECT * FROM tlEmployeeS

UPDATE tlTourPrograms SET ToDate = '2007/02/22'
	Where TourProgramRecID = 1987022600003

exec sp_help tlEmployeeS
*/
