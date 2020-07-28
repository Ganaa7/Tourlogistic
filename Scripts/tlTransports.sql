USE TourLogistic
GO
CREATE TABLE tlFlightsDiscounts(
	FlightDiscountRecID		pkType,
	FlightRecID				pkType,
	ClassTypeID				idType,
	DiscountMinAge			amountType,
	DiscountMaxAge			amountType,
	DiscountPercent			amountType,
	DiscountAmount			amountType,
	DiscountDate			dateType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	CONSTRAINT tlFlightsDiscounts_PK PRIMARY KEY tlFlightsDiscounts(FlightDiscountRecID)
	CONSTRAINT tlFlightsDiscounts_FK FOREIGN KEY FlightRecID(tlFlightsDiscounts) ON DELETE CASCADE ON UPDATE CASCADE
	CONSTRAINT tlFlightsDiscounts_FK FOREIGN KEY ClassTypeID(tlFlightsDiscounts) 
)
GO
	CREATE INDEX tlFlightsDiscounts_idx1 ON tlReqEmployees(ReqEmployeesRecID)
	CREATE INDEX tlFlightsDiscounts_idx1 ON tlReqEmployees(ReqEmployeesRecID)


CREATE TABLE LogtlFlightsDiscounts(
	FlightsDiscountRecID	pkType,
	FlightRecID				pkType,
	ClassTypeID				idType,
	DiscountMinAge			amountType,
	DiscountMaxAge			amountType,
	DiscountPercent			amountType,
	DiscountAmount			amountType,
	DiscountDate			dateType,
	ActionDoneBy			idType,
	ActionDate				dateType,
	InsDelUp				char(1)
) 

CREATE TRIGGER dbo.trg_tlFlightsDiscounts
	ON tlFlightsDiscounts
FOR INSERT, DELETE
AS
SET NOCOUNT ON

	INSERT LogtlFlightsDiscounts ( FlightsDiscountRecID, FlightRecID, ClassTypeID, DiscountMaxAge, DiscountMinAge,
			DiscountPercent, DiscountAmount, DiscountDate, ActionDoneBy, ActionDate, InsDelUp ) 
		SELECT FlightsDiscountRecID, FlightRecID, ClassTypeID, DiscountMaxAge, DiscountMinAge,
		DiscountPercent, DiscountAmount, DiscountDate, ActionDoneBy, ActionDate, 'I'
		FROM inserted  
	
	INSERT LogtlFlightsDiscounts (FlightsDiscountRecID, FlightRecID, ClassTypeID, DiscountMaxAge, DiscountMinAge,
			DiscountPercent, DiscountAmount, DiscountDate, ActionDoneBy, ActionDate, InsDelUp) 
		SELECT FlightsDiscountRecID, FlightRecID, ClassTypeID, DiscountMaxAge, DiscountMinAge,
		DiscountPercent, DiscountAmount, DiscountDate, ActionDoneBy, ActionDate, 'D'
		FROM deleted

/*

	SELECT * FROM tlFlightsDiscounts

*/