	DECLARE @PointDA	pkType, 
			@PointDB	pkType, 
			@Distance	INT

	DECLARE Curs CURSOR FOR
		SELECT PointDA, PointDB, Distance
			FROM tlRoutes

	OPEN Curs
	FETCH NEXT FROM Curs INTO @PointDA, @PointDB, @Distance

	WHILE @@FETCH_STATUS = 0
		BEGIN

		IF NOT EXISTS (SELECT * FROM tlRoutes WHERE PointDA = @PointDB AND PointDB = @PointDA)
		INSERT INTO tlRoutes(PointDA, PointDB, Distance)
			SELECT @PointDB, @PointDA, @Distance

		FETCH NEXT FROM Curs INTO @PointDA, @PointDB, @Distance
		END
	CLOSE Curs
	DEALLOCATE Curs

-- SELECT * FROM tlRoutes
-- DELETE FROM tlRoutes WHERE RouteID > 515
-- SELECT * FROM tlRoutes WHERE PointDA = 174 AND PointDB = 134