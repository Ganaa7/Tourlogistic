USE TourLogistic
GO
ALTER TABLE tlPointRegistrations DROP COLUMN PointProvinceID
ALTER TABLE tlLocalRoutes ADD ToLocalRegistrationID	pkType FOREIGN KEY REFERENCES tlLocalRegistrations(LocalRegistrationID)
DROP CONSTRAINT FK__tlLocalRo__FromL__5B3966D3 ;

ALTER TABLE tlPointRegistrations
DROP CONSTRAINT FK__tlPointRe__Point__1FCE8842 ;


SELECT * FROM tlLocalKoordinatens

UPDATE tlLocalKoordinatens SET LocalRegistrationID = LocalRegistrationInfID

ALTER TABLE tlPointRegistrations
ADD CONSTRAINT FK__tlPointRe__Local__0D8FDC76 FOREIGN KEY (PointTypeID)
    REFERENCES tlPointTypes (PointTypeID)  ON UPDATE CASCADE;


USE TourLogistic
GO
SELECT * FROM sys.foreign_keys WHERE name = 'FK__tlPointRe__Point__1FCE8842' object_id = OBJECT_ID('tlPointRegistrations')

SELECT * FROM tlLocalRegistrations


SELECT * FROM tlProvinces

DROP TABLE tlPointRegistrations

SELECT * 
	INTO #TMP
	FROM tlProvinces