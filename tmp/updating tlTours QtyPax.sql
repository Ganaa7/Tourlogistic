	DECLARE @TourInfID	pkType,
			@QtyPax		INT

	DECLARE Cur CURSOR FOR
		SELECT TourInfID, COUNT(TourInfID) AS QtyPax
			FROM tlPaxsTours
			GROUP BY TourInfID

	OPEN Cur
	FETCH NEXT FROM Cur INTO @TourInfID, @QtyPax
	WHILE @@FETCH_STATUS = 0
		BEGIN

		UPDATE tlTours SET QtyPax = @QtyPax
			WHERE TourInfID = @TourInfID
		
		FETCH NEXT FROM Cur INTO @TourInfID, @QtyPax
		END
	CLOSE Cur
	DEALLOCATE Cur

/*
SELECT * FROM tlPaxsTours

SELECT * FROM tlTours

UPDATE tlTours SET QtyPax = 0

*/