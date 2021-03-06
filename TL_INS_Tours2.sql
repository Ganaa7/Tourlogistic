USE TourLogistic
GO
DROP PROC TL_INS_Tours2
GO

CREATE PROC TL_INS_Tours2(
		@TourRecID			pkType,
		@TourID				idType,
		@LeaderPaxRecID		pkType,
		@TourName			descType,
		@TourTypeInfID		pkType,
		@TourLevelID		idType,
		@TourStatusID		idType,
		@PaxQty				SMALLINT,
		@StaffQty			SMALLINT,
		@StartDate			dateType,
		@EndDate			dateType,
		@Days				SMALLINT,
		@TotalDistance		SMALLINT,
		@TourDate			dateType,   -- confirmed date
		@CustomerInfID		pkType,
		@CustomerDescF		descType,
		@RemarkL			NVARCHAR(1000),
		@RemarkF			NVARCHAR(1000),
		@RemarkD			NVARCHAR(1000),
		@ActionDoneBy		idType
) AS
BEGIN
		
	DECLARE @RecID	pkType
	
	IF NOT EXISTS(SELECT * FROM tlTours WHERE TourRecID = @TourRecID)
	BEGIN
		EXEC CreatePkID 'tlTours', 'TourRecID', @RecID OUTPUT
		
		INSERT INTO tlTours(TourRecID, TourID, LeaderPaxRecID, TourName, TourTypeInfID, TourLevelID, TourStatusID, PaxQty, StaffQty, 
					StartDate, EndDate, Days, TotalDistance, TourDate, CustomerInfID, CustomerDescF, RemarkL, RemarkF, RemarkD, ActionDoneBy, ActionDate)
			VALUES(@RecID, @TourID, @LeaderPaxRecID, @TourName, @TourTypeInfID, @TourLevelID, @TourStatusID, @PaxQty, @StaffQty, 
					@StartDate, @EndDate, @Days, @TotalDistance, @TourDate, @CustomerInfID, @CustomerDescF, @RemarkL, @RemarkF, @RemarkD, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121))	
	END
	ELSE
		UPDATE tlTours SET  TourID = @TourID, 
							LeaderPaxRecID = @LeaderPaxRecID, 
							TourName = @TourName, 
							TourTypeInfID = @TourTypeInfID, 
							TourLevelID = @TourLevelID, 
							TourStatusID = @TourStatusID, 
							PaxQty = @PaxQty, 
							StaffQty = @StaffQty, 
							StartDate = @StartDate, 
							EndDate = @EndDate, 
							Days = @Days, 
							TotalDistance = @TotalDistance,
							TourDate = @TourDate, 
							CustomerInfID = @CustomerInfID, 
							CustomerDescF = @CustomerDescF, 
							RemarkL = @RemarkL,
							RemarkF = @RemarkF,
							RemarkD = @RemarkD,
							ActionDoneBy = @ActionDoneBy,
							ActionDate = CONVERT(VARCHAR(23), GETDATE(), 121)
			WHERE TourRecID = @TourRecID

END
GO
EXEC TL_INS_Tours2 0, 'No040301', 1987040200002, 'Khuvsgul travel', 1987022200004, 'B', 'statReserved', 10, 5, '2007/05/12', '2007/05/25', 13, 3000, '2007/04/05', 0, '', '', '', '', 'Ganaa' 

/*
	INSERT INTO tlTours
		VALUES(1987040200001, 'NO040201', 1987040200001, 'Nomads KhuvsgulTour', 1987022200004, 'A', 'statCanceled', 12, 3, ''   )	

sp_help tlTours
SELECT * FROM tlTourTypes
SELECT * FROM tlTours

SELECT * FROM VIEW_ssTourstatus
SELECT * FROM VIEW_ssTourLevel

SELECT * FROM tlReqOthers

SELECT * FROM tlTours

SELECT * FROM tlTourTypes

UPDATE tlTours SET TourInfID = 2
	WHERE TourInfID = 3

DELETE FROM tlTours WHERE TourInfID = 10
	SELECT * FROM tlPaxs

INSERT INTO tlPaxs(NameL, CountryID, FlightTrainInfID)
	SELECT 'ROBERT', 'USA', 3

SELECT * FROM tlFlightTrain
SELECT * FROM tlCountries
SELECT * FROM tlAirlines
SELECT * FROM tlCurrencies

USE TourLogistic

SELECT * FROM tlTourTypes
SELECT * FROM tlTourLevels
SELECT * FROM tlTourStatus
SELECT * FROM tlEmployees

INSERT INTO tlFlightTrain(Number, AirlineID, CurrencyID, ICCostL, ICCostF, SaleL, SaleF)
	SELECT N'A15', N'МИАТ', N'MNT', 1, 2, 3, 4
*/
