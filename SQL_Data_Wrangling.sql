-- category id is not given in campaign but provided in sub_category table 
-- in order to left join campaign table, add the column 'name' from sub_category table and then join sub_category table and campaign on sub_category.id and campaign.id
ALTER TABLE sub_category ADD COLUMN category VARCHAR (255) NOT NULL;

-- update the empty column in table with the column category 
UPDATE sub_category t1
INNER JOIN category t2 ON t1.category_id = t2.id 
SET t1.category = t2.name;

-- combine all tables into a single table for data analysis and visualization 
SELECT campaign.id AS project_id,
	   campaign.name AS name,
       sub_category.category_id,
       sub_category.category AS category_name,
       campaign.sub_category_id,
       sub_category.name As sub_category_name,
       campaign.country_id,
       country.name AS country,
       campaign.currency_id,
       currency.name AS currency,
       campaign.launched,
       campaign.deadline,
       campaign.goal,
       campaign.pledged,
       campaign.backers,
       campaign.outcome
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
LEFT JOIN country ON campaign.country_id = country.id
LEFT JOIN currency ON campaign.currency_id = currency.id
-- export the big table for data visualization in excel/pandas
-- the command <SHOW VARIABLES LIKE "secure_file_priv"> can be used to check the default directory where mysql uploads files
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Kickstarter_data.csv'
Fields ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY ''
LINES TERMINATED BY '\n';

-- average goal values for failed and successful campaign
SELECT outcome, AVG(goal) AS av_goal_val
FROM campaign
GROUP BY outcome;

-- maximum goal values for failed and successful campaign
SELECT outcome, MAX(goal) AS MAX_goal_val
FROM campaign
GROUP BY outcome;

-- MIN goal values for failed and successful campaign 
SELECT outcome, MIN(goal) AS MIN_goal_val
FROM campaign
GROUP BY outcome;

/* Looking at the average and maximum values it can be said that 
in general the failed campaigns had higher dollar goals than successful campaigns 
although there is no significan difference between small values so there can be other factors affecting the dollar goals for
campaigns*/

-- Top/bottom 3 categories with the most bakers 
SELECT sub_category.category, SUM(backers) AS Backers
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
GROUP BY sub_category.category
ORDER BY Backers DESC;
-- The top three categories are Games, Technology, and Design
-- The bottom three categories are Art, Food and Fashion

-- Top/bottom 3 subcategories by backers 
SELECT sub_category.category, sub_category.name, SUM(backers) AS Backers
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
GROUP BY sub_category.name
ORDER BY Backers DESC;
-- Top 3 subcategories are Tabletop games, Product Design, and Video Games
-- Bottom 3 subcategories are Crafts, Journalism, and Music

-- Top/bottom 3 categories that have raised the most money
SELECT sub_category.category, SUM(goal) AS Funding
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
GROUP BY sub_category.category
ORDER BY Funding DESC;
-- Top three categories that have raised most money are Film & Video, Technology, and Publishing
-- Bottom three categores that have raised most money are Dance, Comics, and Crafts

-- Top/bottom 3 subcategories that have raised money
SELECT sub_category.name, SUM(goal) AS Funding
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
GROUP BY sub_category.name
ORDER BY Funding ASC;
-- Top three subcategories that have raised most money are Technology, Film and Video, and Documentry
-- Bottom three subcategories that have raised most money are Glass, Residencies, and Textiles

-- 'Tabletop Games'
SELECT campaign.name,
	   campaign.goal,
       campaign.backers,
       campaign.outcome,
       sub_category.category,
       sub_category.name,
       currency.name
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
LEFT JOIN currency ON campaign.currency_id = currency.id 
WHERE sub_category.name = 'Tabletop Games'
ORDER BY goal DESC;
-- The most successful company raised an amount of 250,000 USD. The project name was Ghostbuster: The Board company and it had 8396 backers.

-- Top three countries with the most successful campaigns 
SELECT country.name,
       SUM(campaign.pledged) AS dollars_pledged,
       SUM(campaign.backers) AS backers
FROM campaign
LEFT JOIN country ON campaign.country_id = country.id
GROUP BY country.name
ORDER BY dollars_pledged DESC, backers DESC;
-- Top three countries with most successful campaigns in terms of dollars raised and backers are United States, Great Britain and Canada

-- Longer or shorter campaigns tend to raise more money?
SELECT AVG(datediff(campaign.deadline, campaign.launched)) AS avg_campaign_length,
	   MAX(datediff(campaign.deadline, campaign.launched)) AS max_campaign_length,
       MIN(datediff(campaign.deadline, campaign.launched)) AS min_campaign_length
FROM campaign;
-- The average, max and min campaign lengths are 35 days, 92 days and 1 day.
-- Campaigns below 35 are called shorter campaign lengths while the campaigns abouve 35 are called larger campaign lengths.

WITH date_diff AS 
(Select datediff(campaign.deadline, campaign.launched) AS campaign_length,
        campaign.goal AS raised,
        campaign.outcome as result
FROM campaign)
SELECT AVG(raised)
FROM date_diff
WHERE campaign_length > 35 AND result = 'successful';

-- on average an amout 8921 was raised for campaigns with length less than 35 (short campaign length) while an amount of 11216 was raised for the 
-- campaigns in length greater than 35 (larger campaign length). Therefore it can be said that the campaigns with larger campaigns raised 
-- more money

-- Backers for game category
SELECT AVG(campaign.backers) as avg_backers,
       MAX(campaign.backers) as max_backers,
	   MIN(campaign.backers) as min_backers
FROM campaign
LEFT JOIN sub_category ON campaign.sub_category_id = sub_category.id
WHERE sub_category.category = 'Games' AND campaign.outcome = 'Successful';
-- On average 794 backers can be expected from the Games category. The maxium and minimum number of backers this category had was 40642 and 1 respectively.


select Ma(datediff(campaign.deadline, campaign.launched)) AS campaign_length
FROM campaign