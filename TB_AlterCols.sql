USE [TourLogistic]
GO
/****** Object:  StoredProcedure [dbo].[TB_AlterCols]    Script Date: 05/05/2007 15:44:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[TB_AlterCols]
	@TableName	NVARCHAR(75)
AS 
BEGIN
	DECLARE @SQL NVARCHAR(500),
			@AlterTable NVARCHAR(300)
	
	SET @AlterTable =N'ALTER TABLE'

	
	SELECT C.Name TABLE_NAME, B.Name TYPE_NAME, A.Name COLUMN_NAME 
	FROM sys.columns A
		INNER JOIN sys.types B ON A.system_type_id = B.system_type_id AND A.user_type_id = B.user_type_id
		INNER JOIN sys.Objects C ON A.object_id = C.object_id 
	WHERE B.NAME = 'Numeric' AND LEFT(C.NAME,2) = 'tl' AND C.NAME <> 'tlTourRouteFlights'

END



Баазын харьцуулалт дууслаа. Доорхи алдаанууд гарлаа.
NomadsTourLogistic: Error while executing RT_MOD_Triggers
Invalid column name 'ICSalary1'.
Invalid column name 'SLSalary1'.
Invalid column name 'ICSalary2'.
Invalid column name 'SLSalary2'.
Insert Error: Column name or number of supplied values does not match table definition.
Invalid column name 'BookStatusInfID'.
Invalid column name 'BookStatusInfID'.
Invalid column name 'BookStatusInfID'.
Invalid column name 'BookStatusInfID'.
Invalid column name 'BookStatusInfID'.