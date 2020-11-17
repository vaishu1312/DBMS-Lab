REM 1. For the given receipt number, calculate the Discount as follows:
REM For total amount > $10 and total amount < $25: Discount=5%
REM For total amount > $25 and total amount < $50: Discount=10%
REM For total amount > $50: Discount=20%
REM Calculate the amount (after the discount) and update the same in Receipts table.
REM Print the receipt

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
dbms_output.put_line('Amount to be paid :$ '||final_amt);
dbms_output.put_line('************************************************************');
dbms_output.put_line('Great Offers! Discount up to 25% on DIWALI Festival Day...');
dbms_output.put_line('************************************************************');
END;
/

declare
ono item_list.rno%type;
begin
ono:='&Reciept_no';
calcDiscount(ono);
end;
/

REM 4.Write a stored function to display the customer name who ordered maximum for the
given food and flavor.

CREATE [OR REPLACE] FUNCTION cus_max
(gn_food IN products.food%type , 
 gn_flavor IN products.flavor%type) 
RETURN  customers.cid%type
IS
id customers.cid%type;
BEGIN 

select cid from receipts
where rno=
	  (select rno from products join item_list on pid=item
	   where food=gn_food and flavor=gn_flavor)
group by cid
having count(*) >= all (select count(*) from receipts
 		        where rno= (select rno from products,item_list on pid=item
	   			    where food=gn_food and flavor=gn_flavor)
			group by cid);

select cid from receipts
where rno in
	  (select rno from products join item_list on pid=item
	   where food='Cake' and flavor='Chocolate')
group by cid
having count(*) >= all (select count(*) from receipts
 		        where rno in (select rno from products join item_list on pid=item
	   			    where food='Cake' and flavor='Chocolate')
			group by cid);
            
END [function_name];

CREATE OR REPLACE FUNCTION totalCustomers 
RETURN number IS 
   total number(2) := 0; 
BEGIN 
   SELECT count(*) into total 
   FROM customers; 
    
   RETURN total; 
END; 
/ 