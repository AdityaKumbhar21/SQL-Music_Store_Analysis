-- 1. Who is the senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels desc
limit 1;

-- 2. Which countries have the most Invoices?
SELECT billing_country,COUNT(billing_country) as c
from invoice
GROUP BY billing_country
ORDER BY c desc;

-- 3. What are top 3 values of total invoice?
SELECT total from invoice
ORDER BY total DESC
LIMIT 3;


-- 4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals
SELECT billing_city,SUM(total) as total_sum 
from invoice
GROUP BY billing_city
ORDER BY total_sum desc
limit 1;

-- 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money
SELECT customer.first_name, customer.last_name ,SUM(invoice.total) AS total
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY SUM(invoice.total) desc
limit 1;

-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A
SELECT DISTINCT c.email,c.first_name,c.last_name,g.name
FROM customer as c
JOIN invoice ON c.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre as g ON track.genre_id = g.genre_id
WHERE g.name = 'Rock'
ORDER by c.email;

-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands

SELECT a.name, COUNT(t.track_id) as track_count
FROM artist as a 
JOIN album ON a.artist_id = album.artist_id 
JOIN track as t ON album.album_id = t.album_id
GROUP BY a.name
ORDER BY track_count desc
limit 10;

--8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first
SELECT name,milliseconds as length from track
WHERE milliseconds > (
					SELECT AVG(milliseconds)
					FROM track
) ORDER BY length desc ;

-- 9. Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- 10. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres
WITH pop_genre AS(
	SELECT COUNT(invoice_line.invoice_line_id) AS Purchases,customer.country, genre.name,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.invoice_line_id)) AS row
	FROM customer 
	JOIN invoice ON customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY 2,3
	ORDER BY 2 ASC,  1 DESC
)
SELECT * FROM pop_genre WHERE row<=1

-- 11. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount.

WITH top_cust AS (
	SELECT customer.customer_id, CONCAT(customer.first_name ,customer.last_name) AS name, SUM(invoice.total) AS total,invoice.billing_country,
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total) DESC ) AS row
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,4
	ORDER BY invoice.billing_country ASC ,total DESC

)
SELECT * FROM top_cust WHERE row<=1


