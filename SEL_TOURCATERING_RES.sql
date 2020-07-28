USE [TourLogistic]
GO
--select * from tltourcatering
GO
--DROP PROC [dbo].[TL_SEL_TourCateringRes] 'Y'
GO
USE [TourLogistic]
GO
--select * from tltourcatering
GO
DROP PROC [dbo].[TL_SEL_TourCateringRes] 
GO
CREATE PROC [dbo].[TL_SEL_TourCateringRes] (
@IsLocal CHAR(1)
)
AS 
BEGIN	
--Tuluwlult
   	DECLARE @tmpCatering table
   		( 
		RowID					SMALLINT IDENTITY(1,1),
		Date					dateType,
		RestaurantInfID			pkType,
		TourRecID				pkType,
		VoucherNum				idType,
		AprStatusID				idType,
		SumBreakFast			Char(1),
		SumLunch				Char(1),
		SumDinner				Char(1),
		SumEger					Char(1)
		)

	DECLARE @TourCaterRecID		 pkType,
			@TourRecID			 pkType, 
			@RestaurantInfID	 pkType, 
			@AprStatusID		 idType,
			@Date				 dateType,	
			@VoucherNum			 idType,
			@SumLunch 			 SMALLINT,
			@SumBreakFast		 SMALLINT,
			@SumDinner			 SMALLINT,
			@SumEger			 SMALLINT
			

	
	INSERT INTO @tmpCatering(TourRecID, RestaurantInfID, Date, VoucherNum)
		SELECT DISTINCT TourRecID, RestaurantInfID, Date, VoucherNum 
			FROM tlTourCatering
	

	SELECT * FROM @tmpCatering
		
	DECLARE vSet CURSOR FOR
		SELECT TourCaterRecID
			FROM tlTourCatering

	OPEN vSet
	FETCH NEXT FROM vSet INTO @TourCaterRecID
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		SELECT @TourRecID = TourRecID, @RestaurantInfID	= RestaurantInfID, @VoucherNum = VoucherNum, @AprStatusID = AprStatusID, @Date = Date
			FROM tlTourCatering 
			WHERE TourCaterRecID = @TourCaterRecID

		SELECT @SumBreakFast as CountB, @TourRecID AS TourRecID, @RestaurantInfID as Res, @VoucherNum AS Voucher , @AprStatusID  AS Apr, @Date AS Date

		SELECT @SumBreakFast = Count(Breakfast)
			FROM tlTourCatering 
				WHERE BreakFast = 'Y' AND Date = @Date AND IsPax = 'Y' AND TourRecID =  @TourRecID AND @RestaurantInfID	= RestaurantInfID
	
		SELECT @SumLunch = Count(Lunch)
			FROM tlTourCatering 
				WHERE Lunch = 'Y' AND Date = @Date AND IsPax = 'Y' AND TourRecID =  @TourRecID AND @RestaurantInfID	= RestaurantInfID
	
		SELECT @SumDinner = Count(Dinner)
			FROM tlTourCatering 
				WHERE Dinner = 'Y' AND Date = @Date AND IsPax = 'Y' AND TourRecID =  @TourRecID AND @RestaurantInfID	= RestaurantInfID
		
		SELECT @SumEger = Count(Eger)
			FROM tlTourCatering 
				WHERE Eger = 'Y' AND Date = @Date AND IsPax = 'Y' AND TourRecID =  @TourRecID AND @RestaurantInfID	= RestaurantInfID
	
		UPDATE @tmpCatering SET SumLunch = @SumLunch , AprStatusID = @AprStatusID
			WHERE TourRecID = @TourRecID AND RestaurantInfID = @RestaurantInfID	AND VoucherNum = @VoucherNum AND Date = @Date
	
		UPDATE @tmpCatering SET SumBreakFast = @SumBreakFast , AprStatusID = @AprStatusID
			WHERE TourRecID = @TourRecID AND RestaurantInfID = @RestaurantInfID	AND VoucherNum = @VoucherNum AND Date = @Date

		UPDATE @tmpCatering SET SumDinner = @SumDinner , AprStatusID = @AprStatusID
			WHERE TourRecID = @TourRecID AND RestaurantInfID = @RestaurantInfID	AND VoucherNum = @VoucherNum AND Date = @Date
	
		UPDATE @tmpCatering SET SumEger = @SumEger , AprStatusID = @AprStatusID
			WHERE TourRecID = @TourRecID AND RestaurantInfID = @RestaurantInfID	AND VoucherNum = @VoucherNum AND Date = @Date
	
		FETCH NEXT FROM vSet INTO @TourCaterRecID
	END 
	CLOSE vSet
	DEALLOCATE vSet

	SELECT A.RestaurantInfID, A.Date, A.TourRecID, CASE WHEN @IsLocal = 'Y' THEN B.DescriptionL ELSE B.DescriptionF END RestaurantDescription, 
		   A.VoucherNum, A.AprStatusID, A.SumBreakFast, A.SumLunch, A.SumDinner, A.SumEGer
		FROM @tmpCatering A 
			INNER JOIN tlRestaurants B ON A.RestaurantInfID = B.RestaurantInfID
				
	SELECT TourCaterRecID, TourRecID, GuestRecID, RestaurantInfID,	BreakFast, Lunch, Dinner, Eger, Date, IsPax, VoucherNum, IsApproved,
			CASE WHEN IsPax = 'Y' THEN B.FirstName ELSE C.DescriptionL END GuestName
		FROM tlTourCatering A 
			INNER JOIN tlPaxes B ON A.GuestRecID = B.PaxRecID
			LEFT OUTER JOIN tlEmployees C ON A.GuestRecID = C.EmployeeInfID

/*
	SELECT Count(BreakFast)
		FROM tlTourCatering
		WHERE Date = '2007/05/02' AND RestaurantInfID = 1987022300001 AND TourRecID = 1987040200001
			and VoucherNum ='1/0011' AND BreakFast = 'Y'


	1987040200001	1987022600001	1/0010	NULL	2007/05/01
--Guitsetgel
   	DECLARE @tmpTable1 table
   		( 
		Date					dateType,
		RestaurantInfID			pkType,
		TourRecID				pkType,
		VoucherNum				idType,
		SumBreakFast			Char(1),
		SumLunch				Char(1),
		SumDinner				Char(1),
		SumEger					Char(1)
		)

	INSERT INTO @tmpTable1 SELECT Date, RestaurantInfID, TourRecID, VoucherNum, Count(BreakFast), Count(Lunch), Count(Dinner), Count(Eger) FROM tlAprCatering  A 
		WHERE BreakFast = 'Y' OR Lunch = 'Y' OR Dinner = 'Y' OR Eger = 'Y'
		GROUP BY Date, RestaurantInfID, TourRecID, VoucherNum

	SELECT A.RestaurantInfID, A.Date, A.TourRecID, 
		   CASE WHEN @IsLocal = 'Y' THEN B.DescriptionL ELSE B.DescriptionF END RestaurantDescription, 
		   A.VoucherNum, A.SumBreakFast, A.SumLunch, A.SumDinner, A.SumEGer
		FROM @tmpTable1 A INNER JOIN tlRestaurants B ON A.RestaurantInfID = B.RestaurantInfID
			
	SELECT AprCaterRecID, TourRecID, GuestRecID, RestaurantInfID, TourCaterRecID, BreakFast, Lunch, Dinner, Eger, Date, IsPax, VoucherNum,
	CASE WHEN IsPax = 'Y' THEN B.FirstName ELSE C.DescriptionL END GuestName, Status='UnChanged' 
	FROM tlAprCatering A INNER JOIN tlPaxes B ON A.GuestRecID = B.PaxRecID
						  LEFT OUTER JOIN tlEmployees C ON A.GuestRecID = C.EmployeeInfID
*/
END
GO
EXEC TL_SEL_TourCateringRes 'Y'

/*
drop PROC [dbo].[TL_MOD_TourCateringRes]
go
Alter PROC [dbo].[TL_MOD_TourCateringRes]
	@TourRecID			pkType, 
	@RestaurantInfID	pkType, 
	@XML				NVARCHAR(MAX)
AS
BEGIN
	DECLARE @hXML				INT
	DECLARE @AprCaterRecID		pkType
	DECLARE @lastModification   dateType
	SET @lastModification = CONVERT(VARCHAR(23), GETDATE(), 21)
	
	SET NOCOUNT ON

  	EXEC sp_xml_preparedocument @hXML OUTPUT, @XML  
   
   	SELECT * INTO #RestaurantPrDtl
   	FROM OPENXML (@hXML, '//RestaurantPrDtl', 2)
        WITH ( 
		AprCaterRecID		pkType,
		TourCaterRecID		pkType,
		TourRecID			pkType,
		RestaurantInfID		pkType,
		BreakFast			char(1),
		Lunch				char(1),
		Dinner				char(1),
		Eger				char(1),
		Date				dateType,
		IsPax				char(1),
		VoucherNum			idType,
		GuestRecID			pkType,
		Status				nvarchar(50)
		--ActionDoneBy		idType,
		--ActionDate			dateType
		)
   	EXEC sp_xml_removedocument @hXML
  	SET NOCOUNT OFF

	DELETE FROM tlAprCatering WHERE AprCaterRecID IN (SELECT AprCaterRecID FROM #RestaurantPrDtl WHERE Status = 'Deleted')


	UPDATE A SET A.AprCaterRecID = B.AprCaterRecID, A.TourCaterRecID = B.TourCaterRecID, A.TourRecID = B.TourRecID, 
				 A.RestaurantInfID = B.RestaurantInfID, A.BreakFast = B.BreakFast, A.Lunch = B.Lunch, 
				 A.Dinner = B.Dinner, A.Eger = B.Eger, A.Date = B.Date, A.IsPax = B.IsPax, A.VoucherNum = B.VoucherNum, 
				 A.GuestRecID = B.GuestRecID--, --A.ActionDoneBy = B.ActionDoneBy, 
				-- A.ActionDate = @lastModification
		FROM tlAprCatering A INNER JOIN #RestaurantPrDtl B ON A.TourCaterRecID = B.TourCaterRecID
		WHERE B.Status = 'Modified' AND A.TourRecID = @TourRecID AND A.RestaurantInfID = @RestaurantInfID
	IF EXISTS (SELECT * FROM #RestaurantPrDtl WHERE status = 'Added')
	BEGIN
		EXEC CreatePkID 'tlAprCatering', 'AprCaterRecID', @AprCaterRecID OUTPUT
		SELECT IDENTITY(INT, 0, 1) AS RowID, * INTO #RestaurantPrDtl_IDENTITY FROM #RestaurantPrDtl 
			WHERE Status = 'Added' AND TourRecID = @TourRecID AND RestaurantInfID = @RestaurantInfID
		INSERT INTO tlAprCatering (AprCaterRecID, TourCaterRecID, TourRecID, GuestRecID, RestaurantInfID, BreakFast, Lunch, 
				 Dinner, Eger, Date, IsPax, VoucherNum)
		SELECT @AprCaterRecID + RowID, TourCaterRecID, TourRecID, GuestRecID, RestaurantInfID, BreakFast, Lunch, 
				 Dinner, Eger, Date, IsPax, VoucherNum
									FROM #RestaurantPrDtl_IDENTITY
	END	
END
select * from tlaprcatering

[dbo].[TL_MOD_TourCateringRes] 1987040200001, '<TL_SEL_TourCateringRes>
  <Restaurant>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <Date>2007/05/01</Date>
    <TourRecID>1987040200002</TourRecID>
    <RestaurantDescription>Флоувэр</RestaurantDescription>
    <VoucherNum>1/0012</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </Restaurant>
  <Restaurant>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <Date>2007/05/01</Date>
    <TourRecID>1987040200001</TourRecID>
    <RestaurantDescription>Hanamasa</RestaurantDescription>
    <VoucherNum>1/0010</VoucherNum>
    <AprStatusID>Completed</AprStatusID>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </Restaurant>
  <Restaurant>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <Date>2007/05/02</Date>
    <TourRecID>1987040200001</TourRecID>
    <RestaurantDescription>Флоувэр</RestaurantDescription>
    <VoucherNum>1/0011</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </Restaurant>
  <Restaurant>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <Date>2007/05/02</Date>
    <TourRecID>1987040200002</TourRecID>
    <RestaurantDescription>Hanamasa</RestaurantDescription>
    <VoucherNum>1/0013</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </Restaurant>
  <RestaurantDtl>
    <TourCaterRecID>1987040200001</TourCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200003</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>N</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0010</VoucherNum>
    <GuestName>Johnson</GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200002</TourCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200004</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>N</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0010</VoucherNum>
    <GuestName>Johnson1</GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200003</TourCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200003</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0011</VoucherNum>
    <GuestName>Johnson</GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200004</TourCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200004</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0011</VoucherNum>
    <GuestName>Johnson1</GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200006</TourCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200002</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0012</VoucherNum>
    <GuestName>Mary </GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200007</TourCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200017</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0012</VoucherNum>
    <GuestName>July</GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200008</TourCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200002</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <BreakFast>Y</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0013</VoucherNum>
    <GuestName>Mary </GuestName>
  </RestaurantDtl>
  <RestaurantDtl>
    <TourCaterRecID>1987040200009</TourCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200017</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <BreakFast>Y</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0013</VoucherNum>
    <GuestName>July</GuestName>
  </RestaurantDtl>
  <RestaurantPr>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <Date>2007/05/02</Date>
    <TourRecID>1987040200001</TourRecID>
    <RestaurantDescription>Флоувэр</RestaurantDescription>
    <VoucherNum>1/0011</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </RestaurantPr>
  <RestaurantPr>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <Date>2007/05/01</Date>
    <TourRecID>1987040200001</TourRecID>
    <RestaurantDescription>Hanamasa</RestaurantDescription>
    <VoucherNum>1/0010</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </RestaurantPr>
  <RestaurantPr>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <Date>2007/05/01</Date>
    <TourRecID>1987040200002</TourRecID>
    <RestaurantDescription>Флоувэр</RestaurantDescription>
    <VoucherNum>1/0012</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </RestaurantPr>
  <RestaurantPr>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <Date>2007/05/02</Date>
    <TourRecID>1987040200002</TourRecID>
    <RestaurantDescription>Hanamasa</RestaurantDescription>
    <VoucherNum>1/0013</VoucherNum>
    <SumBreakFast>2</SumBreakFast>
    <SumLunch>2</SumLunch>
    <SumDinner>2</SumDinner>
    <SumEGer>2</SumEGer>
  </RestaurantPr>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200003</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <TourCaterRecID>1987040200003</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0011</VoucherNum>
    <GuestName>Johnson</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200004</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <TourCaterRecID>1987040200004</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0011</VoucherNum>
    <GuestName>Johnson1</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200003</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <TourCaterRecID>1987040200001</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>N</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0010</VoucherNum>
    <GuestName>Johnson</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200001</TourRecID>
    <GuestRecID>1987040200004</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <TourCaterRecID>1987040200002</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>N</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0010</VoucherNum>
    <GuestName>Johnson1</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200002</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <TourCaterRecID>1987040200006</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0012</VoucherNum>
    <GuestName>Mary </GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200017</GuestRecID>
    <RestaurantInfID>1987022300001</RestaurantInfID>
    <TourCaterRecID>1987040200007</TourCaterRecID>
    <BreakFast>N</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/01</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0012</VoucherNum>
    <GuestName>July</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200002</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <TourCaterRecID>1987040200008</TourCaterRecID>
    <BreakFast>Y</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0013</VoucherNum>
    <GuestName>Mary </GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
  <RestaurantPrDtl>
    <AprCaterRecID>0</AprCaterRecID>
    <TourRecID>1987040200002</TourRecID>
    <GuestRecID>1987040200017</GuestRecID>
    <RestaurantInfID>1987022600001</RestaurantInfID>
    <TourCaterRecID>1987040200009</TourCaterRecID>
    <BreakFast>Y</BreakFast>
    <Lunch>Y</Lunch>
    <Dinner>Y</Dinner>
    <Eger>Y</Eger>
    <Date>2007/05/02</Date>
    <IsPax>Y</IsPax>
    <VoucherNum>1/0013</VoucherNum>
    <GuestName>July</GuestName>
    <Status>Added</Status>
  </RestaurantPrDtl>
</TL_SEL_TourCateringRes>'

select * from tltourcatering
select * from tlAprcatering
delete from tlAprcatering

*/