-- 4.1
-- 4.1.1 on join

select *
from student s
         join takes t on s.id = t.id;

select *
from student
         natural join takes;

select *
from student s,
     takes t
where s.id = t.id;

-- 4.1.2 outer join

select *
from student
         natural left outer join takes;

select id
from student
         natural left outer join takes
where course_id is null;

select *
from takes
         natural right outer join student;


select *
from (select *
      from student
      where dept_name = 'Comp. Sci.') a
         natural full outer join
         (select * from takes where semester = 'Spring' and year = 2009) b;

select *
from student
         left outer join takes on true
where student.id = takes.id;


-- 4.2 view

select c.course_id, sec_id, building, room_number
from course c,
     section s
where c.course_id = s.course_id
  and c.dept_name = 'Physics'
  and s.semester = 'Fall'
  and s.year = 2009;

select c.course_id, sec_id, building, room_number
from section s
         inner join course c on c.course_id = s.course_id
    and c.dept_name = 'Physics'
    and s.semester = 'Fall'
    and s.year = 2009;


create view faculty as
select id, name, dept_name
from instructor;

create view physics_fall_2009 as
select c.course_id, sec_id, building, room_number
from section s
         inner join course c on c.course_id = s.course_id
    and c.dept_name = 'Physics'
    and s.semester = 'Fall'
    and s.year = 2009;


-- 4.2.2 select view

select course_id
from physics_fall_2009
where building = 'Watson';


create view department_total_salary(dept_name, total_salary) as
select dept_name, sum(salary)
from instructor
group by dept_name;

-- 4.2.4 update view

create view faculty_limited as
select id, name, dept_name
from instructor
where dept_name <> ''
with check option;


-- 4.4.2 not null

create table test_4_4_2
(
    name varchar(20) not null
);


-- 4.4.2 unique

create table test_4_4_3
(
    name   varchar(20) default null,
    budget numeric(12, 2) not null,
    unique (name, budget)
);

-- 4.4.4 check

create table test_4_4_4
(
    name   varchar(20) default null,
    budget numeric(12, 2) not null,
    unique (name, budget),
    check (budget > 0)
);

create table section
(
    course_id    varchar(8),
    sec_id       varchar(8),
    semester     varchar(6)
        check (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
    year         numeric(4, 0) check (year > 1701 and year < 2100
        ),
    building     varchar(15),
    room_number  varchar(7),
    time_slot_id varchar(4),
    primary key (course_id, sec_id, semester, year)
);


-- 4.4.5 referential

create table test_4_4_5_1
(
    id        bigint primary key,
    dept_name varchar(20) not null
        primary key,
    building  varchar(15),
    budget    numeric(12, 2)
        constraint department_budget_check
            check (budget > (0)::numeric)
);

create table test_4_4_5_2
(
    id bigint,
    foreign key (id) references test_4_4_5_1
--         on delete cascade
--         on delete set null
        on delete set default
        on update cascade
);

-- 4.4.6 transaction consistency

create table test_4_4_6
(
    id bigint references test_4_4_5_1 (id) initially deferred primary key
);

set constraints ALL deferred;

set constraints test_4_4_5_1.department_budget_check IMMEDIATE;


-- 4.4.7 complex check and assert

create table test_4_4_7
(
    time_slot_id varchar(4),
    check ( time_slot_id in (select time_slot_id
                             from time_slot) )
);

-- create ASSERTION credit_earned_constraint check
-- (
--   not exists (
--         select id from student where tot_cred <> (
--             select sum(credit) from takes natural join course
-- where student.id = takes.id and grade is not null and grade <> 'F'))
-- );


-- 4.5 other types

-- 4.5.1 date and time

select cast('2001-04-25' as date);

select cast('09:30:00' as time);

select cast('2001-04-25 09:30:00.22' as timestamp);

select extract(year from cast('2001-04-25 09:30:00' as date));
select extract(month from cast('2001-04-25 09:30:00' as date));
select extract(day from cast('2001-04-25 09:30:00' as date));
select extract(hour from cast('2001-04-25 09:30:00' as date));
select extract(minute from cast('2001-04-25 09:30:00' as date));
select extract(second from cast('2001-04-25 09:30:00' as date));

select extract(timezone_hour from (select now()::timestamp at time zone 'US/Eastern'));

select extract(timezone_minute from (select now()::timestamp at time zone 'US/Eastern'));

select current_date, current_time, localtime, current_timestamp, localtimestamp;


-- 4.5.2 default values

create table student
(
    ID        varchar(5),
    name      varchar(20) not null,
    dept_name varchar(20),
    tot_cred  numeric(3, 0) check (tot_cred >= 0) default 0,
    primary key (ID)
);


-- 4.5.3 index

create index stu_id_idx on student (ID);


-- 4.5.4 Binary Large Object

create table test_4_5_4
(
    book bytea
);


-- 4.5.5

create type Dollars as
(
    val numeric(12, 2)
);

create table test_4_5_5
(
    dept_name varchar(20),
    building  varchar(15),
    budget    Dollars,
    primary key (dept_name)
);

alter type Dollars add attribute abc varchar(20);

drop type Dollars cascade;


create domain DDollar as numeric(20, 2) not null default 0;

create domain YearlySalary numeric(8, 2) constraint salary_val_test check ( value >= 29000.00);

create domain degree_level varchar(10) constraint degree_level_test check ( value in ('Bachelors', 'Masters', 'Doctorate'));


-- 4.5.6 create table extension

create table test_4_5_6_1
(
    like instructor including all
);

create table test_4_5_6_2
(
    like instructor
        including defaults
        including constraints
        including indexes
);

create table test_4_5_6_3 as (select *
                              from instructor
                              where dept_name = 'Music') with data;


-- 4.5.7 Schema & Databases

CREATE DATABASE gaga;

CREATE SCHEMA gaga;


-- 4.6 Grant Privilege

grant select, update, insert, update on instructor to admin;

grant all privileges on instructor to admin;

grant update (budget) on department to admin;

grant insert (budget) on department to admin;

grant all privileges on department to public;

revoke all privileges on department from public;

revoke insert (budget) on department from public;


-- 4.6.2 Role

create role instructor;

grant select on student to instructor;

grant instructor to public;

create role instructor2;

grant instructor to instructor2;


-- 4.6.3 Grant View


-- 4.6.4 Grant Schema

grant references (dept_name) on department to public;


-- 4.6.5 Transfer Grant

grant select on department to public with grant option;


-- 4.6.6 Revoke Grant

revoke select on department from public restrict;
revoke select on department from public cascade;

revoke grant option for select on department from public;

set role instructor;

grant instructor to public granted by current_role;

