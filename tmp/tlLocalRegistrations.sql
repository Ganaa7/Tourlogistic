USE TourLogistic
GO

--DROP TABLE tlPointRegistrations
GO
CREATE TABLE tlPointRegistrations(
	PointRegisterID			pkType IDENTITY(1,1) PRIMARY KEY,			
	PointNameL				descType,
	PointNameF				descType,
	PointNameD				descType,
	IsAirport				CHAR(1) DEFAULT('N'),
	IsTrainStation			CHAR(1) DEFAULT('N'),
	IsAccomodation			CHAR(1) DEFAULT('N'),
	IsTourPoint				CHAR(1) DEFAULT('N'),
	IsFuelStation			CHAR(1) DEFAULT('N'),
	ProvinceID				idType FOREIGN KEY REFERENCES tlProvinces(CodeID) ON UPDATE CASCADE,
	PointTypeID				pkType FOREIGN KEY REFERENCES tlPointTypes(PointTypeID) ON UPDATE CASCADE,
	CoordinateX				INT,
	CoordinateY				INT,
	GPSCoordinateX			VARCHAR(30),
	GPSCoordinateY			VARCHAR(30),
	PointNoteL				NVARCHAR(256),
	PointNoteF				NVARCHAR(256),
	PointNoteD				NVARCHAR(256),
	ActionDoneBy			idType,
	ActionDate				dateType)
GO

--DROP TABLE tlRoutes
GO
CREATE TABLE tlRoutes(
	RouteID					pkType IDENTITY(1,1) PRIMARY KEY,
	RouteNameL				descType,
	RouteNameF				descType,
	RouteNameD				descType,
	PointDA					pkType FOREIGN KEY REFERENCES tlPointRegistrations(PointRegisterID) ON UPDATE CASCADE ON DELETE CASCADE,
	PointDB					pkType FOREIGN KEY REFERENCES tlPointRegistrations(PointRegisterID),
	Distance				INT DEFAULT(0),
	IsAeroRoute				CHAR(1) DEFAULT('N'),
	IsRailway				CHAR(1) DEFAULT('N'),
	IsAsphaltRoad			CHAR(1) DEFAULT('N'),
	IsLocalityRoad			CHAR(1) DEFAULT('N'),
	IsNoneRoad				CHAR(1) DEFAULT('N'),
	IsWateryRoad			CHAR(1) DEFAULT('N'),
	RouteNoteL				NVARCHAR(256),
	RouteNoteF				NVARCHAR(256),
	RouteNoteD				NVARCHAR(256))
GO

-- DROP TABLE tlRouteTimes
CREATE TABLE tlRouteTimes(
	RouteID				pkType,
	TransportInfID		pkType,
	TimeConsumption		INT)
GO

-- DROP TABLE tlTours
CREATE TABLE tlTours(
	TourInfID			pkType IDENTITY(1,1) PRIMARY KEY,
	TourID				NVARCHAR(30),
	TourNameL			descType,
	TourNameF			descType,
	TourNameD			descType,
	TourTypeID			NVARCHAR(30) FOREIGN KEY REFERENCES tlTourTypes(CodeID) ON UPDATE CASCADE ON DELETE CASCADE,
	TourLevelID			NVARCHAR(30),
	QtyPax				INT,
	StartDate			VARCHAR(23),
	EndDate				VARCHAR(23),
	Days				INT,--
	TourStatus			NVARCHAR(50),
	RemarkL				NVARCHAR(256),
	RemarkF				NVARCHAR(256),
	RemarkD				NVARCHAR(256),
	TotalDistance		INT)
GO

-- DROP TABLE tlTourPoints
CREATE TABLE tlTourPoints(
	TourInfID			pkType FOREIGN KEY REFERENCES tlTours(TourInfID) ON UPDATE CASCADE ON DELETE CASCADE,
	PointRegisterID		pkType FOREIGN KEY REFERENCES tlPointRegistrations(PointRegisterID) ON UPDATE CASCADE ON DELETE CASCADE,
	PointNum			INT,
	DeptDate			VARCHAR(23),
	ArriveDate			VARCHAR(23),
	ProgramID			idType)
GO

-- DROP TABLE tlDriverVehicles
CREATE TABLE tlDriverVehicles(
	DriverVehicleID		pkType IDENTITY(1,1) PRIMARY KEY,
	TransportInfID		pkType FOREIGN KEY REFERENCES tlTransports(TransportInfID) ON UPDATE CASCADE ON DELETE CASCADE,
	CarNumber			NVARCHAR(30),
	DriverID			NVARCHAR(30),
	IsRent				CHAR(1) )
GO


-- DROP TABLE tlToursEmployees
CREATE TABLE tlToursEmployees(
	ToursEmployeeID		pkType IDENTITY(1,1) PRIMARY KEY,
	TourInfID				pkType FOREIGN KEY REFERENCES tlTours(TourInfID) ON UPDATE CASCADE ON DELETE CASCADE,
	FromDate				VARCHAR(23),
	ToDate					VARCHAR(23),
	Days					INT,
	EmployeeID				idType	FOREIGN KEY REFERENCES tlEmployees(EmployeeID),
	PositionTypeID			idType 	FOREIGN KEY REFERENCES tlPositionTypes(CodeID))
GO

-- DROP TABLE tlPaxsTours
CREATE TABLE tlPaxsTours(
	PaxInfID		pkType FOREIGN KEY REFERENCES tlPaxs(PaxInfID),
	TourInfID		pkType FOREIGN KEY REFERENCES tlTours(TourInfID) )
GO

-- DROP TABLE tlTourRouteTransports
CREATE TABLE tlTourRouteTransports(
	TourRouteTransportID	pkType IDENTITY(1,1) PRIMARY KEY,
	TourInfID				pkType FOREIGN KEY REFERENCES tlTours(TourInfID) ON UPDATE CASCADE ON DELETE CASCADE,
	RouteID					pkType FOREIGN KEY REFERENCES tlRoutes(RouteID),
	DayTimeID				idType FOREIGN KEY REFERENCES tlDayTimes(CodeID),
	DriverVehicleID			pkType ,
	DayNum					INT,
	Date					VARCHAR(23),
	TransportInfID			pkType FOREIGN KEY REFERENCES tlTransports(TransportInfID),
	Distance				INT,
	MglQty					INT,
	GuestQty				INT,
	BuyPriceL				NUMERIC(24,6),
	BuyPriceF				NUMERIC(24,6),
	SalePriceL				NUMERIC(24,6),
	SalePriceF				NUMERIC(24,6),
	CurrencyIDL				NVARCHAR(30),
	CurrencyIDF				NVARCHAR(30),
	TimeConsumption			VARCHAR(5),
	VehicleRentPriceInfID	pkType ,
	BuyAmountL				NUMERIC(24,6),
	BuyAmountF				NUMERIC(24,6),
	SaleAmountL				NUMERIC(24,6),
	SaleAmountF				NUMERIC(24,6) )
GO

-- DROP TABLE tlTransportVehicleFuels
CREATE TABLE tlTransportVehicleFuels(
	TransportInfID			pkType FOREIGN KEY REFERENCES tlTransports(TransportInfID),
	FuelTypeID				idType FOREIGN KEY REFERENCES tlFuelTypes(CodeID),
	FuelConsumption			NUMERIC(8,3) )
GO


CREATE TABLE tlTourRouteFlights (
	ToureRouteFlightID		pkType IDENTITY(1,1 )  PRIMARY KEY,
	FlightTrainPriceInfID	pkType,
	TourRouteID				pkType,
	PersonQty				INT)

CREATE TABLE tlTourRouteTrains (
	ToureRouteTrainID		pkType IDENTITY(1,1 )  PRIMARY KEY,
	FlightTrainPriceInfID	pkType,
	TourRouteID				pkType,
	PersonQty				INT)

-- DROP TABLE tlFlights
CREATE TABLE tlFlights (
	FlightID		pkType IDENTITY(1,1 )  PRIMARY KEY,
	FlightNum		pkType,
	AirlineF		idType,
	PointDA			pkType,
	PointDB			pkType,
	PlaneNum		idType,
	SitNum			INT,
	IsReturn		CHAR(1),
	FlightTypeID	idType  FOREIGN KEY REFERENCES tlFlightTypes(CodeID),
	CurrencyIDL		idType  FOREIGN KEY REFERENCES tlCurrencies(CodeID),
	CurrencyIDF		idType  FOREIGN KEY REFERENCES tlCurrencies(CodeID),
	BuyPriceL		amountType,
	BuyPriceF		amountType,
	SalePriceL		amountType,
	SalePriceF		amountType,
	PriceDate		amountType )

-- DROP TABLE tlFlightTimes
CREATE TABLE tlFlightTimes (
	FlightTimeID	pkType IDENTITY(1,1 )  PRIMARY KEY,
	FlightID		idType  FOREIGN KEY REFERENCES tlFlightTypes(CodeID),
	DayID			idType  FOREIGN KEY REFERENCES tlWeekDays(CodeID),
	DeptTime		VARCHAR(5),
	ArriveTime		VARCHAR(5),
	DuringTime		VARCHAR(5) )


CREATE TABLE tlTourRouteFlights(
	TourRouteFlightsRecID	pkType NOT NULL,
	TourRecID				pkType NULL,
	FlightRecID				pkType NULL,
	CurrencyIDL				idType NULL,
	CurrencyIDF				idType NULL,
	MglQty int NULL,
	GuestQty int NULL,
	BuyPriceL amountType NULL,
	BuyPriceF amountType NULL,
	SalePriceL amountType NULL,
	BuyAmountL  AS (MglQty*BuyPriceL),
	SaleAmountL  AS (MglQty*SalePriceL),
	SalePriceF amountType NULL,
	BuyAmountF  AS (GuestQty*BuyPriceF),
	SaleAmountF  AS (GuestQty*SalePriceF),
	BookStatusInfID pkType NULL,
	FlightDate			dateType,
	CONSTRAINT PK_tlTourRoutesFlights PRIMARY KEY CLUSTERED 
	CONSTRAINT FK__tlBookSta__BookS__44C1AC7D FOREIGN KEY(BookStatusInfID) 
		REFERENCES tlBookStatus (StatusInfID)
	CONSTRAINT FK__tlTourRou__TourR__44C1AC7D FOREIGN KEY(TourRecID)
		 REFERENCES tlTourRoutes1 (TourRouteRecID)
) 
/*
SELECT * FROM tlTourRoutes
SELECT * FROM tlTours
SELECT * FROM tlRoutes
SELECT * FROM tlDayTimes
SELECT * FROM tlDriverVehicles
SELECT * FROM tlVehicleRentPrices


SELECT * FROM tlTourRouteTransports


INSERT INTO tlStaffs(StaffStart, StaffEnd, Days, Qty, StaffName, StaffType) 
	VALUES ('start1', 'end1', 1, 2, 'asdf', 1)

INSERT INTO tlStaffs(StaffStart, StaffEnd, Days, Qty, StaffName, StaffType) 
	VALUES ('start2', 'end2', 1, 2, 'qwer', 2)

INSERT INTO tlStaffs(StaffStart, StaffEnd, Days, Qty, StaffName, StaffType) 
	VALUES ('start3', 'end3', 1, 2, 'zxcv', 3)

INSERT INTO tlStaffs(StaffStart, StaffEnd, Days, Qty, StaffName, StaffType) 
	VALUES ('start4', 'end4', 1, 2, 'yuio', 4)

SELECT * FROM tlStaffs

SELECT * FROM tlTourPoints


INSERT INTO tlTours (TourID, TourNameL) VALUES('001', 'First tour')
INSERT INTO tlTours (TourID, TourNameL) VALUES('002', 'Second tour')

INSERT INTO tlTourPoints VALUES(1, 125, 1, '2007/06/01', '2007/06/02', 'IAF121')
INSERT INTO tlTourPoints VALUES(1, 134, 2, '2007/06/04', '2007/06/05', 'IAF121')
INSERT INTO tlTourPoints VALUES(1, 168, 3, '2007/06/07', '2007/06/08', 'IAF121')


INSERT INTO tlTourPoints VALUES(2, 54, 1, '2007/06/01', '2007/06/02', 'IAS121')
INSERT INTO tlTourPoints VALUES(2, 129, 2, '2007/06/04', '2007/06/05', 'IAS121')
INSERT INTO tlTourPoints VALUES(2, 184, 3, '2007/06/07', '2007/06/08', 'IAS121')
INSERT INTO tlTourPoints VALUES(2, 132, 4, '2007/06/07', '2007/06/08', 'IAS121')
INSERT INTO tlTourPoints VALUES(2, 119, 5, '2007/06/07', '2007/06/08', 'IAS121')

----
INSERT INTO tlDriverVehicles VALUES(1987020100001, 6, 'DriverID', 'N')
INSERT INTO tlTourRoutes(TourInfID, RouteID, DayTimeID, DriverVehicleID, TransportInfID) 
					VALUES(2, 54, '001', 1, 1987020100001)

INSERT INTO tlTourRoutes(TourInfID, RouteID, DayTimeID, DriverVehicleID, TransportInfID) 
					VALUES(2, 112, '001', 1, 1987020100002)

UPDATE tlTourRoutes SET RouteID = 79
SELECT * FROM tlRoutes WHERE PointDA = 54 AND PointDB = 129 AND Distance IS NOT NULL
SELECT * FROM tlRoutes WHERE PointDA = 129 AND PointDB = 184 AND Distance IS NOT NULL

SELECT * FROM tlTourRoutes
SELECT * FROM tlDriverVehicles
SELECT * FROM tlDayTimes
SELECT * FROM tlTransports

INSERT INTO tlDayTimes(CodeID, DescriptionF) VALUES ('001', 'DescL')

*/