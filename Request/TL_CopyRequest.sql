USE TourLogistic
GO
DROP PROC TL_CopyRequest
GO
/*****
	1. copy avah tmp table-diiig uusgene.
	2. Tuhain tmp -d deer pkID-geer update hiine.
	3. tmp - dee undsen table ruu insert hiine.
******/
CREATE PROC TL_CopyRequest(
	@RequestRecID		pkType,
	@ActionDoneBy		idType
)
AS
BEGIN

	DECLARE @ReqRecID			pkType,
			@PointRecID			pkType,
			@FlightRecID		pkType,
			@TrainRecID			pkType,
			@VehicleRecID		pkType,
			@CityVehicleRecID	pkType,
			@ReqAnimalRecID		pkType,
			@ReqCaterRecID		pkType,
			@ReqAccRecID		pkType,
			@ReqEnterRecID		pkType,
			@OtherRecID			pkType,
			@EmpRecID			pkType,
			@Req				BIT,
			@Pnt				BIT,
			@Flt				BIT,
			@Trn				BIT,
			@Veh				bit,
			@Cve				bit,
			@SQL				NVARCHAR(2000),
			@SqlFlight			NVARCHAR(2000),		
			@SqlTrain			NVARCHAR(2000),
			@SqlVehicles		NVARCHAR(2000),
			@SqlCityVehicles	NVARCHAR(2000),
			@SqlAnimals			NVARCHAR(2000),
			@SqlCatering		NVARCHAR(2000),
			@SqlAccomodation	NVARCHAR(2000),
			@SqlEntertainments	NVARCHAR(2000),
			@SqlOthers			NVARCHAR(2000),
			@SqlEmployees		NVARCHAR(2000)


	DECLARE @tmpRequest TABLE(
			RequestRecID	pkType,
			RequestID		idType, 
			LeaderPaxRecID	pkType,
			ReqName			descType,
			ReqTypeInfID	pkType,
			PaxQty			SMALLINT,
			EmployeeQty		SMALLINT,
			StartDate		dateType,
			EndDate			dateType,
			Days			SMALLINT,
			TotalDistance	SMALLINT,
			RemarkL			NVARCHAR(2000),
			RemarkF			NVARCHAR(2000),
			RemarkD			NVARCHAR(2000),
			RequestDate		dateType,
			ActionDoneBy	idType,
			ActionDate		dateType,
			LevelID			idType,
			CustomerInfID	pkType,
			CustomerDescF	descType
)
	
	SET NOCOUNT ON

	EXEC CreatePkID 'tlRequest', 'RequestRecID', @ReqRecID OUTPUT
	
	IF EXISTS (SELECT * FROM tlRequest WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpRequest(RequestRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty, StartDate,
				EndDate, Days, TotalDistance, RemarkL, RemarkF, RemarkD, RequestDate, ActionDoneBy, ActionDate, LevelID, CustomerInfID, CustomerDescF)
			SELECT @ReqRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty, StartDate,
					EndDate, Days, TotalDistance, RemarkL, RemarkF, RemarkD, RequestDate, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121), LevelID, CustomerInfID, CustomerDescF 
				FROM tlRequest 
				WHERE RequestRecID = @RequestRecID

		INSERT INTO tlRequest
			SELECT * FROM @tmpRequest
	END

	EXEC CreatePkID 'tlReqPoints', 'RowRecID', @PointRecID OUTPUT
	
	SET @SQL = N'
	DECLARE @tmpReqPoints TABLE(
			RowRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @PointRecID)+', 1),
			RequestRecID		pkType,
			PointRecID	        pkType,
			PointNum			SMALLINT,
			ArriveDate			dateType,
			DepartDate			dateType,
			TransportTypeID		idType,
			LeaveWithGuide		CHAR(1))

	IF EXISTS (SELECT * FROM tlReqPoints WHERE RequestRecID = @RequestRecID)
	BEGIN
		
		INSERT INTO @tmpReqPoints(RequestRecID, PointRecID, PointNum, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide)
			SELECT @ReqRecID, PointRecID, PointNum, ArriveDate, DepartDate, TransportTypeID, LeaveWithGuide			
				FROM tlReqPoints
				WHERE RequestRecID = @RequestRecID

		INSERT INTO tlReqPoints
			SELECT * FROM @tmpReqPoints	
	END'	

	EXEC SP_EXECUTESQL @SQL, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18)', @RequestRecID, @ReqRecID

	EXEC CreatePkID 'tlReqFlights', 'RowRecID', @FlightRecID OUTPUT

	SET @SqlFlight = N'
	DECLARE @tmpReqFlights TABLE(
			RowRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @FlightRecID)+', 1),
			RequestRecID		pkType,
			FlightRecID			pkType,
			FlightDate			dateType,
			PaxQty				SMALLINT,
			EmployeeQty			SMALLINT,
			IsCargo				CHAR(1),
			CurrencyInfIDL		pkType,
			CurrencyInfIDF		pkType,
			SalePriceL			amountType,
			SalePriceF			amountType,
			SaleAmountL			amountType,
			SaleAmountF			amountType,
			ActionDoneBy		idType,
			ActionDate			dateType)

	IF EXISTS (SELECT * FROM tlReqFlights WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpReqFlights(RequestRecID, FlightRecID, FlightDate, PaxQty, EmployeeQty, IsCargo, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL,
				SaleAmountF, ActionDoneBy, ActionDate)
			SELECT @ReqRecID, FlightRecID, FlightDate, PaxQty, EmployeeQty, IsCargo, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL,
					SaleAmountF, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqFlights
				WHERE RequestRecID = @RequestRecID
			
		INSERT INTO tlReqFlights
			SELECT * FROM @tmpReqFlights
	END
	ELSE 
		PRINT ''NOT EXISTS''
	'

	EXEC SP_EXECUTESQL @SqlFlight, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqTrains', 'RowRecID', @TrainRecID OUTPUT

	SET @SqlTrain = N'

	DECLARE @tmpReqTrains TABLE(
			RowRecID			    NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @TrainRecID)+', 1),
			RequestRecID			pkType,
			TrainRecID				pkType,
			TrainDate				dateType,
			PaxQty					SMALLINT,
			EmployeeQty				SMALLINT,
			CurrencyInfIDL			pkType,
			CurrencyInfIDF			pkType,
			SalePriceL				amountType,
			SalePriceF				amountType,
			SaleAmountL				amountType,
			SaleAmountF				amountType,
			ActionDoneBy			idType,
			ActionDate				dateType)			

	IF EXISTS (SELECT * FROM tlReqTrains WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpReqTrains(RequestRecID, TrainRecID, TrainDate, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL, SaleAmountF,
				ActionDoneBy, ActionDate)
			SELECT @ReqRecID, TrainRecID, TrainDate, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL, SaleAmountF,
					@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqTrains
				WHERE RequestRecID = @RequestRecID
		
		INSERT INTO tlReqTrains
			SELECT * FROM @tmpReqTrains

	END
	ELSE 
		PRINT ''NOT EXISTS Request Train''
	'	
	
	EXEC SP_EXECUTESQL @SqlTrain, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	
	EXEC CreatePkID 'tlReqVehicles', 'ReqVehicleRecID', @VehicleRecID OUTPUT
	
	SET @SqlVehicles = N'
	DECLARE @tmpReqVehicles TABLE(
			ReqVehicleRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @VehicleRecID)+', 1),
			RequestRecID			pkType,
			TransportInfID			pkType,
			RouteRecID				pkType,
			RentTypeID				idType,
			CurrencyInfIDL			pkType,
			RentPrice				amountType,
			RentAmount				amountType,
			CarQty					SMALLINT,
			EmployeeQty				SMALLINT,
			PaxQty					SMALLINT,
			Days					SMALLINT,
			FromDate				dateType,
			ToDate					dateType,
			WithPax					CHAR(1),
			ActionDoneBy			idType,
			ActionDate				dateType
		)

	IF EXISTS (SELECT * FROM tlReqVehicles WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpReqVehicles(RequestRecID, TransportInfID, RouteRecID, RentTypeID, CurrencyInfIDL, RentPrice, RentAmount, CarQty, EmployeeQty, PaxQty, Days, FromDate, ToDate,
				WithPax, ActionDoneBy, ActionDate)
			SELECT @ReqRecID, TransportInfID, RouteRecID, RentTypeID, CurrencyInfIDL, RentPrice, RentAmount, CarQty, EmployeeQty, PaxQty, Days, FromDate, ToDate,
					WithPax, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqVehicles
				WHERE RequestRecID = @RequestRecID
	
		INSERT INTO tlReqVehicles
			SELECT * FROM @tmpReqVehicles
	END 
	ELSE 
		PRINT ''NOT EXISTS Request Vehicles''
	'

	EXEC SP_EXECUTESQL @SqlVehicles, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqCityVehicles', 'ReqVehicleRecID', @CityVehicleRecID OUTPUT

	SET @SqlCityVehicles = N'

	DECLARE @tmpReqCityVehicles TABLE(
			ReqVehicleRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @CityVehicleRecID)+', 1),
			RequestRecID			pkType,
			TransportInfID			pkType,
			RouteRecID				pkType,
			RentTypeID				idType,
			CarQty					SMALLINT,
			EmployeeQty				SMALLINT,
			PaxQty					SMALLINT,
			FromDate				dateType,
			ToDate					dateType,
			TimeQty					SMALLINT,
			CurrencyInfIDL			pkType,
			RentPrice				amountType,
			RentPriceAmount			amountType NULL,
			ActionDoneBy			idType,
			ActionDate				dateType
		)
	IF EXISTS (SELECT * FROM tlReqCityVehicles WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpReqCityVehicles(RequestRecID, TransportInfID, RouteRecID, RentTypeID, CarQty, EmployeeQty, PaxQty, FromDate, ToDate, TimeQty, CurrencyInfIDL, RentPrice, RentPriceAmount,
				ActionDoneBy, ActionDate)
			SELECT @ReqRecID, TransportInfID, RouteRecID, RentTypeID, CarQty, EmployeeQty, PaxQty, FromDate, ToDate, TimeQty, CurrencyInfIDL, RentPrice, RentPriceAmount,
					@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqCityVehicles
				WHERE RequestRecID = @RequestRecID
		
		INSERT INTO tlReqCityVehicles
			SELECT * FROM @tmpReqCityVehicles
	END
	ELSE
		PRINT ''Not Exists CityVehicles''
	'

		EXEC SP_EXECUTESQL @SqlCityVehicles, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy
		
		EXEC CreatePkID 'tlReqAnimals', 'ReqAnimalRecID', @ReqAnimalRecID OUTPUT	

	SET @SqlAnimals = N'
		DECLARE @tmpReqAnimals TABLE(
			ReqAnimalRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @ReqAnimalRecID)+', 1),
			RequestRecID			pkType,
			TransportInfID			pkType,
			CarrierTypeID			idType,
			RouteRecID				pkType,
			EmployeeQty				SMALLINT,
			PaxQty					SMALLINT,
			RentTypeID				idType,
			RentPrice				amountType,
			RentAmountL				amountType	NULL,
			RentAmountF				amountType	NULL,
			CurrencyInfIDL			pkType,
			FromDate				dateType,
			ToDate					dateType,
			ActionDoneBy			idType,
			ActionDate				dateType
		)
	
		IF EXISTS (SELECT * FROM tlReqAnimals WHERE RequestRecID = @RequestRecID)
		BEGIN
			INSERT INTO @tmpReqAnimals(RequestRecID, TransportInfID, CarrierTypeID, RouteRecID, EmployeeQty, PaxQty, RentTypeID, RentPrice, RentAmountL, RentAmountF, CurrencyInfIDL, FromDate, ToDate,
					ActionDoneBy, ActionDate)
				SELECT @ReqRecID, TransportInfID, CarrierTypeID, RouteRecID, EmployeeQty, PaxQty, RentTypeID, RentPrice, RentAmountL, RentAmountF, CurrencyInfIDL, FromDate, ToDate,
					@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqAnimals
				WHERE RequestRecID = @RequestRecID
			
			INSERT INTO tlReqAnimals
				SELECT * FROM @tmpReqAnimals
		END
		ELSE
			PRINT ''Not Exists ReqAnimals''
	'
	
	EXEC SP_EXECUTESQL @SqlAnimals, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy


	EXEC CreatePkID 'tlReqCatering', 'ReqCaterRecID', @ReqCaterRecID OUTPUT	
	
	SET @SqlCatering = N'
		DECLARE @tmpReqCatering TABLE(
			ReqCaterRecID			NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @ReqCaterRecID)+', 1),
			RequestRecID			pkType,
			ReqCaterPriceInfID		pkType,
			RestaurantInfID			pkType,
			RestPriceInfID			pkType,
			CateringTypeID			idType,
			MealTypeID				idType,
			FromDate				dateType,
			ToDate					dateType,
			PaxQty					SMALLINT,
			EmployeeQty				SMALLINT,
			CurrencyInfIDL			pkType,
			CurrencyInfIDF			pkType,
			SalePriceL				amountType,
			SalePriceF				amountType,
			SaleAmountL				amountType,
			SaleAmountF				amountType,
			ActionDoneBy			idType,
			ActionDate				dateType,
			RestaurantClassInfID	pkType
		)
		
		IF EXISTS (SELECT * FROM tlReqCatering WHERE RequestRecID = @RequestRecID)
		BEGIN
			INSERT INTO @tmpReqCatering(RequestRecID, ReqCaterPriceInfID, RestaurantInfID, RestPriceInfID, CateringTypeID, MealTypeID, FromDate, ToDate, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF,
					SalePriceL, SalePriceF, SaleAmountL, SaleAmountF, ActionDoneBy, ActionDate, RestaurantClassInfID)	
				SELECT @ReqRecID, ReqCaterPriceInfID, RestaurantInfID, RestPriceInfID, CateringTypeID, MealTypeID, FromDate, ToDate, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF,
						SalePriceL, SalePriceF, SaleAmountL, SaleAmountF, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121), RestaurantClassInfID
					FROM tlReqCatering
					WHERE RequestRecID = @RequestRecID

			INSERT INTO tlReqCatering
				SELECT * FROM @tmpReqCatering
		END
		ELSE
			PRINT ''Not Exists ReqCatering''
		'

	EXEC SP_EXECUTESQL @SqlCatering, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqAccomodation', 'ReqAccRecID', @ReqAccRecID OUTPUT		

	SET @SqlAccomodation = N'
		DECLARE	@tmpReqAccomodation TABLE(
			ReqAccRecID					NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @ReqAccRecID)+', 1),
			RequestRecID				pkType,
			ReqAccPriceRecID			pkType NULL,
			AccomodationTypeID			idType,
			AccProductTypeInfID			pkType,
			AccomodationInfID			pkType NULL,
			AccProductPriceInfID		pkType NULL,
			LevelID						idType,
			PaxQty						SMALLINT,
			EmployeeQty					SMALLINT,
			CheckInDate					dateType,
			CheckOutDate				dateType,
			Days						SMALLINT,
			CurrencyInfIDL				pkType,
			CurrencyInfIDF				pkType,
			ProductSalePriceL			amountType,
			ProductSalePriceF			amountType,
			SaleAmountL					amountType,
			SaleAmountF					amountType,
			ActionDoneBy				idType,
			ActionDate					dateType
		)
	IF EXISTS (SELECT * FROM tlReqAccomodation WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO	@tmpReqAccomodation(RequestRecID, ReqAccPriceRecID, AccomodationTypeID, AccProductTypeInfID, AccomodationInfID, AccProductPriceInfID, LevelID, PaxQty, EmployeeQty, CheckInDate, CheckOutDate,
				Days, CurrencyInfIDL, CurrencyInfIDF, ProductSalePriceL, ProductSalePriceF, SaleAmountL, SaleAmountF, ActionDoneBy, ActionDate)
			SELECT @ReqRecID, ReqAccPriceRecID, AccomodationTypeID, AccProductTypeInfID, AccomodationInfID, AccProductPriceInfID, LevelID, PaxQty, EmployeeQty, CheckInDate, CheckOutDate,
					Days, CurrencyInfIDL, CurrencyInfIDF, ProductSalePriceL, ProductSalePriceF, SaleAmountL, SaleAmountF, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqAccomodation
				WHERE RequestRecID = @RequestRecID
			
		INSERT INTO tlReqAccomodation
			SELECT * FROM @tmpReqAccomodation
	END
	ELSE
		PRINT ''Not Exists tlReqAccomodation''
	'

	EXEC SP_EXECUTESQL @SqlAccomodation, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqEntertainments', 'EnterRecID', @ReqEnterRecID OUTPUT	
	
	SET @SqlEntertainments = N'
		DECLARE @tmpReqEntertainments TABLE(
			EnterRecID					NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @ReqEnterRecID)+', 1),
			RequestRecID				pkType,
			EnterTainmentTypeID			idType,
			ReqEnterPriceRecID			pkType,
			PaxQty						SMALLINT,
			EmployeeQty					SMALLINT,
			CurrencyInfIDL				pkType,
			CurrencyInfIDF				pkType,
			SalePriceL					amountType,
			SalePriceF					amountType,
			SaleAmountL					amountType,
			SaleAmountF					amountType,
			ActionDoneBy				idType,
			ActionDate					dateType
		)
	
	IF EXISTS (SELECT * FROM tlReqEntertainments WHERE RequestRecID = @RequestRecID)
	BEGIN
		INSERT INTO @tmpReqEntertainments(RequestRecID, EnterTainmentTypeID, ReqEnterPriceRecID, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL, SaleAmountF,
				ActionDoneBy, ActionDate)
			SELECT @ReqRecID, EnterTainmentTypeID, ReqEnterPriceRecID, PaxQty, EmployeeQty, CurrencyInfIDL, CurrencyInfIDF, SalePriceL, SalePriceF, SaleAmountL, SaleAmountF,
					@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
				FROM tlReqEntertainments
				WHERE RequestRecID = @RequestRecID
			
		INSERT INTO tlReqEntertainments
			SELECT * FROM @tmpReqEntertainments
	END
	ELSE
		PRINT ''Not Exists tlReqEntertainments''
	'	

	EXEC SP_EXECUTESQL @SqlEntertainments, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqOthers', 'OtherRecID', @OtherRecID OUTPUT	

	SET @SqlOthers = N'
		DECLARE @tmpReqOthers TABLE(
			OtherRecID				NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @OtherRecID)+', 1),
			RequestRecID			pkType,
			OtherExpenseInfID		pkType,
			Qty						SMALLINT,
			CurrencyInfIDL			pkType,
			SalePrice				amountType,
			SaleAmount				amountType,
			ActionDoneBy			idType,
			ActionDate				dateType
		)
		IF EXISTS (SELECT * FROM tlReqOthers WHERE RequestRecID = @RequestRecID)
		BEGIN
			INSERT INTO @tmpReqOthers(RequestRecID, OtherExpenseInfID, Qty, CurrencyInfIDL, SalePrice, SaleAmount, ActionDoneBy, ActionDate)
				SELECT @ReqRecID, OtherExpenseInfID, Qty, CurrencyInfIDL, SalePrice, SaleAmount, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
					FROM tlReqOthers 
					WHERE RequestRecID = @RequestRecID
			
			INSERT INTO tlReqOthers 
				SELECT * FROM @tmpReqOthers
		END 
		ELSE
			PRINT ''Not Exists tlReqOthers''
	'
	EXEC SP_EXECUTESQL @SqlOthers, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy

	EXEC CreatePkID 'tlReqEmployees', 'ReqEmployeesRecID', @EmpRecID OUTPUT	

	SET @SqlEmployees = N'

		DECLARE @tmpReqEmployees TABLE(
			ReqEmployeesRecID		NUMERIC(18) IDENTITY('+CONVERT(VARCHAR(30), @EmpRecID)+', 1),
			RequestRecID			pkType,
			PositionInfID			pkType,
			EmployeeQty				SMALLINT,
			LevelID					idType,
			FromDate				dateType,
			ToDate					dateType,
			CurrencyInfIDL			pkType,
			SalePrice				amountType,
			SaleAmount				amountType,
			ActionDoneBy			idType,
			ActionDate				dateType
		)

		IF EXISTS (SELECT * FROM tlReqEmployees WHERE RequestRecID = @RequestRecID)
		BEGIN
			INSERT INTO @tmpReqEmployees(RequestRecID, PositionInfID, EmployeeQty, LevelID, FromDate, ToDate, CurrencyInfIDL, SalePrice, SaleAmount, ActionDoneBy, ActionDate)
				SELECT @ReqRecID, PositionInfID, EmployeeQty, LevelID, FromDate, ToDate, CurrencyInfIDL, SalePrice, SaleAmount, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
					FROM tlReqEmployees 
					WHERE RequestRecID = @RequestRecID
			
			INSERT INTO tlReqEmployees 
				SELECT * FROM @tmpReqEmployees
		END
		ELSE
			PRINT ''Not Exists tlReqOthers''
		'
		
		EXEC SP_EXECUTESQL @SqlEmployees, N'@RequestRecID NUMERIC(18), @ReqRecID NUMERIC(18), @ActionDoneBy NVARCHAR(30)', @RequestRecID, @ReqRecID, @ActionDoneBy
	
END
GO 
TL_CopyRequest 1987030900004, 'Bold' 
/*
	exec sp_help tlReqEntertainments
	
	exec sp_help tlReqCatering

	SELECT * FROM tlRequest
	
	SELECT * FROM tlReqPoints

	SELECT * FROM tlReqFlights
	
	SELECT * FROM tlReqTrains 

	SELECT * FROM tlReqVehicles 

	SELECT * FROM tlReqCityVehicles

	SELECT * FROM tlReqAnimals

	SELECT * FROM tlReqCatering

	SELECT * FROM tlReqAccomodation 
	
	SELECT * FROM tlReqEntertainments	

	SELECT * FROM tlReqOthers

	SELECT * FROM tlReqEmployees 


	delete from tlReqOthers
		where actionDate = '2007-03-22 18:42:05.153'

	
	SELECT * FROM tlReqAccomodationPrices
*/