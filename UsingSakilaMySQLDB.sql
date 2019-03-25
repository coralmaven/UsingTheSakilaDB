use sakila;
show tables;
describe actor;

-- * 1a. Display the first and last names of all actors from the table `actor`.
Select first_name, last_name from actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
Select UPPER(CONCAT(first_name, ' ',last_name)) from actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name from actor where first_name = 'Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
Select * from actor where last_name like '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time,
--  order the rows by last name and first name, in that order:
Select * from actor where last_name like '%LI%' order by last_name, first_name ASC;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the 
-- following countries: Afghanistan, Bangladesh, and China:
describe country;
select country_id, country from country where country in ('Afghanistan', 'Bangladesh',  'China');

-- * 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` 
-- and use the data type `BLOB` (Make sure to research the type `BLOB`, 
-- as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- * 3b. Very quickly you realize that entering descriptions for each actor is 
-- too much effort. Delete the `description` column.
ALTER TABLE actor
drop description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, Count(*) as lastNameCount from actor group by last_name order by lastNameCount desc;

-- * 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, Count(*) as lastNameCount 
	from actor 
    group by last_name
    having count(distinct first_name) > 1
    order by lastNameCount asc;
	
-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`.
--  Write a query to fix the record.
select * from actor 
where actor.first_name = 'GROUCHO' and actor.last_name = 'WILLIAMS';

update actor
set actor.first_name =  'HARPO'
where actor.first_name = 'HARPO' and actor.last_name = 'WILLIAMS';

select * from actor 
where actor.first_name = 'HARPO' and actor.last_name = 'WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was 
-- the correct name after all! In a single query, if the first name of the actor is currently `HARPO`,
--  change it to `GROUCHO`.
update actor
set actor.first_name =  'GROUCHO'
where actor.first_name = 'HARPO' and actor.last_name = 'WILLIAMS';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

--   * Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
SHOW CREATE TABLE address;

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
--  Use the tables `staff` and `address`:
select * from staff;
select staff.first_name, staff.last_name, address.address from 
staff  join address using (address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005.
--  Use tables `staff` and `payment`.
describe payment;
select staff.staff_id, staff.first_name, staff.last_name, 
	sum(payment.amount) as 'Total $ Amount Rung Up' 
    from staff  join payment using (staff_id) 
    group by payment.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

select film.title, 
(Select count(*) from film_actor where film_actor.film_id = film.film_id) as 'Number of Actors'
from film;
    
-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*) 
	from inventory 
	where film_id in (
    Select film_id from film
    where title = 'Hunchback Impossible'
    );
    
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer.
--  List the customers alphabetically by last name:
select customer.first_name, customer.last_name, 
	sum(payment.amount) as 'Total Amount Paid $' 
    from customer  join payment using (customer_id) 
    group by payment.customer_id
    order by customer.last_name asc;
    
--   ![Total amount paid](Images/total_payment.png)

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` 
-- have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` 
-- whose language is English.

select title from film
	where  
    language_id in (
    select language_id from `language`
    where `name` = 'English')
    and 
    (title like 'K%' or title like 'Q%');
    
-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
describe film_actor;
select first_name, last_name from actor
	where  
    actor_id in (
    select actor_id from film_actor
    where film_id in (
		select film_id from film
		where title = 'Alone Trip')
	);
    
-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email
--  addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 	c.first_name, 
		c.last_name, 
		c.email,
        y.country
	FROM customer c, address a, city t, country y
	WHERE c.address_id=a.address_id
	AND a.city_id=t.city_id
    AND t.country_id=y.country_id
    AND y.country = "Canada";

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
--  Identify all movies categorized as _family_ films.
select * from film_category;

select title from film where rating in ('G','PG');
	
-- * 7e. Display the most frequently rented movies in descending order.
-- payment.rental_id -> rental.inventory_id -> inventory.film_id -> film.title
select f.title, count(*) as rental_count
	from  film f, inventory i, rental r, payment p
	where p.rental_id = r.rental_id
    and r.inventory_id = i.inventory_id
    and i.film_id = f.film_id
    group by f.film_id
    order by rental_count desc
    limit 10;
				
-- * 7f. Write a query to display how much business, in dollars, each store brought in.
-- payment.rental_id -> rental.customer_id -> customer.store_id
 
select c.store_id, sum(p.amount) as business
	from  customer c, payment p, rental r
    where p.rental_id = r.rental_id
    and r.customer_id = c.customer_id
    group by store_id
    order by business desc;
    
-- * 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, c.city, t.country 
	from  store s, address a, city c, country t
    where s.address_id = a.address_id
    and a.city_id = c.city_id
    and c.country_id = t.country_id;
    
-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- payment.rental_id -> rental.inventory_id -> inventory.film_id -> film_category.category_id -> category.name

select c.name as Genre, sum(p.amount) as 'Gross Revenue'
	from  category c, film_category f, inventory i, payment p,  rental r
    where p.rental_id = r.rental_id
    and r.inventory_id = i.inventory_id
    and i.film_id = f.film_id
    and f.category_id = c.category_id
    group by c.name
    order by 'Gross Revenue' desc limit 5;
    
-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the
--  Top five genres by gross revenue. Use the solution from the problem above to create a view.
--  If you haven't solved 7h, you can substitute another query to create a view.
Create VIEW Top_Five_Genres_By_Gross_Revenue AS
select c.name as Genre, sum(p.amount) as 'Gross Revenue'
	from  category c, film_category f, inventory i, payment p,  rental r
    where p.rental_id = r.rental_id
    and r.inventory_id = i.inventory_id
    and i.film_id = f.film_id
    and f.category_id = c.category_id
    group by c.name
    order by 'Gross Revenue' desc limit 5;

-- * 8b. How would you display the view that you created in 8a?
Select * from Top_Five_Genres_By_Gross_Revenue;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
Drop VIEW Top_Five_Genres_By_Gross_Revenue;

-- ## Appendix: List of Tables in the Sakila DB

-- * A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

-- ```sql
-- 'actor'
-- 'actor_info'
-- 'address'
-- 'category'
-- 'city'
-- 'country'
-- 'customer'
-- 'customer_list'
-- 'film'
-- 'film_actor'
-- 'film_category'
-- 'film_list'
-- 'film_text'
-- 'inventory'
-- 'language'
-- 'nicer_but_slower_film_list'
-- 'payment'
-- 'rental'
-- 'sales_by_film_category'
-- 'sales_by_store'
-- 'staff'
-- 'staff_list'
-- 'store'
-- ```

-- ## Uploading Homework