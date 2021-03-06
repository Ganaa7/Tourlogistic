USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TL_SEL_Tent]    Script Date: 07/07/2007 10:38:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP PROC [dbo].[TL_SEL_Tent]
go 
CREATE PROC [dbo].[TL_SEL_Tent]
(	
	@InfID pkType, 
	@IsLocal CHAR(1), 
	@SystemLoginDate DATETIME, 
	@XMLParameters NVARCHAR(MAX),
	@UserInfID pkType
)AS
BEGIN	
	Select B.TentPriceInfID, A.TentInfID, B.ActionDoneBy,C.CurrencyID AS CurrencyIDL, D.CurrencyID AS CurrencyIDF,
		   CASE WHEN @IsLocal='Y'THEN A.DescriptionL ELSE A.DescriptionF END TentDescription,
		   PriceDate,CurrencyInfIDL,CurrencyInfIDF,BuyPriceL,BuyPriceF,SalePriceL,SalePriceF,Status = 'UnChanged' 
		From tlTentPrices B
			LEFT OUTER JOIN tlTents A on A.TentInfID = B.TentInfID 	
			LEFT OUTER JOIN View_ssCurrencies C on B.CurrencyInfIDL = C.CurrencyInfID	
			LEFT OUTER JOIN View_ssCurrencies D on B.CurrencyInfIDF = D.CurrencyInfID	
	Where B.TentInfID = @InfID
END

