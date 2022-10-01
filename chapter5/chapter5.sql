-- 5 Advance SQL

-- 5.1 Visit Database

-- 5.1.1 JDBC

-- 5.1.2 ODBC


-- 5.2 Function and Process

create or replace function dept_count(dept_name varchar(20))
    returns integer as
$$
declare
    d_count integer;
begin
    select count(*)
    into d_count
    from instructor
    where instructor.dept_name = $1;
    return d_count;
end;
$$
    LANGUAGE plpgsql;

select dept_count('Comp. Sci.');

select dept_name, budget
from department
where dept_count(dept_name) > 12;

-- create or replace function instructor_of(a_dept_name varchar(20))
--     returns table
--             (
--                 id             varchar(5),
--                 name varchar(20),
--                 dept_name       varchar(20),
--                 salary          numeric(8, 2)
--             )
-- as
-- $$
-- BEGIN
--     select id, name, dept_name, salary
--     from instructor
--     where dept_name = $1;
-- end;
-- $$ LANGUAGE plpgsql;

create or replace procedure dept_count_proc(in dept_name varchar(20), inout d_count integer)
as
$$
begin
    select count(*)
    into d_count
    from instructor
    where instructor.dept_name = dept_count_proc.dept_name;
end;
$$ LANGUAGE plpgsql;

create or replace procedure new_dept_count_proc(in dept_name varchar(20), inout d_count integer)
as
$$
begin
    call dept_count_proc(dept_name, d_count);
end;
$$ LANGUAGE plpgsql;

create or replace function new_dept_count(dept_name varchar(20))
    returns integer as
$$
declare
    d_count integer;
begin
    call dept_count_proc(dept_name, d_count);
    return d_count;
end;
$$
    LANGUAGE plpgsql;

select *
from new_dept_count('Comp. Sci.');


-- while

create or replace function while_demo(i integer)
    returns integer as
$$
declare
    ret integer := 0;
BEGIN
    while i < 10
        loop
            if i = 5 then
                raise notice 'i is 5!';
            elseif i = 6
            then
                raise notice 'i is 6!';
            end if;
            raise notice 'i %', i;
            i = i + 1;
        end loop;
    select i into ret;
    return ret;
end;
$$ LANGUAGE plpgsql;

select while_demo(2);


-- 5.3 Trigger

CREATE TABLE employees_5_3
(
    id         serial primary key,
    first_name varchar(40) NOT NULL,
    last_name  varchar(40) NOT NULL
);

CREATE TABLE employee_audits_5_3
(
    id          serial primary key,
    employee_id int4         NOT NULL,
    last_name   varchar(40)  NOT NULL,
    changed_on  timestamp(6) NOT NULL
);

CREATE OR REPLACE FUNCTION log_last_name_changes()
    RETURNS trigger AS
$BODY$
BEGIN
    IF NEW.last_name <> OLD.last_name THEN
        INSERT INTO employee_audits_5_3(employee_id, last_name, changed_on)
        VALUES (OLD.id, OLD.last_name, now());
    END IF;
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER last_name_changes
    BEFORE UPDATE
    ON employees_5_3
    FOR EACH ROW
EXECUTE PROCEDURE log_last_name_changes();

INSERT INTO employees_5_3 (first_name, last_name)
VALUES ('John', 'Doe');

INSERT INTO employees_5_3 (first_name, last_name)
VALUES ('Lily', 'Bush');

UPDATE employees_5_3
SET last_name = 'Brown'
WHERE ID = 2;


-- 5.4 Recursive Search

with recursive rec_pre(course_id, pre_id
    ) as (select course_id, prereq_id
          from prereq
          union
          select rec_pre.course_id, rec_pre.pre_id
          from prereq,
               rec_pre
          where prereq.course_id = rec_pre.course_id)
select *
from rec_pre
where course_id = 'CS-347';


-- 5.5 Aggregation

-- 5.5.1 Ordering

select course_id, rank() over (order by (credits) desc) as s_course
from course
order by s_course;

select course_id, dense_rank() over (order by (credits) desc) as s_course
from course
order by s_course;

select course_id,
       dept_name,
       rank() over (partition by dept_name order by credits desc ) as dept_rank
from course
order by dept_name, dept_rank;

select *
from course
order by credits
limit 5;

select course_id,
       dept_name,
       percent_rank() over (partition by dept_name order by credits desc ) as dept_rank
from course
order by dept_name, dept_rank;

select course_id,
       dept_name,
       cume_dist() over (partition by dept_name order by credits desc ) as dept_rank
from course
order by dept_name, dept_rank;

select course_id,
       dept_name,
       row_number() over (partition by dept_name order by credits desc ) as dept_rank
from course
order by dept_name, dept_rank;


select course_id, ntile(4) over (order by credits desc nulls last ) as quartile
from course;


-- Windowing

create or replace view tot_credits as
select s.id as id, a.year as year, a.credits as num_credits
from student s
         inner join (select t.id, t.year, c.credits
                     from course c
                              inner join takes t on c.course_id = t.course_id) a on a.id = s.id;

select year, avg(num_credits) over (order by year rows 3 preceding)
from tot_credits;

select year, avg(num_credits) over (order by year rows unbounded preceding)
from tot_credits;

select year, avg(num_credits) over (order by year rows between 3 preceding and 2 following)
from tot_credits;

select year, avg(num_credits) over (order by year between year - 4 and year)
from tot_credits;


-- 5.6 OLAP







