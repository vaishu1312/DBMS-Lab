DROP TABLE ORDER_DETAILS;
DROP TABLE ORDERS;
DROP TABLE PART;
DROP TABLE EMPLOYEE;
DROP TABLE CUSTOMER;
DROP TABLE AREA_DETAILS;

REM Consider a mail order database in which employees take orders for parts from customers.

CREATE TABLE AREA_DETAILS(
PINCODE NUMBER(6) CONSTRAINT pn_pk PRIMARY KEY,
AREA VARCHAR2(10));

DESC AREA_DETAILS;

CREATE TABLE EMPLOYEE(
E_NO VARCHAR2(6) CONSTRAINT e_no_pk PRIMARY KEY,
E_NAME VARCHAR2(10) CONSTRAINT e_name NOT NULL,
DOB DATE,
PINCODE NUMBER(6),
CONSTRAINT pn_fk FOREIGN KEY (PINCODE) REFERENCES AREA_DETAILS(PINCODE),
CONSTRAINT E_BEGIN CHECK ( E_NO LIKE 'E%'));

DESC EMPLOYEE; 

CREATE TABLE CUSTOMER(
C_NO VARCHAR2(6),
C_NAME VARCHAR2(10) CONSTRAINT c_name NOT NULL,
STREET_NAME VARCHAR2(10),
PINCODE NUMBER(6),
CONSTRAINT cpn_fk FOREIGN KEY (PINCODE) REFERENCES AREA_DETAILS(PINCODE),
DOB DATE,
PHONE_NO NUMBER(10),
CONSTRAINT c_no_pk PRIMARY KEY(C_NO),
CONSTRAINT phone_no_uni UNIQUE(PHONE_NO),
CONSTRAINT C_BEGIN CHECK ( C_NO LIKE 'C%' ));

DESC CUSTOMER;

CREATE TABLE PART(
P_NO VARCHAR2(6) CONSTRAINT p_no_pk PRIMARY KEY,
P_NAME VARCHAR2(10),
PRICE NUMBER(5) CONSTRAINT price_no NOT NULL,
QTY_AVL NUMBER(5),
CONSTRAINT P_BEGIN CHECK ( P_NO LIKE 'P%' ));

DESC PART;

CREATE TABLE ORDERS(
O_NO VARCHAR2(6) CONSTRAINT o_no PRIMARY KEY,
C_NO VARCHAR2(6),
CONSTRAINT c_no_fk FOREIGN KEY (C_NO) REFERENCES CUSTOMER(C_NO),
E_NO VARCHAR2(6),
CONSTRAINT e_no_fk FOREIGN KEY (E_NO) REFERENCES EMPLOYEE(E_NO),
RCD_DT DATE,
SHIP_DT DATE,
CONSTRAINT dt CHECK (RCD_DT<SHIP_DT),
CONSTRAINT O_BEGIN CHECK ( O_NO LIKE 'O%' ));

DESC ORDERS;

CREATE TABLE ORDER_DETAILS(
O_NO VARCHAR2(6) CONSTRAINT or_no  REFERENCES ORDERS(O_NO),
P_NO VARCHAR2(6),
CONSTRAINT p_no_fk FOREIGN KEY (P_NO) REFERENCES PART(P_NO),
QTY_ORD NUMBER(5),
CONSTRAINT qty_ord_nz CHECK ( QTY_ORD>0 ),
CONSTRAINT o_p_pk PRIMARY KEY (O_NO,P_NO));

DESC ORDER_DETAILS;

INSERT INTO AREA_DETAILS VALUES(600010,'KILPAUK');
INSERT INTO AREA_DETAILS VALUES(600082,'PERAMBUR');
INSERT INTO AREA_DETAILS VALUES(600011,'KALAVAKKAM');
INSERT INTO AREA_DETAILS VALUES(600013,'CHETPET');

INSERT INTO EMPLOYEE VALUES('E5390','AISHU','13-NOV-2000',600010);
INSERT INTO EMPLOYEE VALUES('E4181','VAISHALI','13-DEC-1999',600082);
INSERT INTO EMPLOYEE VALUES('E3912','ABI','13-OCT-1999',600010);

REM  violates constraints

INSERT INTO EMPLOYEE VALUES('3780','santhi','13-NOV-1978',600011);

INSERT INTO CUSTOMER VALUES('C7541','JAISRI','3RD STREET', 600013, '26-JAN-1996', 9451263478);
INSERT INTO CUSTOMER VALUES('C8191','MADHU','1ST STREET',600011,'04-JUL-1993',9348764514);
INSERT INTO CUSTOMER VALUES('C9173','ASHWIN','5TH STREET',600010,'19-APR-1990',9545756281);

REM  violates constraints

INSERT INTO CUSTOMER VALUES ('C2343','RAJ','6TH STREET',600082,'19-AUG-1989', 9348764514);

INSERT INTO PART VALUES('P23456','NUT',23,20);
INSERT INTO PART VALUES('P87910','HAMMER',50,200);
INSERT INTO PART VALUES('P63729','BOLT', 65,410);
INSERT INTO PART VALUES('P01023','SPANNER',45,150);

REM  violates constraints

INSERT INTO PART VALUES('P40952','SAW',NULL,200);

INSERT INTO ORDERS VALUES('O70850','C9173','E4181','05-DEC-2018','07-DEC-2018');
INSERT INTO ORDERS VALUES('O80791','C7541','E3912','20-JAN-2019','21-JAN-2019');
INSERT INTO ORDERS VALUES('O53865','C8191','E5390','10-JAN-2019','15-JAN-2019');

REM  violates constraints

INSERT INTO ORDERS VALUES('O24355', 'C8191','E4181' ,'18-FEB-2018','15-FEB-2018');

INSERT INTO ORDER_DETAILS VALUES('O70850','P01023',45);
INSERT INTO ORDER_DETAILS VALUES('O80791','P01023',15);
INSERT INTO ORDER_DETAILS VALUES('O80791','P87910',80);
INSERT INTO ORDER_DETAILS VALUES('O53865','P63729',100);

REM  violates constraints

INSERT INTO ORDER_DETAILS VALUES('O53865','P23456',-2);

SELECT * FROM AREA_DETAILS;
SELECT * FROM PART;
SELECT * FROM EMPLOYEE;
SELECT * FROM CUSTOMER;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_DETAILS;

REM  It is identified that the following attributes are to be included in respective relations:Parts (reorder level), Employees (hiredate)

ALTER TABLE EMPLOYEE
ADD (HIRE_DATE DATE);

DESC EMPLOYEE;

ALTER TABLE PART
ADD (REORDER_LEVEL NUMBER(5));

DESC PART;

REM The width of a customer name is not adequate for most of the customers.

ALTER TABLE CUSTOMER 
MODIFY C_NAME VARCHAR2(20);

REM  The dateofbirth of a customer can be addressed later / removed from the schema.

ALTER TABLE CUSTOMER 
DROP COLUMN DOB;

DESC CUSTOMER;

REM An order can not be placed without the receive date

ALTER TABLE ORDERS
ADD CONSTRAINT rcd_dt_nn CHECK(RCD_DT IS NOT NULL);

DESC ORDERS;

REM  A customer may cancel an order or ordered part(s) may not be available in a stock. 
REM Hence on removing the details of the order, ensure that all the corresponding details are also deleted.

ALTER TABLE ORDER_DETAILS
DROP CONSTRAINT or_no;
ALTER TABLE ORDER_DETAILS
ADD CONSTRAINT or_no
FOREIGN KEY(O_NO)
REFERENCES ORDERS (O_NO)
ON DELETE CASCADE;
DESC ORDER_DETAILS;

DELETE FROM ORDERS WHERE O_NO='O70850';

SELECT * FROM AREA_DETAILS;
SELECT * FROM PART;
SELECT * FROM EMPLOYEE;
SELECT * FROM CUSTOMER;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_DETAILS;