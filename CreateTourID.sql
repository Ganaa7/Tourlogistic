USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[CreateTourID]    Script Date: 07/03/2007 11:03:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[CreateTourID](
	@UserID			NVARCHAR(30),
	@TourID			NVARCHAR(30) OUTPUT
)AS
BEGIN
	DECLARE @MaxID	SMALLINT,
			@SQL	NVARCHAR(2000),
			@Str	VARCHAR(3)
			
	SET NOCOUNT ON 

	SET @SQL = '
		SELECT @Str = SUBSTRING(TourID, 4, 3) FROM tlTours
			WHERE TourID LIKE (''%'+@UserID+'%'')	

		IF ISNUMERIC(@Str) > 0
		BEGIN
			SELECT @MaxID = MAX(CONVERT(SMALLINT, @Str))
				FROM tlTours
				WHERE TourID LIKE (''%'+@UserID+'%'')

			SET @MaxID = @MaxID + 1
		END
		ELSE
		BEGIN
			SET @MaxID = 0
			SET @MaxID = @MaxID + 1
		END
		
		SET @TourID = @UserID + CASE WHEN LEN(CONVERT(NVARCHAR(30), @MaxID)) = 1 THEN ''00''+ CONVERT(NVARCHAR(30), @MaxID) 
				ELSE CASE WHEN LEN(CONVERT(NVARCHAR(30), @MaxID)) = 2 THEN ''0'' + CONVERT(NVARCHAR(30), @MaxID) ELSE CONVERT(NVARCHAR(30), @MaxID) END END'

	EXEC SP_EXECUTESQL @SQL ,N'@UserID NVARCHAR(30), @MaxID SMALLINT, @Str VARCHAR(3), @TourID idType OUTPUT', @UserID, @MaxID, @Str, @TourID OUTPUT

END
