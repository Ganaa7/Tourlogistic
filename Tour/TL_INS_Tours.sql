USE TourLogistic
GO
DROP PROC TL_INS_Tours
GO

CREATE PROC TL_INS_Tours(
	@IsTour				CHAR(1),
	@RequestRecID		pkType,
	@RequestID			idType,
	@LeaderPaxRecID		pkType,
	@ReqName			descType,
	@ReqTypeInfID		pkType,
	@PaxQty				SMALLINT,
	@EmployeeQty		SMALLINT,
	@StartDate			dateType,
	@EndDate			dateType,
	@Days				SMALLINT,
	@TotalDistance		INT,
	@RemarkL			NVARCHAR(2000),
	@RemarkF			NVARCHAR(2000),
	@RemarkD			NVARCHAR(2000),
	@RequestDate		dateType,
	@ActionDoneBy		idType,
	@LevelID			idType
) AS
BEGIN
		
	DECLARE @RecID	pkType
	
	IF @IsTour = 'N'
	BEGIN
	
		IF NOT EXISTS(SELECT * FROM tlRequest WHERE RequestRecID = @RequestRecID)
		BEGIN
			EXEC CreatePkID 'tlRequest', 'RequestRecID', @RecID OUTPUT
			
			INSERT INTO tlRequest (RequestRecID, RequestID, LeaderPaxRecID, ReqName, ReqTypeInfID, PaxQty, EmployeeQty, 
					StartDate, EndDate, Days, TotalDistance, RemarkL, RemarkF, RemarkD, RequestDate, ActionDoneBy, ActionDate, LevelID)
			VALUES(@RecID, @RequestID, @LeaderPaxRecID, @ReqName, @ReqTypeInfID, @PaxQty, @EmployeeQty,
					@StartDate, @EndDate,  @Days, @TotalDistance, @RemarkL, @RemarkF, @RemarkD, @RequestDate, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121), @LevelID )	
		END
		ELSE
			UPDATE tlRequest SET RequestID = @RequestID,
								LeaderPaxRecID = @LeaderPaxRecID,
								ReqName = @ReqName,
								ReqTypeInfID = @ReqTypeInfID,
								PaxQty =@PaxQty,
								EmployeeQty = @EmployeeQty,
								StartDate = @StartDate,
								EndDate = @EndDate,
								Days = @Days,
								TotalDistance = @TotalDistance,
								RemarkL = @RemarkL,
								RemarkF = @RemarkF,
								RemarkD = @RemarkD,
								RequestDate = @RequestDate,
								ActionDoneBy = @ActionDoneBy,
								ActionDate = CONVERT(VARCHAR(23), GETDATE(), 121),
								LevelID = @LevelID
				WHERE RequestRecID = @RequestRecID 

	END
END
GO
EXEC TL_INS_Tours 'N', 0, 'R03001', 1987030300002, 'Tour Request', 1987022200001, 12, 3, '2007/05/12', '2007/05/25', 12, 3000, '', '', '', '2007/03/12', 'Ganaa', 'C'

/*

SELECT * FROM tlPaxs
SELECT * FROM tlTourTypes

EXEC SP_HELP  tlRequest

INSERT INTO tlPaxsTours(PaxInfID, TourInfID)
	SELECT 4, 3

SELECT * FROM tlPaxsTours
SELECT * FROM tlTours


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
