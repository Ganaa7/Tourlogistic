USE TourLogistic
GO
/****** Object:  Table tlRequest    Script Date: 03/07/2007 18:26:54 ******/
--DROP TABLE tlRequest
GO
CREATE TABLE tlRequest(
	RequestRecID		pkType,
	RequestID			idType,
	LeaderPaxRecID		pkType,
	ReqName			    descType,
	ReqTypeInfID	    pkType,
	PaxQty				SMALLINT,
	EmployeeQty			SMALLINT,
	StartDate			dateType,
	EndDate				dateType,
	Days				SMALLINT,
	TotalDistance		INT,
	RemarkL				NVARCHAR(1000),
	RemarkF				NVARCHAR(1000),
	RemarkD				NVARCHAR(1000),
	RequestDate			dateType,			-- request gargasan date
	ActionDoneBy		idType,
	ActionDate			dateType,
 CONSTRAINT tlRequest_PK PRIMARY KEY(RequestRecID) 
)
GO
CREATE INDEX Request_Idx2 ON tlRequest(RequestID)
CREATE INDEX Request_Idx3 ON tlRequest(LeaderPaxRecID)
CREATE INDEX Request_Idx4 ON tlRequest(ReqTypeInfID)
CREATE INDEX Request_Idx5 ON tlRequest(StartDate)
CREATE INDEX Request_Idx6 ON tlRequest(EndDate)
GO
----
--
----
--DROP TABLE tlReqPoints
GO
CREATE TABLE tlReqPoints(
	RowRecID			pkType,
	RequestRecID		pkType,
	PointRecID	        pkType,
	PointNum			SMALLINT,
	ArriveDate			dateType,
	DepartDate			dateType,
	TransportTypeID		idType,
	LeaveWithGuide		CHAR(1),
	CONSTRAINT tlReqPoint_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqPoint_FK FOREIGN KEY(RequestRecID) 
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT tlReqPoint_FK2 FOREIGN KEY(PointRecID) 
		REFERENCES tlPointRegistrations(PointRegisterRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqPoint_Idx1 ON tlReqPoints(ArriveDate)
CREATE INDEX tlReqPoint_Idx2 ON tlReqPoints(DepartDate)
CREATE INDEX tlReqPoint_Idx3 ON tlReqPoints(TransportTypeID)
GO
----
----
-- 
----
--DROP TABLE tlReqFlights
CREATE TABLE tlReqFlights(
	RowRecID			pkType,
	RequestRecID		pkType,
	FlightRecID			pkType,
	FlightDate			dateType,
	CurrencyIDL			idType,
	CurrencyIDF			idType,
	PaxQty				SMALLINT,
	EmployeeQty			SMALLINT,
	SalePriceL			amountType,
	SalePriceF			amountType,
	SaleAmountL			amountType,
	SaleAmountF			amountType,
	ActionDoneBy		idType,
	ActionDate			dateType,				
 CONSTRAINT tlReqFlights_PK PRIMARY KEY(RowRecID), 
 CONSTRAINT tlReqFlights_FK FOREIGN KEY(RequestRecID) 
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqFlights_Idx1 ON tlReqFlights(FlightRecID)
CREATE INDEX tlReqFlights_Idx2 ON tlReqFlights(FlightDate)
----
-- 
----
-- DROP TABLE tlReqTrains
GO
CREATE TABLE tlReqTrains(
	RowRecID			    pkType,
	RequestRecID			pkType,
	TrainRecID				pkType,
	TrainDate				dateType,
	CurrencyIDL				idType,
	CurrencyIDF				idType,
	PaxQty					SMALLINT,
	EmployeeQty				SMALLINT,
	SalePriceL				amountType,
	SalePriceF				amountType,
	SaleAmountL				amountType,
	SaleAmountF				amountType,
	ActionDoneBy			idType,
	ActionDate				dateType,
 CONSTRAINT tlReqTrains_PK PRIMARY KEY(RowRecID),
 CONSTRAINT tlReqTrains_FK FOREIGN KEY(RequestRecID) 
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT tlReqPoint_FK2 FOREIGN KEY(PointRecID) 
	REFERENCES tlPointRegistrations(PointRegisterRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqTrains_Idx1 ON tlReqTrains(TrainRecID)
CREATE INDEX tlReqTrains_Idx2 ON tlReqTrains(TrainDate)

----
-- 4.
----
--DROP TABLE tlReqVehicles
GO
CREATE TABLE tlReqVehicles(
	ReqVehicleRecID			pkType,
	RequestRecID			pkType,
	TransportInfID			pkType,
	RouteRecID				pkType,
	RentType				descType,
	RentPrice				amountType,
	Days					SMALLINT,
	FromDate				dateType,
	ToDate					dateType,
	WithPax					CHAR(1),
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlReqVehicles_PK PRIMARY KEY(ReqVehicleRecID),
	CONSTRAINT tlReqVehicles_FK FOREIGN KEY(RequestRecID) 
			REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqVehicles_Idx1 ON tlReqVehicles(TransportInfID)
CREATE INDEX tlReqVehicles_Idx2 ON tlReqVehicles(FromDate)
CREATE INDEX tlReqVehicles_Idx3 ON tlReqVehicles(ToDate)
CREATE INDEX tlReqVehicles_Idx4 ON tlReqVehicles(RouteRecID)

----
-- 4.
----
--DROP TABLE tlReqAnimals
GO
CREATE TABLE tlReqAnimals(
	RowRecID				pkType,
	RequestRecID			pkType,
	TransportInfID			pkType,
	RouteRecID				pkType,
	EmployeeQty				SMALLINT,
	PaxQty					SMALLINT,
	RentType				descType,
	RentPrice				amountType,
	RentAmount				amountType,
	CurrencyIDL				idType,
	FromDate				dateType,
	ToDate					dateType,
	Days					SMALLINT,	
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlReqAnimals_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqAnimals_FK FOREIGN KEY(RequestRecID) 
			REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqAnimals_Idx1 ON tlReqAnimals(TransportInfID)
CREATE INDEX tlReqAnimals_Idx2 ON tlReqAnimals(FromDate)
CREATE INDEX tlReqAnimals_Idx3 ON tlReqAnimals(ToDate)
CREATE INDEX tlReqAnimals_Idx4 ON tlReqAnimals(RouteRecID)

----
--5.
---- 
--DROP TABLE tlReqCatering
GO
CREATE TABLE tlReqCatering(
	RowRecID				pkType,
	RequestRecID			pkType,
	ReqCaterPriceInfID		pkType,
	RestaurantInfID			pkType,
	RestaurantClassInfID	pkType,			-- Restaurant class A, B, C
	CateringTypeID			idType,			-- Restaurant, Ger, Nomads
	MealTypeID				idType,			-- Breakfast, Lunch, Dinner
	FromDate				dateType,		-- date from 
	ToDate					dateType,		-- date to 
	PaxQty					SMALLINT,		-- 
	EmployeeQty				SMALLINT,		-- 
	CurrencyInfIDL			pkType,			-- currency for employees
	CurrencyInfIDF			pkType,			-- currency for pax
	SalePriceL				amountType,		-- price for employees
	SalePriceF				amountType,     -- price for pax
	SaleAmountL				amountType,		-- amount for employees
	SaleAmountF				amountType,		-- amount for pax
	IsCatering				CHAR(1),		-- 
	PriceInfID				pkType,			-- Tuhain Restaurant songoson ued unee avna
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlReqCatering_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqCatering_FK FOREIGN KEY(RequestRecID) 
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlReqCatering_Idx1 ON tlReqCatering(RestaurantClassInfID)
CREATE INDEX tlReqCatering_Idx2 ON tlReqCatering(CateringTypeID)
CREATE INDEX tlReqCatering_Idx3 ON tlReqCatering(MealTypeID)
CREATE INDEX tlReqCatering_Idx4 ON tlReqCatering(IsCatering)

----
--6.
---- 
--DROP TABLE tlReqCateringPrice 
GO
CREATE TABLE tlReqCateringPrice(
	ReqCaterPriceInfID		pkType,
	RestaurantClassInfID    pkType,
	CateringTypeID			idType,
	MealTypeID				idType,
	SalePriceL				amountType,		-- price for employees
	SalePriceF				amountType,     -- price for pax	
	CurrencyInfIDL			pkType,			-- currency for employees
	CurrencyInfIDF			pkType,			-- currency for pax	
	ActionDoneBy				idType,
	ActionDate					dateType,
	CONSTRAINT tlReqCateringPrice_PK PRIMARY KEY(ReqCaterPriceInfID)
)
GO 
CREATE INDEX tlReqCateringPrice_Idx1 ON tlReqCateringPrice(CateringTypeID)
CREATE INDEX tlReqCateringPrice_Idx2 ON tlReqCateringPrice(MealTypeID)

-- Restaurant A class meal prices
INSERT INTO tlReqCateringPrice VALUES(1, 'cater1', 'mealBreakfast', 2000, 5,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(2, 'cater1', 'mealLunch',		6000, 12,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(3, 'cater1', 'mealDinner',	9000, 25,	2005060700002, 2005060700001)
-- Restaurant B class meal prices
INSERT INTO tlReqCateringPrice VALUES(4, 'cater2', 'mealBreakfast', 1600, 3,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(5, 'cater2', 'mealLunch',		4000, 10,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(6, 'cater2', 'mealDinner',	7000, 18,	2005060700002, 2005060700001)
-- Restaurant C class meal prices
INSERT INTO tlReqCateringPrice VALUES(7, 'cater3', 'mealBreakfast', 1200, 2,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(8, 'cater3', 'mealLunch',		3000, 8,	2005060700002, 2005060700001)
INSERT INTO tlReqCateringPrice VALUES(9, 'cater3', 'mealDinner',	5000, 10,	2005060700002, 2005060700001)
GO
-----
-- 6.
----
----
--DROP TABLE tlReqAccomodation
GO
CREATE TABLE tlReqAccomodation(
	RowRecID					pkType,
	RequestRecID				pkType,
	ReqAccPriceRecID			pkType,
	AccomodationTypeID			idType,
	AccomodationProductInfID	pkType,
	AccomodationInfID			pkType,
	AccProductPriceInfID		pkType,
	LevelID						idType,
	PaxQty						SMALLINT,
	EmployeeQty					SMALLINT,
	ProductQty					SMALLINT,
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
	ActionDate					dateType,
	CONSTRAINT tlReqAccomodation_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqAccomodation_FK FOREIGN KEY(RequestRecID) 
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlReqAccomodation_Idx1 ON tlReqAccomodation(ReqAccPriceRecID)
	CREATE INDEX tlReqAccomodation_Idx2 ON tlReqAccomodation(AccomodationTypeID)
	CREATE INDEX tlReqAccomodation_Idx3 ON tlReqAccomodation(AccomodationProductInfID)
	CREATE INDEX tlReqAccomodation_Idx4 ON tlReqAccomodation(AccomodationInfID)
	CREATE INDEX tlReqAccomodation_Idx5 ON tlReqAccomodation(AccProductPriceInfID)
GO

--DROP TABLE tlReqAccomodationPrices
GO
CREATE TABLE tlReqAccomodationPrices(
	RecAccPriceInfID		    pkType,
	AccomodationTypeID			idType,
	LevelID						idType,
	AccProductTypeInfID			pkType,
	SalesPriceL					amountType,
	SalesPriceF					amountType,	
	CurrencyInfIDL				pkType,
	CurrencyInfIDF				pkType,
	ActionDoneBy				idType,
	ActionDate					dateType,
	CONSTRAINT tlReqAccomodationPrices_PK PRIMARY KEY(RecAccPriceInfID)
)
GO
	CREATE INDEX tlReqAccomodationPrices_idx1 ON tlReqAccomodationPrices(AccProductPriceInfID)
	CREATE INDEX tlReqAccomodationPrices_idx2 ON tlReqAccomodationPrices(AccomodationTypeID)
	CREATE INDEX tlReqAccomodationPrices_idx3 ON tlReqAccomodationPrices(LevelID)
	CREATE INDEX tlReqAccomodationPrices_idx4 ON tlReqAccomodationPrices(AccProductInfID)
----
-- uusgeh
----
--DROP TABLE tlReqEntertainments
GO
CREATE TABLE tlReqEntertainments(
	RowRecID					pkType,
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
	ActionDate					dateType,
	CONSTRAINT tlReqEntertainment_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqEntertainment_FK FOREIGN KEY(RequestRecID)
		REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlReqEntertainment_idx1 ON tlReqEntertainments(EnterTainmentTypeID)
	CREATE INDEX tlReqEntertainment_idx2 ON tlReqEntertainments(ReqEnterPriceRecID)
	CREATE INDEX tlReqEntertainment_idx3 ON tlReqEntertainments(ServiceID)
GO

-----
--
-----
--DROP TABLE tlReqEnterPrices
GO
CREATE TABLE tlReqEnterPrices(
	ReqEnterPriceInfID			pkType,
	EntertainmentTypeID			idType,
	CurrencyInfIDL				pkType,
	CurrencyInfIDF				pkType,
	SalePriceL					amountType,
	SalePriceF					amountType,
	ActionDoneBy				idType,
	ActionDate					dateType,	
	CONSTRAINT ReqEnterPrices_PK PRIMARY KEY(ReqEnterPriceInfID)
)
GO
	CREATE INDEX tlReqEntertainment_idx1 ON tlReqEnterPrices(EntertainmentTypeID)
----
--
----
GO
--DROP TABLE tlReqOthers
GO
CREATE TABLE tlReqOthers(
	RowRecID				pkType,
	RequestRecID			pkType,
	OtherExpenseInfID		pkType,
	Qty						SMALLINT,
	CurrencyInfID			pkType,
	SalePrice				amountType,
	SaleAmount				amountType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlReqOthers_PK PRIMARY KEY(RowRecID),
	CONSTRAINT tlReqOthers_FK FOREIGN KEY(RequestRecID) REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlReqOthers_idx1 ON tlReqOthers(OtherExpenseInfID)
----
--
----	
--DROP TABLE tlReqEmployees
GO
CREATE TABLE tlReqEmployees(
	ReqEmployeesRecID		pkType,
	RequestRecID			pkType,
	EmpPositionTypeInfID	pkType,
	EmployeeQty				SMALLINT,
	LevelID					idType,
	FromDate				dateType,
	ToDate					dateType,
	CurrencyInfID			pkType,
	SalePrice				amountType,
	SaleAmount				amountType
    CONSTRAINT tlReqEmployees_PK PRIMARY KEY(ReqEmployeesRecID), 
    CONSTRAINT tlReqEmployees_FK FOREIGN KEY(RequestRecID) REFERENCES tlRequest(RequestRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlReqEmployees_idx1 ON tlReqEmployees(ReqEmployeesRecID)
	CREATE INDEX tlReqEmployees_idx2 ON tlReqEmployees(EmpPositionTypeInfID)
	CREATE INDEX tlReqEmployees_idx3 ON tlReqEmployees(LevelID)
	CREATE INDEX tlReqEmployees_idx4 ON tlReqEmployees(FromDate)
	CREATE INDEX tlReqEmployees_idx5 ON tlReqEmployees(ToDate)
----
--
----
--DROP TABLE tlReqEmployeesPrices
GO
CREATE TABLE tlReqEmployeesPrices(
	ReqEmployeesInfID		pkType,
	EmpPositionTypeInfID	pkType,
	LevelID					idType,
	CurrencyInfID			pkType,
	SalePrice				amountType,
	ActionDoneBy				idType,
	ActionDate					dateType,
    CONSTRAINT ReqEmployeesRecID PRIMARY KEY(ReqEmployeesInfID) 
)
GO
CREATE INDEX tlReqEmpPrices_idx1 ON tlReqEmployeesPrices(EmpPositionTypeInfID)
CREATE INDEX tlReqEmpPrices_idx2 ON tlReqEmployeesPrices(LevelID)
GO

-- Хөтөч
INSERT INTO tlReqEmployeesPrices VALUES(1, 1987022200006, 'A', 2005060700001, 35 )
INSERT INTO tlReqEmployeesPrices VALUES(1, 1987022200006, 'B', 2005060700001, 30 )
INSERT INTO tlReqEmployeesPrices VALUES(1, 1987022200006, 'C', 2005060700001, 25 )
GO

/*
 --CONSTRAINT tlReqCatering_FK2 FOREIGN KEY(RestaurantServicePriceInfID) REFERENCES tlRestaurantServicePrices (RestaurantServicePriceInfID) ON DELETE CASCADE ON UPDATE CASCADE
	SELECT * FROM tlTourRoutes1
	SELECT * FROM tlRoutes
	SELECT * FROM tlTourPoints
	SELECT * FROM tlPointRegistrations
	SELECT * FROM tlTrains
	SELECT * FROM tlToursEmployees
	SELECT * FROM VIEW_ssMealType
	SELECT * FROM VIEW_ssCurrencies
	SELECT * FROM tlRoutes
*/

-- DROP PROC TL_SEL_RequestPrices


select * from tlAccomodationsProductTypes