USE TourLogistic
GO
CREATE TABLE tlDate(
	Date	dateType PRIMARY KEY
)


DECLARE @date dateType,
		@dt	  dateTime

	SET @date = '2000/01/01'

WHILE @date < '2011/01/01'
BEGIN
	SET @dt = CONVERT(DATETIME, @date)
	SET @dt = @dt + 1
	SET @date = CONVERT(VARCHAR(23), @dt, 111)
	IF NOT EXISTS (SELECT * FROM tlDate WHERE Date = @date )
		INSERT INTO tlDate VALUES(@date)
	
END

SELECT * FROM tlDate
