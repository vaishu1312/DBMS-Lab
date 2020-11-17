REM 1. For the given receipt number, calculate the Discount as follows:
REM For total amount > $10 and total amount < $25: Discount=5%
REM For total amount > $25 and total amount < $50: Discount=10%
REM For total amount > $50: Discount=20%
REM Calculate the amount (after the discount) and update the same in Receipts table.
REM Print the receipt

alter table RECEIPTS
add amount float default 0;

CREATE OR REPLACE PROCEDURE 
calcDiscount(rid IN item_list.rno%type)

IS

cfname customers.fname%type;
clname customers.lname%type;
rpt_dt date;
prod_row products%rowtype;
total_amt float(10);
discount_cent number(2);
discount_amt float(10);
final_amt float(10);
no_of_items number(3);

cursor c1 is select pid,flavor,food,price
from item_list  join products on item=pid
where rno=rid;

BEGIN

no_of_items:=1;
select fname,lname into cfname,clname
from customers natural join receipts
where rno=rid;

select rdate into rpt_dt from receipts where rno=rid;

select sum(price) into total_amt 
from item_list join products on item=pid 
where rno=rid;

if total_amt>10 and total_amt<=25 then
  discount_cent:=5;
elsif total_amt>25 and total_amt<=50 then
  discount_cent:=10;
elsif total_amt>50 then
  discount_cent:=20;
end if;

discount_amt:=(total_amt*discount_cent)/100;
dbms_output.put_line('************************************************************');
dbms_output.put_line
('Receipt Number: '||rid||'          Customer Name:'||cfname||' '||clname); 
dbms_output.put_line('Receipt Date : '||rpt_dt); 
dbms_output.put_line('************************************************************');
dbms_output.put_line('S.no  Flavor   Food      Price');
for prod_row in c1 loop
 dbms_output.put_line(no_of_items||'     '||prod_row.flavor||'     '||prod_row.food||'     '||prod_row.price);
 no_of_items:=no_of_items+1;
end loop;
dbms_output.put_line('------------------------------------------------------------');
dbms_output.put_line('                       '||'Total = '||total_amt);
dbms_output.put_line('------------------------------------------------------------');
dbms_output.put_line('Total Amount      :$ '||total_amt);
dbms_output.put_line('Discount('||discount_cent||'%)     :$ '||discount_amt);
dbms_output.put_line('------------------------------------------------------------');
final_amt:=total_amt-discount_amt;
update RECEIPTS set amount = final_amt where RECEIPTS.rno = rid;
dbms_output.put_line('Amount to be paid :$ '||final_amt);
dbms_output.put_line('************************************************************');
dbms_output.put_line('Great Offers! Discount up to 25% on DIWALI Festival Day...');
dbms_output.put_line('************************************************************');
END;
/

declare
ono item_list.rno%type;
BEGIN
ono:='&Reciept_no';
calcDiscount(ono);
end;
/



REM 2. Ask the user for the budget and his/her preferred food type. You recommend the best
REM item(s) within the planned budget for the given food type. The best item is
REM determined by the maximum ordered product among many customers for the given
REM food type.

CREATE OR REPLACE PROCEDURE
chooseProd (budget IN PRODUCTS.price%type, foodType IN PRODUCTS.food%type)

IS

prod_row PRODUCTS%rowtype; 
bestpid PRODUCTS.pid%type;
bestflav PRODUCTS.flavor%type;
bestprice PRODUCTS.price%type;
bestfood PRODUCTS.food%type;
num number(5);
cnt number(2);

cursor c1 is select pid,food,flavor,price,count(*)
from PRODUCTS join ITEM_LIST on pid=item
where food=foodType and price<=budget
group by pid,food,flavor,price
order by count(*) desc;

cursor c2 is select pid,food,flavor,price,count(*)
from PRODUCTS join ITEM_LIST on pid=item
where food=foodType and price<=budget
group by pid,food,flavor,price
order by count(*) desc;

BEGIN

open c2;
fetch c2 into bestpid, bestfood, bestflav, bestprice,cnt;
dbms_output.put_line('************************************************************');
dbms_output.put_line
('Budget:$ '||budget||'                       Food Type:'||foodType);
dbms_output.put_line('Item ID         Flavor         Food       Price');
dbms_output.put_line('************************************************************');
for prod_row in c1 loop
	dbms_output.put_line(prod_row.pid||'    '||prod_row.flavor||'     '||foodType||'       '||prod_row.price);
end loop;
dbms_output.put_line('------------------------------------------------------------');
dbms_output.put_line(bestpid||' with '||bestflav||' flavor is the best type in '||foodType||' type!');
num := trunc(budget/bestprice);
dbms_output.put_line('You are entitled to purchase '||num||' '||foodType||' chocolates for the given budget !!!');
dbms_output.put_line('************************************************************');
END;
/

declare
budg PRODUCTS.price%type;
fooType PRODUCTS.food%type;
BEGIN
fooType := '&food_type';
budg := '&budget';
chooseProd(budg,fooType);
end;
/

REM 3. Take a receipt number and item as arguments, and insert this information into 
REM the Item list. However, if there is already a receipt with that receipt number, then 
REM keep adding 1 to the maximum ordinal number. Else before inserting into the Item list 
REM with ordinal as 1, ask the user to give the customer name who placed the order and insert 
REM this information into the Receipts.

alter table receipts 
drop column amount;

CREATE OR REPLACE PROCEDURE
insertRow(rec_no IN RECEIPTS.rno%type, item_no IN ITEM_LIST.item%type, o OUT ITEM_LIST.ordinal%type)

IS

ord ITEM_LIST.ordinal%type;

cursor c1 is select ordinal 
	     from ITEM_LIST
	     where rno=rec_no;
BEGIN

o:=1;
open c1;
loop
	fetch c1 into ord;
	if c1%FOUND then 
		o:=o+1;
	else
		exit;
	end if;
end loop;

END;
/


declare rc_no RECEIPTS.rno%type;ite_no ITEM_LIST.item%type;cust_id CUSTOMERS.cid%type;date_in RECEIPTS.rdate%type;o ITEM_LIST.ordinal%type;

BEGIN
rc_no:='&Receipt_no';
ite_no:='&Item';
insertRow(rc_no,ite_no,o);
if o = 1 then
		cust_id := '&customer_id';
		date_in := '&date';
		insert into Receipts values(rc_no, date_in, cust_id);
end if;
INSERT into item_list values(rc_no, o, ite_no);
dbms_output.put_line('Inserted '||rc_no||' '||o||' '||ite_no);
end;
/


REM 4. Write a stored function to display the customer name who ordered 
REM maximum for the given food and flavor.

create or replace function maxcustomer(p IN products.pid%type) return varchar2 

as 

c customers.cid%type;
m int;
n1 customers.fname%type;
n2 customers.lname%type;
name varchar2(40);

BEGIN
	select max(count(*)) into m from receipts r join item_list i on i.rno = r.rno
	where i.item = p
	group by r.cid;
	select r.cid into c from receipts r join item_list i on i.rno = r.rno
	where i.item = p
	group by r.cid
	having count(*) = m;
	select fname into n1 from customers  where cid = c;
	select lname into n2 from customers  where cid = c;
	name := n1||n2;
	return name;
end maxcustomer;
/

declare 
	name varchar2(40);
	p products.pid%type;
	fo products.food%type;
	fl products.flavor%type;
BEGIN
	fo:='&food';
	fl:='&flavor';
	select p1.pid into p from products p1 where p1.food = fo and p1.flavor = fl;
	name := maxcustomer(p);
	dbms_output.put_line('Name: '||name);
end;
/



REM 5. Implement Question (1) using stored function to return the amount to be paid 
REM and update the same, for the given receipt number.

alter table RECEIPTS
add amount float default 0;

CREATE OR REPLACE FUNCTION 
discountCalc(rid IN item_list.rno%type) return PRODUCTS.price%type 

as 

final_amt PRODUCTS.price%type;
cfname customers.fname%type;
clname customers.lname%type;
rpt_dt date;
prod_row products%rowtype;
total_amt float(10);
discount_cent number(2);
discount_amt float(10);
no_of_items number(3);

cursor c1 is select pid,flavor,food,price
from item_list  join products on item=pid
where rno=rid;

BEGIN

no_of_items:=1;
select fname,lname into cfname,clname
from customers natural join receipts
where rno=rid;

select rdate into rpt_dt from receipts where rno=rid;

select sum(price) into total_amt 
from item_list join products on item=pid 
where rno=rid;

if total_amt>10 and total_amt<=25 then
  discount_cent:=5;
elsif total_amt>25 and total_amt<=50 then
  discount_cent:=10;
elsif total_amt>50 then
  discount_cent:=20;
end if;

discount_amt:=(total_amt*discount_cent)/100;
dbms_output.put_line('************************************************************');
dbms_output.put_line
('Receipt Number: '||rid||'          Customer Name:'||cfname||' '||clname); 
dbms_output.put_line('Receipt Date : '||rpt_dt); 
dbms_output.put_line('************************************************************');
dbms_output.put_line('S.no  Flavor   Food      Price');
for prod_row in c1 loop
 dbms_output.put_line(no_of_items||'     '||prod_row.flavor||'     '||prod_row.food||'     '||prod_row.price);
 no_of_items:=no_of_items+1;
end loop;
dbms_output.put_line('------------------------------------------------------------');
dbms_output.put_line('                       '||'Total = '||total_amt);
dbms_output.put_line('------------------------------------------------------------');
dbms_output.put_line('Total Amount      :$ '||total_amt);
dbms_output.put_line('Discount('||discount_cent||'%)     :$ '||discount_amt);
dbms_output.put_line('------------------------------------------------------------');
final_amt:=total_amt-discount_amt;
dbms_output.put_line('Amount to be paid :$ '||final_amt);
dbms_output.put_line('************************************************************');
dbms_output.put_line('Great Offers! Discount up to 25% on DIWALI Festival Day...');
dbms_output.put_line('************************************************************');
return final_amt;
END;
/

declare
ono item_list.rno%type;Amount PRODUCTS.price%type;
BEGIN
ono:='&Reciept_no';
Amount:=discountCalc(ono);
update RECEIPTS set amount = Amount where rno = ono;
end;
/
