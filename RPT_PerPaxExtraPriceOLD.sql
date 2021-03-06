USE NomadsTourLogistic
go
DROP PROC RPT_PerPaxExtraPrice
GO
/*
	Ene procedure ni tuhain neg aylagchiin uniig bodno.
	Tuhain aylagchiin uilchilgee tus burees bodno.
	Tuhain group-n zardaliig bodood groupt hamaarah aylagchiin toond huvaaj tuhain aylagchiin zardal deer nemne.
*/
CREATE PROC RPT_PerPaxExtraPrice(
	@IsLocal		CHAR(1),
	@TourRecID		pkType,
	@PaxRecID		pkType
)
AS
BEGIN

	DECLARE @RequestRecID			pkType,
			@TourAccRecID			pkType,
			@AccInfID				pkType,
			@AccTypeID				idType,
			@AccProdTypeInfID		pkType,
			@Date					dateType,
			@SalePrice				amountType,
			@SalePriceCvr			amountType,
			@RCurrencyInfID			pkType,
			@RAccTypeID				idType,
			@RAccProdTypeInfID		pkType,
			@RAccInfID				pkType,
			@RSalePriceL			amountType,
			@RSalePriceF			amountType,
			@CurrencyInfID			pkType,
			@REmpQty				SMALLINT,
			@EmpQty					SMALLINT,
			@IsPax					CHAR(1),
			@RequestDate			dateType,
			@ReqRate				amountType
	
	DECLARE @AccExpense TABLE(
			DescL				descType,
			DescF				descType,
			AccInfID			pkType,
			AccTypeID			idType,
			AccProTypeInfID		pkType,
			Date				dateType,
			CurrencyInfID		pkType,
			SalePrice			amountType,
			SalePriceFcy		amountType
	)

	DECLARE @RRestaurantInfID	pkType, 
			@RCaterinTypeID		idType,
			@TourCaterRecID		pkType, 
			@cAccInfID			pkType, 
			@CateringTypeID		idType, 
			@RestaurantInfID	pkType, 
			@B					CHAR(1), 
			@L					CHAR(1),
			@D					CHAR(1),
			@E					CHAR(1),
			@cDate				dateType,
			@cCurrInfID			pkType,
			@BSalePrice			amountType,
			@BSalePriceCvr		amountType,
			@LSalePrice			amountType,
			@LSalePriceCvr		amountType,
			@DSalePrice			amountType,
			@DSalePriceCvr		amountType,
			@ESalePrice			amountType,
			@ESalePriceCvr		amountType,
			@rB					CHAR(1),
			@rL					CHAR(1),
			@rD					CHAR(1),
			@rE					CHAR(1),
			@rBCurrL				pkType,
			@rBCurrF				pkType,
			@rBSPriceL			amountType,
			@rBSPriceF			amountType,
			@rLSPriceL			amountType,
			@rLSPriceF			amountType,
			@rLCurrL				pkType,
			@rLCurrF				pkType,
			@rDSPriceL			amountType,
			@rDSPriceF			amountType,		
			@rDCurrL				pkType,
			@rDCurrF				pkType,
			@rESPriceL			amountType,
			@rESPriceF			amountType,		
			@rECurrL				pkType,
			@rECurrF				pkType

	DECLARE @CatExpense TABLE(
			DescL				descType	NULL,
			DescF				descType	NULL,
			CateringTypeID		idType		NULL,
			MealType			idType		NULL,
			Date				dateType	NULL,
			SalePrice			amountType	NULL,	
			CurrencyInfID		pkType		NULL,
			SalePriceFcy		amountType	NULL
	)

	DECLARE @RowID				pkType,
			@EnterTypeID		idType,
			@EnQty				SMALLINT,
			@EnSPrice			amountType,
			@EnSPriceCvr		amountType,
			@RQty				SMALLINT,
			@DifQty				SMALLINT,
			@StrEnt				NVARCHAR(MAX)

	DECLARE @EnterTain TABLE(
			DescL				descType,
			DescF				descType,
			EnterTypeID			idType,	
			SalePrice			amountType	NULL,
			SalePriceFcy		amountType	NULL
		)

	SELECT @RequestRecID = RequestRecID 
		FROM tlTours
		WHERE TourRecID = @TourRecID

	SELECT @RequestDate = CONVERT(VARCHAR(23), CONVERT(DATETIME, ActionDate), 111)
		FROM tlRequest
		WHERE RequestRecID = @RequestRecID 

	SELECT @RequestRecID, @TourRecID

	SET NOCOUNT ON
	
	-- Per pax price calculation start here
/*
	DECLARE AccCur CURSOR FOR 
		SELECT TourAccRecID, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID, Date, CurrencyInfID, SalePrice, SalePriceCvr  
			FROM tlTourAccomodations 
			WHERE TourRecID = @TourRecID AND GuestRecID = @PaxRecID AND IsPax = 'Y'
		ORDER BY Date
	
	OPEN AccCur
	
	FETCH NEXT FROM AccCur INTO @TourAccRecID, @AccInfID, @AccTypeID, @AccProdTypeInfID, @Date, @CurrencyInfID, @SalePrice, @SalePriceCvr 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @TourAccRecID, @AccInfID, @AccTypeID, @AccProdTypeInfID, @Date, @CurrencyInfID, @SalePrice, @SalePriceCvr 
		-- IsPax = Y 
		IF EXISTS (SELECT 1 FROM tlReqAccomodation WHERE RequestRecID = @RequestRecID AND @Date BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111))
		BEGIN
			SELECT @RAccTypeID = AccomodationTypeID, @RAccProdTypeInfID = AccProductTypeInfID, @RAccInfID = AccomodationInfID, @RCurrencyInfID = CurrencyInfIDF, @RSalePriceL = ProductSalePriceL, @RSalePriceF = ProductSalePriceF
				FROM tlReqAccomodation 
					WHERE RequestRecID = @RequestRecID AND @Date BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111)
--		SELECT @Date, * FROM tlReqAccomodation 
--				WHERE RequestRecID = @RequestRecID AND @Date BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111)
			IF @RAccInfID <> @AccInfID
				INSERT INTO @AccExpense(DescL, DescF, AccInfID, AccTypeID, AccProTypeInfID, Date, CurrencyInfID, SalePrice, SalePriceFcy) 
					SELECT N'Амрах газрын зөрүү', 'Accomodations extra price', @AccInfID, '', 0, @Date, @CurrencyInfID, @SalePrice - @RSalePriceL, @SalePriceCvr - @RSalePriceF
			ELSE
			BEGIN
				IF @RAccTypeID <> @AccTypeID 
					INSERT INTO @AccExpense(DescL, DescF, AccInfID, AccTypeID, AccProTypeInfID, Date, CurrencyInfID, SalePrice, SalePriceFcy) 
						SELECT N'Амрах газрын зөрүү', 'Accomodations extra price', 0, @AccTypeID, 0, @Date, @CurrencyInfID, @SalePrice - @RSalePriceL, @SalePriceCvr - @RSalePriceF
				ELSE 
					IF @RAccProdTypeInfID <> @AccProdTypeInfID
						INSERT INTO @AccExpense(DescL, DescF, AccInfID, AccTypeID, AccProTypeInfID, Date, CurrencyInfID, SalePrice, SalePriceFcy) 
							SELECT N'Амрах газрын зөрүү', 'Accomodations extra price', 0, '', @AccProdTypeInfID, @Date, @CurrencyInfID, @SalePrice - @RSalePriceL, @SalePriceCvr - @RSalePriceF
			END
		END
		ELSE
			INSERT INTO @AccExpense(DescL, DescF, AccInfID, AccTypeID, AccProTypeInfID, Date, CurrencyInfID, SalePrice, SalePriceFcy) 
				SELECT N'Амрах газрын зөрүү', 'Accomodations extra price', @AccInfID, @AccTypeID, @AccProdTypeInfID, @Date, @CurrencyInfID, @SalePrice - @RSalePriceL, @SalePriceCvr - @RSalePriceF

		FETCH NEXT FROM AccCur INTO @TourAccRecID, @AccInfID, @AccTypeID, @AccProdTypeInfID, @Date, @CurrencyInfID, @SalePrice, @SalePriceCvr 
	END

	CLOSE AccCur
	DEALLOCATE AccCur

	EXEC SS_SEL_GetLastRate 'USD', @RequestDate, @ReqRate OUTPUT

	-- Catering 
	DECLARE CatCur CURSOR FOR 
		SELECT TourCaterRecID, AccomodationInfID, CateringTypeID, RestaurantInfID, BreakFast, Lunch, Dinner, Eger, Date, CurrencyInfID, BSalePrice, BSalePriceCvr, LSalePrice, LSalePriceCvr, DSalePrice, DSalePriceCvr, ESalePrice, ESalePriceCvr 
			FROM tlTourCatering 
			WHERE TourRecID = @TourRecID AND GuestRecID = @PaxRecID AND IsPax = 'Y'
	
	OPEN CatCur
	
	FETCH NEXT FROM CatCur INTO @TourCaterRecID, @cAccInfID, @CateringTypeID, @RestaurantInfID, @B, @L, @D, @E, @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr, @LSalePrice, @LSalePriceCvr, @DSalePrice, @DSalePriceCvr, @ESalePrice, @ESalePriceCvr 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	--SELECT @TourCaterRecID, @cAccInfID, @CateringTypeID, @RestaurantInfID, @B, @L, @D, @E, @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr, @LSalePrice, @LSalePriceCvr, @DSalePrice, @DSalePriceCvr, @ESalePrice, @ESalePriceCvr 
		-- CaterGerCamp breakfast here
		IF @B = 'Y'
		BEGIN
			-- Catering here
			IF @CateringTypeID = 'caterGerCamp' 
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast') 
				BEGIN
					SELECT @RRestaurantInfID = RestaurantInfID, @rBCurrL = CurrencyInfIDL, @rBCurrF = CurrencyInfIDF, @rBSPriceL = SalePriceL, @rBSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealBreakfast'
--						SELECT 'R' AS REQ, * FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast'
					--@rBCurrF
					IF @cAccInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өглөөний хоолны зөрүү үнэ', 'Gcamp restaurant breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice - @rBSPriceF, @BSalePriceCvr - @rBSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өглөөний хоолны зөрүү үнэ', 'Gcamp restaurant breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice - @rBSPriceF * @ReqRate, @BSalePriceCvr - @rBSPriceF 
					END
				END
				ELSE 
				INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
					SELECT N'Өглөөний хооны зөрүү үнэ', 'BreakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr
			END	
			-- caterNamedCook
			IF @CateringTypeID = 'caterNamedCook' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс Өглөөний хооны зөрүү үнэ', 'Nomads breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr
			END

			-- caterNomNaadam
			IF @CateringTypeID = 'caterNomNaadam' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс Өглөөний хооны зөрүү үнэ', 'Nomads breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr
			END

			--caterRestaurant
			IF @CateringTypeID = 'caterRestaurant' 
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast') 
				BEGIN
					SELECT @RRestaurantInfID = RestaurantInfID, @rBCurrL = CurrencyInfIDL, @rBCurrF = CurrencyInfIDF, @rBSPriceL = SalePriceL, @rBSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealBreakfast'

--						SELECT 'R' AS REQ, * FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast'
					--@rBCurrF
					IF @RestaurantInfID <> @RRestaurantInfID
					BEGIN
						EXEC SS_SEL_GetLastRate 'USD', @RequestDate, @ReqRate OUTPUT
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өглөөний хоолны зөрүү үнэ', 'Gcamp restaurant breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice - @rBSPriceF, @BSalePriceCvr - @rBSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өглөөний хоолны зөрүү үнэ', 'Gcamp restaurant breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice - @rBSPriceF * @ReqRate, @BSalePriceCvr - @rBSPriceF 
					END
				END
				ELSE 
				INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
					SELECT N'Өглөөний хооны зөрүү үнэ', 'BreakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr
			END
			-- Standart ger camp caterStGCamp
			IF @CateringTypeID = 'caterStGCamp' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealBreakfast')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс Өглөөний хооны зөрүү үнэ', 'Nomads breakFast extra price', @CateringTypeID, 'B', @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr
			END 

		END
	-- Lunch here
		IF @L = 'Y' 
		BEGIN
			IF @CateringTypeID = 'caterGerCamp'  
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
				BEGIN
				--	SELECT @cDate AS Date, * FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealLunch'
					SELECT @RRestaurantInfID = RestaurantInfID, @rLCurrL = CurrencyInfIDL, @rLCurrF = CurrencyInfIDF, @rLSPriceL = SalePriceL, @rLSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealLunch'

					--@rBCurrF
					IF @cAccInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice - @rLSPriceF, @LSalePriceCvr - @rLSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice - @rLSPriceF * @ReqRate, @LSalePriceCvr - @rLSPriceF 
					END
				END
				ELSE				
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant Lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice, @LSalePriceCvr
			END
			
			-- caterNamedCook
			IF @CateringTypeID = 'caterNamedCook' 
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterNamedCook' AND MealTypeID = 'mealLunch')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс өдрийн хоолны зөрүү үнэ', 'Nomads restaurant Lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice, @LSalePriceCvr
			
			-- caterNomNaadam
			IF @CateringTypeID = 'caterNomNaadam' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс өдрийн хоолны зөрүү үнэ', 'Nomads restaurant Lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice, @LSalePriceCvr
			END
			
			-- caterRestaurant
			IF @CateringTypeID = 'caterRestaurant'  
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
				BEGIN
				--	SELECT @cDate AS Date, * FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealLunch'
					SELECT @RRestaurantInfID = RestaurantInfID, @rLCurrL = CurrencyInfIDL, @rLCurrF = CurrencyInfIDF, @rLSPriceL = SalePriceL, @rLSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch'

					--@rBCurrF
					IF @RestaurantInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice - @rLSPriceF, @LSalePriceCvr - @rLSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice - @rLSPriceF * @ReqRate, @LSalePriceCvr - @rLSPriceF 
					END
				END
				ELSE				
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Өдрийн хоолны зөрүү үнэ', 'Gcamp restaurant Lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice, @LSalePriceCvr
			END

			-- caterStgCamp
			IF @CateringTypeID = 'caterStGCamp' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс өдрийн хоолны зөрүү үнэ', 'Nomads restaurant Lunch extra price', @CateringTypeID, 'L', @cDate, @cCurrInfID, @LSalePrice, @LSalePriceCvr
			END 
		END	

		-- Dinner here
		IF @D = 'Y' 
		BEGIN
			IF @CateringTypeID = 'caterGerCamp'  
			BEGIN 
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealDinner')
				BEGIN
					SELECT @RRestaurantInfID = RestaurantInfID, @rDCurrL = CurrencyInfIDL, @rDCurrF = CurrencyInfIDF, @rDSPriceL = SalePriceL, @rDSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterGerCamp' AND MealTypeID = 'mealDinner'

					--@rBCurrF
					IF @cAccInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice - @rDSPriceF, @DSalePriceCvr - @rDSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice - @rDSPriceF * @ReqRate, @DSalePriceCvr - @rDSPriceF 
					END
				END
				ELSE
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Оройн хоолны зөрүү үнэ', 'Gcamp restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice, @DSalePriceCvr
			END

			-- caterNamedCook
			IF @CateringTypeID = 'caterNamedCook' 
				INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
					SELECT N'Номадс оройн хоолны зөрүү үнэ', 'Nomads restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice, @DSalePriceCvr

			-- caterNomNaadam
			IF @CateringTypeID = 'caterNomNaadam' 
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс оройн хоолны зөрүү үнэ', 'Nomads restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice, @DSalePriceCvr
		
			-- Restaurant here
			IF @CateringTypeID = 'caterRestaurant'  
			BEGIN 
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealDinner')
				BEGIN
					SELECT @RRestaurantInfID = RestaurantInfID, @rDCurrL = CurrencyInfIDL, @rDCurrF = CurrencyInfIDF, @rDSPriceL = SalePriceL, @rDSPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealDinner'

					--@rBCurrF
					IF @cAccInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice - @rDSPriceF, @DSalePriceCvr - @rDSPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice - @rDSPriceF * @ReqRate, @DSalePriceCvr - @rDSPriceF 
					END
				END
				ELSE
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Оройн хоолны зөрүү үнэ', 'Gcamp restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice, @DSalePriceCvr
			END
			-- caterStgCamp
			IF @CateringTypeID = 'caterStGCamp' 
			BEGIN
				IF NOT EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'mealLunch')
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Номадс оройн хоолны зөрүү үнэ', 'Nomads restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @DSalePrice, @DSalePriceCvr
			END 
		END

	-- Entertainment		
	-- Eger baaziin uzveriin ger 
		IF @E = 'Y' 
		BEGIN
			IF @CateringTypeID = 'caterRestaurant'  
			BEGIN 
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'EnterGer')
				BEGIN
					SELECT @RRestaurantInfID = RestaurantInfID, @rECurrL = CurrencyInfIDL, @rECurrF = CurrencyInfIDF, @rESPriceL = SalePriceL, @rESPriceF = SalePriceF
						FROM tlReqCatering 
						WHERE RequestRecID = @RequestRecID AND @cDate BETWEEN FromDate AND ToDate AND CateringTypeID = @CateringTypeID AND MealTypeID = 'EnterGer'

					--@rBCurrF
					IF @RestaurantInfID <> @RRestaurantInfID
					BEGIN
						--EXEC SS_SEL_GetRateByInfID @rBCurrF, @RequestDate, @ReqRate OUTPUT
						IF 'MNT' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'E', @cDate, @cCurrInfID, @ESalePrice - @rESPriceF, @ESalePriceCvr - @rESPriceF / @ReqRate

						IF 'USD' IN (SELECT CurrencyID FROM VIEW_ssCurrencies WHERE CurrencyInfID = @rBCurrF) 
							INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)	
								SELECT N'Гэр баазын оройн хоолны зөрүү үнэ', 'Gcamp restaurant dinner extra price', @CateringTypeID, 'E', @cDate, @cCurrInfID, @ESalePrice - @rESPriceF * @ReqRate, @ESalePriceCvr - @rESPriceF 
					END
				END
				ELSE
					INSERT INTO @CatExpense(DescL, DescF, CateringTypeID, MealType, Date, CurrencyInfID, SalePrice, SalePriceFcy)
						SELECT N'Оройн хоолны зөрүү үнэ', 'Gcamp restaurant Dinner extra price', @CateringTypeID, 'D', @cDate, @cCurrInfID, @ESalePrice, @ESalePriceCvr
			END
		END
	
	FETCH NEXT FROM CatCur INTO @TourCaterRecID, @cAccInfID, @CateringTypeID, @RestaurantInfID, @B, @L, @D, @E, @cDate, @cCurrInfID, @BSalePrice, @BSalePriceCvr, @LSalePrice, @LSalePriceCvr, @DSalePrice, @DSalePriceCvr, @ESalePrice, @ESalePriceCvr 
	END 
	CLOSE CatCur
	DEALLOCATE CatCur


	DECLARE @TourEnter TABLE(
			RowID					pkType IDENTITY(1,1),
			EnterTainmentTypeID		idType,
			EnterCount				SMALLINT,
			SalePrice				amountType	null,
			SalePriceCvr			amountType	null
	)

	INSERT INTO @TourEnter 
		SELECT EnterTainmentTypeID, COUNT(EnterTainmentTypeID), SUM(ISNULL(SalePrice, 0)), SUM(ISNULL(SalePriceCvr, 0))
			FROM tlTourEntertain
			WHERE TourRecID = @TourRecID AND GuestRecID = @PaxRecID AND IsPax = 'Y'
			GROUP BY EnterTainmentTypeID

	DECLARE EntCur CURSOR FOR 
		SELECT RowID, EnterTainmentTypeID, EnterCount, SalePrice, SalePriceCvr
			FROM @TourEnter 
	
	OPEN EntCur
	
	FETCH NEXT FROM EntCur INTO @RowID, @EnterTypeID, @EnQty, @EnSPrice, @EnSPriceCvr
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		-- EnterType Req ded b,val
		IF EXISTS (SELECT 1 FROM tlReqEntertainments WHERE RequestRecID = @RequestRecID AND EnterTainmentTypeID = @EnterTypeID)	
		BEGIN
			SELECT @RQty = Qty
				FROM tlReqEntertainments
				WHERE RequestRecID = @RequestRecID AND EnterTainmentTypeID = @EnterTypeID

			-- Tour-n entertainment too ni req-n enter toonoos ih b,val
			IF @EnQty > @RQty
			BEGIN
				SET @DifQty = @EnQty - @RQty

				SET @StrEnt = 'SELECT TOP '+CONVERT(NVARCHAR(5), @DifQty)+' N''Үзвэрийн нэмэлт үнэ'', ''Entertainment extra price'', EnterTainmentTypeID, SalePrice, SalePriceFcy
									FROM tlTourEntertain 
									WHERE TourRecID = @TourRecID AND GuestRecID = @PaxRecID AND EntertainmentTypeID = @EnterTypeID AND IsPax = ''Y''
									ORDER BY ActionDate Desc'
				PRINT @StrEnt
				INSERT INTO @EnterTain(DescL, DescF, EnterTypeID, SalePrice, SalePriceFcy)
					EXEC sp_executesql @StrEnt, N'@TourRecID pkType, @PaxRecID pkType, @EnterTypeID idType', @TourRecID, @PaxRecID, @EnterTypeID 
			END 
		END
		ELSE
			INSERT INTO @EnterTain(DescL, DescF, EnterTypeID, SalePrice, SalePriceFcy)
				SELECT N'Үзвэрийн нэмэлт үнэ', 'Entertainment extra price', EnterTainmentTypeID, SalePrice, SalePriceFcy
					FROM tlTourEntertain 
					WHERE TourRecID = @TourRecID AND GuestRecID = @PaxRecID AND EntertainmentTypeID = @EnterTypeID AND IsPax = 'Y'

		FETCH NEXT FROM EntCur INTO @RowID, @EnterTypeID, @EnQty, @EnSPrice, @EnSPriceCvr
	END
	CLOSE EntCur
	DEALLOCATE EntCur

	DECLARE @FlightRecID	pkType,
			@IsCargo		CHAR(1),
			@IsTwoWay		CHAR(1),
			@FsPrice		amountType,
			@FsPriceCvr		amountType,
			@FliDate		dateType,
			@RFlightRecID	pkType,
			@RFsPriceL		amountType,
			@RFsPriceF		amountType,
			@RIsTwoWay		CHAR(1),
			@RIsCargo		CHAR(1)

	DECLARE @Flight	TABLE(
			DescF			descType,
			DescL			descType,
			FlightRecID		pkType,
			FlightDate		dateType,
			SalePrice		amountType,
			SalePriceFcy		amountType
		)
--	SELECT @ReqRate AS Rate
	-- Flight 
	DECLARE Flcur CURSOR FOR 
		SELECT FlightRecID, IsCargo, IsTwoWay, FlightDate, SalePrice, SalePriceCvr 
			FROM tlTourFlights
			WHERE TourRecID = @TourRecID AND PassengerRecID = @PaxRecID AND IsPax  = 'Y' 

	OPEN Flcur
	FETCH NEXT FROM FlCur INTO @FlightRecID, @IsCargo, @IsTwoWay, @FliDate, @FsPrice, @FsPriceCvr
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		IF EXISTS (SELECT 1 FROM tlReqFlights WHERE RequestRecID = @RequestRecID AND FlightDate = @FliDate)
		BEGIN
			SELECT @RFlightRecID = FlightRecID, @RIsTwoWay = IsTwoWay, @RIsCargo = IsCargo, @RFsPriceL = SalePriceL, @RFsPriceF = SalePriceF
				FROM tlReqFlights WHERE RequestRecID = @RequestRecID AND FlightDate = @FliDate	
	
			IF @RFlightRecID <> @FlightRecID
			BEGIN
				INSERT INTO @Flight
					SELECT N'Нислэгийн нэмэлт үнэ', 'Flights extra price', @RFlightRecID, @FliDate, @FsPrice - @RFsPriceF * @ReqRate, @FsPriceCvr - @RFsPriceF   
			END	
			ELSE
			BEGIN
				IF @RIsTwoWay <> @IsTwoWay  OR @RIsCargo <> @IsCargo
					INSERT INTO @Flight
						SELECT N'Нислэгийн нэмэлт үнэ', 'Flights extra price', @RFlightRecID, @FliDate, @FsPrice - @RFsPriceF * @ReqRate, @FsPriceCvr - @RFsPriceF   
			END
		END
		ELSE
			INSERT INTO @Flight
				SELECT N'Нислэгийн нэмэлт үнэ', 'Flights extra price', @RFlightRecID, @FliDate, @FsPrice , @FsPriceCvr 

		FETCH NEXT FROM FlCur INTO @FlightRecID, @IsCargo, @IsTwoWay, @FliDate, @FsPrice, @FsPriceCvr
	END
	CLOSE Flcur
	DEALLOCATE Flcur

--  Train 
	DECLARE @Train	TABLE(
			DescF			descType,
			DescL			descType,
			TrainRecID		pkType,
			TrainDate		dateType,
			SalePrice		amountType,
			SalePriceFcy		amountType
		)

	DECLARE @TrainRecID		pkType,
			@TrainDate		dateType, 
			@TsPrice		amountType,
			@TsPriceCvr		amountType,
			@RTrainRecID	pkType,
			@RTPriceF		amountType

--	SELECT @ReqRate AS Rate
	-- Flight 
	DECLARE Trcur CURSOR FOR 
		SELECT TrainRecID, TrainDate, SalePrice, SalePriceCvr 
			FROM tlTourTrains
			WHERE TourRecID = @TourRecID AND PassengerRecID = @PaxRecID AND IsPax  = 'Y' 

	OPEN Trcur
	FETCH NEXT FROM Trcur INTO @TrainRecID, @TrainDate, @TsPrice, @TsPriceCvr 
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		IF EXISTS (SELECT 1 FROM tlReqTrains WHERE RequestRecID = @RequestRecID AND TrainDate = @TrainDate)
		BEGIN
			SELECT @RTrainRecID = TrainRecID, @RTPriceF = SalePriceF
				FROM tlReqTrains WHERE RequestRecID = @RequestRecID AND TrainDate = @TrainDate	
	
			IF @TrainRecID <> @RTrainRecID
			BEGIN
				INSERT INTO @Train
					SELECT N'Галт тэрэгний нэмэлт үнэ', 'Train extra price', @RTrainRecID, @TrainDate, @TsPrice - @RTPriceF  * @ReqRate, @TsPriceCvr - @RTPriceF    
			END	
		END
		ELSE
			INSERT INTO @Train
				SELECT N'Галт тэрэгний нэмэлт үнэ', 'Train extra price', @RTrainRecID, @TrainDate, @TsPrice , @TsPriceCvr 

		FETCH NEXT FROM Trcur INTO @TrainRecID, @TrainDate, @TsPrice, @TsPriceCvr 
	END
	CLOSE Trcur
	DEALLOCATE Trcur 

*/
	-- Per pax price calculation end here

	-- Group price
	-- Accomodation

	DECLARE @StaffAcc TABLE(
			id			SMALLINT IDENTITY(1,1),
			Date		dateType,
			StffQty		SMALLINT,
			AccTypeID   idType,
			AccInfID	pkType,
			SPrice		amountType,
			SPriceCvr	amountType
		)

	DECLARE @StaffAccEx	TABLE(
			DescL			descType,
			DescF			descType,
			Date			dateType,
			SalePrice		amountType NULL,
			SalePriceFcy	amountType NULL
		)

	DECLARE @stDate			dateType,
			@StffQty		smallint,
			@StAccTypeID	idType,
			@StAccInfID		pkType,
			@StSprice		amountType,
			@StSpriceCvr	amountType,
			@StRAccTypeID	idType,
			@StRAccInfID	pkType,
			@StRQty			SMALLINT,
			@StSaleAmt		amountType,
			@StDifQty			SMALLINT,
			@StAccSPrice		amountType,
			@StAccSPriceCvr		amountType,
			@StRSPriceL			amountType
			
	INSERT INTO @StaffAcc(Date, StffQty, AccTypeID, AccInfID, SPrice, SPriceCvr)
		SELECT Date, COUNT(GuestRecID), AccomodationTypeID, AccomodationInfID, SUM(SalePrice), SUM(SalePriceCvr)
			FROM tlTourAccomodations 
		WHERE TourRecID = @TourRecID AND IsPax = 'N'
		GROUP BY Date, AccomodationTypeID, AccomodationInfID
		ORDER BY Date

	SET NOCOUNT ON

	DECLARE AccScur CURSOR FOR 
		SELECT Date, StffQty, AccTypeID, AccInfID, SPrice, SPriceCvr
			FROM @StaffAcc 
	
	OPEN AccScur
	FETCH NEXT FROM AccScur INTO @stDate, @StffQty, @StAccTypeID, @StAccInfID, @StSPrice, @StSpriceCvr
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @StAccSPrice = SalePrice, @StAccSPriceCvr =  SalePriceCvr
			FROM tlTourAccomodations
			WHERE TourRecID = @TourRecID AND Date = @stDate AND AccomodationInfID = @StAccInfID AND AccomodationTypeID = @StAccTypeID

		IF EXISTS (SELECT 1 FROM tlReqAccomodation
						WHERE RequestRecID = @RequestRecID AND @stDate BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111))
		BEGIN		
			SELECT @StRAccTypeID = AccomodationTypeID, @StRAccInfID = AccomodationInfID, @StRQty = EmployeeQty, @StSaleAmt = SaleAmountL, @StRSPriceL = ProductSalePriceL
				FROM tlReqAccomodation
				WHERE RequestRecID = @RequestRecID AND @stDate BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111)

			IF @StffQty <> @StRQty	
			BEGIN
				IF @StAccTypeID <> @StRAccTypeID 
				BEGIN
					INSERT INTO @StaffAccEx
						SELECT N'A Ажилтан буудлын зөрүү', 'Employee accomodation price', @stDate, @StSPrice - @StRSPriceL, @StSpriceCvr - @StRSPriceL/@ReqRate 
				END
				ELSE
					IF @StAccInfID <> @StRAccInfID
					BEGIN 
						INSERT INTO @StaffAccEx
							SELECT N'B Ажилтан буудлын зөрүү', 'Employee accomodation price', @stDate, @StSPrice - @StRSPriceL, @StSpriceCvr - @StRSPriceL/@ReqRate 
					END
					ELSE
						IF @StffQty - @StRQty > 0	-- Tour deer ih bol
						BEGIN 
							SET @StDifQty = @StffQty - @StRQty
							INSERT INTO @StaffAccEx
								SELECT N'C Ажилтан буудлын зөрүү', 'Employee accomodation price', @stDate, @StAccSPrice * @StDifQty , @StAccSPriceCvr * @StDifQty
						END
						ELSE
							IF @StffQty - @StRQty < 0
							BEGIN
								SET @StDifQty =  @StffQty - @StRQty
								INSERT INTO @StaffAccEx
									SELECT N'D Ажилтан буудаын зөрүү', 'Employee accomodation price', @stDate, @StDifQty * @StRSPriceL, @StDifQty * @StRSPriceL/@ReqRate 
							END
			END	
		END
		ELSE
			INSERT INTO @StaffAccEx
				SELECT N'E Ажилтан буудлын зөрүү', 'Employee accomodation price', @stDate, @StAccSPrice, @StAccSPriceCvr 

		FETCH NEXT FROM AccScur INTO @stDate, @StffQty, @StAccTypeID, @StAccInfID, @StSPrice, @StSpriceCvr
	END
	CLOSE AccScur
	DEALLOCATE AccScur


/*
	-- Staff here
	DECLARE @TourStaff TABLE(
			Date			dateType,
			StffQty			SMALLINT,
			PosInfID		pkType,
			LevelID			idType,
			SPriceAmt		amountType	NULL,
			SPriceAmtFcy	amountType NULL
		)

	DECLARE @TourStaffEx TABLE(
			DescL			descType,
			DescF			descType,
			Date			dateType,
			SalePrice		amountType	NULL,
			SalePriceFcy	amountType NULL
		)

	DECLARE @StaffDate			dateType, 
			@StaffQty			SMALLINT,	
			@PosInfID			pkType, 
			@StaffSPriceAmt		amountType, 
			@StaffPriceAmtFcy	amountType,
			@LevelID			idType,
			@StaffRQty			SMALLINT,
			@RlevelID			idType,
			@RPosInfID			pkType,
			@SPrice				amountType,
			@SaleAmt			amountType,
			@SQL				NVARCHAR(MAX)

--	IF EXISTS (SELECT LevelID FROM tlTourStaffs	WHERE TourRecID = @TourRecID AND LevelID IS NULL)
--	BEGIN
--		SET @SQL = 'RAISERROR(''There is no Level !!!. You need set value!!!'', 15, 1)'
--		EXEC(@SQL)
--	END 

	INSERT INTO @TourStaff
		SELECT Date, COUNT(EmployeeInfID) AS Qty, PositionInfID, ISNULL(LevelID, 'N'), SUM(ISNULL(SalePrice, 0)), SUM(ISNULL(SalePriceCvr, 0))
			FROM tlTourStaffs
			WHERE TourRecID = @TourRecID AND LevelID <> 'N'
			GROUP BY Date, LevelID, PositionInfID
	--SELECT * FROM @TourStaff

	DECLARE Staffcur CURSOR FOR 
		SELECT Date, StffQty, PosInfID, LevelID, SPriceAmt, SPriceAmtFcy
			FROM @TourStaff 
	
	OPEN Staffcur
	FETCH NEXT FROM Staffcur INTO @StaffDate, @StaffQty, @PosInfID, @LevelID, @StaffSPriceAmt, @StaffPriceAmtFcy	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @StaffDate,  * FROM tlReqEmployees WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate	
		IF EXISTS (SELECT 1 FROM tlReqEmployees WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate)
		BEGIN
--			SELECT @StaffDate, @PosInfID, * FROM tlReqEmployees WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate AND PositionInfID = @PosInfID
			IF EXISTS (SELECT 1 FROM tlReqEmployees 
							WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate AND PositionInfID = @PosInfID)
			BEGIN
				SELECT @StaffRQty = EmployeeQty, @RlevelID = LevelID, @SPrice = SalePrice, @SaleAmt = SaleAmount 
					FROM tlReqEmployees 
					WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate AND PositionInfID = @PosInfID
				--	SELECT 'Positon', * FROM tlReqEmployees 
				--			WHERE RequestRecID = @RequestRecID AND @StaffDate BETWEEN FromDate AND ToDate AND PositionInfID = @PosInfID
				IF @StaffQty <> @StaffRQty 
				BEGIN
					INSERT INTO @TourStaffEx
						SELECT N'Ажилтан албан тушаалын зөрүү', 'Employee position difference', @StaffDate, @StaffSPriceAmt - @StaffRQty * @SPrice, @StaffPriceAmtFcy - @StaffRQty * @SPrice/@ReqRate			
					--SELECT * FROM @TourStaffEx
				END
				ELSE
					IF @LevelID <> @RLevelID
					BEGIN
						INSERT INTO @TourStaffEx
							SELECT N'Ажилтан албан тушаалын зөрүү', 'Employee position difference', @StaffDate,  @StaffSPriceAmt - @StaffRQty * @SPrice, @StaffPriceAmtFcy - @StaffRQty * @SPrice/@ReqRate
						--SELECT * FROM @TourStaffEx			
					END
			END 
			ELSE 
				INSERT INTO @TourStaffEx
					SELECT N'Ажилтан албан тушаалын зөрүү', 'Employee position difference', @StaffDate, @StaffSPriceAmt, @StaffPriceAmtFcy
		END
		ELSE
			INSERT INTO @TourStaffEx
				SELECT N'Ажилтан албан тушаалын зөрүү', 'Employee position difference', @StaffDate, @StaffSPriceAmt, @StaffPriceAmtFcy

		FETCH NEXT FROM Staffcur INTO @StaffDate, @StaffQty, @PosInfID, @LevelID, @StaffSPriceAmt, @StaffPriceAmtFcy	
	END
	CLOSE Staffcur
	DEALLOCATE Staffcur

	-- Catering 
	DECLARE @ReqCatEx TABLE(
			DescL			descType,
			DescF			descType,
			Date			dateType,
			SalePrice		amountType	NULL,
			SalePriceFcy	amountType NULL
		)
		
	DECLARE @CatEmpQty		SMALLINT,
			@CatTypeID		idType,
			@CRestInfID		pkType,	
			@RestInfID		pkType,	
			@BSPrice		amountType,
			@BSPriceCvr		amountType,
			@CSalePriceL	amountType,
			@MealTypeID		idType,
			@CaterinTypeID	idType,
			@LSPrice		amountType,
			@LSPriceCvr		amountType,
			@DSPrice		amountType,
			@DSPriceCvr		amountType,
			@ESPrice		amountType,
			@ESPriceCvr		amountType
			
	DECLARE ReqCat CURSOR FOR 
		SELECT COUNT(GuestRecID) EmpQty, AccomodationInfID, CateringTypeID, RestaurantInfID, BreakFast, Lunch, Dinner, Eger, Date, BSalePrice, BSalePriceCvr, SUM(BSalePrice), SUM(BSalePriceCvr), LSalePrice, LSalePriceCvr, SUM(LSalePrice), SUM(LSalePriceCvr), DSalePrice, DSalePriceCvr, SUM(DSalePrice), SUM(DSalePriceCvr), ESalePrice, ESalePriceCvr, SUM(ESalePrice), SUM(ESalePriceCvr) 
			FROM tlTourCatering 
			WHERE TourRecID = @TourRecID AND IsPax = 'N'
			GROUP BY AccomodationInfID, CateringTypeID, RestaurantInfID, BreakFast, Lunch, Dinner, Eger, Date, BSalePrice, BSalePriceCvr, LSalePrice, LSalePriceCvr, DSalePrice, DSalePriceCvr, ESalePrice, ESalePriceCvr

--		SELECT * FROM tlReqCatering
--			WHERE RequestRecID = 2007062500079
--		SELECT * FROM tlTourCatering 
--			WHERE TourRecID = @TourRecID AND IsPax = 'N' AND Date = '2007/07/03'

	OPEN ReqCat
	FETCH NEXT FROM ReqCat INTO @CatEmpQty, @AccInfID, @CatTypeID, @CRestInfID, @B, @L, @D, @E, @Date, @BSPrice, @BSPriceCvr, @BSalePrice, @BSalePriceCvr, @LSPrice, @LSPriceCvr, @LSalePrice, @LSalePriceCvr, @DSPrice, @DSPriceCvr, @DSalePrice, @DSalePriceCvr, @ESPrice, @ESPriceCvr, @ESalePrice, @ESalePriceCvr 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate)
		BEGIN	
			IF @B = 'Y'
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealBreakfast') 
				BEGIN
					-- SELECT * FROM tlTourCatering
						SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
							FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealBreakfast'

					IF @CatTypeID <> @CaterinTypeID 
						INSERT INTO @ReqCatEx
							SELECT N'B c Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @BSalePrice - @EmpQty* @CSalePriceL, @BSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
					ELSE
						IF @AccInfID <> @RestInfID
							INSERT INTO @ReqCatEx
								SELECT N'B A Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @BSalePrice - @EmpQty* @CSalePriceL, @BSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
						ELSE
						-- Employee
							IF @CatEmpQty <> @EmpQty 
							BEGIN
								IF @CatEmpQty - @EmpQty > 0
									INSERT INTO @ReqCatEx
										SELECT N'B E Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @BSPrice, @CatEmpQty - @EmpQty * @BSPriceCvr
								ELSE IF @CatEmpQty - @EmpQty < 0
									INSERT INTO @ReqCatEx
										SELECT N'B E R Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @CSalePriceL, @CatEmpQty - @EmpQty * @CSalePriceL/@ReqRate
							END
				END	
			END
			ELSE
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealBreakfast') 
				BEGIN
					SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
						FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealBreakfast'
					INSERT INTO @ReqCatEx
						SELECT N'B Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  0 - @EmpQty * @CSalePriceL, 0 - @EmpQty * @CSalePriceL/@ReqRate
				END

			IF @L = 'Y'
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealLunch') 
				BEGIN
					-- SELECT * FROM tlTourCatering
						SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
							FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealLunch'

					IF @CatTypeID <> @CaterinTypeID 
						INSERT INTO @ReqCatEx
							SELECT N'L C Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @LSalePrice - @EmpQty* @CSalePriceL, @LSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
					ELSE
						IF @AccInfID <> @RestInfID
							INSERT INTO @ReqCatEx
								SELECT N'L A Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @LSalePrice - @EmpQty* @CSalePriceL, @LSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
						ELSE
						-- Employee
							IF @CatEmpQty <> @EmpQty 
							BEGIN
								IF @CatEmpQty - @EmpQty > 0
									INSERT INTO @ReqCatEx
										SELECT N'L E Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @LSPrice, @CatEmpQty - @EmpQty * @LSPriceCvr
								ELSE IF @CatEmpQty - @EmpQty < 0
									INSERT INTO @ReqCatEx	
										SELECT N'L E R Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @CSalePriceL, @CatEmpQty - @EmpQty * @CSalePriceL/@ReqRate
							END
				END	
			END
			ELSE
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealLunch') 
				BEGIN
					SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
						FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealLunch'
					INSERT INTO @ReqCatEx
						SELECT N'L Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  0 - @EmpQty * @CSalePriceL, 0 - @EmpQty * @CSalePriceL/@ReqRate
				END
		
			IF @D = 'Y'
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealDinner') 
				BEGIN
					-- SELECT * FROM tlTourCatering
						SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
							FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealDinner'

					IF @CatTypeID <> @CaterinTypeID 
						INSERT INTO @ReqCatEx
							SELECT N'D c Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @DSalePrice - @EmpQty* @CSalePriceL, @DSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
					ELSE
						IF @AccInfID <> @RestInfID
							INSERT INTO @ReqCatEx
								SELECT N'D Ac Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @DSalePrice - @EmpQty* @CSalePriceL, @DSalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
						ELSE
						-- Employee
							IF @CatEmpQty <> @EmpQty 
							BEGIN
								IF @CatEmpQty - @EmpQty > 0
									INSERT INTO @ReqCatEx
										SELECT N'D E Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @DSPrice, @CatEmpQty - @EmpQty * @DSPriceCvr
								ELSE IF @CatEmpQty - @EmpQty < 0
									INSERT INTO @ReqCatEx
										SELECT N'D E R Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @CSalePriceL, @CatEmpQty - @EmpQty * @CSalePriceL/@ReqRate
							END
				END	
			END
			ELSE
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealDinner') 
				BEGIN
					SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
						FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealDinner'
					INSERT INTO @ReqCatEx
						SELECT N'D Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  0 - @EmpQty * @CSalePriceL, 0 - @EmpQty * @CSalePriceL/@ReqRate
				END


			IF @E = 'Y'
			BEGIN
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealEger') 
				BEGIN
					-- SELECT * FROM tlTourCatering
						SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
							FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealEger'

					IF @CatTypeID <> @CaterinTypeID 
						INSERT INTO @ReqCatEx
							SELECT N'Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date, @ESalePrice - @EmpQty* @CSalePriceL, @ESalePriceCvr - @EmpQty* @CSalePriceL/@ReqRate
					ELSE
						-- Employee
							IF @CatEmpQty <> @EmpQty 
							BEGIN
								IF @CatEmpQty - @EmpQty > 0
									INSERT INTO @ReqCatEx	
										SELECT N'Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @ESPrice, @CatEmpQty - @EmpQty * @ESPriceCvr
								ELSE IF @CatEmpQty - @EmpQty < 0
									INSERT INTO @ReqCatEx
										SELECT N'Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  @CatEmpQty - @EmpQty * @CSalePriceL, @CatEmpQty - @EmpQty * @CSalePriceL/@ReqRate
							END
				END	
			END
			ELSE
				IF EXISTS (SELECT 1 FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealEger') 
				BEGIN
					SELECT @RestInfID = RestaurantInfID, @MealTypeID = MealTypeID, @EmpQty = EmployeeQty, @CSalePriceL = SalePriceL, @CateringTypeID = CateringTypeID
						FROM tlReqCatering WHERE RequestRecID = @RequestRecID AND @Date BETWEEN FromDate AND ToDate AND MealTypeID = 'mealEger'
					INSERT INTO @ReqCatEx
						SELECT N'Ажилтан хоолны үнийн зөрүү', 'Employees catering prices', @Date,  0 - @EmpQty * @CSalePriceL, 0 - @EmpQty * @CSalePriceL/@ReqRate
				END

		END
		FETCH NEXT FROM ReqCat INTO @CatEmpQty, @AccInfID, @CatTypeID, @CRestInfID, @B, @L, @D, @E, @Date, @BSPrice, @BSPriceCvr, @BSalePrice, @BSalePriceCvr, @LSPrice, @LSPriceCvr, @LSalePrice, @LSalePriceCvr, @DSPrice, @DSPriceCvr, @DSalePrice, @DSalePriceCvr, @ESPrice, @ESPriceCvr, @ESalePrice, @ESalePriceCvr 
	END
	CLOSE ReqCat
	DEALLOCATE ReqCat
*/
	SELECT * FROM @StaffAccEx
--	SELECT * FROM @TourStaffEx
--	SELECT * FROM @ReqCatEx
--
--	SELECT 'Accomodation', DescF, SUM(SalePrice) AS SalePrice, SUM(SalePriceFcy) AS SalePriceFcy 
--		FROM @StaffAccEx 		
--		GROUP BY DescF
--	
--	--UNION
--	SELECT 'Staffs',  DescF, SUM(SalePrice) AS SalePrice, SUM(SalePriceFcy) AS SalePriceFcy 
--		FROM @TourStaffEx 		
--		GROUP BY DescF
--	--UNION 
--	SELECT 'Catering', DescF, SUM(SalePrice) AS SalePrice, SUM(SalePriceFcy) AS SalePriceFcy 
--		FROM @ReqCatEx		
--		GROUP BY DescF
--	UNION 
-- Summary
/*
	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
		FROM @AccExpense
		GROUP BY DescF
	UNION
	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
		FROM @CatExpense
		GROUP BY DescF
	UNION
	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
	 	FROM @EnterTain
		GROUP BY DescF
	UNION
	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
		FROM @Flight
		GROUP BY DescF
	UNION
	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
		FROM @Train
		GROUP BY DescF
	UNION 
	SELECT 'Total', SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
		FROM (	SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
					FROM @AccExpense
					GROUP BY DescF
				UNION
				SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
					FROM @CatExpense
					GROUP BY DescF
				UNION
				SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
	 				FROM @EnterTain
					GROUP BY DescF
				UNION
				SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
					FROM @Flight
					GROUP BY DescF
				UNION
				SELECT DescF, SUM(SalePrice) SalePrice, SUM(SalePriceFcy) SalePriceFcy
					FROM @Train
					GROUP BY DescF	
				UNION
				SELECT DescF, SUM(SalePrice), SUM(SalePriceFcy) 
					FROM @StaffAccEx
					GROUP BY DescF
				UNION
				SELECT DescF, SUM(SalePrice), SUM(SalePriceFcy) 
					FROM @TourStaffEx
					GROUP BY DescF	
				UNION 
				SELECT DescF, SUM(SalePrice), SUM(SalePriceFcy) 
					FROM @ReqCatEx
					GROUP BY DescF	
		) AS B 
*/
END
GO
RPT_PerPaxExtraPrice 'Y', 2007070300006, 2007070500089

--RPT_PerPaxExtraPrice 'Y', 2007070300005, 2007070300017
	
/*

	

	SELECT * FROM tlReqCatering WHERE RequestRecID = 2007062500079 AND '2007/07/03' BETWEEN FromDate AND ToDate AND CateringTypeID = 'caterRestaurant'

	SELECT COUNT(GuestRecID) EmpQty, AccomodationInfID, CateringTypeID, RestaurantInfID, BreakFast, Lunch, Dinner, Eger, Date, BSalePrice, BSalePriceCvr, SUM(BSalePrice), SUM(BSalePriceCvr), SUM(LSalePrice), SUM(LSalePriceCvr), SUM(DSalePrice), SUM(DSalePriceCvr), SUM(ESalePrice), SUM(ESalePriceCvr) 
		FROM tlTourCatering 
		WHERE TourRecID = 2007070300006 AND IsPax = 'N'
		GROUP BY AccomodationInfID, CateringTypeID, RestaurantInfID, BreakFast, Lunch, Dinner, Eger, Date, BSalePrice, BSalePriceCvr		


-- TourStaffs
	SELECT Date, COUNT(EmployeeInfID) AS Qty, PositionInfID, ISNULL(LevelID, 'N'), SUM(ISNULL(SalePrice, 0)), SUM(ISNULL(SalePriceCvr, 0))
			FROM tlTourStaffs
			WHERE TourRecID = 2007070300006
			GROUP BY Date, LevelID, PositionInfID

	SELECT * FROM tlTourStaffs
		WHERE TourRecID = 2007070300006

	SELECT * FROM tlReqEmployees
		WHERE RequestRecID = 2007062500079
	
	SELECT * FROM tlAccomodationsPrices

	SELECT * FROM tlTours
		where tourrecid = 2007070300006

	SELECT * FROM View_AccomodationType

	SELECT * FROM tlTours
		WHERE TourRecID = 2007070300006 

	SELECT * FROM tlTourStaffs
		WHERE TourRecID = 2007070200001

	SELECT AccomodationInfID, AccomodationTypeID, SalePrice, SalePriceFcy, Count(GuestRecID) AS EmpQty, Min(Date) as Mindate, Max(Date) as Mindate
		FROM tlTourAccomodations
		WHERE TourRecID = 2007070300006 AND IsPax = 'N'
		GROUP BY AccomodationInfID, AccomodationTypeID, SalePrice, SalePriceFcy

	SELECT * FROM tlTourAccomodations
		WHERE TourRecID = 2007070300006

	SELECT * FROM tlReqAccomodation 
		WHERE RequestRecID IN (SELECT RequestRecID FROM tlTours
									WHERE TourRecID = 2007070300006 )


	UPDATE tlTourAccomodations SET IsPax = 'N'
		WHERE TourAccRecID IN (2007070700113, 2007070700114)

-- TRAIN

	SELECT * FROM tl

	SELECT * FROM tlTourTrains
	SELECT * FROM tlReqTrains
	

-- ACCOMODATIONS

	SELECT * FROM tlReqAccomodation 
		WHERE RequestRecID = 2007062500075 AND '2007/06/29' BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111)

	SELECT * FROM tlTours
		WHERE RequestRecID = 2007062500084
 
	SELECT * FROM tlReqAccomodation
		WHERE RequestRecID = 2007062500084 

	SELECT * FROM tlTourAccomodations
		WHERE TourRecID = 2007070300005
			 AND GuestRecID = 2007070300017 AND IsPax = 'Y' 

	SELECT * FROM tlTourCater

-- ENTERTAINS

	SELECT EnterTainmentTypeID, COUNT(EnterTainmentTypeID), SUM(SalePrice), SUM(SalePriceCvr)
		FROM tlTourEntertain
		WHERE TourRecID = 2007070200001 AND GuestRecID = 2007070200001 AND IsPax = 'Y'
	GROUP BY EnterTainmentTypeID

	SELECT * FROM tlTourEntertain
		WHERE TourRecID = 2007070200001 AND GuestRecID = 2007070200001 AND IsPax = 'Y'

	SELECT * FROM tlReqEntertainments
		WHERE RequestRecID = 2007062500075

-- TOURS
	SELECT * FROM tlTours
		WHERE TourRecID = 2007070300005

	SELECT * FROM tlReqCatering 
		WHERE RequestRecID = 2007062500075 AND '2007/07/26' BETWEEN FromDate AND ToDate

-- FLIGHTS

	SELECT * FROM tlTourFlights
		WHERE TourRecID = 2007070300005

	SELECT * FROM tlReqFlights
		WHERE RequestRecID = 2007062500084


*/