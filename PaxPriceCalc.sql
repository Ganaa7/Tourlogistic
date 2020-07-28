USE Tourlogistic
GO
DROP PROC PaxPriceCalc
GO
CREATE PROC PaxPriceCalc(
	@TourRecID		pkType,
	@PaxRecID		pkType,
	@ActionDoneBy	idtype
)AS
BEGIN
	DECLARE @RecID			pkType
	DECLARE @CostInfID		pkType
	
	EXEC CREATEPKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT

	EXEC CREATEPKID 'tlPaxPayDtl', 'CostInfID', @CostInfID OUTPUT

	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY A.FlightRecID) + @RecID, TourPaxRecID, A.FlightRecID, 'FL', CONVERT(VARCHAR(23), CONVERT(dATETIME, A.FlightDate), 111) AS Date, 
			   'Y', 'cost4', @CostInfID, ISNULL(AprGroupTotal / AprPaxQty, 0), ISNULL(A.SalePriceCvr, 0), 
			   ISNULL(PlanGroupTotal / PlanPaxQty, 0), ISNULL(B.SalePriceCvr, 0), @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121) 
			 FROM tlAprFlights A
				LEFT OUTER JOIN tlTourFlights B ON A.TourFlightRecID = B.TourFlightRecID
				INNER JOIN tlTourPaxes H   ON A.PassengerRecID = H.PaxRecID AND A.TourRecID = H.TourRecID
				LEFT OUTER JOIN ( SELECT TourRecID, FlightRecID, FlightDate, SUM(SalePriceCvr) AS PlanGroupTotal
									  FROM tlTourFlights 
									  WHERE IsPax = 'N'
									  GROUP BY TourRecID, FlightRecID, FlightDate ) AS C 
											ON B.TourRecID = C.TourRecID AND B.FlightRecID = C.FlightRecID AND B.FlightDate = C.FlightDate
				LEFT OUTER JOIN ( SELECT TourRecID, FlightRecID, FlightDate, COUNT(PassengerRecID) AS PlanPaxQty
									  FROM tlTourFlights 
									  WHERE IsPax = 'Y'
									  GROUP BY TourRecID, FlightRecID, FlightDate ) AS D 
											ON B.TourRecID = D.TourRecID AND B.FlightRecID = D.FlightRecID AND B.FlightDate = D.FlightDate
				LEFT OUTER JOIN ( SELECT TourRecID, FlightRecID, FlightDate, SUM(SalePriceCvr) AS AprGroupTotal
									  FROM tlAprFlights 
									  WHERE IsPax = 'N'
									  GROUP BY TourRecID, FlightRecID, FlightDate ) AS E 
											ON A.TourRecID = E.TourRecID AND A.FlightRecID = E.FlightRecID AND A.FlightDate = E.FlightDate
				LEFT OUTER JOIN ( SELECT TourRecID, FlightRecID, FlightDate, COUNT(PassengerRecID) AS AprPaxQty
									  FROM tlAprFlights
									  WHERE IsPax = 'Y'
									  GROUP BY TourRecID, FlightRecID, FlightDate ) AS F 
											ON A.TourRecID = F.TourRecID AND A.FlightRecID = F.FlightRecID AND A.FlightDate = F.FlightDate
			WHERE A.IsPax = 'Y' AND A.TourRecID = @TourRecID AND A.PassengerRecID = @PaxRecID

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT

	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, AprGroupPrice, 
							AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY A.FlightRecID) + @RecID, TourPaxRecID, A.FlightRecID, 'FL', CONVERT(VARCHAR(23), CONVERT(dATETIME, A.FlightDate), 111) AS Date,
			    'Y', 'cost4', @CostInfID, 0, 0, ISNULL(AprGroupPrice / AprPaxQty, 0), ISNULL(A.SalePriceCvr, 0), @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)  
			FROM tlTourFlights A
				INNER JOIN tlTourPaxes B ON A.PassengerRecID = B.PaxRecID AND A.TourRecID = B.TourRecID
				LEFT OUTER JOIN (SELECT TourRecID, FlightRecID, FlightDate, SUM(SalePriceCvr) as AprGroupPrice
									 FROM tlTourFlights 	
									 WHERE IsPax = 'N'
								 GROUP BY TourRecID, FlightRecID, FlightDate ) AS C 
									ON A.TourRecID = C.TourRecID AND A.FlightRecID = C.FlightRecID AND A.FlightDate = C.FlightDate
				LEFT OUTER JOIN ( SELECT TourRecID, FlightRecID, FlightDate, COUNT(PassengerRecID) AS AprPaxQty
									  FROM tlTourFlights
									  WHERE IsPax = 'Y'
								  GROUP BY TourRecID, FlightRecID, FlightDate ) AS F 
										ON A.TourRecID = F.TourRecID AND A.FlightRecID = F.FlightRecID AND A.FlightDate = F.FlightDate
			WHERE A.IsPax = 'Y' AND TourFlightRecID NOT IN (SELECT TourFlightRecID FROM tlAprFlights WHERE TourFlightRecID <> 0 )
				  AND A.TourRecID = @TourRecID AND A.PassengerRecID = @PaxRecID

	-- Train 

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, 
							AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY B.TrainRecID) + @RecID, TourPaxRecID, B.TrainRecID, 'TR', CONVERT(VARCHAR(23), CONVERT(DATETIME, B.TrainDate), 111) AS Date, 
				'Y', 'cost4', @CostInfID, ISNULL(AprPrice / AprPaxQty, 0), ISNULL(B.SalePriceCvr, 0), 
				ISNULL(PlanPrice / PlanPaxQty, 0), ISNULL(C.SalePriceCvr, 0), @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)  
			FROM tlTourPaxes A
				INNER JOIN tlAprTrain B ON A.TourRecID = B.TourRecID AND A.PaxRecID = B.PassengerRecID
				LEFT OUTER JOIN tlTourTrains C ON B.TourTrainRecID = C.TourTrainRecID
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, SUM(SalePriceCvr) AS PlanPrice
									  FROM tlTourTrains 
									  WHERE IsPax = 'N'
									  GROUP BY TourRecID, TrainRecID, TrainDate ) AS D 
											ON B.TourRecID = D.TourRecID AND B.TrainRecID = D.TrainRecID AND B.TrainDate = D.TrainDate
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, COUNT(PassengerRecID) AS PlanPaxQty
									  FROM tlTourTrains 
									  WHERE IsPax = 'Y'
									  GROUP BY TourRecID, TrainRecID, TrainDate ) AS E 
											ON B.TourRecID = E.TourRecID AND B.TrainRecID = E.TrainRecID AND B.TrainDate = E.TrainDate
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, SUM(SalePriceCvr) AS AprPrice
									  FROM tlAprTrain 
									  WHERE IsPax = 'N'
									  GROUP BY TourRecID, TrainRecID, TrainDate) AS F 
											ON B.TourRecID = F.TourRecID AND B.TrainRecID = F.TrainRecID AND B.TrainDate = F.TrainDate
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, COUNT(PassengerRecID) AS AprPaxQty
									  FROM tlAprTrain
									  WHERE IsPax = 'Y'
									  GROUP BY TourRecID, TrainRecID, TrainDate ) AS H 
											ON B.TourRecID = H.TourRecID AND B.TrainRecID = H.TrainRecID AND B.TrainDate = H.TrainDate
		WHERE B.TourRecID = @TourRecID AND B.PassengerRecID = @PaxRecID

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, 
							AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY C.TrainRecID) + @RecID, TourPaxRecID, C.TrainRecID, 'TR', CONVERT(VARCHAR(23), CONVERT(DATETIME, C.TrainDate), 111) AS Date, 
			   'Y', 'cost4', @CostInfID, 0, 0, ISNULL(PlanPrice / PlanPaxQty, 0), ISNULL(C.SalePriceCvr, 0), @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)  
			FROM tlTourPaxes A
				INNER JOIN tlTourTrains C ON A.TourRecID = C.TourRecID AND A.PaxRecID = C.PassengerRecID
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, SUM(SalePriceCvr) AS PlanPrice
									  FROM tlTourTrains 
									  WHERE IsPax = 'N'
									  GROUP BY TourRecID, TrainRecID, TrainDate ) AS D 
											ON C.TourRecID = D.TourRecID AND C.TrainRecID = D.TrainRecID AND C.TrainDate = D.TrainDate
				LEFT OUTER JOIN ( SELECT TourRecID, TrainRecID, TrainDate, COUNT(PassengerRecID) AS PlanPaxQty
									  FROM tlTourTrains 
									  WHERE IsPax = 'Y'
									  GROUP BY TourRecID, TrainRecID, TrainDate ) AS E 
											ON C.TourRecID = E.TourRecID AND C.TrainRecID = E.TrainRecID AND C.TrainDate = E.TrainDate
			WHERE C.TourRecID = @TourRecID AND C.PassengerRecID = @PaxRecID 
				  AND TourTrainRecID NOT IN (SELECT TourTrainRecID FROM tlAprTrain WHERE TourTrainRecID <> 0)

	-- Vehicles script here

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, AprGroupPrice, 
								AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY C.TourPaxRecID) + @RecID, C.TourPaxRecID, B.CarInfID, 'CA', D.Date, 'Y', 'cost4', @CostInfID,
				0, 0, A.RentPriceCvr, 0, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121) 
			FROM tlAprVehicles A
				LEFT OUTER JOIN tlTourVehicles E	ON A.TourVehiclesRecID = E.TourVehiclesRecID 
				INNER JOIN tlCars B		    ON A.CarID = B.CarID
				INNER JOIN tlTourPaxes C    ON A.TourRecID = C.TourRecID
				CROSS JOIN tlDate	   D  
			WHERE A.StartDate <= D.Date AND A.EndDate >= D.Date AND A.TourRecID = @TourRecID AND PaxRecID = @PaxRecID

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl(RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, AprGroupPrice, 
								AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY C.TourPaxRecID) + @RecID, C.TourPaxRecID, CarInfID, 'CA', D.Date, 'Y', 'cost4', @CostInfID,
				0, 0, ISNULL(A.RentPriceCvr, 0), 0, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121) 
			FROM tlTourVehicles A
				INNER JOIN tlCars B		  ON A.CarID = B.CarID
				INNER JOIN tlTourPaxes C  ON A.TourRecID = C.TourRecID
				CROSS JOIN tlDate	   D  
			WHERE A.StartDate <= D.Date AND A.EndDate >= D.Date AND A.TourRecID = @TourRecID AND PaxRecID = @PaxRecID
				  AND A.TourVehiclesRecID NOT IN ( SELECT TourVehiclesRecID FROM tlAprVehicles WHERE TourRecID = @TourRecID)

	-- City vehicles 
	
	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl( RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, 
							 AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY C.TourPaxRecID) + @RecID, C.TourPaxRecID, B.CarInfID, 'CA', D.Date, 'Y', 'cost4', @CostInfID,
				ISNULL(A.RentPriceCvr, 0),  0, 0, 0, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121) 
			FROM tlAprCityVehicles A
				INNER JOIN tlCars             B ON A.CarID = B.CarID
				INNER JOIN tlTourPaxes        C ON A.TourRecID = C.TourRecID
				LEFT OUTER JOIN tlTourCityVehicles E ON A.TourCityVeRecID = E.TourCityVeRecID
				CROSS JOIN tlDate			  D  
			WHERE A.StartDate <= D.Date AND A.EndDate >= D.Date AND A.TourRecID = @TourRecID AND PaxRecID = @PaxRecID

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	
	INSERT INTO tlPaxPayDtl( RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID,
							 AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY C.TourPaxRecID) + @RecID, C.TourPaxRecID, B.CarInfID, 'CA', D.Date, 'Y', 'cost4', @CostInfID, 
				0, 0, ISNULL(A.RentPriceCvr, 0), 0, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121) 
			FROM tlTourCityVehicles			  A
				INNER JOIN tlCars             B ON A.CarID = B.CarID
				INNER JOIN tlTourPaxes        C ON A.TourRecID = C.TourRecID
				CROSS JOIN tlDate			  D  
			WHERE A.StartDate <= D.Date AND A.EndDate >= D.Date AND A.TourRecID = @TourRecID AND C.PaxRecID = @PaxRecID
				  AND TourCityVeRecID NOT IN (SELECT TourCityVeRecID FROM tlAprCityVehicles WHERE TourRecID = @TourRecID )
	
	-- Animal here

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT

	INSERT INTO tlPaxPayDtl( RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID, 
							 AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY A.TourRecID) + @RecID as RowRecID, C.TourPaxRecID, A.TransportInfID, 'AN', A.Date, 
			   'Y', 'cost4', @CostInfID, ISNULL((B.PlanPrice / D.EmpQty), 0), ISNULL(A.RentPriceCvr, 0), 0, 0, 
				@ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
			FROM tlAprAnimals A
				INNER JOIN tlTourPaxes C ON A.TourRecID = C.TourRecID AND A.GuestRecID = C.PaxRecID
				LEFT OUTER JOIN (SELECT TourRecID, GuestRecID, SUM(RentPriceCvr) AS PlanPrice
									FROM tlAprAnimals 
									WHERE IsPax  = 'Y' AND TourRecID = @TourRecID AND GuestRecID = @PaxRecID
									GROUP BY TourRecID, GuestRecID ) AS B
										 ON A.TourRecID = B.TourRecID AND A.GuestRecID = B.GuestRecID
				LEFT OUTER JOIN (SELECT TourRecID, GuestRecID, COUNT(GuestRecID) as EmpQty
									FROM tlAprAnimals 
									WHERE IsPax = 'N' AND TourRecID = @TourRecID AND GuestRecID = @PaxRecID
									GROUP BY TourRecID, GuestRecID 	) AS D
										 ON A.TourRecID = D.TourRecID AND A.GuestRecID = D.GuestRecID
				LEFT OUTER JOIN tlTourAnimals E ON A.TourAnimalRecID = E.TourAnimalRecID 
			WHERE A.TourRecID = @TourRecID AND A.GuestRecID = @PaxRecID

	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT

	INSERT INTO tlPaxPayDtl( RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID,
							 AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY A.TourRecID) + @RecID as RowRecID, C.TourPaxRecID, A.TransportInfID, 'AN', A.Date, 
			   'Y', 'cost4', @CostInfID, 0, 0, ISNULL((B.PlanPrice / D.EmpQty), 0), A.RentPriceCvr, @ActionDoneBy, CONVERT(VARCHAR(23), GETDATE(), 121)
			FROM tlTourAnimals A 
				LEFT OUTER JOIN (SELECT TourRecID, GuestRecID, SUM(RentPriceCvr) AS PlanPrice
									FROM tlTourAnimals 
									WHERE IsPax  = 'Y' AND TourRecID = @TourRecID AND GuestRecID = @PaxRecID
								    GROUP BY TourRecID, GuestRecID ) AS B
										 ON A.TourRecID = B.TourRecID AND A.GuestRecID = B.GuestRecID
				LEFT OUTER JOIN (SELECT TourRecID, GuestRecID, COUNT(GuestRecID) as EmpQty
									FROM tlTourAnimals 
									WHERE IsPax = 'N' AND TourRecID = @TourRecID AND GuestRecID = @PaxRecID	
									GROUP BY TourRecID, GuestRecID ) AS D
										 ON A.TourRecID = D.TourRecID AND A.GuestRecID = D.GuestRecID
			   INNER JOIN tlTourPaxes C  ON A.TourRecID = C.TourRecID AND A.GuestRecID = C.PaxRecID
			WHERE A.TourAnimalRecID NOT IN ( SELECT TourAnimalRecID FROM tlAprAnimals WHERE TourAnimalRecID <> 0)
				  AND A.TourRecID = @TourRecID AND A.GuestRecID = @PaxRecID

	-- AccomodationType
	EXEC CreatePKID 'tlPaxPayDtl', 'RowRecID', @RecID OUTPUT
	EXEC CREATEPKID 'tlPaxPayDtl', 'CostInfID', @CostInfID OUTPUT

	INSERT INTO tlPaxPayDtl( RowRecID, TourPaxRecID, ExpenseInfID, ExpenseTypeID, ExpenseDate, IsCheck, CostType, CostInfID,
							 AprGroupPrice, AprPaxPrice, PlanGroupPrice, PlanPaxPrice, ActionDoneBy, ActionDate)
		SELECT ROW_NUMBER() OVER (ORDER BY A.TourRecID) AS RowRecID + @RecID, B.TourPaxRecID, A.AccomodationInfID, 
			   A.AccomodationTypeID, A.Date, 'cost1', @CostInfID, 
			FROM tlAprAccomodations A
				INNER JOIN tlTourPaxes B			  ON A.TourRecID = B.TourRecID AND A.GuestRecID = B.PaxRecID	
				LEFT OUTER JOIN tlTourAccomodations	C ON A.TourAccRecID = C.TourAccRecID
				LEFT OUTER JOIN ( 	SELECT A.TourRecID, A.AccomodationInfID, A.AccomodationTypeID, A.Date, COUNT(A.GuestRecID) AS StaffQty
										FROM tlAprAccomodations	A
											LEFT OUTER JOIN tlTourAccomodations	B ON A.TourAccRecID = B.TourAccRecID			
										WHERE A.TourRecID = @TourRecID AND A.GuestRecID = @PaxRecID
										GROUP BY A.TourRecID, A.AccomodationInfID, A.AccomodationTypeID, A.Date	) AS D 
							ON A.TourRecID = D.TourRecID AND A.AccomodationInfID = D.AccomodationInfID AND 

		SELECT * FROM tlAprAccomodations	
		SELECT * FROM tlTourAccomodations

END
GO
EXEC PaxPriceCalc 1987051600001, 1987051600006, 'Admin' 
/*

	SELECT A.TourRecID, A.AccomodationInfID, A.AccomodationTypeID, A.Date, COUNT(A.GuestRecID) AS StaffQty
		FROM tlAprAccomodations	A
		LEFT OUTER JOIN tlTourAccomodations	B ON A.TourAccRecID = B.TourAccRecID			
	GROUP BY A.TourRecID, A.AccomodationInfID, A.AccomodationTypeID, A.Date 	

	SELECT * FROM tlAprAccomodations	
	SELECT * FROM tlTourAccomodations

	SELECT * FROM tlPaxPayDtl

	DELETE FROM tlPaxPayDtl

	SELECT * FROM ssSystemconstants
		WHERE Type = 'accomodationType'

	SELECT * FROM ssSystemconstants
		WHERE Type = 'costType'

	SELECT * FROM tlTourAccomodations	
	SELECT * FROM tlAprAccomodations	

	SELECT *
		FROM tlAprAccomodations	A
		LEFT OUTER JOIN tlTourAccomodations	B ON A.TourAccRecID = B.TourAccRecID			

	SELECT * FROM tlPaxPayDtl
	SELECT * FROM tlAprAnimals
	SELECT * FROM tlTourCityVehicles
	SELECT * FROM tlAprCityVehicles

	SELECT * FROM tlTourVehicles
	SELECT * FROM tlAprVehicles
	SELECT * FROM tlTourPaxes
	SELECT * FROM tlTransports
	SELECT * FROM tlCars
	SELECT * FROM tlTourPaxes

	RT_DB_BackUP
	
	SELECT * FROM tlTourPaxes
	SELECT * FROM tlPaxPayDtl
	SELECT * FROM tlAprFlights
	SELECT * FROM tlTourFlights 
	SELECT * FROM tlAprTrain

	SELECT '' AS FLights, Approved, Planned, Approved - Planned AS Diff
		FROM 
		(SELECT SUM(EmpAmt / PaxQty + Amt) AS Approved
			FROM (SELECT TourRecID, SUM(SalePriceCvr) EmpAmt
					FROM tlAprFlights 
					WHERE IsPax = 'N'
				  GROUP BY TourRecID ) AS A
				INNER JOIN  ( SELECT TourRecID, COUNT(PassengerRecID) AS PaxQty, SUM(SalePriceCvr) AS Amt
								FROM tlAprFlights 
								WHERE IsPax = 'Y'
								GROUP BY TourRecID ) AS B ON A.TourRecID = B.TourRecID) AS A, 
		(SELECT SUM(EmpAmt / PaxQty + Amt) AS Planned
			FROM (SELECT TourRecID, SUM(SalePriceCvr) EmpAmt
					FROM tlTourFlights 
					WHERE IsPax = 'N'
				  GROUP BY TourRecID ) AS A
				INNER JOIN  ( SELECT TourRecID, COUNT(PassengerRecID) AS PaxQty, SUM(SalePriceCvr) AS Amt
								FROM tlTourFlights
								WHERE IsPax = 'Y'
								GROUP BY TourRecID ) AS B ON A.TourRecID = B.TourRecID) AS B

	SELECT SUM(EmpAmt / PaxQty + Amt) AS Approved
		FROM (SELECT TourRecID, FlightRecID, FlightDate, SUM(SalePriceCvr) EmpAmt
				FROM tlAprFlights 
				WHERE IsPax = 'N'
			  GROUP BY TourRecID ) AS A
				INNER JOIN  ( SELECT TourRecID, FlightRecID, FlightDate, COUNT(PassengerRecID) AS PaxQty, SUM(SalePriceCvr) AS Amt
								FROM tlAprFlights 
								WHERE IsPax = 'Y'
								GROUP BY TourRecID, FlightRecID, FlightDate ) AS B ON A.TourRecID = B.TourRecID
*/