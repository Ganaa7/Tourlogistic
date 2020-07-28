USE TourLogistic
GO
SELECT * FROM tlAccomodationsDiscounts

CREATE TABLE tlAccomodationsDiscounts(
	AccDiscountInfID	pkType PRIMARY KEY,
	AccomodationInfID	pkType FOREIGN KEY REFERENCES tlAccomodationsPrices (AccProductPriceInfID) ON UPDATE CASCADE ON DELETE CASCADE,
	AccProductTypeInfID pkType,
	DiscountMinAge		amountType,
	DiscountMaxAge		amountType,
	DiscountPercent		amountType,
	DiscountAmount		amountType,
	DiscountDate		dateType,
	ActionDoneBy		idType,
	ActionDate			dateType
)

CREATE TABLE LogtlAccomodationsDiscounts(
	AccDiscountInfID	pkType,
	AccomodationInfID	pkType,
	AccProductTypeInfID pkType,
	DiscountMinAge		amountType,
	DiscountMaxAge		amountType,
	DiscountPercent		amountType,
	DiscountAmount		amountType,
	DiscountDate		dateType,
	ActionDoneBy		idType,
	ActionDate			dateType,
	
)

CREATE TRIGGER TRI_DEL_tlAccomodationsDiscounts ON tlAccomodationsDiscounts 
FOR INSERT, DELETE 
AS
BEGIN
	DECLARE @lastModification dateType
	SET @lastModification = CONVERT(VARCHAR(23), GETDATE(), 21)
	UPDATE LastLocalModifications SET LastModification = @lastModification  WHERE TableName ='tlAccomodations'
	INSERT INTO LogtlAccomodationsDiscounts 
	SELECT 
		AccDiscountInfID, AccomodationInfID, AccProductTypeInfID, DiscountMinAge, DiscountMaxAge, DiscountPercent, DiscountAmount, DiscountDate, 'sa', @lastModification
			FROM deleted
END

----------tlAccomodations -----------------

CREATE TABLE tlAccomodations(
	AccomodationInfID		pkType PRIMARY KEY,
	AccomodationID			idType,
	DescriptionL			descType,
	DescriptionF			descType,
	DescriptionD			descType,
	PointRegisterRecID		pkType FOREIGN KEY REFERENCES tlPointRegistrations(PointRegisterRecID) ON UPDATE CASCADE ON DELETE CASCADE ,
	AccomodationTypeID		idType,
	Address					NVARCHAR,
	WebAddress				NVARCHAR,
	IsContract				CHAR(1),
	IsVoucher				CHAR(1),
	RemarkL					NVARCHAR,
	RemarkF					NVARCHAR,
	RemarkD					NVARCHAR,
	ActionDoneBy			idType,
	ActionDate				dateType 
)


CREATE TABLE LogtlAccomodations(
	AccomodationInfID		pkType,
	AccomodationID			idType,
	DescriptionL			descType,
	DescriptionF			descType,
	DescriptionD			descType,
	PointRegisterRecID		pkType,
	AccomodationTypeID		idType,
	Address					NVARCHAR(256),
	WebAddress				NVARCHAR(256),
	IsContract				CHAR(1),
	IsVoucher				CHAR(1),
	RemarkL					NVARCHAR(512),
	RemarkF					NVARCHAR(512),
	RemarkD					NVARCHAR(512),
	ActionDoneBy			idType,
	ActionDate				dateType
)


CREATE TRIGGER TRI_DEL_tlAccomodations ON tlAccomodations FOR DELETE AS
BEGIN
	DECLARE @lastModification dateType
	SET @lastModification = CONVERT(VARCHAR(23), GETDATE(), 21)
	UPDATE LastLocalModifications SET LastModification = @lastModification  WHERE TableName ='tlAccomodations'
	INSERT INTO LogtlAccomodations 
	SELECT 
		AccomodationInfID, AccomodationID, DescriptionL,DescriptionF, DescriptionD, PointRegisterRecID,AccomodationTypeID,Address, WebAddress, IsContract,IsVoucher, RemarkL, RemarkF, RemarkD,'sa', @lastModification
			FROM deleted
END



