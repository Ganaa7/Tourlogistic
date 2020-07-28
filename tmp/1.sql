USE TourLogistic
GO

SELECT * FROM tlProvinces

EXEC sp_addlinkedserver 
   @server = 'TourLogistic_LS', 
   @provider = 'Microsoft.Jet.OLEDB.4.0', 
   @srvproduct = 'OLE DB Provider for Jet',
   @datasrc = 'E:\Interactive\Orshikhoo\travel1.mdb'
GO

EXEC sp_addlinkedsrvlogin 'TourLogistic_LS', 'false', 'sa', 'Admin', NULL 
GO

/*
EXEC sp_droplinkedsrvlogin 'TourLogistic_LS', sa
GO
EXEC sp_dropserver N'123'
GO
*/
SELECT *
		FROM TourLogistic_LS...tbl_MGLprovince

SELECT * 
FROM TourLogistic_LS...tbl_OrteAuswahl
SELECT *
		FROM TourLogistic_LS...tbl_OrteKoordinaten 

SELECT * FROM TourLogistic_LS...tbl_MGLprovince
SELECT * FROM tlProvinces
DELETE FROM tlProvinces
INSERT INTO tlProvinces (CodeID, DescriptionL, DescriptionF, ActionDoneBy, ActionDate)
	SELECT IDProvince, Province, Province, 'Admin', CONVERT(VARCHAR(23), GETDATE(), 21)
		FROM TourLogistic_LS...tbl_MGLprovince
		WHERE Province IS NOT NULL 

SELECT * FROM tlLocalRegistrations
SELECT * FROM TourLogistic_LS...tbl_OrteAuswahl
INSERT INTO tlLocalRegistrations(LocalRegistrationInfID, LocalRegistrationID, DescriptionL, DescriptionF,
		ProvinceInfID, LocalNote, ActionDoneBy, ActionDate)
	SELECT A.ID_OrteMGL, A.ID_OrteMGL_alt, A.NameOrt_MGL, A.NameOrte,  
			B.ProvinceInfID, '', 'Admin', CONVERT(VARCHAR(23), GETDATE(), 21)
		FROM TourLogistic_LS...tbl_OrteAuswahl A
			INNER JOIN tlProvinces B ON A.ProvinceOrt = B.ProvinceID
		WHERE ID_OrteMGL_alt <> '0'

SELECT * FROM tlLocalRoutes
INSERT INTO tlLocalRoutes(LocalRouteInfID, FromLocalRegistrationInfID, ToLocalRegistrationInfID, Distance, 
		RouteTypeInfID, RouteTripDay, RouteInfo, RouteCode)
	SELECT A.ID, A.StreckeOrt_A, A.StreckeOrt_B, A.StreckeDistanz, -292500531, 0, '', 0 
		FROM TourLogistic_LS...tbl_StreckeOrte A
			INNER JOIN tlLocalRegistrations B ON A.StreckeOrt_A = B.LocalRegistrationInfID
			INNER JOIN tlLocalRegistrations C ON A.StreckeOrt_B = C.LocalRegistrationInfID

SELECT * FROM tlRouteTypes
INSERT INTO tlRouteTypes(RouteTypeInfID, RouteTypeID, DescriptionL, DescriptionF, ActionDoneBy, ActionDate)
	SELECT ID, StreckenTypID, StreckenTypBezeichnungEngl, StreckenTypBezeichnungEngl, 'Admin', 
			CONVERT(VARCHAR(23), GETDATE(), 21) 
		FROM TourLogistic_LS...tbl_StreckenTypAuswahl

SELECT * FROM tlLocalKoordinatens
INSERT INTO tlLocalKoordinatens(LocalKoordinatenInfID, LocalRegistrationInfID, KoordinateX, koordinateY)
	SELECT A.ID, A.Ort_ID, A.Koordinate_X, A.Koordinate_Y 
		FROM TourLogistic_LS...tbl_OrteKoordinaten A 
			INNER JOIN tlLocalRegistrations B ON A.Ort_ID = B.LocalRegistrationInfID

USE TourLogistic
SELECT * FROM tlLocalRegistrations
SELECT 	*	FROM TourLogistic_LS...tbl_StreckeOrte A INNER JOIN tlPointRegistrations B ON 

SELECT * FROM tlPointRegistrations WHERE PointNameF IN ( '-')
'Altai', 
'Bayan ondor', 
'Bayantsagaan', 
'Bulgan', 
'Eej Khad ( mother rock)', 
'Soyot' )

DELETE FROM tlPointRegistrations WHERE PointRegisterID IN (163)

INSERT INTO tlRoutes (PointDA, PointDB, Distance)
SELECT B.PointRegisterID AS PointDA, C.PointRegisterID AS PointDB, A.StreckeDistanz AS Distance 
	FROM (
SELECT B.NameOrte AS Apoint, C.NameOrte AS BPoint, A.StreckeDistanz
	FROM TourLogistic_LS...tbl_StreckeOrte A
		LEFT OUTER JOIN TourLogistic_LS...tbl_OrteAuswahl B ON A.StreckeOrt_A = B.ID_OrteMGL
		LEFT OUTER JOIN TourLogistic_LS...tbl_OrteAuswahl C ON A.StreckeOrt_B = C.ID_OrteMGL
	WHERE B.NameOrte NOT IN (
'Altai', 
'Bayan ondor', 
'Bayantsagaan', 
'Bulgan', 
'Eej Khad ( mother rock)', 
'Soyot')
AND
C.NameOrte NOT IN (
'Altai', 
'Bayan ondor', 
'Bayantsagaan', 
'Bulgan', 
'Eej Khad ( mother rock)', 
'Soyot')
AND B.NameOrte IS NOT NULL AND C.NameOrte IS NOT NULL) A 
LEFT OUTER JOIN tlPointRegistrations B ON A.Apoint = B.PointNameF
LEFT OUTER JOIN tlPointRegistrations C ON A.Bpoint = C.PointNameF

SELECT * FROM tlPointRegistrations
SELECT * FROM tlRoutes

DELETE FROM tlRoutes WHERE RouteID IN (2, 3)

NameOrte

SELECT A.NameOrte--,  B.PointNameF
	FROM TourLogistic_LS...tbl_OrteAuswahl A INNER JOIN tlPointRegistrations B ON A.NameOrte = B.PointNameF
	GROUP BY A.NameOrte
	HAVING COUNT(A.NameOrte) > 1

	WHERE B.PointNameF IS NULL

SELECT * FROM TourLogistic_LS...tbl_OrteAuswahl WHERE NameOrte IN (
'Altai', 
'Bayan ondor', 
'Bayantsagaan', 
'Bulgan', 
'Eej Khad ( mother rock)', 
'Soyot' )