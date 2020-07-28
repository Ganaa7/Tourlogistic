USE TourLogistic
GO
DROP PROC SS_SEL_TourVoucher
GO
CREATE PROC SS_SEL_TourVoucher
AS
BEGIN

	DECLARE  @SQL NVARCHAR(4000)
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
	
		SELECT TourRecID, AccomodationInfID, Date, '+@result+'
			INTO #Accomdation
		FROM( SELECT Date, TourRecID, AccomodationProductTypeID, AccomodationInfID 
				FROM tlTourAccomodations A 
				FULL OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
		WHERE B.TypeID = ''accHotel'' AND A.IsPax = ''Y'' ) Ptable
			PIVOT(COUNT(AccomodationProductTypeID) FOR AccomodationProductTypeID IN ('+@result+')) AS B

		SELECT B.AccomodationID, B.DescriptionF, A.* 
			FROM #Accomdation A
				INNER JOIN tlAccomodations B ON A.AccomodationInfID = B.AccomodationInfID'
		
	EXEC sp_executesql @SQL

END
GO
SS_SEL_TourVoucher 

/*

	DECLARE @tmpTourAccomodation TABLE (
		TourRecID				 NUMERIC(18),
		Date					VARCHAR(23),
		VoucherNum			NVARCHAR(15),
		IsPax				CHAR(1),
		AccomodationInfID	NUMERIC(18), 
		AccomodationProductTypeID NVARCHAR(30),
		GuestQty					int
	)

	INSERT INTO @tmpTourAccomodation
	SELECT TourRecID, Date, VoucherNum, A.isPax, AccomodationInfID, B.AccomodationProductTypeID, Count(A.TourAccRecID) AS GuestQty
		FROM tlTourAccomodations A 
			RIGHT OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
		WHERE B.TypeID = 'accHotel' 
		GROUP BY A.TourRecID, A.Date, A.VoucherNum, A.IsPax, A.AccomodationInfID, AccProductTypeInfID, AccomodationProductTypeID

	SET @SQL='SELECT Date, '+@result+' '+'
	FROM(
			SELECT TourRecID, AccomodationInfID, Date, BookStatusInfID, VoucherNum
				FROM tlTourAccomodations A 
				RIGHT OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
				WHERE B.TypeID = ''accHotel''  
				) 
		PIVOT (
		COUNT(GuestRecID) FOR A.AccomodationTypeID IN ('+@result+')
		) AS B'

	SELECT * FROM tlTourAccomodations
	DROP TABLE #tmpTourAccomodation
	SET @SQL='SELECT Date, '+@result+' '+'
	FROM(
			SELECT TourRecID, AccomodationInfID, Date, BookStatusInfID, VoucherNum, GuestRecID, AccomodationProductTypeID
				FROM tlTourAccomodations A 
				RIGHT OUTER JOIN tlAccomodationsProductTypes B ON A.AccProductTypeInfID=B.AccomodationProductTypeInfID
				WHERE B.TypeID = ''accHotel'' 
				WHERE IsPax = ''Y'' ) 
		PIVOT (
		COUNT(GuestRecID) FOR A.AccomodationTypeID IN ('+@result+')
		) AS B'

	PRINT @SQL
--	WHERE (InvDate BETWEEN @BeginDate AND @EndDate) AND 
--	CashiersProductInfID=@CashiersProductInfID AND IsDebit=''Y''
--		ORDER BY B.InvDate'



, N' @BeginDate VARCHAR(23), @EndDate VARCHAR(23), @CashiersProductInfID NUMERIC(18)',
@BeginDate, @EndDate, @CashiersProductInfID  

SELECT * FROM tlAccomodationsProductTypes
*/
/*
	
	TourRecID, AccomodationInfID, Date, BookStatusInfID, VoucherNum
	
	SELECT * FROM tlTours
	SELECT * FROM tlTourPaxes		
	SELECT * FROM tlTourStaffs
	SELECT * FROM tlPaxes
	SELECT * FROM tlAccomodations
	SELECT * FROM tlAccomodationsProductTypes
	
	SELECT * FROM tlBookStatus
	SELECT * FROM tlTourAccomodations 
	SELECT * FROM tlTourPaxes	

	INSERT INTO tlTourPaxes VALUES()

	sp_help tlTourAccomodations

	SELECT * FROM tlAccomodationsProductTypes

	SELECT * FROM tlTourAccomodations 

	INSERT INTO tlTourAccomodations (TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID, Date, BookStatusInfID, VoucherNum, ActionDoneBy, ActionDate, IsApproved)
		VALUES(1987040200004, 1987040200001, 1987040200013, 'Y', 1987031500001, 'accHotel', 1987022300004, '2007/04/12', 1987030500001, '001', 'admin', CONVERT(VARCHAR(23), GETDATE(), 121), 'N')

*/