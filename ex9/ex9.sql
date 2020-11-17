drop table emp_payroll;

CREATE TABLE emp_payroll(
eid number(3) constraint eid_pk PRIMARY KEY,
ename varchar2(20) constraint ename_nn NOT NULL,
dob date,
sex varchar2(5),
designation varchar2(20) ,
basic float(6) ,
da float(6),
hra float(6),
pf float(6),
mc float(6),
gross float(6),
tot_deduc float(6),
net_pay float(6)
);

REM PL/SQL for calculating payroll
set serveroutput on;

CREATE OR REPLACE PROCEDURE netpay_calc(
eid IN emp_payroll.eid%type,
basic IN emp_payroll.basic%type, 
da OUT emp_payroll.da%type, 
hra OUT emp_payroll.hra%type, 
mc OUT emp_payroll.mc%type, 
pf OUT emp_payroll.pf%type, 
gross OUT emp_payroll.gross%type, 
tot_deduc OUT emp_payroll.tot_deduc%type, 
net_pay OUT emp_payroll.net_pay%type) 

IS
BEGIN
da:=0.6*basic;
hra:=0.11*basic;
mc:=0.03*basic;
pf:=0.04*basic;
gross:=basic+da+hra;
tot_deduc:=pf+mc;
net_pay:=gross-tot_deduc;
end;
/