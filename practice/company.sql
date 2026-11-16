-- =====================================================================
-- Practice database 1: COMPANY
-- The EMPLOYEE and DEPARTMENT tables used in the SQL lectures
-- (lessons 7, 8 and 9). Run this whole file in MySQL Workbench, then
-- try the queries from the lessons.
--
-- To start again from scratch, run:  drop schema company;
-- =====================================================================
create schema company;
use company;

create table DEPARTMENT(
    DeptName varchar(20) primary key,
    Address varchar(30),
    City varchar(20)
);

create table EMPLOYEE(
    FirstName varchar(20),
    Surname varchar(20),
    Dept varchar(20),
    Office smallint,
    Salary integer,
    City varchar(20),
    primary key (FirstName, Surname),
    foreign key (Dept)
        references DEPARTMENT(DeptName)
);

insert into DEPARTMENT values ('Administration', 'Bond Street', 'London');
insert into DEPARTMENT values ('Production', 'Rue Victor Hugo', 'Toulouse');
insert into DEPARTMENT values ('Distribution', 'Pond Road', 'Brighton');
insert into DEPARTMENT values ('Planning', 'Bond Street', 'London');
insert into DEPARTMENT values ('Research', 'Sunset Street', 'San Jose');

insert into EMPLOYEE values ('Mary', 'Brown', 'Administration', 10, 45, 'London');
insert into EMPLOYEE values ('Mairead', 'Green', 'Production', 20, 36, 'Toulouse');
insert into EMPLOYEE values ('Alice', 'O''Neil', 'Administration', 20, 40, 'Cork');
insert into EMPLOYEE values ('Jackson', 'Neri', 'Distribution', 16, 45, 'Dover');
insert into EMPLOYEE values ('Charles', 'Brown', 'Planning', 10, 80, 'Limerick');
insert into EMPLOYEE values ('Laurence', 'Chen', 'Planning', 20, 73, 'Worthing');
insert into EMPLOYEE values ('Pauline', 'Bradshaw', 'Production', 20, 45, 'Brighton');
insert into EMPLOYEE values ('Alice', 'Brown', 'Research', 10, null, 'Dublin');
