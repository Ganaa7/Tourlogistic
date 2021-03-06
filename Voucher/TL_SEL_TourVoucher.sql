USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_SEL_TourVoucher]    Script Date: 04/10/2007 14:26:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TL_SEL_TourVoucher](
	@IsLocal			CHAR(1)
)	
AS
BEGIN

	DECLARE @SQL	NVARCHAR(4000)
	DECLARE @result NVARCHAR(MAX)

	SET @result = 
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
		SELECT TourRecID, AccomodationInfID, VoucherNum, PrintCount, PrintLastDoneBy, AprStatusID, Date, '+@result+'
			INTO #Accomodation
		FROM( SELECT Date, TourRecID, AccomodationProductTypeID, VoucherNum, AccomodationInfID, PrintCount, PrintLastDoneBy, AprStatusID
				FROM tlTourAccomodations A 
				FULL OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
			WHERE B.TypeID = ''accHotel'' AND A.IsPax = ''Y'' ) Ptable
				PIVOT(COUNT(AccomodationProductTypeID) FOR AccomodationProductTypeID IN ('+@result+')) AS B

		SELECT B.AccomodationID, CASE WHEN @IsLocal = ''Y'' THEN B.DescriptionL ELSE B.DescriptionF END AccomodationDescription, A.* 
			FROM #Accomodation A
				INNER JOIN tlAccomodations B ON A.AccomodationInfID = B.AccomodationInfID'
		
	EXEC sp_executesql @SQL ,N'@IsLocal CHAR(1)', @IsLocal

	SELECT TourAccRecID, A.TourRecID, GuestRecID,IsPax, 
		   CASE	WHEN IsPax = 'Y' THEN D.FirstName ELSE 											 
												CASE WHEN @IsLocal = 'Y' THEN E.DescriptionL ELSE E.DescriptionF END 											 
		   END GuestDescription, F.SameRoom,
		   A.AccomodationInfID,A.AccProductTypeInfID,C.AccomodationProductTypeID,
		   CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END AccProductTypeDescription,Date
	FROM tlTourAccomodations A
	LEFT OUTER JOIN tlAccomodations B ON A.AccomodationInfID = B.AccomodationInfID		
	INNER JOIN tlAccomodationsProductTypes C ON A.AccProductTypeInfID = C.AccomodationProductTypeInfID	
	LEFT OUTER JOIN tlPaxes D ON A.GuestRecID = D.PaxRecID
	LEFT OUTER JOIN tlEmployees E ON A.GuestRecID = E.EmployeeInfID    
	LEFT OUTER JOIN tlTourPaxes F ON A.GuestRecID = F.PaxRecID AND A.TourRecID = F.TourRecID
	WHERE A.AccomodationTypeID = 'accHotel' 
	
	SET @SQL ='	
		SELECT TourRecID, AccomodationInfID, Date, VoucherNum, '+@result+'
			INTO #Accomodation
		FROM( SELECT Date, TourRecID, VoucherNum, AccomodationProductTypeID, AccomodationInfID 
				FROM tlAprAccomodations A 
				FULL OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
			WHERE B.TypeID = ''accHotel'' AND A.IsPax = ''Y'' ) Ptable
				PIVOT(COUNT(AccomodationProductTypeID) FOR AccomodationProductTypeID IN ('+@result+')) AS B

		SELECT B.AccomodationID, CASE WHEN @IsLocal = ''Y'' THEN B.DescriptionL ELSE B.DescriptionF END AccomodationDescription, A.* 
			FROM #Accomodation A
				INNER JOIN tlAccomodations B ON A.AccomodationInfID = B.AccomodationInfID
			'
		
	EXEC sp_executesql @SQL ,N'@IsLocal CHAR(1)', @IsLocal

	SELECT AprAccRecID, A.TourRecID, GuestRecID,IsPax,TourAccRecID,
		   CASE	WHEN IsPax = 'Y' THEN D.FirstName ELSE 											 
												CASE WHEN @IsLocal = 'Y' THEN E.DescriptionL ELSE E.DescriptionF END 											 
		   END GuestDescription, F.SameRoom,
		   A.AccomodationInfID,A.AccProductTypeInfID,C.AccomodationProductTypeID,
		   CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END AccProductTypeDescription,Date
	FROM tlAprAccomodations A
	LEFT OUTER JOIN tlAccomodations B ON A.AccomodationInfID = B.AccomodationInfID		
	INNER JOIN tlAccomodationsProductTypes C ON A.AccProductTypeInfID = C.AccomodationProductTypeInfID	
	LEFT OUTER JOIN tlPaxes D ON A.GuestRecID = D.PaxRecID
	LEFT OUTER JOIN tlEmployees E ON A.GuestRecID = E.EmployeeInfID    
	LEFT OUTER JOIN tlTourPaxes F ON A.GuestRecID = F.PaxRecID AND A.TourRecID = F.TourRecID
	WHERE A.AccomodationTypeID = 'accHotel' 

END

TL_SEL_TourVoucher 'Y'