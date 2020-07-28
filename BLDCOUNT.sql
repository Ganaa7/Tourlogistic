	
	INSERT INTO @tmpMealType
	  	SELECT Date, 'Y' AS IsPax, Count(Breakfast) Counts, 'mealBreakfast' as MealTypeID
		     FROM tlTourCatering 
			 WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax='Y' AND BreakFast = 'Y'  
			 GROUP BY Date, BreakFast
		UNION 
		SELECT Date, 'Y' AS IsPax, Count(Lunch) Counts, 'mealLunch' as MealTypeID
			FROM tlTourCatering 
			WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax='Y' AND Lunch = 'Y'   
			GROUP BY Date, Lunch
		UNION
		SELECT Date, 'Y' AS IsPax, Count(Dinner) Counts, 'mealDinner' as MealTypeID
			FROM tlTourCatering 
			WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax='Y' AND Dinner = 'Y' 
			GROUP BY Date, Dinner
		UNION 
		SELECT Date, 'N' AS IsPax, Count(Breakfast) Counts, 'mealBreakfast' as MealTypeID
		     FROM tlTourCatering 
			 WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax = 'N' AND BreakFast = 'Y'  
			 GROUP BY Date, BreakFast
		UNION 
		SELECT Date, 'N' AS IsPax, Count(Lunch) Counts, 'mealLunch' as MealTypeID
			FROM tlTourCatering 
			WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax = 'N' AND Lunch = 'Y'   
			GROUP BY Date, Lunch
		UNION 
		SELECT Date, 'N' AS IsPax, Count(Dinner) Counts, 'mealDinner' as MealTypeID
			FROM tlTourCatering 
			WHERE CateringTypeID = 'caterNamedCook' AND TourRecID = @TourRecID AND IsPax='N' AND Dinner = 'Y' 
			GROUP BY Date, Dinner
