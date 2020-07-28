
USE TourLogistic


SELECT * FROM sysobjects WHERE LEFT(name, 2) = 'tl' AND xtype = 'U'

SELECT * FROM tlCurrencies
SELECT * FROM tlLocalKoordinatens
SELECT * FROM tlTourCatering
SELECT * FROM tlRestaurantTypes
SELECT * FROM tlLookUps
SELECT * FROM tlContactTypes
SELECT * FROM tlStaffs
SELECT * FROM tlFuelTypes
SELECT * FROM tlStaffsLanguage
SELECT * FROM tlRestaurants
SELECT * FROM tlStaffTypes
SELECT * FROM tlMealTypes
SELECT * FROM tlTourLevels
SELECT * FROM tlContacts
SELECT * FROM tlTourStatus
SELECT * FROM tlRestaurantMenus
SELECT * FROM tlLanguageTypes
SELECT * FROM tlPositionTypes
SELECT * FROM tlTourDistances
SELECT * FROM tlTours
SELECT * FROM tlVehicles
SELECT * FROM tlTransportTypes
SELECT * FROM tlCountries
SELECT * FROM tlLanguageLevels
SELECT * FROM tlTourTypes
SELECT * FROM tlProvinces
SELECT * FROM tlAccomodationTypes
SELECT * FROM tlLocalRegistrations
SELECT * FROM tlRoomTypes
SELECT * FROM tlTourTransports
SELECT * FROM tlLocalRoutes
SELECT * FROM tlUnitTypes
SELECT * FROM tlLogLookUps
