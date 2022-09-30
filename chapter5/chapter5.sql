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

create function find_all_pre(cid varchar(8))
    returns table
            (
                course_id varchar(8)
            )
as
$$
BEGIN
    Create temporary table c_req
    (
        course_id varchar(8)
    );
    create temporary table new_c_req
    (
        course_id varchar(8)
    );
    create temporary table temp
    (
        course_id varchar(8)
    );

    insert into new_c_req
    select prereq_id
    from prereq
    where course_id = cid;





end;
$$













