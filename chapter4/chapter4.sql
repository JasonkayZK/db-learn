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
    course_id varchar(8),
    sec_id    varchar(8),
    semester  varchar(6)
        check (semester in ('Fall', 'Winter', 'Spring', 'Summer')),
    year      numeric(4, 0) check (year > 1701 and year < 2100
) ,
    building     varchar(15),
    room_number  varchar(7),
    time_slot_id varchar(4),
    primary key (course_id, sec_id, semester, year),
);


-- 4.4.5 referential

create table test_4_4_5_1
(
    id bigint,
    foreign key (dept_name) references department
--         on delete cascade
--         on delete set null
        on delete set default
        on update cascade
)











