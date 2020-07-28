
	 SELECT Date, ISNULL([BreakFast], 0) BreakFast, ISNULL([Lunch], 0) Lunch, ISNULL([Dinner], 0) Dinner
		INTO #tmpMealNum
		FROM (SELECT Date, Count(Breakfast) Counts, 'BreakFast' as MealType
			     FROM tlTourCatering 
				 WHERE CateringTypeID = 'caterRestaurant' AND TourRecID = @TourRecID AND IsPax='Y' AND BreakFast = 'Y'  
				 GROUP BY Date, BreakFast
			  UNION 
			  SELECT Date, Count(Lunch) Counts, 'Lunch' as MealType
				 FROM tlTourCatering 
				 WHERE CateringTypeID = 'caterRestaurant' AND TourRecID = @TourRecID AND IsPax='Y' AND Lunch = 'Y'   
				 GROUP BY Date, Lunch
			  UNION
			  SELECT Date, Count(Dinner) Counts, 'Dinner' as MealType
			     FROM tlTourCatering 
				 WHERE CateringTypeID = 'caterRestaurant' AND TourRecID = @TourRecID AND IsPax='Y' AND Dinner = 'Y' 
				 GROUP BY Date, Dinner) AS A
		PIVOT(SUM(Counts) FOR MealType IN ([BreakFast], [Lunch], [Dinner])) AS B