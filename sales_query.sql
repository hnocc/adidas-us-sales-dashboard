--Thống kê số lượng review và trung bình điểm rating theo từng tháng
WITH table_joined AS (
	SELECT ord.*
		, review_id
		, score
		, description
	FROM orders ord
	LEFT JOIN review rv
		ON ord.order_id = rv.order_id
)
SELECT month
	, count(review_id) AS number_reviews
	, avg(CAST (score AS DECIMAL)) AS AVG_rating
FROM table_joined
GROUP BY month
ORDER BY month ASC


WITH table_review AS (
	SELECT rv.*
		, purchase_time
	FROM orders ord
	RIGHT JOIN review rv
		ON ord.order_id = rv.order_id
)
select YEAR(purchase_time)
	, avg(CAST (score AS DECIMAL(10,2))) AS AVG_rating
from table_review
GROUP BY YEAR(purchase_time);


WITH table_rating AS (
	SELECT rv.*
		, category
	FROM review rv
	LEFT JOIN orders ord
		ON ord.order_id = rv.order_id
	LEFT JOIN product pro
		ON pro.product_id = ord.product_id
)
select category
	, avg(CAST (score AS DECIMAL(10,2))) AS AVG_rating
from table_rating
GROUP BY category
ORDER BY AVG_rating ASC

--2. những lý do nào khiến khách hàng không hài lòng về dịch vụ giao hàng
WITH table_joined AS (
	SELECT ord.order_id
		, month
		, review_id
		, score
		, description
		, category
	FROM review rv
	LEFT JOIN orders ord
		ON ord.order_id = rv.order_id
	LEFT JOIN product pro
		ON ord.product_id = pro.product_id
	WHERE review_id IS NOT NULL
)
SELECT category
	, COUNT(order_id) AS number_review
FROM table_joined
WHERE LOWER(CAST(description AS VARCHAR)) LIKE '%giao hàng chậm%'
GROUP BY category
ORDER BY number_review DESC

	SELECT ord.order_id
		, month
		, review_id
		, score
		, description
		, CASE WHEN score <= 5 THEN 'negative'
			WHEN score <= 7 THEN 'normal'
			ELSE 'positive'
			END AS description_group
	FROM orders ord
	LEFT JOIN review rv
		ON ord.order_id = rv.order_id
	WHERE review_id IS NOT NULL


	-- Câu 3: khu vực nào có điểm rating thấp nhất
WITH table_joined AS (
	SELECT ord.order_id
		, purchase_time 
		, review_id
		, score
		, economic_region
		, province
	FROM orders ord
	LEFT JOIN review rv
		ON ord.order_id = rv.order_id
	LEFT JOIN location lo
		ON lo.location_id = ord.location_id
	WHERE review_id IS NOT NULL
)
SELECT province
	, avg(CAST (score AS DECIMAL)) AS AVG_rating
FROM table_joined
WHERE YEAR(purchase_time) = 2022
GROUP BY province
ORDER BY AVG_rating DESC


-- Câu 4: khu vực nào có tỉ lệ giao hàng trễ cao nhất
WITH table_joined AS (
	SELECT ord.order_id
		, status 
		, economic_region
		, province
	FROM orders ord
	LEFT JOIN location lo
		ON lo.location_id = ord.location_id
)
, table_total AS (
	SELECT economic_region
		, COUNT(order_id) AS total_orders
	FROM table_joined
	GROUP BY economic_region
)
, table_late AS (
	SELECT economic_region
		, COUNT(order_id) AS late_orders
	FROM table_joined
	WHERE status = 'late'
	GROUP BY economic_region
)
SELECT table_total.*
	, late_orders
	, CAST(late_orders AS DECIMAL (10,2))/total_orders AS late_ratio
FROM table_total
	JOIN table_late ON table_total.economic_region = table_late.economic_region
ORDER BY late_orders DESC
