/*********************************************************************************************************
             BANKING SYSTEM (Oracle SQL & PL/SQL) — Gagnef Savings Bank
 A small relational banking system: tables, constraints, triggers, functions, and stored procedures
 for handling customers, accounts, deposits, withdrawals, and transfers with balance integrity,
 overdraft protection, and authorization checks enforced at the database level.
*********************************************************************************************************/

	   
/* CREATING THE TABLES: The data model is implemented with SQL DDL below, creating each table and
                        establishing the primary and foreign key constraints that enforce the
                        relationships between them. */	   

/******** CUSTOMER TABLE ********/
create table customer(
cust_id varchar2(11) not null,
first_name varchar2(25) not null,
last_name varchar2(25) not null,
passwd varchar2(6) not null
);

alter table customer
add constraint customer_custid_pk primary key(cust_id);


/******** ACCOUNT_TYPE TABLE ********/
create table account_type(
accty_id number(6) not null,
accty_name varchar2(20) not null,
present_interest number(5,2) not null
);

alter table account_type
add constraint accounttype_acctyid_pk primary key(accty_id);


/******** INTEREST_CHANGE TABLE ********/
create table interest_change(
intch_id number(6) not null,
accty_id number(6) not null,
interest number(5,2) not null,
date_time date not null
);

alter table interest_change
add constraint interestchange_intchid_pk primary key(intch_id)
add constraint interestchange_acctyid_fk foreign key(accty_id) references account_type(accty_id);

/******** ACCOUNT TABLE ********/
create table account(
acc_id number(8) not null,
accty_id number(6) not null,
date_time date not null,
balance number(10,2) not null
);

alter table account
add constraint account_accid_pk primary key(acc_id)
add constraint account_acctyid_fk foreign key(accty_id) references account_type(accty_id);


/******** ACCOUNT_OWNER TABLE ********/
create table account_owner(
accow_id number(9) not null,
cust_id varchar2(11) not null,
acc_id number(8) not null
);

alter table account_owner
add constraint accountowner_accowid_pk primary key(accow_id)
add constraint accountowner_custid_fk foreign key(cust_id) references customer(cust_id)
add constraint accountowner_accid_fk foreign key(acc_id) references account(acc_id);


/******** DEPOSITION TABLE ********/
create table deposition(
dep_id number(9) not null,
cust_id varchar2(11) not null,
acc_id number(8) not null,
amount number(10,2) not null,
date_time date not null);

alter table deposition
add constraint deposition_depid_pk primary key(dep_id)
add constraint deposition_custid_fk foreign key(cust_id) references customer(cust_id)
add constraint deposition_accid_fk foreign key(acc_id) references account(acc_id);


/******** WITHDRAWAL TABLE ********/
create table withdrawal(
wit_id number(9) not null,
cust_id varchar2(11) not null,
acc_id number(8) not null,
amount number(10,2) not null,
date_time date not null
);

alter table withdrawal
add constraint withdrawal_witid_pk primary key(wit_id)
add constraint withdrawal_custid_fk foreign key(cust_id) references customer(cust_id)
add constraint withdrawal_accid_fk foreign key(acc_id) references account(acc_id);


/******** TRANSFER TABLE ********/
create table transfer(
tra_id number(9) not null,
cust_id varchar2(11) not null,
from_acc_id number(8) not null,
to_acc_id number(8) not null,
amount number(10,2) not null,
date_time date not null
);

alter table transfer
add constraint transfer_traid_pk primary key(tra_id)
add constraint transfer_custid_fk foreign key(cust_id) references customer(cust_id)
add constraint transfer_fromaccid_fk foreign key(from_acc_id) references account(acc_id)
add constraint transfer_toaccid_fk foreign key(to_acc_id) references account(acc_id);


		   
/* PASSWORD VALIDATION: The biufer_customer trigger fires before any insert or update of the passwd
                        column on the customer table. It verifies that every password is exactly six
                        characters long; if not, the transaction is halted and an error is reported. */
 
		   
create or replace trigger biufer_customer
before insert or update
of passwd
on customer
for each row
when (length(new.passwd) <> 6)
begin
   raise_application_error(-20001,'Password must contain 6 characters!');
end;
/


/* ADDING CUSTOMERS: The do_new_customer procedure inserts new rows into the customer table. Its input
                     parameters, in order, are cust_id, first_name, last_name, and passwd. */

create or replace procedure do_new_customer(
p_cust_id    in customer.cust_id%type,
p_first_name in customer.first_name%type,
p_last_name  in customer.last_name%type,
p_passwd     in customer.passwd%type)
as
begin
  insert into customer(cust_id, first_name, last_name, passwd)
  values(p_cust_id, p_first_name,p_last_name,p_passwd);
  commit;
end;
/
 
 
/* ADDING CUSTOMERS: The do_new_customer procedure inserts new rows into the customer table. Its input
                     parameters, in order, are cust_id, first_name, last_name, and passwd. */

--Trigger test:   

begin 
do_new_customer('861124-4478','Raul','Ortiz','qwe'); 
end;

--Result of the trigger test:

/*ORA-20001: Password must contain 6 characters! ORA-06512: at "SQL_KLXDRLKTEHZPQVKDMAISAPBIY.BIUFER_CUSTOMER", line 2
ORA-06512: at "SQL_KLXDRLKTEHZPQVKDMAISAPBIY.DO_NEW_CUSTOMER", line 8
ORA-06512: at line 2
ORA-06512: at "SYS.DBMS_SQL", line 1721 /*


/* AUTOMATIC PRIMARY KEYS: A shared sequence, pk_seq, supplies primary key values for the
                           account_owner, withdrawal, deposition, transfer, and interest_change tables,
                           each wired up through its own before-insert trigger. */

create sequence pk_seq;

create or replace trigger bifer_accountowner_pk
before insert
on account_owner 
for each row
begin
  select pk_seq.nextval
  into :new.accow_id
  from dual;
end;
/
    
create or replace trigger bifer_withdrawal_pk
before insert
on withdrawal
for each row
begin
  select pk_seq.nextval
  into :new.wit_id
  from dual;
end;
/

create or replace trigger bifer_deposition_pk
before insert
on deposition
for each row
begin
  select pk_seq.nextval
  into :new.dep_id
  from dual;
end;
/

create or replace trigger bifer_transfer_pk
before insert
on transfer
for each row
begin
  select pk_seq.nextval
  into :new.tra_id
  from dual;
end;
/

create or replace trigger bifer_interestchange_pk
before insert
on interest_change
for each row
begin
  select pk_seq.nextval
  into :new.intch_id
  from dual;
end;
/

/* AUTHENTICATION: The log_in function returns 1 on a successful login and 0 on a failed one. A customer
                   authenticates by supplying two parameters: cust_id and passwd. */

create or replace function log_in(
p_cust_id in customer.cust_id%type,
p_passwd  in customer.passwd%type)
return number
as
v_result customer.cust_id%type;
begin
    select cust_id
    into v_result
    from customer
    where cust_id = p_cust_id
    and passwd = p_passwd;
    return 1;
exception
    when no_data_found then
    return 0;
end;
/


-- Test the login function with valid and invalid credentials:
select log_in('650707-1111','qwerTY') as log_in
from dual;

select log_in('650707-1111','olle85') as log_in
from dual;


/* ACCOUNT BALANCE: The get_balance function returns the current balance of the account whose account
                    number (acc_id) is passed to it. */
		 
create or replace function get_balance(
p_acc_id in account.acc_id%type)
return account.balance%type
as
v_balance account.balance%type;
begin
    select balance
    into v_balance
    from account
    where acc_id = p_acc_id;
    return v_balance;
end;
/

-- Function test:
select get_balance(123) as current_balance
from dual;


/* ACCOUNT AUTHORITY: The get_authority function takes two parameters from the account_owner table,
                      cust_id and acc_id, and returns 1 if the customer is authorized to make
                      withdrawals from the account, or 0 otherwise. It is also used during transfers to
                      confirm authority over the account referenced by from_acc_id. */

create or replace function get_authority(
p_cust_id in account_owner.cust_id%type,
p_acc_id  in account_owner.acc_id%type)
return number
as
v_result number(1);
begin
    select count(accow_id)
    into v_result
    from account_owner
    where cust_id = p_cust_id
    and acc_id = p_acc_id;
    return v_result;
end;
/

-- Function test:
select get_authority('650707-1111',123) as authorization
from dual;

select get_authority('650707-1111',5899) as authorization
from dual;

select get_authority('650707-1111',8896) as authorization
from dual;


/* BALANCE UPDATE ON DEPOSIT: The aifer_deposition trigger fires after an insert on the deposition
                              table and updates the account balance so it is correct after a deposit. */

create or replace trigger aifer_deposition
after insert
on deposition
for each row
begin
    update account
    set balance = balance + :new.amount
    where acc_id = :new.acc_id;
end;
/


/* OVERDRAFT PROTECTION ON WITHDRAWAL: The bifer_withdrawal trigger fires before an insert on the
                                       withdrawal table and uses the get_balance function to prevent a
                                       withdrawal larger than the available balance. */
			
create or replace trigger bifer_withdrawal
before insert
on withdrawal
for each row
begin
  if ( :new.amount > get_balance(:new.acc_id) ) then
  raise_application_error(-20001,'You do not have enough money in your account!');
  end if;
end;
/


/* BALANCE UPDATE ON WITHDRAWAL: The aifer_withdrawal trigger fires after an insert on the withdrawal
                                 table and updates the account balance so it is correct after a
                                 withdrawal. */

create or replace trigger aifer_withdrawal
after insert
on withdrawal
for each row
begin
     update account
     set balance = balance - :new.amount
     where acc_id = :new.acc_id;
end;
/


/* OVERDRAFT PROTECTION ON TRANSFER: The bifer_transfer trigger fires before an insert on the transfer
                                     table and uses the get_balance function to prevent moving more
                                     money out of the source account than it currently holds. */

create or replace trigger bifer_transfer
before insert
on transfer
for each row
begin
  if ( :new.amount > get_balance(:new.from_acc_id) ) then
  raise_application_error(-20001,'You do not have enough money in your account!');
  end if;
end;
/


/* BALANCE UPDATE ON TRANSFER: The aifer_transfer trigger fires after an insert on the transfer table
                               and keeps both accounts correct by deducting the amount from the source
                               account and adding it to the destination account. */
			
create or replace trigger aifer_transfer
after insert
on transfer
for each row
begin
     update account
     set balance = balance - :new.amount
     where acc_id = :new.from_acc_id; 

     update account
     set balance = balance + :new.amount
     where acc_id = :new.to_acc_id;     
end;
/
/* DEPOSIT PROCEDURE: The do_deposition procedure inserts a row into the deposition table and, after the
                      transaction commits, prints a message with the account's updated balance. */
			
create or replace procedure do_deposition(
p_cust_id in deposition.cust_id%type,
p_acc_id  in deposition.acc_id%type,
p_amount  in deposition.amount%type)
as
begin
    insert into deposition(cust_id, acc_id, amount, date_time)
    values(p_cust_id, p_acc_id,p_amount,sysdate);
    commit;
    dbms_output.put_line('The current balance of the account '||p_acc_id||' is '||get_balance(p_acc_id)||' sek.');
end;
/

/* TESTING THE DEPOSIT PROCEDURE: */

begin 
    do_deposition('650707-1111',123,3240);
end;
/

select balance
from account
where acc_id = 123;


/* WITHDRAWAL PROCEDURE: The do_withdrawal procedure inserts a row into the withdrawal table. It declares
                         an unauthorized exception, raised through get_authority when the customer lacks
                         authority over the account. If unauthorized, the transaction is stopped and
                         "Unauthorized user!" is printed; if authorized, the account balance after the
                         transaction is printed. */

create or replace procedure do_withdrawal(
p_cust_id in withdrawal.cust_id%type,
p_acc_id  in withdrawal.acc_id%type,
p_amount  in withdrawal.amount%type)
as
begin
   if (get_authority(p_cust_id, p_acc_id)=0) then
       raise_application_error(-20001,'Unauthorized user!');
   else
       insert into withdrawal(cust_id, acc_id, amount, date_time)
       values(p_cust_id, p_acc_id,p_amount,sysdate);
       commit;
       dbms_output.put_line('The current balance of the account '||p_acc_id||' is '||get_balance(p_acc_id)||' sek.');
   end if;
end;
/


/* TESTING THE WITHDRAWAL PROCEDURE: This also confirms the supporting triggers work, checking that a
                                     withdrawal larger than the balance and an unauthorized withdrawal
                                     are both rejected, and that the balance updates correctly. */
			
begin
  do_withdrawal('650707-1111',123,1000);
end;
/

select balance
from account
where acc_id = 123;

begin
  do_withdrawal('650707-1111',123,3000);
end;
/
--ORA-20001: You do not have enough money in your account!

begin
  do_withdrawal('861124-4478',123,100);
end;
/ 

--ORA-20001: Unauthorized user!


/* TRANSFER PROCEDURE: The do_transfer procedure inserts a row into the transfer table. Like the
                       withdrawal procedure, it declares an unauthorized exception, raised through
                       get_authority when the customer lacks authority over the source account. If
                       unauthorized, the transaction is stopped and "Unauthorized user!" is printed; if
                       authorized, the balances of both accounts after the transaction are printed. */


create or replace procedure do_transfer(
p_cust_id     in transfer.cust_id%type,
p_from_acc_id in transfer.from_acc_id%type,
p_to_acc_id   in transfer.to_acc_id%type,
p_amount      in transfer.amount%type)
as
begin
   if (get_authority(p_cust_id, p_from_acc_id)=0) then
       raise_application_error(-20001,'Unauthorized user!');
   else
       insert into transfer(cust_id, from_acc_id, to_acc_id, amount, date_time)
       values(p_cust_id, p_from_acc_id, p_to_acc_id, p_amount, sysdate);
       commit;
       dbms_output.put_line('The current balance of the account '||p_from_acc_id||' is '||get_balance(p_from_acc_id)||' sek.');
       dbms_output.put_line('The current balance of the account '||p_to_acc_id  ||' is '||get_balance(p_to_acc_id)  ||' sek.');
   end if;
end;
/ 
 
 
/* TESTING THE TRANSFER PROCEDURE: Money is moved between accounts to confirm the triggers behave as
                                   expected. */
  
begin
  do_transfer('650707-1111',123,8896,1500);
end;
/

-- Statement processed.
-- The current balance of the account 123 is 740 sek.
-- The current balance of the account 8896 is 1500 sek.

select balance
from account
where acc_id in (123,8896);

begin
  do_transfer('861124-4478',123,8896,600);
end;
/   

-- ORA-20001: Unauthorized user!

begin
  do_transfer('650707-1111',123,8896,2000);
end;
/ 

-- ORA-20001: You do not have enough money in your account!