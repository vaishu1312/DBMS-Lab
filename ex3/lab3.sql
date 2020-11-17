DROP TABLE ITEM_LIST;
DROP TABLE RECEIPTS;
DROP TABLE CUSTOMERS;
DROP TABLE PRODUCTS;

CREATE TABLE CUSTOMERS(
CID NUMBER(6) CONSTRAINT cid_pk PRIMARY KEY,
FNAME VARCHAR2(15),
LNAME VARCHAR2(15));

CREATE TABLE PRODUCTS(
PID VARCHAR2(15) CONSTRAINT pid_pk PRIMARY KEY,

FLAVOR VARCHAR2(10),
FOOD VARCHAR2(20),
PRICE FLOAT(10));

CREATE TABLE RECEIPTS(
RNO NUMBER(6) CONSTRAINT rno_pk PRIMARY KEY,
RDATE DATE,
CID NUMBER(6) CONSTRAINT cid_fk REFERENCES CUSTOMERS(CID));

CREATE TABLE ITEM_LIST(
RNO NUMBER(6) CONSTRAINT rno_fk REFERENCES RECEIPTS(RNO),
ORDINAL NUMBER(3),
ITEM VARCHAR2(15) CONSTRAINT item_fk REFERENCES PRODUCTS(PID),
CONSTRAINT rno_ONO_pk PRIMARY KEY(RNO,ORDINAL));

REM 1. Display the food details that is not purchased by any of customers

SELECT *
FROM PRODUCTS 
WHERE PID NOT IN (SELECT ITEM FROM ITEM_LIST);

REM 2. Show the customer details who had placed more than 2 orders on the same date.

SELECT *
FROM CUSTOMERS 
WHERE CID IN 
	(SELECT CID
	 FROM RECEIPTS
	 WHERE RDATE IN 
		(SELECT RDATE 
		 FROM RECEIPTS
		 GROUP BY RDATE
		 HAVING COUNT(*) >2)
         GROUP BY CID,RDATE
	 HAVING COUNT(*)>2)
ORDER BY CID;
	 	

REM 3.  Display the products details that has been ordered maximum by the customers. (use ALL)

SELECT *
FROM PRODUCTS 
WHERE PID IN
	(SELECT ITEM 
	 FROM ITEM_LIST 
	 GROUP BY ITEM
	 HAVING COUNT(*) >= ALL (SELECT COUNT(*) 
	                        FROM ITEM_LIST 
	                        GROUP BY ITEM));

REM 4. Show the number of receipts that contain the product whose price is more than the average price of its food type.

SELECT ITEM,COUNT(*) AS NO_OF_RECEIPTS
FROM ITEM_LIST
WHERE ITEM IN  (SELECT PID
		FROM PRODUCTS P
		WHERE P.PRICE> (SELECT AVG(PRICE)
            			FROM PRODUCTS R
            			GROUP BY FOOD 
				HAVING P.FOOD=R.FOOD))
GROUP BY ITEM;

REM 5.Display the customer details along with receipt number and date for the receipts that
are dated on the last day of the receipt month.
          
SELECT *
FROM CUSTOMERS NATURAL JOIN RECEIPTS
WHERE RDATE=LAST_DAY(RDATE)
ORDER BY CID;

REM 6.Display the receipt number(s) and its total price for the receipt(s) that contain Twist as one among five items. Include only the receipts with total price more than $25.

SELECT RNO,SUM(PRICE) AS TOTAL_PRICE
FROM ITEM_LIST JOIN PRODUCTS ON ITEM=PID
WHERE RNO IN
	  (SELECT RNO 
	   FROM ITEM_LIST JOIN PRODUCTS ON ITEM=PID
	   WHERE FOOD='Twist')
GROUP BY RNO
HAVING COUNT(*)=5 AND SUM(PRICE)>25;

REM 7.Display the details (customer details, receipt number, item) for the product that was
purchased by the least number of customers.

SELECT CID,FNAME,LNAME,RNO
	 FROM RECEIPTS NATURAL JOIN CUSTOMERS 
	 WHERE RNO IN 
		   (SELECT RNO FROM ITEM_LIST WHERE ITEM IN
		   (SELECT ITEM
		    FROM ITEM_LIST
	 	    GROUP BY ITEM
	 	    HAVING COUNT(*) <= ALL (SELECT COUNT(*) 
	                        	    FROM ITEM_LIST 
	                        	    GROUP BY ITEM)));

select c.*,r.rno,i.item from item_list i join Receipts r on(r.rno = i.rno) join customers c on(r.cid = c.cid)
where i.item in
	( select item from item_list 
	  group by item
	  having count(*) <= all(select count(*) from item_list group by item));


REM 8.Display the customer details along with the receipt number who ordered all the flavors of Meringue in the same receipt.

SELECT CID,FNAME,LNAME,RNO
FROM RECEIPTS NATURAL JOIN CUSTOMERS  
WHERE RNO IN
	  (SELECT RNO
 	   FROM RECEIPTS NATURAL JOIN ITEM_LIST JOIN PRODUCTS on(item=pid)
	   WHERE FOOD='Meringue'
	   GROUP BY RNO
           HAVING COUNT(distinct FLAVOR)=(SELECT COUNT(distinct FLAVOR) FROM PRODUCTS WHERE FOOD = 'Meringue'));


select cid,fname,lname,rno from customers natural join receipts
where rno in  (
select rno from item_list
where item in (select pid from products where food='Meringue')
group by rno
having count(distinct item)>=2);
 
REM 9. Display the product details of both Pie and Bear Claw.

(SELECT * 
FROM PRODUCTS
WHERE FOOD='Pie')
UNION 
(SELECT * 
FROM PRODUCTS
WHERE FOOD='Bear Claw');

REM 10.Display the customers details who haven't placed any orders.

(SELECT * 
FROM CUSTOMERS) 
MINUS
(SELECT * 
FROM CUSTOMERS
WHERE CID IN (SELECT CID FROM RECEIPTS));


REM 11.Display the food that has the same flavor as that of the common flavor between the
Meringue and Tart.

SELECT FOOD 
FROM PRODUCTS
WHERE FLAVOR IN 
((SELECT FLAVOR 
FROM PRODUCTS 
WHERE FOOD='Meringue')
INTERSECT
(SELECT FLAVOR 
FROM PRODUCTS 
WHERE FOOD='Tart'))
AND
FOOD NOT IN ('Meringue','Tart');

