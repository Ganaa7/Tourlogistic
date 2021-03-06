USE [TourLogistic]
GO
DROP PROC TL_SS_SelCatering
GO
CREATE PROC [dbo].[TL_SS_SelCatering](
	@DateType				SMALLINT,
	@DateSelection			NVARCHAR(2000),
	@TourType				SMALLINT,
	@TourSelection			NVARCHAR(2000),
	@RestaurantType			SMALLINT,
	@RestaurantSelection   	NVARCHAR(2000),
	@IsLocal				CHAR(1),
	@UserInfID				NUMERIC(18))AS
BEGIN
	DECLARE @BeginDate VARCHAR(23)
	DECLARE @EndDate VARCHAR(23)
	DECLARE @ResultTourID VARCHAR(23)
	DECLARE @ResultRestaurantID VARCHAR(23)
	DECLARE @ResultVoucherNoID VARCHAR(23)
	DECLARE @SQL NVARCHAR(4000)

	SET NOCOUNT ON
	SET @DateSelection = REPLACE(@DateSelection, N'<', N'')
	SET @DateSelection = REPLACE(@DateSelection, N'>', N'')
	SET @DateSelection = REPLACE(@DateSelection, N'=', N'')
	SET @DateSelection = REPLACE(@DateSelection, N'''', N'')

	SET @BeginDate = LEFT(@DateSelection, 10)
	SET @EndDate = RIGHT(@DateSelection, 10)
	IF  @DateType = 2 SET @BeginDate = '1980/01/01'
	
	SET @ResultRestaurantID=''
	SET @ResultTourID=''
	IF @TourType <> 1
	EXEC SS_CodeSelectionFilter 'tlTours', @UserInfID, @TourType, @TourSelection, @ResultTourID OUTPUT 
	IF @RestaurantType <> 1
	EXEC SS_CodeSelectionFilter 'tlRestaurants', @UserInfID, @RestaurantType, @RestaurantSelection, @ResultRestaurantID OUTPUT 

	CREATE TABLE #tmpCater(
		TourRecID			NUMERIC(18),
		RestPriceRecID		NUMERIC(18),
		RestaurantInfID		NUMERIC(18),
		Date				VARCHAR(23),
		MenuTypeID			NVARCHAR(30),
		Breakfast			SMALLINT,
		Dinner				SMALLINT,
		Lunch				SMALLINT,
		PaxQty				SMALLINT,
		EmpQty				SMALLINT)

	SET @SQL = '
	DECLARE @CaterRecID			NUMERIC(18),
			@PaxQty				SMALLINT,
			@EmpQty				SMALLINT,
			@Date				VARCHAR(23),
			@ServicePrInfID		NUMERIC(18),
			@Qty				SMALLINT,
			@MealTypeID			NVARCHAR(30),
			@MenuTypeID			NVARCHAR(30),
			@RestaurantInfID	NUMERIC(18)

	INSERT INTO #tmpCater(TourRecID, Date)
		SELECT DISTINCT TourRecID, Date 
			FROM tlTourCatering  ' +
				CASE WHEN @ResultTourID = '' THEN '' ELSE N' INNER JOIN '+@ResultTourID + N' B ON A.TourRecID=B.CodeInfID' END + N'
			WHERE Date BETWEEN @BeginDate AND @EndDate

	DECLARE vCrs CURSOR FOR
		SELECT A.TourCateringRecID 
			FROM tlTourCatering A ' +
				CASE WHEN @ResultTourID = '' THEN '' ELSE N' INNER JOIN '+@ResultTourID + N' B ON A.TourRecID=B.CodeInfID' END + N'
			WHERE Date BETWEEN @BeginDate AND @EndDate

	OPEN vCrs
	FETCH NEXT FROM vCrs INTO @CaterRecID 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @Date = Date, @Qty = Qty, @PaxQty = GuestQty, @EmpQty = MglQty, @ServicePrInfID = RestaurantServicePriceInfID
			FROM tlTourCatering	A '+
					CASE WHEN @ResultTourID = '' THEN '' ELSE N'INNER JOIN' +@ResultTourID+ 'B ON A.TourRecID=B.CodeInfID' END + N'	
			WHERE TourCateringRecID = @CaterRecID AND Date BETWEEN @BeginDate AND @EndDate
		
		SELECT @RestaurantInfID = RestaurantInfID, @MealTypeID = MealTypeID, @MenuTypeID = MenuTypeID
			FROM tlRestaurantServicePrices	A '+
					CASE WHEN @ResultRestaurantID = '' THEN '' ELSE N'INNER JOIN '+@ResultRestaurantID+' B ON A.RestaurantInfID = B.CodeInfID' END + N'
			WHERE RestaurantServicePriceInfID = @ServicePrInfID
		
		IF @MealTypeID = ''mealBreakfast''		
			UPDATE #tmpCater SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, BreakFast = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date 

		IF @MealTypeID = ''mealDinner''		
			UPDATE #tmpCater SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, Dinner = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date
			
		IF @MealTypeID = ''mealLunch''	
			UPDATE #tmpCater SET RestaurantInfID = @RestaurantInfID, MenuTypeID = @MenuTypeID, Lunch = @Qty, PaxQty = @PaxQty, EmpQty = @EmpQty 					
				WHERE Date = @Date
		
	FETCH NEXT FROM vCrs INTO @CaterRecID 
	END 
	
	CLOSE vCrs
	DEALLOCATE vCrs'

PRINT @SQL
	EXEC sp_executesql @SQL, N'@BeginDate VARCHAR(23), @EndDate VARCHAR(23)', @BeginDate, @EndDate

	IF @TourType <> 1
	BEGIN
		SET @SQL = 'DROP PROC '+@ResultTourID
		EXEC @SQL
	END
	IF @RestaurantType <> 1
	BEGIN
		SET @SQL = 'DROP PROC '+@ResultRestaurantID
		EXEC @SQL
	END

	SET NOCOUNT ON
	SELECT ROW_NUMBER( ) OVER(ORDER BY Date) Num, A.Date, B.TourID, A.RestaurantInfID, C.DescriptionF [RestaurantName], A.MenuTypeID Menu, A.BreakFast, A.Lunch, A.Dinner, A.PaxQty, A.EmpQty
		FROM #tmpCater A
			INNER JOIN tlTours B ON A.TourRecID = B.TourRecID
			INNER JOIN tlRestaurants C ON A.RestaurantInfID = C.RestaurantInfID
	
	SELECT '' AS ManuID, '' AS Product, '' AS Date, '' AS Product

			
END
GO
EXEC TL_SS_SelCatering 2, '2007/04/03', 1, '', 1, '','Y', 0

SELECT * FROM tlTourCatering
--DROP PROCEDURE [dbo].[IM_SEL_SimpleOutList]
--GO
--CREATE PROCEDURE [dbo].[IM_SEL_SimpleOutList]
--	@VARCHAR(23)				SMALLINT,
--	@DateSelection			NVARCHAR(2000),
--	@TourType				SMALLINT,
--	@TourSelection			NVARCHAR(2000),
--	@RestaurantType			SMALLINT,
--	@RestaurantSelection   	NVARCHAR(2000),
--	@VoucherNoType			SMALLINT,
--	@VoucherNoSelection     NVARCHAR(2000),
--	@IsLocal				CHAR(1),
--	@UserInfID				NUMERIC(18)
--AS		
--BEGIN 
--	DECLARE @BeginDate VARCHAR(23)
--	DECLARE @EndDate VARCHAR(23)
--	DECLARE @ResultTourID VARCHAR(23)
--	DECLARE @ResultRestaurantID VARCHAR(23)
--	DECLARE @ResultVoucherNoID VARCHAR(23)
--	
--	SET @DateSelection = REPLACE(@DateSelection, N'<', N'')
--	SET @DateSelection = REPLACE(@DateSelection, N'>', N'')
--	SET @DateSelection = REPLACE(@DateSelection, N'=', N'')
--	SET @DateSelection = REPLACE(@DateSelection, N'''', N'')
--
--	SET @BeginDate = LEFT(@DateSelection, 10)
--	SET @EndDate = RIGHT(@DateSelection, 10)
--	IF  @VARCHAR(23) = 2 SET @BeginDate = '1980/01/01'
--	SET @ResultVoucherNoID = ''	
--
--	EXEC SS_CodeSelectionFilter 'tlTours', @UserInfID, @TourType, @TourSelection, @ResultTourID OUTPUT 
--	EXEC SS_CodeSelectionFilter 'tlRestaurants', @UserInfID, @RestaurantType, @RestaurantSelection, @ResultRestaurantID OUTPUT 	
--
--	CREATE TABLE #tmp(
--		InvPkID					NUMERIC(18),
--		InvRef					NVARCHAR(15),
--		SumAmount				NUMERIC(18,6),
--		InvDate					VARCHAR(23),
--		SymbolInfID				NUMERIC(18),
--		InvDescription			NVARCHAR(75),
--		IsOut					CHAR(1),
--		PostedByDescription		NVARCHAR(75)		
--	)
--	
--	CREATE TABLE #tmp1(
--		InvPkID					NUMERIC(18),
--		InvRef					NVARCHAR(15),
--		SumAmount				NUMERIC(18,6),
--		InvDate					VARCHAR(23),
--		SymbolInfID				NUMERIC(18),
--		InvDescription			NVARCHAR(75),
--		IsOut					CHAR(1),
--		PostedByDescription		NVARCHAR(75)	
--	)
--
--	INSERT INTO #tmp
--		SELECT InvPkID, InvRef, SumAmount, InvDate, SymbolInfID,
--			  CASE WHEN @IsLocal = 'Y' THEN InvDescriptionL ELSE InvDescriptionF END InvDescription, IsOut, 
--			  CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END PostedByDescription	 
--				 FROM imInvSimpleHdr B INNER JOIN CodeSelectionResult A ON A.CodeInfID = B.ItemLocationInfID								
--									   LEFT OUTER JOIN ssUsers C ON B.PostedBy = C.UserID
--				 WHERE InvDate BETWEEN @BeginDate AND @EndDate AND A.ResultID = @ResultID AND B.IsDebit = 'N'
--					   AND InvPkID IN(SELECT InvPkID FROM CodeSelectionResult A 
--													 INNER JOIN imInvSimpleDtl B ON A.CodeInfID = B.ItemInfID
--													 WHERE ResultID = @ResultItemID)	
--
--	IF @SymbolType <> 1
--	BEGIN		
--		EXEC SS_CodeSelectionFilter 'ssSymbols', @UserInfID, @SymbolType, @SymbolSelection, @ResultSymbolID OUTPUT 	
--		
--		INSERT INTO #tmp1
--			SELECT InvPkID,InvRef,SumAmount,InvDate,SymbolInfID,InvDescription,IsOut,PostedByDescription
--			FROM #tmp A INNER JOIN CodeSelectionResult B ON A.SymbolInfID = B.CodeInfID
--			WHERE ResultID = @ResultSymbolID		
--
--		DELETE FROM #tmp
--		
--		INSERT INTO #tmp SELECT * FROM #tmp1
--	END
--	
--
--	SELECT * FROM #tmp
--
--	SELECT InvPkID, B.ItemInfID, ItemID, OutQty, B.SalePrice, CASE WHEN @IsLocal = 'Y' THEN C.DescriptionL ELSE C.DescriptionF END Description
--		FROM imInvSimpleDtl B INNER JOIN CodeSelectionResult A ON A.CodeInfID = B.ItemInfID		
--							  INNER JOIN VIEW_isItems C ON B.ItemInfID = C.ItemInfID							
--		WHERE ResultID = @ResultItemID AND B.IsDebit =	'N' AND InvPkID IN (SELECT InvPkID FROM #tmp)
--
--	DROP TABLE #tmp
--	DROP TABLE #tmp1
--	DELETE FROM CodeSelectionResult Where ResultID IN(@ResultID, @ResultItemID, @ResultSymbolID)	
--END
--
--EXEC IM_SEL_SimpleOutList 0, '2007/02/01', 1, '', 1, '', 1 ,'','Y', 0
--EXEC IM_SEL_SimpleOutList 0, '2007/01/29', 0, '1987010400001', 1, '', 1 ,'','Y', 0
--EXEC IM_SEL_SimpleOutList 0, '2007/01/29', 0, 1987010400001, 1, '', 0 ,'1986080100001','Y', 0


