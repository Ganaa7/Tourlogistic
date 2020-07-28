--USE LinkDiamond

--DROP PROC ssAddLinkedServerXLS 
GO
CREATE PROC ssAddLinkedServerXLS @XlsFileName NVARCHAR(500) AS
BEGIN
	EXEC sp_addlinkedserver 'TemplateExcel', 'Jet 4.0', 
		'Microsoft.Jet.OLEDB.4.0', 
		@XlsFileName,   
		NULL, 'Excel 5.0'
	
	EXEC sp_addlinkedsrvlogin 'TemplateExcel', 'false', 'sa', 'Admin', NULL 
END

--DROP PROC ssDropLinkedServerXLS 
GO
CREATE PROC ssDropLinkedServerXLS AS
BEGIN
	EXEC sp_droplinkedsrvlogin 'TemplateExcel', sa

	EXEC sp_dropserver N'TemplateExcel'
END

	EXEC ssDropLinkedServerXLS

	EXEC ssAddLinkedServerXLS 'D:\Trips.xls' -- server deeree huulna	

	USE TourLogistic
		
	DECLARE @MaxReqID	pkType,
			@SQL		NVARCHAR(MAX)

	SELECT @MaxReqID = MAX(RequestRecID) 
		FROM tlRequest
	
	SET @SQL = 'DECLARE @tmpRequest TABLE(
						ReqRecID	pkType  IDENTITY('+CONVERT(NVARCHAR(18), @MaxReqID)+', 1),
						DescF		descType, 
						ID			idType,
						Code		idType,
						Company		idType,
						StartDate	dateType,
						EndDate		dateType
					)
	
	INSERT INTO @tmpRequest(DescF, ID, Code, Company, StartDate, EndDate)
		SELECT Trips, ID, Code, Co, CONVERT(VARCHAR(23), StartDate, 111), CONVERT(VARCHAR(23), EndDate, 111)
			FROM OPENQUERY(TemplateExcel, ''SELECT * From [sheet4$]'') XLS	
	
--		SELECT Trips, DescF, ID, Code, Co, CONVERT(VARCHAR(23), StartDate, 111), CONVERT(VARCHAR(23), EndDate, 111)
--			FROM OPENQUERY(TemplateExcel, ''SELECT * From [sheet4$]'') XLS	
		
		SELECT * FROM @tmpRequest
		SELECT * FROM tlRequest

--		SELECT ReqRecID, ID+CASE WHEN LEN(Code) = 2 THEN ''00'' ELSE CASE WHEN LEN(Code) = 1 THEN ''000'' END ''''+Code, 
--				CASE WHEN A.Company IN (SELECT CustomerID FROM VIEW_ssCustomers) 
--				THEN (SELECT DescriptionL FROM VIEW_ssCustomers WHERE CustomerID = A.CustomerID) 
--				ELSE ''None'' END Company, StartDate, EndDate
--			FROM @tmpRequest A'

	PRINT @SQL
	EXEC(@SQL)	

	SELECT CONVERT(VARCHAR(23), 'May 24 2007 12:00AM', 121)

--	INSERT INTO tlRequest
--		SELECT * FROM @tmpRequest

/*
	SELECT * FROM tlRequest
	SELECT * FROM tlReqTypes
	SELECT * FROM tlTours

	INSERT INTO tlRequest VALUES(1987062300001, 'FIT001', 0, '', NULL, 2, 4, '2007/08/15', '2007/08/15', 0, 1200, '', '', '', '', 'GanaaD', CONVERT(VARCHAR(23), GETDATE(), 121), 20, 'A',   

	SELECT * FROM VIEW_ssCustomers								
		WHERE CustomerInfID = 1986080300001

	USE TourLogistic
		SELECT * FROM VIEW_ssCustomers

DROP PROC InsDataFromXLS
GO
CREATE PROC InsDataFromXLS
AS
BEGIN
	DECLARE @P		VARCHAR(8000),			
			@SQL	NVARCHAR(MAX),
			@Str	VARCHAR(200)

	SET @SQL = '
		USE master  	
		EXEC sp_configure ''show advanced options'', 1  	
		RECONFIGURE WITH OVERRIDE  
		EXEC sp_configure ''xp_cmdshell'', 1	
		RECONFIGURE WITH OVERRIDE  	
		EXEC sp_configure ''show advanced options'', 0'
	EXEC (@SQL)
	DECLARE @tmpXLS TABLE(
			RowID	SMALLINT IDENTITY(1, 1),
			OUTS	NVARCHAR(MAX)
		)

	SET @P = 'dir d:\*.xls'
	INSERT INTO @tmpXLS(OUTS)
	  Execute Master.DBO.XP_CmdShell @P
	
	DECLARE @Outs VARCHAR(200)
	DECLARE CURS FOR 
		SELECT OUTS FROM @tmpXLS
			WHERE OUTS LIKE ('%.xls%')

	OPEN CUR
	FETCH NEXT FROM CURS INTO @Str
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @STR = SUBSTRING((SUBSTRING(@Str , CHARINDEX(',', @STR), CHARINDEX('.xls', @STR))), 5, CHARINDEX('.xls', @STR))

	SET @SQL = '
		USE master 
		EXEC sp_configure ''show advanced options'', 1  	
		RECONFIGURE WITH OVERRIDE  
		EXEC sp_configure ''xp_cmdshell'', 0
		RECONFIGURE WITH OVERRIDE  	
		EXEC sp_configure ''show advanced options'', 0'

	EXEC (@SQL)
END
GO
InsDataFromXLS
	--SELECT SUBSTRING(@IP, @begin, @end - @begin) AS IPAddress
*/
/*
	USE TourLogistic
	GO
	SELECT * FROM tlTours
    SELECT "Employee Names" = SUBSTRING(names,1,CHARINDEX(' ',names)-1) + ', ' + SUBSTRING(names, CHARINDEX(' ',names)+1,1) + '.'
	    FROM Employee
	DECLARE @STR VARCHAR(200)
	SET @STR = 'dont afraid.xls'
	SELECT CHARINDEX(' ', @STR)
--	SELECT SUBSTRING(@STR, 1, CHARINDEX(''))

*/


