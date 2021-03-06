	USE TourLogistic
GO
/************************
	1.
	SELECT * FROM tlTours

************************/
--DROP TABLE tlTours
GO
CREATE TABLE tlTours(
	TourRecID				pkType,				-- touriin 
	TourID					idType,
	LeaderPaxRecID			pkType,				-- connected
	TourName				descType,
	TourTypeInfID			pkType,				-- nomads private, 
	TourLevelID				idType,
	TourStatusID			idType,
	RequestRecID			pkType,
	PaxQty					SMALLINT DEFAULT ((1)),
	StaffQty				SMALLINT,
	StartDate				dateType,
	EndDate					dateType,
	Days					INT,
	TotalDistance			INT,
	ConfirmedDate			dateType,	        -- 
	CustomerInfID			pkType,				-- company
	CustomerDescF			descType,
	RemarkL					NVARCHAR(1000),
	RemarkF					NVARCHAR(1000),
	RemarkD					NVARCHAR(1000),
	ActionDoneBy			idType,
	ActionDate				dateType
	CONSTRAINT tlTours_PK PRIMARY KEY(TourRecID)
)
GO
CREATE UNIQUE INDEX tlTours_idx1 ON tlTours(TourID)
CREATE INDEX tlTours_idx2 ON tlTours(LeaderPaxRecID)
CREATE INDEX tlTours_idx3 ON tlTours(TourTypeInfID)
CREATE INDEX tlTours_idx4 ON tlTours(TourStatusID)
CREATE INDEX tlTours_idx6 ON tlTours(TourDate)
CREATE INDEX tlTours_idx7 ON tlTours(CustomerInfID)
CREATE INDEX tlTours_idx8 ON tlTours(StartDate)
CREATE INDEX tlTours_idx9 ON tlTours(EndDate)
CREATE INDEX tlTours_idx10 ON tlTours(RequestRecID)

/*****************
	2.
    Created
*****************/
--DROP TABLE tlPaxes

GO
CREATE TABLE tlPaxes(
	PaxRecID				pkType,
	FirstName				descType,
	LastName				descType,
	Gender					CHAR(1),
	Passport				NVARCHAR(25),
	BirthDate				dateType,
	Occupation				descType,
	CountryInfID			pkType,			
	Phone					idType,
	EMail					NVARCHAR(50),
	IsVegetarian			CHAR(1),
	ActionDoneBy			idType,
	ActionDate				dateType
	CONSTRAINT tlPaxes_PK PRIMARY KEY(PaxRecID)
)
GO
CREATE INDEX tlPaxes_idx1 ON tlPaxes(FirstName)
CREATE INDEX tlPaxes_idx2 ON tlPaxes(LastName)
CREATE INDEX tlPaxes_idx3 ON tlPaxes(Gender)
CREATE INDEX tlPaxes_idx4 ON tlPaxes(Passport)
CREATE INDEX tlPaxes_idx5 ON tlPaxes(BirthDate)
CREATE INDEX tlPaxes_idx6 ON tlPaxes(Occupation)
CREATE INDEX tlPaxes_idx7 ON tlPaxes(CountryInfID)
CREATE INDEX tlPaxes_idx8 ON tlPaxes(Phone)
CREATE INDEX tlPaxes_idx9 ON tlPaxes(EMail)

/*******************
	3.	
	created

	SELECT * FROM tlTourPaxes

********************/
--DROP TABLE tlTourPaxes
GO
CREATE TABLE tlTourPaxes(
	TourPaxRecID			pkType	,	
	PaxRecID				pkType	,
	TourRecID				pkType	,
	ArriveType				idType   NULL,				-- Flight or Train or Other
	ArriveFlightRecID		pkType   NULL,
	DepartFlightRecID		pkType   NULL,
	ArriveTrainRecID		pkType	 NULL,
	DepartTrainRecID		pkType	 NULL,	
	ArriveDate				dateType NULL,
	ArriveTime				dateType NULL,
	DepartDate				dateType NULL,
	DepartTime				dateType NULL,
	IsInvoice				CHAR(1)  NULL,
	CustomerInfID			pkType	 NULL,				-- Zuuchluulj b,gaa company
	IsTrekLeader			CHAR(1)	 NULL,
	TrekLeaderType			idType	 NULL,
	IsApproved				CHAR(1)  NULL,				
	ActionDoneBy			idType   NULL,
	ActionDate				dateType NULL
	CONSTRAINT tlTourPaxes_PK PRIMARY KEY(TourPaxRecID),
	CONSTRAINT tlTourPaxes_FK1 FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT tlTourPaxes_FK2 FOREIGN KEY(PaxRecID)
		REFERENCES tlPaxes(PaxRecID) ON DELETE CASCADE ON UPDATE CASCADE	
)
GO
CREATE INDEX tlTourPaxes_idx1 ON tlTourPaxes(ArriveFlightRecID)
CREATE INDEX tlTourPaxes_idx2 ON tlTourPaxes(ArriveDate)
CREATE INDEX tlTourPaxes_idx3 ON tlTourPaxes(ArriveTime)
CREATE INDEX tlTourPaxes_idx4 ON tlTourPaxes(DepartFlightRecID)
CREATE INDEX tlTourPaxes_idx5 ON tlTourPaxes(DepartDate)
CREATE INDEX tlTourPaxes_idx6 ON tlTourPaxes(DepartTime)
CREATE INDEX tlTourPaxes_idx8 ON tlTourPaxes(CustomerInfID)
CREATE INDEX tlTourPaxes_idx9 ON tlTourPaxes(IsTrekLeader)
CREATE INDEX tlTourPaxes_idx10 ON tlTourPaxes(TrekLeaderType)
CREATE INDEX tlTourPaxes_idx11 ON tlTourPaxes(IsApproved)

/*******************
ALTER TABLE 
	4.
		SELECT * FROM tlTourRoutes

********************/
--DROP TABLE tlTourRoutes
GO
CREATE TABLE tlTourRoutes
(
	TourRouteRecID		pkType,
	TourRecID			pkType,
	RouteNum			SMALLINT,
	FromPointRecID		pkType,
	ToPointRecID		pkType,
	Date				dateType,
	CONSTRAINT tlTourRoutes_PK PRIMARY KEY(TourRouteRecID),
	CONSTRAINT tlTourRoutes_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE	
)
GO
CREATE INDEX tlTourRoute_idx1 ON tlTourRoutes(FromPointRecID)
CREATE INDEX tlTourRoute_idx2 ON tlTourRoutes(ToPointRecID)
CREATE INDEX tlTourRoute_idx3 ON tlTourRoutes(Date)
GO

/********************
	5.
	SELECT * FROM tlTourTypes
	SELECT * FROM tlReqRoutes
	created!
********************/
CREATE TABLE tlTourTypes(
	TourTypeInfID		pkType,
	TourTypeID			idType,
	DescriptionL		descType,
	DescriptionF		descType,
	DescriptionD		descType,
	ActionDoneBy		idType,
	ActionDate			dateType,
	CONSTRAINT tlTourTypes_PK PRIMARY KEY(TourTypeInfID)
)
GO
CREATE INDEX tlTourTypes_idx1 ON tlTourTypes(TourTypeID)
GO	

/*******************
	6.
	SELECT * FROM tlTransports
	sp_help tlTransports
*******************/
--DROP TABLE tlTransports
GO
CREATE TABLE tlTransports(
	TransportInfID		pkType,
	TransportID			idType,
	DescriptionL		descType,
	DescriptionF		descType,
	DescriptionD		descType,
	TransportTypeID		idType,
	TourLevelID			idType,
	PerNum				SMALLINT,
	CarrierTypeID		idType,
	FuelTypeID			idType,
	FuelConsumption		amountType ,
	ActionDoneBy		idType,
	ActionDate			dateType,
 CONSTRAINT PK__tlTransports__573F8414 PRIMARY KEY(TransportInfID) CLUSTERED 
)
GO	
CREATE INDEX TransportInfID_idx2 ON tlTransports(TransportID)
CREATE INDEX tlTransports_idx2 ON tlTransports(TransportTypeID)
CREATE INDEX tlTransports_idx3 ON tlTransports(TourLevelID)
CREATE INDEX tlTransports_idx4 ON tlTransports(CarrierTypeID)
CREATE INDEX tlTransports_idx5 ON tlTransports(FuelTypeID)

/******************
	7.
	SELECT * FROM tlTourStaffs
	CREATED
******************/
--DROP TABLE tlTourStaffs 
GO
ALTER TABLE tlTourStaffs (
	TourStaffRecID		pkType,
	TourRecID			pkType,
	Date				dateType,
	EmployeeInfID		pkType,
	PositionInfID		idType,
	LevelID				idType,
	IsRecipient			Char(1),
	ActionDoneBy		idType,
	ActionDate			dateType
	CONSTRAINT tlTourStaffs_PK	PRIMARY KEY(TourStaffRecID),
	CONSTRAINT tlTourStaffs_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE	 
) 
GO
CREATE INDEX tlTourStaffs_idx1 ON tlTourStaffs(Date)
CREATE INDEX tlTourStaffs_idx2 ON tlTourStaffs(EmployeeInfID)
CREATE INDEX tlTourStaffs_idx3 ON tlTourStaffs(PositionInfID)
CREATE INDEX tlTourStaffs_idx4 ON tlTourStaffs(LevelID) 

/*
	9.
	SELECT * FROM tlTourFlights

	passrecid = paxrec
	passrecid = tourstaffrecid

	droped
*/
-- DROP TABLE tlTourFlights
GO
CREATE TABLE tlTourFlights(
	TourFlightRecID			pkType,
	TourRecID				pkType,
	PassangerRecID			pkType,		-- Pax ch baij bolno Staff ch baij bolno
	IsPax					CHAR(1),
	FlightRecID				pkType,
	FlightDate				dateType,
	BookStatusInfID			pkType,
	IsCargo					CHAR(1)
	CONSTRAINT tlTourFlights_PK PRIMARY KEY(TourFlightRecID),
	CONSTRAINT tlTourFlights_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE	 
) 
GO
CREATE INDEX tlTourFlights_idx1 ON tlTourFlights(PassangerRecID)
CREATE INDEX tlTourFlights_idx2 ON tlTourFlights(IsPax)
CREATE INDEX tlTourFlights_idx3 ON tlTourFlights(FlightRecID)
CREATE INDEX tlTourFlights_idx4 ON tlTourFlights(FlightDate)
CREATE INDEX tlTourFlights_idx5 ON tlTourFlights(BookStatusInfID)

/****************
	10.
	SELECT * FROM tlTourTrains

	Created!
******************/
DROP TABLE tlTourTrains 
GO
CREATE TABLE tlTourTrains(
	TourTrainRecID			pkType,
	TourRecID				pkType,
	PassangerRecID			pkType,		-- Pax ch baij bolno Staff ch baij bolno
	IsPax					CHAR(1),
	TrainRecID				pkType,
	TrainDate				dateType,
	BookStatusInfID			pkType
	CONSTRAINT tlTourTrains_PK PRIMARY KEY(TourTrainRecID),
	CONSTRAINT tlTourTrains_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE	 
)
GO
CREATE INDEX tlTourTrains_idx1 ON tlTourTrains(PassangerRecID)
CREATE INDEX tlTourTrains_idx2 ON tlTourTrains(IsPax)
CREATE INDEX tlTourTrains_idx3 ON tlTourTrains(TrainRecID)
CREATE INDEX tlTourTrains_idx4 ON tlTourTrains(TrainDate)
CREATE INDEX tlTourTrains_idx5 ON tlTourTrains(BookStatusInfID)

/***************
	11.
	SELECT * FROM tlTourVehicles

	Created!	
***************/
DROP TABLE tlTourVehicles
GO
CREATE TABLE tlTourVehicles(
	TourVehiclesRecID		pkType,
	TourRecID				pkType,
	EmployeeInfID			pkType,			-- driver
	CarID					idType,			-- Mashinii dugaar
	TransportInfID			pkType,
	RentTypeID				idType,
	RentPrice				amountType,
	Distance				SMALLINT,
	StartDate				dateType,
	EndDate					dateType,
	StaffQty				SMALLINT,
	PaxQty					SMALLINT,
	WithPax					CHAR(1),
	Days					SMALLINT,
	ActionDoneBy			idType,
	ActionDate				dateType
	CONSTRAINT tlTourVehicles_PK PRIMARY KEY (TourVehiclesRecID),
	CONSTRAINT tlTourVehicles_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO

CREATE INDEX tlTourVehicles_idx2 ON tlTourVehicles(EmployeeInfID)
CREATE INDEX tlTourVehicles_idx3 ON tlTourVehicles(CarID)
CREATE INDEX tlTourVehicles_idx4 ON tlTourVehicles(TransportInfID)
CREATE INDEX tlTourVehicles_idx5 ON tlTourVehicles(RentType)


--DROP TABLE tlTourCityVehicles
GO
CREATE TABLE tlTourCityVehicles(
	TourCityVeRecID			pkType,
	TourRecID				pkType,
	EmployeeInfID			pkType,			-- driver
	CarID					idType,	
	TransportInfID			pkType,
	RouteRecID				pkType,
	RentTypeID				idType,
	StaffQty				SMALLINT,
	PaxQty					SMALLINT,
	StartDate				dateType,
	EndDate					dateType,
	TimeQty					SMALLINT,
	RentPrice				amountType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlTourCityVehicles_PK PRIMARY KEY(TourCityVeRecID),
	CONSTRAINT tlTourCityVehicles_FK FOREIGN KEY(TourRecID) 
			REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlTourCityVehicles_Idx1 ON tlTourCityVehicles(TransportInfID)
CREATE INDEX tlTourCityVehicles_Idx4 ON tlTourCityVehicles(RouteRecID)
CREATE INDEX tlTourCityVehicles_Idx5 ON tlTourCityVehicles(StartDate)
CREATE INDEX tlTourCityVehicles_Idx6 ON tlTourCityVehicles(EndDate)
GO



/*
	SELECT * FROM tlTourAnimals
	SELECT * FROM VIEW_ssCarrierType
	Ene table-d 1 TourRecID, EmployeeInfID, TransportInfID, CarrierTypeID, GuestRecID, 	

	DROP TABLE tlTourAnimals	

*/
CREATE TABLE tlTourAnimals(
	TourAnimalRecID			pkType,
	TourRecID				pkType,
	EmployeeInfID			pkType,		
	TransportInfID			pkType,
	CarrierTypeID			idType,
	GuestRecID				pkType,
	IsPax					CHAR(1), 
	Date					dateType,
	CurrencyInfID			pkType,				-- Fcy -n Currency
	RentPrice				amountType,
	RateFcy					amountType,
	RentPriceFcy			amountType,
	RateCvr					amountType,
	RentPriceCvr			amountType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlTourAnimals_PK PRIMARY KEY(TourAnimalRecID),
	CONSTRAINT tlTourAnimals_FK FOREIGN KEY(TourRecID) 
			REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlTourAnimals_Idx1 ON tlTourAnimals(TransportInfID)
CREATE INDEX tlTourAnimals_Idx2 ON tlTourAnimals(Date)
CREATE INDEX tlTourAnimals_Idx3 ON tlTourAnimals(GuestRecID)
CREATE INDEX tlTourAnimals_Idx4 ON tlTourAnimals(IsPax)
CREATE INDEX tlTourAnimals_Idx5 ON tlTourAnimals(CarrierTypeID)
CREATE INDEX tlTourAnimals_Idx6 ON tlTourAnimals(CurrencyInfID)
CREATE INDEX tlTourAnimals_Idx7 ON tlTourAnimals(RateFcy)

/*
	CREATE TABLE tlTourAnimals(
		TourAnimalRecID		pkType NOT NULL,
		TourRecID			pkType NULL,
		EmployeeInfID		pkType NULL,
		TransportInfID		pkType NULL,
		CarrierTypeID		idType NULL,
		RouteRecID			pkType NULL,
		StaffQty			smallint NULL,
		PaxQty				smallint NULL,
		RentTypeID			idType NULL,
		RentPrice			amountType NOT NULL,
		FromDate			dateType NULL,
		ToDate				dateType NULL,
		ActionDoneBy		idType NULL,
		ActionDate			dateType NULL
	) 

*/

/*****************
	12.

	SELECT * FROM VIEW_ssCateringType
	SELECT * FROM tlTourAccomodations
	SELECT * FROM tlReqAccomodation

	ALTER TABLE tlTourAccomodations ALTER COLUMN ActionDate pkType NULL

*****************/
--DROP TABLE tlTourAccomodations
GO
CREATE TABLE tlTourAccomodations(
	TourAccRecID			pkType,
	TourRecID				pkType,
	GuestRecID				pkType,				-- PaxRecID, StaffRecID 2 orno
	IsPax					CHAR(1),
	AccomodationInfID		pkType,
	AccomodationTypeID		idType,				
	AccProductTypeInfID		pkType,	
	SameRoom				SMALLINT,
	Date					dateType,
	BookStatusInfID			pkType,				-- zahialgiin status
	VoucherNum				idType,				-- voucher-n dugaar
	AprStatusID				idType,
	IsApproved				CHAR(1),			-- guitsetgegdsen
	PrintCount				INT,
	PrintLastDoneBy			idType,
	ActionDoneBy			idType,				
	ActionDate				dateType	
	CONSTRAINT tlTourAcc_PK PRIMARY KEY(TourAccRecID),
	CONSTRAINT tlTourAcc_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
CREATE INDEX tlTourAcc_idx1 ON tlTourAccomodations(GuestRecID)
CREATE INDEX tlTourAcc_idx2 ON tlTourAccomodations(IsPax)
CREATE INDEX tlTourAcc_idx3 ON tlTourAccomodations(AccomodationInfID)
CREATE INDEX tlTourAcc_idx4 ON tlTourAccomodations(AccProductTypeInfID)
CREATE INDEX tlTourAcc_idx5 ON tlTourAccomodations(Date)
CREATE INDEX tlTourAcc_idx8 ON tlTourAccomodations(IsApproved)
CREATE INDEX tlTourAcc_idx9 ON tlTourAccomodations(SameRoom)
CREATE UNIQUE INDEX tlTourAcc_idx10 ON tlTourAccomodations(TourRecID, GuestRecID, AccomodationInfID, Date)
GO

/*******************

	SELECT * FROM tlTourAccomodations 
	
	SELECT * FROM tlReqAccomodation

	INSERT INTO tlTourAccomodations (TourAccRecID, TourRecID)
	SELECT * FROM tlTourCatering

	sp_help tlTourCatering

	SELECT * FROM tlTourCatering
		
*******************/
--DROP TABLE tlTourCatering
GO
CREATE TABLE tlTourCatering(
	TourCaterRecID			pkType,
	TourRecID				pkType,
	GuestRecID				pkType,	 		-- PaxRecID, StaffRecID 2 orno
	AccomodationInfID		pkType,			-- Ger baaziin hoolniig avah 
	CateringTypeID			idType,			-- restaurant, ger baaz zeregiig yalgah
	RestaurantInfID			pkType,			-- 
	BreakFast				CHAR(1),
	Lunch					CHAR(1),
	Dinner					CHAR(1),
	Eger					CHAR(1),			-- restaurant nomads
	Date					dateType,		
	IsPax					CHAR(1),
	BookStatusInfID			pkType,
	VoucherNum				idType,				-- voucher-n dugaar
	AprStatusID				idType,
	IsApproved				CHAR(1),
	BCurrencyInfID			pkType,
	BICPrice				amountType,
	BSalePrice				amountType,
	BICPriceCvr				amountType,
	BSalePriceCvr			amountType,
	BRateCvr				amountType,
	BICPriceFcy				amountType,
	BSalePriceFcy			amountType,
	BRate					amountType,
	LCurrencyInfID			pkType,
	LICPrice				amountType,
	LSalePrice				amountType,
	LICPriceCvr				amountType,
	LSalePriceCvr			amountType,
	LRateCvr				amountType,
	LICPriceFcy				amountType,
	LSalePriceFcy			amountType,
	LRate					amountType,
	DCurrencyInfID			pkType,
	DICPrice				amountType,
	DSalePrice				amountType,
	DICPriceCvr				amountType,
	DSalePriceCvr			amountType,
	DRateCvr				amountType,
	DICPriceFcy				amountType,
	DSalePriceFcy			amountType,
	DRate					amountType,
	ActionDoneBy			idType,
	ActionDate				dateType
	CONSTRAINT tlTourCatering_PK PRIMARY KEY(TourCaterRecID),
	CONSTRAINT tlTourCatering_FK FOREIGN KEY(TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE	
)
GO
CREATE INDEX tlTourCatering_idx1 ON tlTourCatering(GuestRecID)
CREATE INDEX tlTourCatering_idx2 ON tlTourCatering(AccomodationInfID)
CREATE INDEX tlTourCatering_idx3 ON tlTourCatering(RestaurantInfID)
CREATE INDEX tlTourCatering_idx4 ON tlTourCatering(Date)
CREATE INDEX tlTourCatering_idx5 ON tlTourCatering(IsPax)
CREATE INDEX tlTourCatering_idx6 ON tlTourCatering(BookStatusInfID)
CREATE INDEX tlTourCatering_idx9 ON tlTourCatering(CateringTypeID)
CREATE INDEX tlTourCatering_idx8 ON tlTourCatering(VoucherNum)
CREATE INDEX tlTourCatering_idx7 ON tlTourCatering(AprStatusID)
CREATE INDEX tlTourCatering_idx7 ON tlTourCatering(AprStatusID)

/********************
	14.
	SELECT * FROM #tlAprCatering
	
	sp_help tlAprCatering

	ALTER TABLE tlAprCatering ADD MNTInvRef refType NULL
	ALTER TABLE tlAprCatering ADD USDInvRef refType NULL
	ALTER TABLE tlAprCatering ADD EURInvRef refType NULL

		
*********************/
--DROP TABLE tlAprCatering
GO
CREATE TABLE tlAprCatering(
	AprCaterRecID			pkType,
	TourCaterRecID			pkType,
	TourRecID				pkType,
	GuestRecID				pkType,	 		-- PaxRecID, StaffRecID 2 orno
	AccomodationInfID		pkType,			-- Ger baaziin hoolniig avah 
	CateringTypeID			idType,			-- restaurant, ger baaz zeregiig yalgah
	RestaurantInfID			pkType,			-- 
	BreakFast				CHAR(1),
	Lunch					CHAR(1),
	Dinner					CHAR(1),
	Eger					CHAR(1),			-- restaurant nomads
	Date					dateType,		
	IsPax					CHAR(1),
	VoucherNum				idType,				-- voucher-n dugaar
	BCurrencyInfID			pkType,
	BICPrice				amountType,
	BSalePrice				amountType,
	BICPriceCvr				amountType,
	BSalePriceCvr			amountType,
	BRateCvr				amountType,
	BICPriceFcy				amountType,
	BSalePriceFcy			amountType,
	BRate					amountType,
	LCurrencyInfID			pkType,
	LICPrice				amountType,
	LSalePrice				amountType,
	LICPriceCvr				amountType,
	LSalePriceCvr			amountType,
	LRateCvr				amountType,
	LICPriceFcy				amountType,
	LSalePriceFcy			amountType,
	LRate					amountType,
	DCurrencyInfID			pkType,
	DICPrice				amountType,
	DSalePrice				amountType,
	DICPriceCvr				amountType,
	DSalePriceCvr			amountType,
	DRateCvr				amountType,
	DICPriceFcy				amountType,
	DSalePriceFcy			amountType,
	DRate					amountType,
	IsPaid					CHAR(1) NULL,
	PaidDate				dateType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	
	CONSTRAINT tlAprCatering_PK PRIMARY KEY(AprCaterRecID)
)
GO
CREATE INDEX tlAprCatering_idx1 ON tlAprCatering(GuestRecID)
CREATE INDEX tlAprCatering_idx2 ON tlAprCatering(AccomodationInfID)
CREATE INDEX tlAprCatering_idx3 ON tlAprCatering(RestaurantInfID)
CREATE INDEX tlAprCatering_idx4 ON tlAprCatering(Date)
CREATE INDEX tlAprCatering_idx5 ON tlAprCatering(IsPax)
CREATE INDEX tlAprCatering_idx6 ON tlAprCatering(TourCaterRecID)
CREATE INDEX tlAprCatering_idx7 ON tlAprCatering(VoucherNum)
CREATE INDEX tlAprCatering_idx9 ON tlAprCatering(CateringTypeID)
	

/*********************
	15.
	
	SELECT * FROM tlAprCatering
	SELECT * INTO #AprCatering
		FROM tlAprCatering
	
	SELECT * FROM tlAprAccomodations
	
	INSERT INTO tlAprCatering
		SELECT * FROM #AprCatering
	
	SP_HELP tlTourAccomodations

	INSERT INTO tlAprAccomodations(TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID,
			SameRoom, Date, BookStatusInfID, VoucherNum, AprStatusID, IsApproved, PrintCount, PrintLastDoneBy, ActionDoneBy, ActionDate)
		SELECT TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID, AccProductTypeInfID,
			SameRoom, Date, BookStatusInfID, VoucherNum, 'Y', IsApproved, PrintCount, PrintLastDoneBy, ActionDoneBy, ActionDate FROM tlAprAccomodations
	
	ALTER TABLE tlAprAccomodations ADD MNTInvRef refType NULL
	ALTER TABLE tlAprAccomodations ADD USDInvRef refType NULL
	ALTER TABLE tlAprAccomodations ADD EURInvRef refType NULL

**********************/
-- DROP TABLE tlAprAccomodations
sp_help tlAprAccomodations

CREATE TABLE tlAprAccomodations(
	AprAccRecID			pkType NOT NULL,
	TourRecID			pkType NULL,
	TourAccRecID		pkType NULL,
	GuestRecID			pkType NULL,
	IsPax				CHAR(1),
	AccomodationInfID	pkType NULL,
	AccomodationTypeID	idType NULL,
	AccProductTypeInfID pkType NULL,
	Date				dateType NULL,
	BookStatusInfID		pkType NULL,
	VoucherNum			idType NULL,
	SameRoom			SMALLINT, 
	ActionDoneBy		idType NULL,
	ActionDate			dateType NULL
	CONSTRAINT tlAprAccomodations_PK PRIMARY KEY(AprAccRecID),
)
GO
CREATE INDEX tlAprAccomodations_idx1 ON tlAprAccomodations(TourAccRecID)	
CREATE INDEX tlAprAccomodations_idx2 ON tlAprAccomodations(GuestRecID)
CREATE INDEX tlAprAccomodations_idx3 ON tlAprAccomodations(IsPax)
CREATE INDEX tlAprAccomodations_idx4 ON tlAprAccomodations(AccomodationInfID)
CREATE INDEX tlAprAccomodations_idx5 ON tlAprAccomodations(AccomodationTypeID)
CREATE INDEX tlAprAccomodations_idx6 ON tlAprAccomodations(AccProductTypeInfID)
CREATE INDEX tlAprAccomodations_idx7 ON tlAprAccomodations(Date)
CREATE INDEX tlAprAccomodations_idx8 ON tlAprAccomodations(BookStatusInfID)
CREATE INDEX tlAprAccomodations_idx9 ON tlAprAccomodations(VoucherNum)
CREATE INDEX tlAprAccomodations_idx10 ON tlAprAccomodations(TourRecID)
CREATE INDEX tlAprAccomodations_idx11 ON tlAprAccomodations(SameRoom)

/**********************
	DROP INDEX tlAprAccomodations.tlAprAccomodations_FK
	16.
	SELECT * FROM tlAprAccomodations 
	SELECT * FROM tlTourAccomodations 
	not edited!
**********************/

--DROP TABLE tlTourPrograms
GO
CREATE TABLE tlTourPrograms(
	ProgramRecID		pkType,
	TourRecID			pkType, 
	ProgramInfID		pkType, 
	DayTimeID			idType,
	Date				dateType,
	BeginTime			DATETIME,
	EndTime				DATETIME,
	Activities			descType
	CONSTRAINT tlTourPrograms_PK PRIMARY KEY(ProgramRecID),
	CONSTRAINT tlTourPrograms_FK FOREIGN KEY(TourRecID) 
		REFERENCES tlTours(TourRecID) ON UPDATE CASCADE ON DELETE CASCADE		
)
GO
CREATE INDEX tlTourPrograms_idx1 ON tlTourPrograms(DayTimeID)	
CREATE INDEX tlTourPrograms_idx2 ON tlTourPrograms(Date)	
CREATE INDEX tlTourPrograms_idx3 ON tlTourPrograms(BeginTime)	
CREATE INDEX tlTourPrograms_idx4 ON tlTourPrograms(EndTime)	
CREATE INDEX tlTourPrograms_idx5 ON tlTourPrograms(ProgramInfID)	

/*
	SELECT * FROM tlTourEntertain
	SELECT * FROM tlReqEntertainments
	select * from tlEntertainments
	Contsert
	Naadam
*/
--DROP TABLE tlTourEntertain
GO
CREATE TABLE tlTourEntertain(
	TourEnterRecID		pkType,
	TourRecID			pkType, 
	EntertainmentInfID	pkType,
	EnterTainmentTypeID idType,
	GuestRecID			pkType,
	IsPax				CHAR(1),
	Date				dateType,
	DayTimeID			idType, 
	BeginTime			dateType,
	EndTime				dateType,
	BookStatusInfID		pkType,
	VoucherNum			idType,
	AprStatusID			idType,
	ActionDoneBy		idType,
	ActionDate			dateType
	CONSTRAINT tlTourEntertain_PK PRIMARY KEY(TourEnterRecID),
	CONSTRAINT tlTourEntertain_FK FOREIGN KEY(TourRecID) 
		REFERENCES tlTours(TourRecID) ON UPDATE CASCADE ON DELETE CASCADE		
)
GO
CREATE INDEX tlTourEnter_idx1 ON tlTourEntertain(DayTimeID)	
CREATE INDEX tlTourEnter_idx2 ON tlTourEntertain(Date)	
CREATE INDEX tlTourEnter_idx3 ON tlTourEntertain(BeginTime)	
CREATE INDEX tlTourEnter_idx4 ON tlTourEntertain(EndTime)	
CREATE INDEX tlTourEnter_idx5 ON tlTourEntertain(EntertainmentInfID)	
CREATE INDEX tlTourEnter_idx6 ON tlTourEntertain(EnterTainmentTypeID)
CREATE INDEX tlTourEnter_idx7 ON tlTourEntertain(BookStatusInfID)
CREATE INDEX tlTourEnter_idx8 ON tlTourEntertain(VoucherNum)
CREATE INDEX tlTourEnter_idx9 ON tlTourEntertain(AprStatusID)
CREATE INDEX tlTourEnter_idx10 ON tlTourEntertain(GuestRecID)


/**********************
	SELECT * FROM tlAprEntertain
***********************/
--DROP TABLE tlAprEntertain
/*
	ALTER TABLE tlAprEntertain ADD MNTInvRef refType NULL
	ALTER TABLE tlAprEntertain ADD USDInvRef refType NULL
	ALTER TABLE tlAprEntertain ADD EURInvRef refType NULL

*/
GO
CREATE TABLE tlAprEntertain(
	AprEnterRecID		pkType,
	TourRecID			pkType, 
	TourEnterRecID		pkType,
	EntertainmentInfID	pkType,
	EnterTainmentTypeID idType,
	GuestRecID			pkType,
	IsPax				CHAR(1),
	Date				dateType,
	DayTimeID			idType, 
	BeginTime			dateType,
	EndTime				dateType,
	BookStatusInfID		pkType,
	VoucherNum			idType,
	ActionDoneBy		idType,
	ActionDate			dateType
	CONSTRAINT tlAprEntertain_PK PRIMARY KEY(AprEnterRecID),
)
GO
CREATE INDEX tlAprEntertain_idx1 ON tlAprEntertain(DayTimeID)	
CREATE INDEX tlAprEntertain_idx2 ON tlAprEntertain(Date)	
CREATE INDEX tlAprEntertain_idx3 ON tlAprEntertain(BeginTime)	
CREATE INDEX tlAprEntertain_idx4 ON tlAprEntertain(EndTime)	
CREATE INDEX tlAprEntertain_idx5 ON tlAprEntertain(EntertainmentInfID)	
CREATE INDEX tlAprEntertain_idx6 ON tlAprEntertain(EnterTainmentTypeID)
CREATE INDEX tlAprEntertain_idx7 ON tlAprEntertain(BookStatusInfID)
CREATE INDEX tlAprEntertain_idx8 ON tlAprEntertain(VoucherNum)
CREATE INDEX tlAprEntertain_idx9 ON tlAprEntertain(TourEnterRecID)
CREATE INDEX tlAprEntertain_idx10 ON tlAprEntertain(GuestRecID)

******************/
--DROP TABLE tlTourOthers
GO
CREATE TABLE tlTourOthers(
	TourOtherRecID			pkType,
	TourRecID				pkType,
	OtherExpenseInfID		pkType,
	Qty						SMALLINT,
	CurrencyInfIDL			pkType,
	SalePrice				amountType,
	SaleAmount				amountType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	TypeID					idType,
	TypeRecID				pkType
	
	CONSTRAINT tlTourOthers_PK PRIMARY KEY(TourOtherRecID),
	CONSTRAINT tlTourOthers_FK FOREIGN KEY(TourRecID) REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlTourOthers_idx1 ON tlTourOthers(OtherExpenseInfID)

	ALTER TABLE tlTourOthers ADD ICPrice			amountType
	ALTER TABLE tlTourOthers ADD ICPriceCvr			amountType
	ALTER TABLE tlTourOthers ADD SalePriceCvr		amountType
	ALTER TABLE tlTourOthers ADD RateCvr			amountType
	ALTER TABLE tlTourOthers ADD ICPriceFcy			amountType
	ALTER TABLE tlTourOthers ADD SalePriceFcy		amountType
	ALTER TABLE tlTourOthers ADD Rate				amountType
	ALTER TABLE tlTourOthers ADD ICPriceAmt			amountType
	ALTER TABLE tlTourOthers ADD SalePriceAmt		amountType
	ALTER TABLE tlTourOthers ADD ICPriceCvrAmt		amountType
	ALTER TABLE tlTourOthers ADD SalePriceCvrAmt	amountType
	ALTER TABLE tlTourOthers ADD ICPriceFcyAmt		amountType
	ALTER TABLE tlTourOthers ADD SalePriceFcyAmt	amountType
	
SELECT * FROM tlTourOthers	

/*
	Created Date 2007-05-15 12:51:00.170
	Created By	Gandava
	
	Ajiltanii huvid tuhain aylald yavah uridchilgaa zardaliig bodoh heseg

DELETE FROM tlPreExpenses
 
	sp_help tlPreExpenses
	
*/
--DROP TABLE tlPreExpenses
GO
CREATE TABLE tlPreExpenses(
		PreExpenseInfID		pkType,
		TourRecID			pkType,
		ExpenseID			idType,
		EmployeeInfID		pkType, 
		PositionInfID		pkType,
		DescriptionL		descType,
		DescriptionF		descType,
		PriceAmt			amountType,
		CurrencyInfID		pkType,
		Offered				amountType	NULL,
		Accepted			amountType	NULL,
		IsAccepted			CHAR(1)		NULL, 
		CashRecID			pkType		NULL,	
		ActionDoneBy		idType	,
		ActionDate			dateType

	CONSTRAINT tlPreExpenses_PK PRIMARY KEY(PreExpenseInfID),
	CONSTRAINT tlPreExpenses_FK FOREIGN KEY(TourRecID) REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE
	)
	CREATE UNIQUE INDEX tlPreExpenses_idx1 ON tlPreExpenses(TourRecID, ExpenseID, EmployeeInfID, PriceAmt, CurrencyInfID)
	--DROP INDEX 	tlPreExpenses.tlPreExpenses_idx1 
GO
--CREATE INDEX tlPreExpenses_idx1 ON tlPreExpenses(ExpenseTypeInfID)

--SELECT * FROM Diamond..ssManufactoryExpenses
--*****************************************
-- DROP TABLE tlTourPrograms
/*
	USE TourLogistic	

	SELECT * FROM tlTourCatering	

	SELECT * FROM tlCash
	
	TL_SEL_TourVoucher 'Y', 1987041100001

	SELECT * FROM tlTourEntertain

	SELECT * FROM tlTourAccomodations
	
	SELECT * FROM tlReqEntertainments
	SELECT * FROM tlPrograms
	SELECT * FROM tlRestaurants
	SELECT * FROM tlRestaurantServicePrices
	SELECT * FROM tlAccomodationsPrices
	SELECT * FROM tlAccomodations
	SELECT * FROM tlAccomodationsMealPrices
	SELECT * FROM tlAccomodationsProductTypes
	SELECT * FROM tlTransports
	SELECT * FROM tlRestaurants
	SELECT * FROM tlGerCampMealPrices
	
	SELECT * FROM tlTourPlanningPrice
	SELECT * FROM tlTourPrograms

	SELECT * FROM tlTourCatering
	SELECT * FROM tlTourStaffs
	SELECT * FROM tlTourVehibcles
	
	DROP TABLE tlTourAcc
	
	CREATE TABLE tlTourAcc(
		TourAccRecID			pkType,
		TourRecID				pkType,
		GuestRecID				pkType,			
		IsPax					CHAR(1)  NULL,
		AccomodationInfID		pkType   NULL,
		AccomodationTypeID		idType	 NULL,				
		AccProductTypeInfID		pkType   NULL,	
		SameRoom				SMALLINT NULL,
		Date					dateType NULL,
		BookStatusInfID			pkType	 NULL,			
		ReqAccProdTypeInfID		pkType   NULL,
		ReqSalePrice			amountType NULL,
		SalePrice				amountType NULL,
		CurrencyInfID			pkType,
		VoucherNum				idType	 NULL,			
		AprStatusID				idType	 NULL,
		IsApproved				CHAR(1),		
		PrintCount				INT,
		PrintLastDoneBy			idType   NULL,
		ActionDoneBy			idType,				
		ActionDate				dateType
	)

	INSERT INTO tlTourAcc(TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID,				
								AccProductTypeInfID, SameRoom, Date, BookStatusInfID, VoucherNum, AprStatusID, IsApproved, PrintCount, PrintLastDoneBy)

		SELECT TourAccRecID, TourRecID, GuestRecID, IsPax, AccomodationInfID, AccomodationTypeID,				
								AccProductTypeInfID, SameRoom, Date, BookStatusInfID, VoucherNum, AprStatusID, IsApproved, PrintCount, PrintLastDoneBy 
				FROM tlTourAccomodations

	

	SELECT * FROM tlTourAcc

	
	DROP TABLE tlPriceTourAcc

	CREATE TABLE tlPriceTourAcc(
		PriceAccRecID			pkType		IDENTITY(1987050300001, 1),
		TourAccRecID			pkType			, 
		TourRecID				pkType			,
		ReqAccProdTypeInfID		pkType		NULL,
		ReqSalePrice			amountType  NULL,
		SalePrice				amountType  NULL,
		CurrencyInfID			pkType		NULL,
		CurrencyID				idType		NULL,
		ActionDoneBy			idType		NULL,				
		ActionDate				dateType	NULL
	)

	INSERT INTO tlPriceTourAcc(TourAccRecID, TourRecID, ReqAccProdTypeInfID, ReqSalePrice, SalePrice, CurrencyInfID, CurrencyID, ActionDoneBy, ActionDate)
		SELECT TourAccRecID, TourRecID,  AccProductTypeInfID, 25000, 20000, 2005060700002, 'USD', 'Admin', CONVERT(VARCHAR(23), GETDATE(), 121)
			FROM tlTourAcc
	
	SELECT * FROM tlPriceTourAcc
	SELECT * FROM tlTourAcc

	SELECT * FROM tlReqAccomodation

	SELECT * FROM sys.indexes A
		INNER JOIN sys.objects B ON A.Object_id = B.object_id
		WHERE A.name = 'tlReqCityVehicles_Idx1'
	
	SELECT * FROM sys.objects
		WHERE name = 'tlReqCityVehicles_Idx1'

TourRecID = 1987051000001


	SELECT * FROM tlCash
	
*/

