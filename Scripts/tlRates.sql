USE TourLogistic

--DROP TABLE tlRates
CREATE TABLE tlRates(
	RateRecID  			pkType,
	TourRecID			pkType,	
	TableInfID	 		pkType,
	TableType			CHAR(1),
	RateID 				idType,	
	Rate				SMALLINT,
	QualityInfID 		pkType,	
	CreatedBy			idType,
	CreatedDate			dateType
	CONSTRAINT tlRates_PK PRIMARY KEY(RateRecID),
	CONSTRAINT tlRates_FK1 FOREIGN KEY (TourRecID)
		REFERENCES tlTours(TourRecID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT tlRates_FK2 FOREIGN KEY (QualityInfID)
		REFERENCES tlQualities(QualityInfID) ON DELETE CASCADE ON UPDATE CASCADE
)
GO
	CREATE INDEX tlRate_idx1 ON tlRates(TableInfID)
	CREATE INDEX tlRate_idx2 ON tlRates(TableType)
	CREATE INDEX tlRate_idx3 ON tlRates(RateID)

/*
    SELECT * FROM tlQualities
	SELECT * FROM tlTours

*/