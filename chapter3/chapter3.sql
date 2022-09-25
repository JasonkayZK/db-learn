-- 3.3.1
select name
from instructor;

select dept_name
from instructor;

select distinct dept_name
from instructor;

select all dept_name
from instructor;


-- 3.3.2 Cartesian product
select name, instructor.dept_name, building
from instructor,
     department
where instructor.dept_name = department.dept_name;

select name, course_id
from instructor,
     teaches
where instructor.id = teaches.id;

select name, course_id
from instructor,
     teaches
where instructor.id = teaches.id
  and instructor.dept_name = 'Comp. Sci.';


-- 3.3.3 natural join
select name, course_id
from instructor
         natural join teaches;

select name, title
from instructor
         natural join teaches,
     course
where teaches.course_id = teaches.course_id;

select name, title
from instructor
         natural join teaches
         natural join course;

select name, title, a.dept_name, b.dept_name
from (instructor natural join teaches) as a
         join course as b using (course_id);

-- 3.4.1

select distinct t.name
from instructor t,
     instructor s
where t.salary > s.salary
  and s.dept_name = 'Biology';


-- 3.4.2

select 'it''s right';

select upper('it''s right');

select trim('  it''s right  ');

select dept_name
from department
where building like '%Watson%';

select *
from (select 'abc' as x union select 'ab%cd' as x union select 'ss' as x union select 'ab%cde' as x) as a
where a.x like 'ab\%cd%' escape '\';

select *
from (select 'abc' as x union select 'ab%cd' as x union select 'ss' as x union select 'ab%cde' as x) as a
where a.x not like 'ab\%cd%' escape '\';

select *
from (select 'abc' as x union select 'ab%cd' as x union select 'ss' as x union select 'ab%cde' as x) as a
where a.x similar to 'ab\%cd%' escape '\';


-- 3.4.3

select *
from instructor,
     teaches
where instructor.id = teaches.id;

-- 3.4.4

select *
from instructor
where dept_name = 'Physics'
order by name;

select *
from instructor
order by salary desc, name asc;


-- 3.4.5

select name
from instructor
where salary between 90000 and 100000;

select name, course_id
from instructor,
     teaches
where (instructor.id, dept_name) = (teaches.id, 'Biology');

select *
from instructor i,
     teaches t
where (i.salary, t.year) < (100000, 2010);


-- 3.5

select course_id
from section
where semester = 'Fall'
  and year = 2009
-- union
-- union all
-- intersect
-- intersect all
-- except
except all
select course_id
from section
where semester = 'Spring'
  and year = 2010;


-- 3.6 null

select name
from instructor
where salary is not null;

select name
from instructor
where salary > 0 is not unknown;

select null = null is unknown;


-- 3.7 aggregate

select avg(salary)
from instructor
where dept_name = 'Comp. Sci.';

select count(distinct id)
from teaches
where semester = 'Spring'
  and year = 2010;

select count(*)
from course;


-- 3.7.2

select dept_name, avg(salary)
from instructor
group by dept_name;

select dept_name, count(distinct id)
from instructor
         natural join teaches
where semester = 'Spring'
  and year = 2010
group by dept_name;


-- 3.7.3 having

select dept_name, avg(salary)
from instructor
group by dept_name
having avg(salary) > 72000;


select course_id, semester, year, sec_id, avg(tot_cred)
from takes
         natural join student
where year = 2010
group by course_id, semester, year, sec_id
having count(id) >= 2;

select every(x > 1)
from (select 'a' as c, 1 as x union select 'b' as c, 2 as x union select 'c' as c, 3 as x union select 'd' as c, 1) a
group by x
having count(*) > 1;


-- 3.8

select course_id
from section
where semester = 'Fall'
  and year = 2009
  and course_id in (select course_id
                    from section
                    where semester = 'Spring'
                      and year = 2010);

select course_id
from section
where semester = 'Fall'
  and year = 2009
  and course_id not in (select course_id
                        from section
                        where semester = 'Spring'
                          and year = 2010);

select distinct name
from instructor
where name not in ('Mozart', 'Einstein');

select count(distinct id)
from takes
where (course_id, sec_id, semester, year) in (select course_id, sec_id, semester, year
                                              from teaches
                                              where teaches.id = '10101');

-- 3.8.2

select distinct t.name
from instructor t,
     instructor s
where t.salary > s.salary
  and s.dept_name = 'Biology';

select name
from instructor
where salary > some (select salary from instructor where dept_name = 'Biology');

select name
from instructor
where salary > all (select salary from instructor where dept_name = 'Biology');

select name
from instructor
where salary > (select max(salary) from instructor where dept_name = 'Biology');

select dept_name
from instructor
group by dept_name
having avg(salary) >= all (select avg(salary) from instructor group by dept_name);


-- 3.8.3

select course_id
from section s
where semester = 'Fall'
  and year = 2009
  and not exists(select * from section t where s.semester = 'Spring' and t.year = 2010 and s.course_id = t.course_id);

select s.id, s.name
from student s
where not exists(
            (select course_id from course where s.dept_name = 'Biology')
            except
            (select t.course_id from takes t where s.id = t.id));


-- 3.8.4 unique

-- select t.course_id
-- from course t
-- where unique (select r.course_id
--     from section r
--     where r.course_id = t.course_id
--   and r.year = 2010);

select t.course_id
from course t
where 1 >= (select count(r.course_id)
            from section r
            where r.course_id = t.course_id
              and r.year = 2010);


-- 3.8.5 from subsection

select dept_n, avg_s
from (select dept_name, avg(salary)
      from instructor
      group by dept_name) x(dept_n, avg_s)
where avg_s > 42000;

select max(total_s)
from (select dept_name, sum(salary)
      from instructor
      group by dept_name) x(dept_n, total_s);


select name, salary, avg_s
from instructor i,
     lateral (
         select avg(salary) as avg_s
         from instructor i2
         where i2.dept_name = i.dept_name
         ) x;


-- 3.8.6 with

with max_budget(value) as (select max(budget)
                           from department)
select budget
from department,
     max_budget
where department.budget = max_budget.value;


with dept_total(dept_name, value) as (select dept_name, sum(salary)
                                      from instructor
                                      group by dept_name),
     dept_total_avg(value) as (select avg(value)
                               from dept_total)
select dept_name
from dept_total,
     dept_total_avg
where dept_total.value >= dept_total_avg.value;


-- 3.8.7 scalar subselection

select dept_name,
       (select count(*)
        from instructor
        where department.dept_name = instructor.dept_name) as num_instructors
from department;


-- 3.9

-- 3.9.1 delete

delete
from instructor
where salary between 13000 and 15000;

delete
from instructor
where salary < (select avg(salary) from instructor);


-- 3.9.2 insert

insert into course (course_id, title, dept_name, credits)
values ('CS-437', 'Database System', 'Comp.Sci', 4),
       ('CS-437-2', 'Database System 2', 'Comp.Sci', 4);


insert into instructor (id, name, dept_name, salary)
select id, name, dept_name, 18000
from student
where dept_name = 'Music'
  and tot_cred > 144;


-- 3.9.3 update

update instructor
set salary = salary * 1.05
where salary < 70000;


update instructor
set salary = case
                 when salary <= 100000 then salary * 1.05
                 else salary * 1.03
    end;


update student s
set tot_cred = (select case
                           when sum(credits) is not null then sum(credits)
                           else 0
                           end
                from takes
                         natural join course
                where s.id = takes.id
                  and takes.grade <> 'F'
                  and takes.grade is not null);

