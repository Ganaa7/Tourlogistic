
SELECT * FROM tlProvinces 

UPDATE tlProvinces SET ProvinceInfID = 1 WHERE ProvinceInfID = -1501985515 

SELECT * FROM tlLocalRegistrations 

DECLARE @Cursor			CURSOR,
		@ProvinceInfID	pkType,
		@InfID			pkType

SET @InfID = 2007011600000

SET @Cursor=CURSOR FOR
	SELECT ProvinceInfID
		FROM tlProvinces

OPEN @Cursor
FETCH NEXT FROM @Cursor INTO @ProvinceInfID
WHILE @@FETCH_STATUS = 0
	BEGIN
	
	UPDATE tlProvinces SET ProvinceInfID = @InfID WHERE ProvinceInfID = @ProvinceInfID
	SET @InfID = @InfID + 1

	FETCH NEXT FROM @Cursor INTO @ProvinceInfID
	END
CLOSE @Cursor
DEALLOCATE @Cursor

