-- TABLE REFERENCE
	SELECT * FROM nutrients;
	SELECT * FROM foods;
	SELECT * FROM food_nutrients;
	SELECT * FROM food_consumption;
	SELECT * FROM dietary_requirements;

-- COLUMN NAME UPDATE
ALTER TABLE food_nutrients
RENAME COLUMN amount TO amount_per_100g;

----Q1.Which foods contain protein, and how much protein does each food contain per 100 grams?---

SELECT f.food_name ,fn.amount_per_100g FROM foods f
JOIN food_nutrients fn
ON f.food_id=fn.food_id
JOIN nutrients n ON
fn.nutrient_id=n.nutrient_id
WHERE nutrient_name ='Protein'
ORDER BY amount_per_100g DESC ;

--Q2.Which foods provide more than 100 mg of calcium per 100 grams?--

SELECT f.food_name ,fn.amount_per_100g FROM foods f
JOIN food_nutrients fn ON
f.food_id=fn.food_id
JOIN nutrients n ON
fn.nutrient_id=n.nutrient_id
WHERE nutrient_name ='Calcium' AND amount_per_100g > 100 ;

--Q3.For each food category, what is the average amount of protein per 100g?--

SELECT f.food_category ,AVG(fn.amount_per_100g) as avg_protein FROM foods f
JOIN food_nutrients fn ON
f.food_id=fn.food_id
JOIN nutrients n ON
fn.nutrient_id=n.nutrient_id
WHERE nutrient_name ='Protein'
GROUP BY f.food_category
ORDER BY  avg_protein DESC ;

--Q4.Which food category contains the highest number of different foods?--

SELECT food_category , COUNT(DISTINCT food_name) as number_of_foods FROM foods
GROUP BY food_category
ORDER BY number_of_foods DESC ;

--Q5.Which foods have a protein amount per 100g that is higher than the average protein amount across all foods?--

SELECT f.food_name , fn.amount_per_100g FROM foods f
JOIN food_nutrients fn ON
f.food_id=fn.food_id
JOIN nutrients n ON
fn.nutrient_id=n.nutrient_id
WHERE nutrient_name='Protein'AND amount_per_100g >
(
SELECT AVG(amount_per_100g) FROM food_nutrients 
WHERE nutrient_id=1
)
;
--Q6.Which foods have never been consumed?--

SELECT food_name FROM foods f
LEFT JOIN food_consumption fc
ON f.food_id=fc.food_id
WHERE fc.food_id IS NULL ;

--Q7.For each food category, rank the foods based on their protein amount per 100g, from highest to lowest.--

SELECT f.food_category ,f.food_name ,fn.amount_per_100g ,RANK() over(PARTITION BY f.food_category ORDER BY amount_per_100g DESC) as protein_rank 
FROM foods f
JOIN food_nutrients fn
ON f.food_id=fn.food_id
JOIN nutrients n
ON fn.nutrient_id=n.nutrient_id
WHERE nutrient_name ='Protein' ;

--Q8.For each food category, count how many foods are high-protein and how many are low-protein.--

SELECT f.food_category ,COUNT(case when fn.amount_per_100g >= 15 THEN 1 ELSE null END) as high_protein
,COUNT(case when fn.amount_per_100g < 15 THEN 1 ELSE null END) as low_protein
FROM foods f
JOIN food_nutrients fn
ON f.food_id=fn.food_id
JOIN nutrients n
ON fn.nutrient_id=n.nutrient_id
WHERE nutrient_name ='Protein'
GROUP BY f.food_category ;

--Q9.For each month, find the total quantity of food consumed.--

SELECT EXTRACT (month FROM consumption_date) as month,SUM(quantity) as total_quantity FROM food_consumption
GROUP BY EXTRACT (month FROM consumption_date) ;

--Q10.For each food category, find the top 2 foods with the highest calcium amount per 100g.--

 SELECT food_category,
       food_name,
       amount_per_100g,
       food_rank
FROM (
    SELECT f.food_category,
           f.food_name,
           fn.amount_per_100g,
           RANK() OVER (
               PARTITION BY f.food_category
               ORDER BY fn.amount_per_100g DESC
           ) AS food_rank
    FROM foods f
    JOIN food_nutrients fn
        ON f.food_id = fn.food_id
    JOIN nutrients n
        ON fn.nutrient_id = n.nutrient_id
    WHERE n.nutrient_name = 'Calcium'
) AS ranked_foods
WHERE food_rank <= 2;

