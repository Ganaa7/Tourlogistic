
USE TourLogistic

/*
SELECT * FROM tlPointRegistrations
*/

		--Restrict the password to 0-9 and a-z
		SET @loop = 1
		WHILE @loop = 1
		BEGIN
			SET @charindex = CONVERT(INT, RAND() * 600)
			IF @charindex BETWEEN 48 AND 57 OR @charindex BETWEEN 97 AND 122
				 SET @loop = 0
		END

		--Accumulate characters for password string
		SET @char = CHAR(@charindex)
		SET @string = @string + @char
		SET @counter = @counter + 1


	DECLARE @PointRegisterID	NUMERIC(18), 
			@CoordinateX		INT, 
			@CoordinateY		INT

	DECLARE Curs CURSOR FOR
		SELECT PointRegisterID
			FROM tlPointRegistrations

	OPEN Curs
	FETCH NEXT FROM Curs INTO @PointRegisterID

	WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @CoordinateX = CONVERT(INT, RAND() * 600)
		SET @CoordinateY = CONVERT(INT, RAND() * 270)

		IF @CoordinateX > 200 AND @CoordinateX < 400
		UPDATE tlPointRegistrations SET CoordinateX = - @CoordinateX, CoordinateY = @CoordinateY
			WHERE PointRegisterID = @PointRegisterID

		ELSE
		UPDATE tlPointRegistrations SET CoordinateX = @CoordinateX, CoordinateY = @CoordinateY
			WHERE PointRegisterID = @PointRegisterID

		FETCH NEXT FROM Curs INTO @PointRegisterID
		END
	CLOSE Curs
	DEALLOCATE Curs