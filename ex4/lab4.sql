REM 1. Create a view named Blue_Flavor, which display the product details (product id,
REM food, price) of Blueberry flavor.

CREATE VIEW Blue_Flavor AS
SELECT PID,FOOD,PRICE
FROM PRODUCTS 
WHERE FLAVOR='Blueberry';

SELECT * FROM Blue_flavor;

SELECT COLUMN_NAME, UPDATABLE from
USER_UPDATABLE_COLUMNS where TABLE_NAME='BLUE_FLAVOR';

SELECT * FROM PRODUCTS WHERE FLAVOR='Blueberry';

INSERT INTO Blue_flavor values ('30-BLFV','PIZZA',34);
UPDATE Blue_flavor SET PRICE=25
WHERE PID='90-BLU-11';
DELETE FROM Blue_flavor
WHERE FOOD='Danish';

SELECT * FROM PRODUCTS WHERE FLAVOR='Blueberry';

SELECT * FROM Blue_flavor;

INSERT INTO PRODUCTS values('35-BLFV','Blueberry','Cookie',19);
UPDATE PRODUCTS SET PRICE=25 
WHERE FLAVOR='Blueberry';
DELETE FROM PRODUCTS WHERE FOOD='Tart';

SELECT * FROM Blue_flavor;

REM 2. Create a view named Cheap_Food, which display the details (product id, flavor,
REM food, price) of products with price lesser than $1. Ensure that, the price of these
REM food(s) should never rise above $1 through view.

CREATE VIEW Cheap_Food AS
SELECT *
FROM PRODUCTS 
WHERE PRICE<1;

SELECT * FROM Cheap_Food;

SELECT COLUMN_NAME, UPDATABLE from
USER_UPDATABLE_COLUMNS where TABLE_NAME='CHEAP_FOOD';

SELECT * FROM PRODUCTS WHERE PRICE<1;

INSERT INTO Cheap_Food values ('60-CPF','Veg','Nugget',0.32);
UPDATE Cheap_Food SET FOOD='IceCream'
WHERE PID='70-W';
DELETE FROM Cheap_Food
WHERE FLAVOR='Lemon';
 
SELECT * FROM PRODUCTS WHERE PRICE<1;

SELECT * FROM Cheap_Food;

INSERT INTO PRODUCTS values('18-CPF','Nuts','Twist',0.19);
UPDATE PRODUCTS SET PRICE=0.25 
WHERE FLAVOR='Lemon' and FOOD='Cookie';
DELETE FROM PRODUCTS WHERE FOOD='Nugget';

SELECT * FROM Cheap_Food;

REM 3.Create a view called Hot_Food that show the product id and its quantity where the
REM same product is ordered more than once in the same receipt.

CREATE VIEW Hot_Food AS
SELECT ITEM,COUNT(*) AS QUANTITY
FROM ITEM_LIST
GROUP BY RNO,ITEM
HAVING COUNT(*)>1;

SELECT * FROM Hot_Food;

SELECT COLUMN_NAME, UPDATABLE from
USER_UPDATABLE_COLUMNS where TABLE_NAME='HOT_FOOD';

SELECT ITEM,COUNT(*) AS QUANTITY
FROM ITEM_LIST
GROUP BY RNO,ITEM
HAVING COUNT(*)>1;

INSERT INTO Hot_Food values(
'13-HF',3);
UPDATE Hot_Food SET QUANTITY=10
WHERE ITEM='46-11';
DELETE FROM Hot_Food 
WHERE ITEM='70-R';

SELECT ITEM,COUNT(*) AS QUANTITY
FROM ITEM_LIST
GROUP BY RNO,ITEM
HAVING COUNT(*)>1;

REM 4.Create a view named Pie_Food that will display the details (customer lname, flavor,
REM receipt number and date, ordinal) who had ordered the Pie food with receipt details.

CREATE VIEW Pie_Food AS
SELECT CID,LNAME,FLAVOR,RNO,RDATE,ORDINAL
FROM CUSTOMERS NATURAL JOIN RECEIPTS NATURAL JOIN ITEM_LIST JOIN PRODUCTS on ITEM=PID
WHERE FOOD='Pie';

SELECT * FROM Pie_Food;

SELECT COLUMN_NAME, UPDATABLE from
USER_UPDATABLE_COLUMNS where TABLE_NAME='PIE_FOOD';

SELECT CID,LNAME,FLAVOR,RNO,RDATE,ORDINAL
FROM CUSTOMERS NATURAL JOIN RECEIPTS NATURAL JOIN ITEM_LIST JOIN PRODUCTS on ITEM=PID
WHERE FOOD='Pie';

INSERT INTO Pie_Food values (30,'RAJEN','STRAWBERRY',87210,'13-DEC-99',1);
UPDATE Pie_Food SET LNAME='MARIE' 
WHERE ORDINAL=4;
DELETE FROM Pie_Food WHERE
RNO=98806;

SELECT CID,LNAME,FLAVOR,RNO,RDATE,ORDINAL
FROM CUSTOMERS NATURAL JOIN RECEIPTS NATURAL JOIN ITEM_LIST JOIN PRODUCTS on ITEM=PID
WHERE FOOD='Pie';

REM 5. Create a view Cheap_View from Cheap_Food that shows only the product id, flavor and food.

CREATE VIEW Cheap_View AS
SELECT PID,FLAVOR,FOOD
FROM Cheap_Food;

SELECT * FROM Cheap_View;

SELECT COLUMN_NAME, UPDATABLE from
USER_UPDATABLE_COLUMNS where TABLE_NAME='CHEAP_VIEW';

SELECT *
FROM Cheap_Food;

INSERT INTO Cheap_View values(
'56-CV','Grape','Juice');
UPDATE Cheap_View SET FOOD='Chocolate'
WHERE PID='70-W';
DELETE FROM Cheap_View 
WHERE FLAVOR='Nuts';

SELECT * FROM Cheap_Food;

SELECT * FROM Cheap_View;

INSERT INTO Cheap_Food values ('82-CPF','Non-Veg','Nugget',0.62);
UPDATE Cheap_Food SET FOOD='IceCream'
WHERE PID='70-W';
DELETE FROM Cheap_Food
WHERE FLAVOR='Lemon';

SELECT * FROM Cheap_View;

REM 6.Create a sequence named Ordinal_No_Seq which generates the ordinal number
REM starting from 1, increment by 1, to a maximum of 10. Include the options of cycle,
REM cache and order. Use this sequence to populate the item_list table for a new order.

CREATE SEQUENCE Ordinal_No_Seq
MAXVALUE 10 
START WITH 1
INCREMENT BY 1
CACHE 5
CYCLE
ORDER;

INSERT INTO RECEIPTS values(491204,'20-Jan-2019',12);
INSERT INTO ITEM_LIST values(491204,Ordinal_No_Seq.nextval,'90-CH-PF');
INSERT INTO ITEM_LIST values(491204,Ordinal_No_Seq.nextval,'70-GA');
INSERT INTO ITEM_LIST values(491204,Ordinal_No_Seq.nextval,'51-APP');

SELECT * FROM ITEM_LIST WHERE RNO=491204;

REM 7:Create a synonym named Product_details for the item_list relation. Perform the DML operations on it.

CREATE SYNONYM Product_details for ITEM_LIST;

INSERT INTO RECEIPTS values(181923,'10-Jul-2009',10);
INSERT INTO Product_details
values(181923,8,'24-8x10');
SELECT * FROM Product_details WHERE RNO=181923;
SELECT * FROM ITEM_LIST WHERE RNO=181923;

UPDATE Product_details 
SET ITEM='90-APR-PF'
where RNO=181923 and ordinal='8';
SELECT * FROM Product_details WHERE RNO=181923;
SELECT * FROM ITEM_LIST WHERE RNO=181923;

DELETE FROM Product_details
where RNO=181923;
SELECT * FROM Product_details WHERE RNO=181923;
SELECT * FROM ITEM_LIST WHERE RNO=181923;

REM 8:Drop all the above created database objects.

DROP VIEW Blue_flavor;
DROP VIEW Cheap_Food;
DROP VIEW Hot_Food ;
DROP VIEW Pie_Food;
DROP VIEW Cheap_View;
DROP SEQUENCE Ordinal_No_Seq;
DROP SYNONYM Product_details;