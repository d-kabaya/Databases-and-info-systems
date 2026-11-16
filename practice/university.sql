-- =====================================================================
-- Practice database 2: UNIVERSITY
-- The STUDENTS, COURSES and EXAMS tables used in the relational model,
-- relational algebra and SQL data definition lectures
-- (lessons 2 to 6). Run this whole file in MySQL Workbench.
--
-- To start again from scratch, run:  drop schema university;
-- =====================================================================
create schema university;
use university;

create table STUDENTS(
    StudentID integer primary key,
    Surname varchar(20) not null,
    FirstName varchar(20) not null,
    BirthDate date
);

create table COURSES(
    CourseID smallint primary key,
    Title varchar(20),
    Tutor varchar(20)
);

create table EXAMS(
    StudentID integer,
    Grade varchar(2),
    CourseID smallint,
    primary key (StudentID, CourseID),
    foreign key (StudentID)
        references STUDENTS(StudentID)
        on delete no action
        on update cascade,
    foreign key (CourseID)
        references COURSES(CourseID)
        on delete cascade
        on update no action
);

insert into STUDENTS values (276545, 'Smith', 'Mary', '1990-11-25');
insert into STUDENTS values (485745, 'Black', 'Anna', '1991-04-23');
insert into STUDENTS values (200768, 'Verdi', 'Paolo', '1991-02-12');
insert into STUDENTS values (587614, 'Smith', 'Lucy', '1990-10-10');
insert into STUDENTS values (937653, 'Brown', 'Mavis', '1990-12-01');

insert into COURSES values (1, 'Physics', 'Grant');
insert into COURSES values (3, 'Chemistry', 'Beale');
insert into COURSES values (4, 'Chemistry', 'Clark');

insert into EXAMS values (276545, 'C', 1);
insert into EXAMS values (276545, 'B', 4);
insert into EXAMS values (937653, 'A+', 1);
insert into EXAMS values (200768, 'B', 4);
