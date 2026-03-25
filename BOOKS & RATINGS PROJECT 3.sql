CREATE DATABASE bookstore;
USE bookstore;

CREATE TABLE books(
book_id int PRIMARY KEY,
book_name varchar(100),
author varchar(100),
publisher varchar(100),
publishing_year date,
language_codec varchar(35),
genre varchar(100));

CREATE TABLE ratings(
book_id int,
author_rating float,
book_average_rating float,
book_ratings_count int,
gross_sales int,
publisher_revenue int,
sale_price float,
units_sold int,
FOREIGN KEY(book_id) references books(book_id)
);



SELECT * FROM ratings;



ALTER TABLE ratings
DROP FOREIGN KEY ratings_ibfk_1;

ALTER TABLE books
DROP primary key;

ALTER TABLE books
MODIFY publishing_year int;

-- TOP SELLING BOOKS BY GROSS STORE USING SUB QUERY
-- SELECT b.book_name, r.gross_sales
-- from books b
-- join ratings r
-- on b.book_id = r.book_id
-- order by gross_sales desc
-- limit 10;

-- Top-Selling Books by Gross Sales "Using a Subquery"
SELECT book_name, gross_sales
from(
select b.book_name, r.gross_sales
from books b
join ratings r
on b.book_id = r.book_id) as sales_data
order by r.gross_sales desc
limit 10;

-- Average rating by genre using CTE
with genre_ratings AS(
Select b.genre, r.book_average_rating
from books b
join ratings r
on b.book_id =  r.book_id
)
select genre, avg(book_average_rating) as avg_rating
from genre_ratings
group by genre
order by avg_rating desc;

-- Average rating by genre using subquery
select genre, avg(book_average_rating) as avg_rating
from(
select b.genre, r.book_average_rating
from books b
join ratings r
on b.book_id = r.book_id
) as genre_rating
group by b.genre
order by avg_rating desc;


-- Publishers with the highest revenue using Windows Function and sub query
SELECT publisher, total_publisher_revenue
FROM (
SELECT b.publisher, SUM(r.publisher_revenue) AS total_publisher_revenue,
RANK() OVER (ORDER BY SUM(r.publisher_revenue) DESC) AS revenue_rank
FROM books b
JOIN ratings r ON b.book_id = r.book_id
GROUP BY b.publisher
) AS ranked_publishers

WHERE revenue_rank <= 5;

with high_revenue as(
select b.publisher, r.publisher_revenue
from books b
join ratings r
on b.book_id = r.book_id)
select publisher, sum(publisher_revenue) as revenue
from high_revenue
group by publisher
order by revenue desc
limit 5;

select publisher, total_revenue
from(
select b.publisher, sum(r.publisher_revenue) as total_revenue,
rank() over(order by sum(r.publisher_revenue) desc) as rank_revenue
from books b
join ratings r 
on b.book_id = r.book_id
group by b.publisher
) as rank_publisher
 where rank_revenue<=5;
 
 --  High-rated books published in 2012
 select book_name,book_average_rating
 from(
 select b.book_name, b.publishing_year, r.book_average_rating
 from books b
 join ratings r
 on b.book_id = r.book_id
 order by r.book_average_rating desc
 ) as book_rating
 where publishing_year = 2012;
 
 with book_rating as(
 select b.book_name, b.publishing_year, r.book_average_rating
 from books b
 join ratings r
 on b.book_id = r.book_id)
 select book_name, book_average_rating
 from book_rating
 where publishing_year = 2012
 order by book_average_rating desc;
 
-- High-rated genre published in 2012
select genre, publishing_year, best_rating
from(
select b.genre, b.publishing_year, max(r.book_average_rating) as best_rating
from books b 
join ratings r 
on b.book_id = r.book_id
group by b.genre, b.publishing_year
order by best_rating desc
) as testing
where publishing_year = 2012;

-- Prolific authors with their average ratings
With author_rating as(
select b.author, r.author_rating
from books b
join ratings r
on b.book_id = r.book_id
)
select author, avg(author_rating) as avg_rating
from author_rating
group by author
order by avg_rating desc;

-- AUTHORE RATING WHO WROTE MORE THAN 1 BOOK

WITH author as(
select b.author,b.book_name,r.author_rating
from books b
join ratings r
on b.book_id = r.book_id
)
select author, count(AUTHOR) as count_books, avg(author_rating) as avg
from author
group by author
having count_books>1
order by count_books desc;

-- Low-sale but high-rated books (hidden gems) WITH SUBQUERY
 SELECT book_name, book_average_rating, low_sale
from(
SELECT b.book_name,r.book_average_rating, sum(r.gross_sales) as low_sale
from books b
join ratings r
on b.book_id = r.book_id
group by b.book_name,r.book_average_rating
having r.book_average_rating>=4.5 and low_sale<50000
order by r.book_average_rating desc
) as hidden_gem;

-- Profit margin per book
with profit_book as(
select b.book_name, r.gross_sales, r.publisher_revenue
from books b
join ratings r
on b.book_id = r.book_id
)
select book_name, (gross_sales - publisher_revenue) as profit_margin
from profit_book
group by book_name, profit_margin
order by profit_margin desc;
