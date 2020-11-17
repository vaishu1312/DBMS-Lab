REM 1. The combination of Flavor and Food determines the product id. Hence, while
REM inserting a new instance into the Products relation, ensure that the same combination
REM of Flavor and Food is not already available.

alter table RECEIPTS
drop column amount;

CREATE or REPLACE TRIGGER combination
BEFORE INSERT on PRODUCTS for each row

declare
t_food products.food%type;
t_flavor products.flavor%type;
cursor c1 is select food,flavor from products;

begin
open c1;
fetch c1 into t_food,t_flavor;
while c1%found loop	
   if t_food = :new.food and t_flavor = :new.flavor then
	raise_application_error(-20000,'error:combination present');
	exit;
   end if;
fetch c1 into t_food,t_flavor;
end loop;
end;
/

insert into products values('55-ALM','Almond','Croissant',1.45);

REM 2. While entering an item into the item_list relation, update the amount 
REM in Receipts with the total amount for that receipt number.

alter table RECEIPTS
add amount float default 0;

update receipts r
set amount=(select sum(price)  from item_list i join products 
	     on item=pid where r.rno=i.rno );

create or replace trigger update_amnt
after insert on item_list for each row 

declare
tprice products.price%type;

begin
select price into tprice
from products where pid=:new.item;

update receipts
set amount=amount+tprice
where rno=:new.rno;
end;
/

select * from receipts where rno=99002;
insert into item_list values(99002, 3,  '50-CH');
select * from receipts where rno=99002;

REM 3. Implement the following constraints for Item_list relation:
REM a. A receipt can contain a maximum of five items only.
REM b. A receipt should not allow an item to be purchased more than thrice.

create or replace trigger five_max
before insert or update on item_list for each row
begin
if :new.ordinal>5 then
	raise_application_error(-20200,:new.rno||' has more than 5 items');
end if;
end;
/

select * from item_list where rno=52761;
insert into item_list values(52761,6,'70-TU');

create or replace trigger pur_thrice
before insert or update on item_list for each row

declare
cursor c1 is select rno,item,count(*)
from item_list
group by rno,item;

rid item_list.rno%type;
t_item item_list.item%type;
cnt int;
	
begin

open c1;
fetch c1 into rid,t_item,cnt;
while c1%found loop
    if rid = :new.rno and t_item = :new.item and cnt>=3 then
	raise_application_error(-20100,t_item||' will be purchased more than thrice in '||rid);
	exit;
    end if;
fetch c1 into rid,t_item,cnt;
end loop;
end;
/

select rno,item from item_list where rno=41028;
insert into item_list values(41028, 4,  '90-BER-11');


