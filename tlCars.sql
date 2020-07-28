USE TourLogistic

--DROP TABLE tlCars
CREATE TABLE tlCars(
	CarInfID  			pkType   PRIMARY KEY,
	CarID				idType,	
	DescriptionL 			descType,
	DescriptionF 			descType,	
	DescriptionD 			descType,	
	CustomerInfID			pkType, 
	IsRent					char(1),
	ActionDoneBy			idType,
	ActionDate				dateType)
GO

CREATE UNIQUE INDEX tlCars_Idx0 ON tlCars(CarID)

--DROP TABLE LogtlCars
CREATE TABLE LogtlCars(
	CarInfID  			pkType,
	CarID				idType,	
	DescriptionL 			descType,
	DescriptionF 			descType,	
	DescriptionD 			descType,	
	CustomerInfID			pkType, 
	IsRent					char(1),
	ActionDoneBy			idType,
	ActionDate				dateType)
GO
--DROP TABLE tlCarsDynamicItem
CREATE TABLE tlCarsDynamicItem(
	CarInfID 		pkType FOREIGN KEY REFERENCES tlCars(CarInfID)
							ON DELETE CASCADE ON UPDATE CASCADE,
	DynamicItemInfID	pkType,
	ValueL				descType,
	ValueF				descType)
CREATE UNIQUE INDEX tlCarsDynamicItem_Idx1 ON tlCarsDynamicItem(CarInfID, DynamicItemInfID)
CREATE INDEX tlCarsDynamicItem_Idx2 ON tlCarsDynamicItem(DynamicItemInfID)
GO

--DROP TABLE tlCarsAdditionalValues
CREATE TABLE tlCarsAdditionalValues(
	CarInfID 		pkType FOREIGN KEY REFERENCES tlCars(CarInfID)
							ON DELETE CASCADE ON UPDATE CASCADE,
	AdditionalFieldID	idType,
	ValueL				descType,
	ValueF				descType)
CREATE UNIQUE INDEX ltlCarsAdditionalValues_Idx1 ON tlCarsAdditionalValues(CarInfID, AdditionalFieldID)
CREATE INDEX ltlCarsAdditionalValues_Idx2 ON tlCarsAdditionalValues(AdditionalFieldID)
GO

--DROP TRIGGER TRI_MOD_tlCars
CREATE TRIGGER TRI_MOD_tlCars ON tlCars FOR INSERT, UPDATE AS
BEGIN
	DECLARE @lastModification dateType
	SET @lastModification = CONVERT(VARCHAR(23), GETDATE(), 21)

	UPDATE LastLocalModifications SET LastModification = @lastModification 
		WHERE TableName = 'tlCars'
	UPDATE A SET A.ActionDate = @lastModification 
		FROM tlCars A INNER JOIN inserted B ON A.CarInfID = B.CarInfID
END
GO

--DROP TRIGGER TRI_DEL_tlCars
CREATE TRIGGER TRI_DEL_tlCars ON tlCars FOR  DELETE AS
BEGIN
	DECLARE @lastModification dateType
	SET @lastModification = CONVERT(VARCHAR(23), GETDATE(), 21)

	UPDATE LastLocalModifications SET LastModification = @lastModification 
		WHERE TableName = 'tlCars'
	INSERT INTO LogtlCars SELECT 	CarInfID,CarID,DescriptionL,DescriptionF, DescriptionD, CustomerInfID, IsRent,'sa', @lastModification FROM deleted
END
GO


