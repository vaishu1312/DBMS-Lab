REM 1. Check whether the given combination of food and flavor is available. If any one or
REM both are not available, display the relevant message.

DECLARE

id products.pid%type;
cfood products.food%type;
cflavor products.flavor%type;

cursor c1 is select food,flavor from products where food=cfood and flavor=cflavor ;
cursor c2 is select food from products where food=cfood;
cursor c3 is select flavor from products where flavor=cflavor ;

BEGIN
  cfood:='&food';
  cflavor:='&flavor';
  open c1;
  open c2;
  open c3;
  fetch c1 into cfood,cflavor;
  fetch c2 into cfood;
  fetch c3 into cflavor;
  if c1%found then
    dbms_output.put_line('Given food and flavor is found');
  elsif c2%found then
   dbms_output.put_line('Given food is found');
  elsif c3%found then
   dbms_output.put_line('Given flavor is found');
  else
   dbms_output.put_line('Given food and flavor not found');
  end if;
END;
/

REM 2. On a given date, find the number of items sold (Use Implicit cursor).

DECLARE 
 
gn_date date;
count_val number(3);

BEGIN 

gn_date:='&date'; 
SELECT COUNT(*) into count_val FROM RECEIPTS NATURAL JOIN ITEM_LIST
GROUP BY RDATE
HAVING RDATE=gn_date;
dbms_output.put_line('No of items sold: ' || count_val); 
END;
/

REM 3. An user desired to buy the product with the specific price. Ask the user for a price,
REM find the food item(s) that is equal or closest to the desired price. Print the product
REM number, food type, flavor and price. Also print the number of items that is equal or
REM closest to the desired price.

DECLARE

cprice products.price%type;
prod_row products%rowtype;
cursor c is select * from products where
abs(cprice-price) = (select min(abs(cprice-price)) from products);

BEGIN

cprice:='&dprice';
dbms_output.put_line('ProductID   Food   Flavor   Price');  
dbms_output.put_line('---------------------------------');
open c;
fetch c into prod_row;
while c%found loop
 dbms_output.put_line(prod_row.pid||'   '||prod_row.food||'  '||prod_row.flavor||'   '||prod_row.price);
 fetch c into prod_row;
end loop;
dbms_output.put_line('---------------------------------');
dbms_output.put_line(c%rowcount || 'product(s) found EQUAL/CLOSEST to given price');
close c;
END;
/

REM 4. Display the customer name along with the details of item and its quantity ordered for
REM the given order number. Also calculate the total quantity ordered.

DECLARE 

cfname customers.fname%type;
clname customers.lname%type;
cfood products.food%type;
cflavor products.flavor%type;
qty number(3);
ono receipts.rno%type;

cursor c2 is select food,flavor,count(*) 
from item_list  join products on item=pid
where rno=ono
group by food,flavor;

BEGIN

ono:='&rid';
select fname,lname into cfname,clname
from customers natural join receipts 
where rno=ono;
dbms_output.put_line('Customer name: '||cfname||' '||clname);

dbms_output.put_line('Ordered Following Items:');
dbms_output.put_line('Flavor     Food       Qty');  
dbms_output.put_line('--------------------------');
open c2;
fetch c2 into cfood,cflavor,qty;
while c2%found loop
 dbms_output.put_line(cflavor||'      '||cfood||'       '||qty);
 fetch c2 into cfood,cflavor,qty;
end loop;
dbms_output.put_line('--------------------------');

dbms_output.put_line('Total Qty: '||c2%rowcount);
close c2;
END;
/