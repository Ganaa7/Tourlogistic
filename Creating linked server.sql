
EXEC sp_addlinkedserver 'TemplateExcel', 'Jet 4.0', 
   'Microsoft.Jet.OLEDB.4.0', 
   'D:\Trips.xls',   
    NULL, 'Excel 5.0'
GO

EXEC sp_addlinkedsrvlogin 'TemplateExcel', 'false', 'sa', 'Admin', NULL 

GO
dbo.ASCIIToUniCode(XLS.UNAME)

SELECT * FROM OPENQUERY(TemplateExcel, 'SELECT * From [Sheet4$]') XLS

DECLARE @CHAR NVARCHAR(30)
SELECT @CHAR = UNAME
	FROM #TMP
	WHERE UCODE = '0001'
SELECT @CHAR


/*
EXEC sp_droplinkedsrvlogin 'TemplateExcel', sa
GO
EXEC sp_dropserver N'TemplateExcel'
GO
*/

sp_attach_db 'OldSystemInfo', 'D:\Update\New Folder\borUndurSystemInfo.mdf', 'D:\Update\New Folder\borUndurSystemInfolog.mdf'

sp_attach_db 'oldsysteminfo',
'D:\Update\New Folder\borUndurSystemInfo.mdf',
'D:\Update\New Folder\borUndurSystemInfolog.ldf'


sp_linkedservers
USE Erelbank
SELECT * FROM ssConfigurations WHERE ID = 'Annex'
