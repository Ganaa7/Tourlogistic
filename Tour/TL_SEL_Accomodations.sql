USE TourLogistic
GO
DROP PROC TL_SEL_TourHotel
GO
/*
*/
CREATE PROC TL_SEL_TourHotel(
	@TourRecID		pkType
) AS
BEGIN
	
	DECLARE @SQL	NVARCHAR(4000)
	DECLARE @Result NVARCHAR(MAX)

	SET @Result = 
	  STUFF(
		(SELECT N', '+ QUOTENAME(pivot_col) AS [text()]
			FROM(SELECT DISTINCT(AccomodationProductTypeID) AS pivot_col
			FROM(SELECT * FROM tlAccomodationsProductTypes WHERE TypeID = 'accHotel' ) AS Query
		) AS DistinctCols
		ORDER BY pivot_col
		FOR XML PATH('')
		) 
		,1, 1, N'')

	SET @SQL ='	
		SELECT TourRecID, MIN(Date) as CheckInDate, Max(Date) as CheckOutDate, B.AccomodationInfID, C.DescriptionF, '+@result+'
			FROM( SELECT TourRecID, Date, GuestRecID, AccomodationInfID, AccomodationTypeID, AccomodationProductTypeID
				FROM tlTourAccomodations A 
				FULL OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
			WHERE A.AccomodationTypeID = ''accHotel'' AND A.IsPax = ''Y'' AND A.TourRecID = @TourRecID ) Ptable
				PIVOT(COUNT(GuestRecID) FOR AccomodationProductTypeID IN ('+@result+')) AS B 
				INNER JOIN tlAccomodations C ON B.AccomodationInfID = C.AccomodationInfID
			GROUP BY TourRecID, B.AccomodationInfID, C.DescriptionF, '+@result+''
			
	EXEC sp_executesql @SQL ,N'@TourRecID NUMERIC(18)', @TourRecID

END
GO
TL_SEL_TourHotel 1987041000001

--TL_SEL_TourVoucher 'Y'
/*
	SELECT * FROM tlTours
		WHERE TourRecID = 1987041000001

	SELECT * FROM tlAccomodations

	Gercamp	    2007/06/02	2007/06/03
	Ulaanbaatar	2007/06/01	2007/06/05

	SELECT * FROM tlReqAccomodation
		WHERE RequestRecID = 1987040200006

	SELECT * FROM tlTourAccomodations
	SELECT * FROM tlAprAccomodations

	SELECT * FROM tlAccomodationsProductTypes
	SELECT * FROM VIEW_ssAccomodationType
*/


			
			
			