USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_SEL_PrtVoucherCamp]    Script Date: 04/17/2007 16:53:11 ******/
DROP PROC TL_SEL_PrtVoucherCamp
GO
CREATE PROC [dbo].[TL_SEL_PrtVoucherCamp](
	@IsLocal		CHAR(1),
	@TourRecID		pkType,
	@CodeInfID		pkType --  Camp, ... InfID	
) AS
BEGIN
	DECLARE @Accomodation TABLE(
		IsPrint			CHAR(1),
		ID				SMALLINT,
		Date			dateType,
		VoucherNum		idType	
	)
	DECLARE @TourAccRecID	pkType,
			@FDate			dateType,
			@Date			dateType,
			@cnt			SMALLINT,
			@ID				SMALLINT

	SET @ID = 1 
	SET @cnt = 1

	DECLARE rqPtr CURSOR FOR
		SELECT TourAccRecID, Date FROM tlTourAccomodations
			WHERE TourRecID = @TourRecID AND AccomodationInfID = @CodeInfID AND AccomodationTypeID = 'accLuxGCamp' OR AccomodationTypeID = 'accStGCamp'
			ORDER BY Date
	
	OPEN rqPtr
	FETCH NEXT FROM rqPtr INTO @TourAccRecID, @Date
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @cnt = 1
		BEGIN
			SET @FDate = @Date
			INSERT INTO @Accomodation(IsPrint, ID, Date, VoucherNum)
				SELECT 'N', @ID, @Date, VoucherNum 
					FROM tlTourAccomodations
					WHERE TourAccRecID = @TourAccRecID 	
		END
		ELSE
		BEGIN
			IF (SELECT CONVERT(VARCHAR(23), DATEADD(dd, 1, CONVERT(DATETIME, @FDate)), 111)) = @Date  
			BEGIN
				INSERT INTO @Accomodation(IsPrint, ID, Date, VoucherNum)	
					SELECT 'N', @ID, @Date, VoucherNum FROM tlTourAccomodations
						WHERE TourAccRecID = @TourAccRecID 
			END
			ELSE 
				IF @FDate <> @Date
				BEGIN
					SET @ID = @ID + 1
					INSERT INTO @Accomodation(IsPrint, ID, Date, VoucherNum)	
						SELECT 'N', @ID, @Date, VoucherNum 
							FROM tlTourAccomodations
							WHERE TourAccRecID = @TourAccRecID 
				END
			SET @FDate = @Date
		END	
			SET @cnt = 0 
		FETCH NEXT FROM rqPtr INTO @TourAccRecID, @Date
	END
	CLOSE rqPtr
	DEALLOCATE rqPtr

	SELECT * FROM @Accomodation
	GROUP BY ID,Date,VoucherNum,IsPrint	
END