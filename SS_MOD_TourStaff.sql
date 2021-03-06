USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[SS_MOD_TourStaff]    Script Date: 10/11/2007 12:23:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SS_MOD_TourStaff](
	@XML	NVARCHAR(MAX)	
)
AS
BEGIN
	DECLARE @hXML				INT
	DECLARE	@AprOtherRecID		pkType
	DECLARE @tmpTourStaff TABLE(
					AprStaffRecID		pkType,
					TourRecID			pkType,
					TourName			idType,
					EmployeeInfID		pkType,
					EmployeeName		descType,
					PositionInfID		pkType,
					FromDate			dateType,
					ToDate				dateType,
					CurrencyInfID		pkType,
					Rate				amountType,
					AmtICPrice			amountType,
					AmtSalePrice		amountType,
					RateCvr				amountType,
					AmtICPriceCvr		amountType,
					AmtSalePriceCvr		amountType,
					AmtICPriceFcy		amountType,
					AmtSalePriceFcy		amountType,
					IsOverWork			CHAR(1),
					MapRecID			pkType,
					MarkRecID			NUMERIC(18),
					Status				idType
		)

	EXEC sp_xml_preparedocument @hXML OUTPUT, @XML  
 
	INSERT INTO @tmpTourStaff
		SELECT AprStaffRecID, TourRecID, TourName, EmployeeInfID, EmployeeName,
				PositionInfID, CONVERT(VARCHAR(23), CONVERT(DATETIME, FromDate), 111), 
				CONVERT(VARCHAR(23), CONVERT(DATETIME, ToDate), 111),
				CurrencyInfID, Rate, AmtICPrice, AmtSalePrice, RateCvr, AmtICPriceCvr, AmtSalePriceCvr, AmtICPriceFcy,
				AmtSalePriceFcy, IsOverWork, MapRecID, MarkRecID, Status				
			FROM OPENXML (@hXML, N'//TourStaff', 2)
			WITH ( 
					AprStaffRecID		NUMERIC(18),
					TourRecID			NUMERIC(18),
					TourName			NVARCHAR(30),
					EmployeeInfID		NUMERIC(18),
					EmployeeName		NVARCHAR(75),
					PositionInfID		NUMERIC(18),
					FromDate			VARCHAR(23),
					ToDate				VARCHAR(23),
					CurrencyInfID		NUMERIC(18),
					Rate				NUMERIC(24, 6),
					AmtICPrice			NUMERIC(24, 6),
					AmtSalePrice		NUMERIC(24, 6),
					RateCvr				NUMERIC(24, 6),
					AmtICPriceCvr		NUMERIC(24, 6),
					AmtSalePriceCvr		NUMERIC(24, 6),
					AmtICPriceFcy		NUMERIC(24, 6),
					AmtSalePriceFcy		NUMERIC(24, 6),
					IsOverWork			CHAR(1),
					MapRecID			NUMERIC(18),
					MarkRecID			NUMERIC(18),
					Status				NVARCHAR(30)
				)

		SELECT * INTO #AprOtherExpense
   		FROM OPENXML (@hXML, '//AprOtherExpense', 2)
			WITH ( 
			AprOtherRecID  		pkType, 
			TourRecID  			pkType, 
			OtherExpenseInfID 	pkType,
			Qty 				amountType,	
			ICPriceCvrAmt 		amountType,
			SalePriceCvrAmt		amountType,
			ICPriceAmt			amountType,
			SalePriceAmt		amountType,
			Rate 				amountType,
			RateCvr				amountType,
			TourOtherRecID		pkType,
			TypeID				idType,
			Status				varchar(50)
			)

	EXEC sp_xml_removedocument @hXML

	DECLARE @CreateDate		dateType,
			@pkID			pkType,
			@MarkRecID		pkType,
			@Error			NVARCHAR(200)
		
	SET @CreateDate = CONVERT(NVARCHAR(30), GETDATE(), 121)

--	SELECT * FROM @tmpTourStaff
--
--	SELECT A.* 
--		FROM tlAprStaffs A
--			INNER JOIN @tmpTourStaff B ON A.MapRecID =  B.MapRecID

	BEGIN TRY 

		IF EXISTS (SELECT 1 FROM @TmpTourstaff WHERE Status = 'Added' ) 
		BEGIN
			EXEC CREATEPKID 'tlAprStaffs', 'AprStaffRecID', @pkID OUTPUT
			
			INSERT INTO tlAprStaffs(AprStaffRecID, TourStaffRecID, TourRecID, Date, EmployeeInfID, PositionInfID, LevelID, IsRecipient, CurrencyInfID, 
						Rate, ICPrice, SalePrice, RateCvr, ICPriceCvr, SalePriceCvr, ICPriceFcy, SalePriceFcy, IsOverWork, ActionDoneBy, ActionDate, MapRecID, MarkRecID)
				SELECT @pkID + ROW_NUMBER() OVER (ORDER BY  B.TourRecID) AS AprStaffRecID, A.TourStaffRecID, A.TourRecID, A.Date, A.EmployeeInfID,
					A.PositionInfID, A.LevelID, IsRecipient, B.CurrencyInfID, B.Rate, AmtICPrice, AmtSalePrice, B.RateCvr, AmtICPriceCvr, 
					AmtSalePriceCvr, AmtICpriceFcy, AmtSalePriceFcy, B.IsOverWork, N'Admin', @CreateDate, B.MapRecID, NULL
				FROM tlTourStaffs A
					INNER JOIN @tmptourstaff B ON A.MapRecID = B.MapRecID
				WHERE B.Status = 'Added'
				
			UPDATE A SET IsApproved = 'Y'
				FROM tlTourStaffs A 
					INNER JOIN @tmpTourStaff B ON A.MapRecID = B.MapRecID
				WHERE B.Status = 'Added'
		END


		IF EXISTS (SELECT 1 FROM @TmpTourStaff WHERE MapRecID = 0 AND Status = 'Added')
		BEGIN
			EXEC CREATEPKID 'tlAprStaffs', 'MarkRecID', @MarkRecID OUTPUT
			EXEC CREATEPKID 'tlAprStaffs', 'AprStaffRecID', @pkID OUTPUT

			UPDATE A SET A.MarkRecID = B.MarkRecID
				FROM @TmpTourStaff A 
					INNER JOIN ( SELECT TourRecID, EmployeeInfID, PositionInfID, @MarkRecID + ROW_NUMBER() OVER (ORDER BY  TourRecID) AS MarkRecID
									FROM @tmpTourStaff
									WHERE Status = 'Added' AND MapRecID = 0) AS B 
					ON A.TourRecID = B.TourRecID AND A.EmployeeInfID = B.EmployeeInfID AND A.PositionInfID = B.PositionInfID 
				WHERE Status = 'Added' AND MapRecID = 0

			INSERT INTO tlAprStaffs(AprStaffRecID, TourStaffRecID, TourRecID, Date, EmployeeInfID, PositionInfID, LevelID, IsRecipient, CurrencyInfID, 
							Rate, ICPrice, SalePrice, RateCvr, ICPriceCvr, SalePriceCvr, ICPriceFcy, SalePriceFcy, IsOverWork, ActionDoneBy, ActionDate, MapRecID, MarkRecID)
				SELECT @pkID + ROW_NUMBER() OVER (ORDER BY TourRecID) AS AprStaffRecID, 0, A.TourRecID, B.Date, A.EmployeeInfID, 
						A.PositionInfID, C.EmployeeLevelTypeID, 'N', A.CurrencyInfID, A.Rate, AmtICPrice, AmtSalePrice, RateCvr, AmtICPriceCvr,	
						AmtSalePriceCvr, AmtICPriceFcy, AmtSalePriceFcy, IsOverWork, 'Admin', @CreateDate, MapRecID, MarkRecID
					FROM @tmpTourStaff A
						LEFT OUTER JOIN ssCustomers C ON A.EmployeeInfID = C.CustomerInfID
						CROSS JOIN tlDate B 
					WHERE A.MapRecID = 0 AND B.Date >= A.FromDate AND B.Date <= A.ToDate AND A.Status = 'Added'
		END

		IF EXISTS (SELECT 1 FROM @TmpTourstaff WHERE Status = 'Deleted')
		BEGIN
			DELETE FROM tlAprStaffs 
				WHERE MapRecID IN (SELECT MapRecID FROM @tmpTourStaff WHERE Status = 'Deleted')

			DELETE FROM tlAprStaffs
				WHERE MarkRecID IN (SELECT MarkRecID FROM @tmpTourStaff WHERE Status = 'Deleted')
			
--			DELETE FROM tlAprStaffs A
--					INNER JOIN @tmpTourStaff B ON A.TourRecID = B.TourRecID AND A.EmployeeInfID = B.EmployeeInfID 
				
		END

		IF EXISTS (SELECT 1 FROM @TmpTourstaff WHERE Status = 'Modified')
		BEGIN

			DELETE FROM tlAprStaffs
				WHERE MapRecID IN (SELECT MapRecID FROM @tmpTourStaff WHERE Status = 'Modified')

			DELETE FROM tlAprStaffs
				WHERE MapRecID IN (SELECT MarkRecID FROM @tmpTourStaff WHERE Status = 'Modified')

			EXEC CreatePkID 'tlAprStaffs', 'AprStaffRecID', @pkID OUTPUT

			INSERT INTO tlAprStaffs(AprStaffRecID, TourStaffRecID, TourRecID, Date, EmployeeInfID, PositionInfID, LevelID, IsRecipient, CurrencyInfID, 
						Rate, ICPrice, SalePrice, RateCvr, ICPriceCvr, SalePriceCvr, ICPriceFcy, SalePriceFcy, IsOverWork, ActionDoneBy, ActionDate, MapRecID, MarkRecID)
				SELECT @pkID + ROW_NUMBER() OVER (ORDER BY TourRecID) AS AprStaffRecID, 0, A.TourRecID, B.Date, A.EmployeeInfID, 
						A.PositionInfID, C.EmployeeLevelTypeID, 'N', A.CurrencyInfID, A.Rate, 
						AmtICPrice /  (DATEDIFF(DD, A.FromDate, A.ToDate) + 1), 
						AmtSalePrice / (DATEDIFF(DD, A.FromDate, A.ToDate) + 1), RateCvr, 
						AmtICPriceCvr / (DATEDIFF(DD, A.FromDate, A.ToDate) + 1),	
						AmtSalePriceCvr /(DATEDIFF(DD, A.FromDate, A.ToDate) + 1), 
						AmtICPriceFcy / (DATEDIFF(DD, A.FromDate, A.ToDate) + 1), 
						AmtSalePriceFcy / (DATEDIFF(DD, A.FromDate, A.ToDate) + 1), IsOverWork, 'Admin', @CreateDate, MapRecID, MarkRecID
					FROM @tmpTourStaff A
						LEFT OUTER JOIN ssCustomers C ON A.EmployeeInfID = C.CustomerInfID
						CROSS JOIN tlDate B 
					WHERE A.Status = 'Modified' AND B.Date >= A.FromDate AND B.Date <= A.ToDate
/*
			EXEC CreatePkID 'tlAprStaffs', 'AprStaffRecID', @pkID OUTPUT
		
			INSERT INTO tlAprStaffs(AprStaffRecID, TourRecID, Date, EmployeeInfID, PositionInfID, LevelID, MapRecID) 
				SELECT B.*
					FROM tlAprStaffs A 
						INNER JOIN ( SELECT @pkID + ROW_NUMBER() OVER (ORDER BY TourRecID) AS AprStaffRecID, A.TourRecID, B.Date, A.EmployeeInfID, 
										A.PositionInfID, C.EmployeeLevelTypeID, MapRecID 
										--DATEDIFF(DD, FromDate, ToDate) + 1 AS Daydiff 
				--						AmtICPrice / (DATEDIFF(DD, FromDate, ToDate) + 1), AmtSalePrice / (DATEDIFF(DD, FromDate, ToDate) + 1), 
				--						RateCvr, AmtICPriceCvr / (DATEDIFF(DD, FromDate, ToDate) + 1),	
				--						AmtSalePriceCvr / (DATEDIFF(DD, FromDate, ToDate) + 1), AmtICPriceFcy / (DATEDIFF(DD, FromDate, ToDate) + 1), 
				--						AmtSalePriceFcy / (DATEDIFF(DD, FromDate, ToDate) + 1) , IsOverWork, 'Admin', @CreateDate, MapRecID, MarkRecID
							FROM @tmpTourStaff A
								LEFT OUTER JOIN ssCustomers C ON A.EmployeeInfID = C.CustomerInfID
								CROSS JOIN tlDate B 
							WHERE A.MapRecID IS NOT NULL AND B.Date >= A.FromDate AND B.Date <= A.ToDate AND A.Status = 'Modified' ) B
					ON A.MapRecID = B.MapRecID AND A.Date <> B.Date

			INSERT INTO tlAprStaffs(AprStaffRecID, TourRecID, Date, EmployeeInfID, PositionInfID, LevelID, MarkRecID) 
				SELECT B.*
					FROM tlAprStaffs A 
						INNER JOIN ( SELECT @pkID + ROW_NUMBER() OVER (ORDER BY TourRecID) AS AprStaffRecID, A.TourRecID, B.Date, A.EmployeeInfID, 
										A.PositionInfID, C.EmployeeLevelTypeID, MarkRecID
										--DATEDIFF(DD, FromDate, ToDate) + 1 AS Daydiff 
				--						AmtICPrice / (DATEDIFF(DD, FromDate, ToDate) + 1), AmtSalePrice / (DATEDIFF(DD, FromDate, ToDate) + 1), 
				--						RateCvr, AmtICPriceCvr / (DATEDIFF(DD, FromDate, ToDate) + 1),	
				--						AmtSalePriceCvr / (DATEDIFF(DD, FromDate, ToDate) + 1), AmtICPriceFcy / (DATEDIFF(DD, FromDate, ToDate) + 1), 
				--						AmtSalePriceFcy / (DATEDIFF(DD, FromDate, ToDate) + 1) , IsOverWork, 'Admin', @CreateDate, MarkRecID, MarkRecID
							FROM @tmpTourStaff A
								LEFT OUTER JOIN ssCustomers C ON A.EmployeeInfID = C.CustomerInfID
								CROSS JOIN tlDate B 
							WHERE A.MarkRecID IS NOT NULL AND B.Date >= A.FromDate AND B.Date <= A.ToDate AND A.Status = 'Modified' ) B
					ON A.MarkRecID = B.MarkRecID AND A.Date <> B.Date
		
			--DELETE FROM A
			--	FROM tlAprStaffs A 
			--		INNER JOIN @tmpTourStaff B ON Date <= FromDate AND A.Date >= ToDate AND A.MapRecID = B.MapRecID
			--			WHERE B.Status = 'Modified'
			
			--DELETE FROM A
			--	FROM tlAprStaffs A 
			--		INNER JOIN @tmpTourStaff B ON Date <= FromDate AND A.Date >= ToDate AND A.MarkRecID = B.MarkRecID
			--			WHERE B.Status = 'Modified'
			
			UPDATE A SET A.EmployeeInfID = B.EmployeeInfID,  
						 A.Date = B.Date, A.Rate = B.Rate, A.ICPrice = B.AmtICPrice / Days, 
						 A.SalePrice = B.AmtSalePrice / Days , A.RateCvr = B.RateCvr, A.ICPriceCvr = B.AmtICPriceCvr / Days, 
						 A.SalePriceCvr = B.AmtSalePriceCvr / Days , A.ICPriceFcy = B.AmtICPriceFcy / Days, 
						 A.SalePriceFcy = B.AmtSalePriceFcy / Days , A.IsOverWork = B.IsOverWork, 
						 A.MapRecID = B.MapRecID, ActionDate = @CreateDate
				FROM tlAprStaffs A
					INNER JOIN ( SELECT TourRecID, EmployeeInfID, PositionInfID, (DATEDIFF(DAY, FromDate, ToDate) + 1) AS Days,
										D.Date, Rate, 
										AmtICPrice, AmtSalePrice, RateCvr, AmtICPriceCvr,	
										AmtSalePriceCvr, AmtICPriceFcy, AmtSalePriceFcy, 
										IsOverWork, MapRecID
									FROM @tmpTourStaff A
										CROSS JOIN tlDate D
									WHERE D.Date >= A.FromDate AND D.Date <= A.ToDate AND A.Status = 'Modified' AND MapRecID <> 0) AS B 
					ON A.MapRecID = B.MapRecID AND A.Date = B.Date  

			UPDATE A SET A.EmployeeInfID = B.EmployeeInfID,  
						 A.Date = B.Date, A.Rate = B.Rate, A.ICPrice = B.AmtICPrice / CASE WHEN Days = 0 THEN 1 ELSE Days END, 
						 A.SalePrice = B.AmtSalePrice / CASE WHEN Days = 0 THEN 1 ELSE Days END, A.RateCvr = B.RateCvr, 
						 A.ICPriceCvr = B.AmtICPriceCvr / CASE WHEN Days = 0 THEN 1 ELSE Days END, 
						 A.SalePriceCvr = B.AmtSalePriceCvr / CASE WHEN Days = 0 THEN 1 ELSE Days END, A.ICPriceFcy = B.AmtICPriceFcy / CASE WHEN Days = 0 THEN 1 ELSE Days END, 
						 A.SalePriceFcy = B.AmtSalePriceFcy / CASE WHEN Days = 0 THEN 1 ELSE Days END, A.IsOverWork = B.IsOverWork, 
						 A.MarkRecID = B.MarkRecID, ActionDate = @CreateDate
				FROM tlAprStaffs A
					INNER JOIN ( SELECT TourRecID, EmployeeInfID, PositionInfID, 
										DATEDIFF(DAY, CONVERT(DATETIME, FromDate), CONVERT(DATETIME, ToDate)) AS Days,
										D.Date, Rate, 
										AmtICPrice, AmtSalePrice, RateCvr, AmtICPriceCvr,	
										AmtSalePriceCvr, AmtICPriceFcy, AmtSalePriceFcy, 
										IsOverWork, MarkRecID
									FROM @tmpTourStaff A
										CROSS JOIN tlDate D
									WHERE D.Date >= A.FromDate AND D.Date <= A.ToDate AND A.Status = 'Modified' AND A.MarkRecID <> 0 ) AS B 
					ON A.MarkRecID = B.MarkRecID
*/
		END
	END TRY 

	BEGIN CATCH

		--SET @Error = ERROR_MESSAGE()
		RAISERROR(N'Нэг аялал дээр ажилтан огноо давхцаж байна. Мэдээлэлээ засаж оруулна уу!.', 16, 1, @Error)

	END CATCH

	--OtherExpense
	DELETE FROM tlAprOthers WHERE AprOtherRecID IN (SELECT AprOtherRecID FROM #AprOtherExpense WHERE Status = 'Deleted')

	UPDATE A SET A.AprOtherRecID = B.AprOtherRecID, A.TourRecID = B.TourRecID, A.OtherExpenseInfID = B.OtherExpenseInfID,
				 A.Qty = B.Qty, A.TypeID = B.TypeID, A.ICPriceCvrAmt = B.ICPriceCvrAmt, A.SalePriceCvrAmt = B.SalePriceCvrAmt,
				 A.ICPriceAmt = B.ICPriceAmt, A.SalePriceAmt = B.SalePriceAmt, A.Rate = B.Rate,
				 A.RateCvr = B.RateCvr, A.TourOtherRecID = B.TourOtherRecID,
				 A.ActionDoneBy = 'sa', A.ActionDate = @CreateDate 
		FROM tlAprOthers A LEFT OUTER JOIN #AprOtherExpense B ON A.AprOtherRecID = B.AprOtherRecID
		WHERE B.Status = 'Modified'
	IF EXISTS (SELECT * FROM #AprOtherExpense WHERE Status = 'Added')
	BEGIN
		EXEC CreatePkID 'tlAprOthers', 'AprOtherRecID', @AprOtherRecID OUTPUT
		SELECT IDENTITY(INT, 0, 1) AS RowID, * INTO #AprOtherExpense_IDENTITY FROM #AprOtherExpense WHERE Status = 'Added'
		INSERT INTO tlAprOthers(AprOtherRecID, TourRecID, OtherExpenseInfID, Qty, TypeID, 
							ICPriceCvrAmt, SalePriceCvrAmt, ICPriceAmt, SalePriceAmt, Rate, RateCvr, TourOtherRecID, ActionDoneBy, ActionDate)
		SELECT @AprOtherRecID + RowID, TourRecID, OtherExpenseInfID, Qty, TypeID, 
										ICPriceCvrAmt, SalePriceCvrAmt, ICPriceAmt, SalePriceAmt, Rate,
										RateCvr, TourOtherRecID, 'sa', @CreateDate
							   FROM #AprOtherExpense_IDENTITY
	END	


END
GO
