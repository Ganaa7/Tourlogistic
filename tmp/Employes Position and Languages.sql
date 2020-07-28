

SELECT * 
	FROM tlEmployees A 
		INNER JOIN tlPositionTypes B ON A.PositionTypeID = B.CodeID
		INNER JOIN tlEmployeeLanguages C ON A.EmployeeInfID = C.EmployeeInfID
		INNER JOIN tlLanguageTypes D ON C.LanguageTypeID = D.CodeID
		INNER JOIN tlLanguageLevels D ON C.LanguageLevelID = D.CodeID

SELECT * FROM tlEmployeeLevelTypes

SELECT * FROM tlPositionTypes

SELECT * FROM tlEmployeeLanguages

SELECT * FROM tlLanguageTypes
SELECT * FROM tlLanguageLevels

