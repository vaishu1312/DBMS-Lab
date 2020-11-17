REM Display the nobel laureate(s) who born after 1Jul1960.
SELECT * 
FROM nobel
WHERE dob>'01-jul-1960';

REM Display the Indian laureate (name, category, field, country, year awarded) who was awarded in the Chemistry category.
SELECT name,category,field,country,year_award 
FROM nobel
WHERE category='Che' and country='India';

REM Display the laureates (name, category,field and year of award) who was awarded between 2000 and 2005 for the Physics or Chemistry category.

SELECT name,category,field,year_award 
FROM nobel
WHERE year_award between 2000 and 2005 and (category='Phy' or category='Che');

REM Display the laureates name with their age at the time of award for the Peace category.

SELECT name, year_award-EXTRACT (YEAR FROM dob) as age
FROM nobel
WHERE category='Pea';

REM Display the laureates (name,category,aff_role,country) whose name starts with A or ends with a, but not from Isreal.

SELECT name,category,aff_role,country 
FROM nobel
WHERE country not in('Isreal') and (name LIKE 'A%' or name LIKE '%a') ;

REM Display the name, gender, affiliation, dob and country of laureates who was born in 1950's. Label the dob column as Born 1950.

SELECT name,gender,aff_role,dob as Born_1950 ,country
FROM nobel
WHERE EXTRACT (YEAR FROM (dob)) between 1950 and 1960;

REM Display the laureates (name,gender,category,aff_role,country) whose name starts with A, D or H. 
REM Remove the laureate if he/she do not have any affiliation. Sort the results in ascending order of name.

SELECT name,gender,category,aff_role,country 
FROM nobel
WHERE (name LIKE 'A%' or name LIKE 'D%' or name LIKE 'H%' ) and aff_role not in('null')
ORDER BY name ASC;

REM Display the university name(s) that has to its credit by having at least 2 nobel laureate with them.

SELECT aff_role, COUNT(name) as count
FROM nobel
WHERE aff_role LIKE 'University%'  or aff_role LIKE '%University'
GROUP BY aff_role
HAVING COUNT(name)>=2;

REM List the date of birth of youngest and eldest laureates by countrywise.
REM Label the column as Younger, Elder respectively. Include only the country having more than one laureate. 
REM Sort the output in alphabetical order of country.

SELECT country, COUNT(name) count, min(dob) Younger,max(dob) Elder
FROM nobel
GROUP BY country
HAVING COUNT(name)>1
ORDER BY country ASC;

REM Show the details (year award,category,field) where the award is shared among the laureates in the same category and field. Exclude the laureates from USA.

SELECT year_award,category,field 
FROM nobel
WHERE country not in('USA')
GROUP BY year_award,category,field 
having count(category)>1 
order by year_award;

REM 11.Mark an intermediate point in the transaction (savepoint).
SAVEPOINT spt;

SELECT * 
FROM nobel;

REM 12.Insert a new tuple into the nobel relation.

INSERT INTO nobel VALUES (129,'Abdul Kalam','m','Phy','Satellite Launch',2004,null,'01-oct-1935','India');

REM 13.Update the aff_role of literature laureates as 'Linguists'.

UPDATE nobel
SET aff_role='Linguists'
WHERE category='Lit';

REM 14.Delete the laureate(s) who was awarded in Enzymes field.

DELETE FROM nobel
WHERE field='Enzymes';

SELECT * 
FROM nobel;

REM 15.Discard the most recent update operations (rollback).
ROLLBACK TO spt;

SELECT * 
FROM nobel;

REM Commit the changes.

COMMIT;