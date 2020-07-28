USE [TourLogistic]
GO
/****** Object:  Index [tlTentPrices_Idx0]    Script Date: 07/07/2007 10:48:01 ******/
CREATE UNIQUE NONCLUSTERED INDEX [tlTentPrices_Idx0] ON [dbo].[tlTentPrices] 
(
	[AccomodationProductTypeInfID] ASC,
	[PriceDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


SELECT