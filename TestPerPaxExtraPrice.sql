USE NomadsTourLogistic
GO
--TEST PerPaxPriceExtra

	SELECT * FROM tlReqAccomodation
		WHERE  RequestRecID = 2007062500079 AND '2007/07/04' BETWEEN CheckInDate AND CONVERT(VARCHAR(23), (CONVERT(DATETIME, CheckOutDate) - 1), 111)

	-- AND 
	SELECT * FROM tlTourAccomodations
		WHERE TourRecID = 2007070300006 AND Date = '2007/07/04'


