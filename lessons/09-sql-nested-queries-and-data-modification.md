# Lesson 9: SQL Part 5, Nested Queries, Data Modification, Checks and Views

[← Previous: Aggregates and set queries](08-sql-aggregates-and-set-queries.md) · [Back to index](../README.md) · [Next: Intro to database design →](10-intro-to-database-design.md)

## The big idea

This lesson finishes SQL with four topics:

1. **Nested queries:** a query inside the `where` clause of another query.
2. **Data modification:** `insert`, `delete` and `update`.
3. **More ways to define data:** `check`, assertions and views.
4. **SQL inside programs.**

> **Analogy for nested queries:** answering a question in two steps. "Who works in a London department?" First find the London departments (the inner question). Then find the employees in those departments (the outer question). A nested query writes both steps as one statement.

All examples use the EMPLOYEE and DEPARTMENT tables from [Lesson 7](07-sql-simple-queries.md#the-practice-database).

## Part A: Nested queries

### 1. `any` and `all`

A **nested query** is a SQL query contained in the `where` clause of another query. An attribute is compared with the **result** of the nested query.

```
ComparisonOperator < any | all > SelectSQL
```

where the comparison operator is one of `=`, `<>`, `<`, `>`, `<=`, `>=`.

| Keyword | The predicate is true if | Short form |
|---|---|---|
| `any` | **at least one** row returned by the nested query satisfies the comparison | `= any` is the same as **`in`** |
| `all` | **every** row returned by the nested query satisfies the comparison | `<> all` is the same as **`not in`** |

The nested query must return values whose domain is **compatible** with the attribute being compared.

### 2. `= any` (also written `in`)

**Find the first names and surnames of employees who work in the departments based in London.**

```sql
select FirstName, Surname
from EMPLOYEE
where Dept = any (select DeptName
                  from DEPARTMENT
                  where City = 'London')
```

**Read it inside out.**

1. The inner query returns the London departments: Administration, Planning.
2. The outer query keeps each employee whose Dept equals **any** of those.

Result: Mary Brown, Alice O'Neil, Charles Brown, Laurence Chen.

The same question as a simple join:

```sql
select FirstName, Surname
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName and D.City = 'London'
```

Many nested queries can be rewritten as joins. Both are correct.

**Find the employees of the Planning department who share an office with an employee of the Research department.**

```sql
select FirstName, Surname
from EMPLOYEE
where Dept = 'Planning' and
      Office = any (select Office
                    from EMPLOYEE
                    where Dept = 'Research')
```

The inner query returns office 10 (Alice Brown). The Planning employee in office 10 is **Charles Brown**.

`= any` can be replaced by `in`:

```sql
where Dept = 'Planning' and
      Office in (select Office from EMPLOYEE where Dept = 'Research')
```

### 3. `<> all` (also written `not in`)

**Find the names of the departments in which no one sits in office 20.**

```sql
select DeptName
from DEPARTMENT
where DeptName <> all (select Dept
                       from EMPLOYEE
                       where Office = 20)
```

1. The inner query returns the departments that **do** have someone in office 20: Production, Administration, Planning, Production.
2. The outer query keeps each department whose name is **different from all** of those.

Result: Distribution, Research.

The same question as a set query:

```sql
select DeptName
from DEPARTMENT
except
select Dept
from EMPLOYEE
where Office = 20
```

✅ **"No one", "never" and "none" questions** are answered with `<> all` / `not in`, with `except`, or with `not exists` (below). They cannot be answered with a simple join.

### 4. Aggregates inside nested queries

[Lesson 8](08-sql-aggregates-and-set-queries.md) showed that `select FirstName, Surname, max(Salary)` is not allowed. A nested query solves it.

**Find the first names and surnames of the employees who earn the highest salary.**

```sql
select FirstName, Surname
from EMPLOYEE
where Salary = any (select max(Salary)
                    from EMPLOYEE)
```

The inner query returns one value, 80. The outer query finds who earns it: **Charles Brown**.

An alternative using `all`:

```sql
select FirstName, Surname
from EMPLOYEE
where Salary >= all (select Salary
                     from EMPLOYEE
                     where Salary is not null)
```

"Their salary is greater than or equal to **every** salary."

⚠️ **Why `where Salary is not null`?** Without it, the inner query would include Alice Brown's null salary. `80 >= null` is not true, so the condition "greater than or equal to **all**" would fail for every employee and the query would return nothing.

### 5. `exists` and `not exists`

`exists` is a logical operator used with a nested query.

- `exists (query)` is true if the nested query returns **at least one row**.
- `not exists (query)` is true if the nested query returns **no rows**.

**Find the names and cities of the departments in which no employees earn a salary greater than 40.**

```sql
select D.DeptName, D.City
from DEPARTMENT D
where not exists (select *
                  from EMPLOYEE E
                  where D.DeptName = E.Dept and
                        E.Salary > 40)
```

**How to read it.** Take each department D in turn, and ask: "is there any employee of **this** department earning more than 40?" If there is none, keep D.

| Department | Employees earning more than 40 | Kept? |
|---|---|---|
| Administration | Mary Brown (45) | no |
| Production | Pauline Bradshaw (45) | no |
| Distribution | Jackson Neri (45) | no |
| Planning | Charles Brown (80), Laurence Chen (73) | no |
| Research | none (Alice Brown's salary is null) | **yes** |

Result: **Research, San Jose**.

Notice that the inner query mentions `D.DeptName`, which comes from the **outer** query. The inner query is therefore run again for each department.

## Part B: Data modification

Three statements change the contents of a table:

| Statement | Does |
|---|---|
| `insert` | adds rows |
| `delete` | removes rows |
| `update` | changes attribute values in existing rows |

All three are **set-oriented**: one statement can affect many rows. Their conditions can include nested queries that look at other tables.

### 6. `insert`

```
insert into TableName [ (AttributeList) ]
    < values (ListOfValues) | SelectSQL >
```

**All columns, in table order:**

```sql
insert into DEPARTMENT
values ('Payroll', 'Merrion Sq North', 'Dublin')
```

**Named columns, in any order:**

```sql
insert into DEPARTMENT(City, Address, DeptName)
values ('Dublin', 'Beech Hill Office Campus', 'H&R')
```

**Some columns only:**

```sql
insert into DEPARTMENT(DeptName, City)
values ('Finance', 'Dublin')
```

Address is not listed, so it gets its default value, or **null** if it has no default.

**From a query:** insert many rows at once by copying the result of a `select`.

```sql
insert into LONDON_DEPARTMENT
    (select DeptName, Address
     from DEPARTMENT
     where City = 'London')
```

The rules:
- If there is an attribute list, its order decides which value goes to which attribute.
- If there is no attribute list, all attributes are used in the order of the table definition.
- Any attribute left out gets its **default**, or **null**.

### 7. `delete`

```
delete from TableName [ where Condition ]
```

**Delete all employees whose salary is null:**

```sql
delete from EMPLOYEE
where Salary is null
```

**Delete all employees who work in a department based in London:**

```sql
delete from EMPLOYEE
where Dept = any (select DeptName
                  from DEPARTMENT
                  where City = 'London')
```

Three things to know:

- `delete` removes **all rows that satisfy the condition**.
- It may also delete rows in **other tables**, if a foreign key with the `cascade` policy refers to this table ([Lesson 6](06-sql-constraints-and-schema-updates.md#5-reaction-policies)).
- ⚠️ **With no `where`, it removes every row**, but the table itself stays.

```sql
delete from LONDON_DEPARTMENT      -- empties the table, keeps the schema
drop table LONDON_DEPARTMENT       -- removes the table itself
```

### 8. `update`

```
update TableName
set Attribute = < Expression | SelectSQL | null | default >
    { , Attribute = < Expression | SelectSQL | null | default > }
[ where Condition ]
```

**Increase the salary of all employees in the Production department by 10%:**

```sql
update EMPLOYEE
set Salary = Salary * 1.1
where Dept = 'Production'
```

Mairead's salary goes from 36 to 39.6, and Pauline's from 45 to 49.5. (In the practice database Salary is an `integer` column, so MySQL stores the rounded values 40 and 50.)

⚠️ With no `where`, **every** row is updated.

### ⚠️ The double-raise trap

Because the language is set-oriented, **the order of statements matters**.

```sql
update EMPLOYEE
set Salary = Salary * 1.1
where Salary < 50

update EMPLOYEE
set Salary = Salary * 1.1
where Salary >= 50
```

The intention is a 10% raise for everyone. But look at an employee earning 48:

1. The first statement raises 48 to **52.8**.
2. The second statement now sees a salary of 52.8, which is ≥ 50, and raises it **again** to 58.08.

That employee got two raises. Anyone whose salary crosses 50 because of the first statement is caught by the second.

## Part C: Other definitions of data

### 9. Classifying constraints

By **when** they are checked:

| Type | Checked |
|---|---|
| **Immediate** | straight after each modification |
| **Deferred** | only at the end of a series of operations (a transaction) |

By **what** they involve:

| Level | Kind | Example |
|---|---|---|
| A single tuple | attribute constraint | Salary must be between 20 and 150 |
| A single tuple | multiple-attribute constraint | Bonus must always be less than Salary |
| Several rows of one relation | functional dependency, cardinality constraint | There must be at least three employees in Administration |
| A single relation | aggregation constraint | The average salary in Planning must be greater than 30 |
| Several relations | referential integrity, and others | The sum of salaries of employees working in London must not exceed 900 |

### 10. The `check` clause

`check` expresses an **arbitrary constraint** in a table definition.

```
check ( Condition )
```

The condition can be anything that could appear in a `where` clause, **including nested queries**.

```sql
create table MODULES(
    Code varchar(10),
    Name varchar(20),
    Credits smallint,
    check (Code like 'COMP%'),
    check (Credits >= 5 and Credits <= 15)
)
```

| Constraint | Meaning |
|---|---|
| `check (Code like 'COMP%')` | module codes must start with COMP |
| `check (Credits >= 5 and Credits <= 15)` | the number of credits is between 5 and 15 |

An insert or update that would make a condition false is rejected.

### 11. Assertions

An **assertion** is a constraint defined **outside** any table definition. It is useful for general constraints that involve several tables.

```
create assertion AssertionName check ( Condition )
```

**Ensure that EMPLOYEE always has at least one row:**

```sql
create assertion AtLeastOneEmp
    check (1 <= (select count(*) from EMPLOYEE))
```

⚠️ **MySQL does not support assertions** (as of version 8.0.41). A trigger is a possible alternative.

### 12. Views

A **view** is a **virtual table**. Its contents are not stored separately. They are defined by a query over other tables, so a view always reflects the current data.

```
create view ViewName [ (AttributeList) ] as SelectSQL
    [ with [ local | cascaded ] check option ]
```

**A view of all employees in the Production department:**

```sql
create view PROD_EMPLOYEE as
    select * from EMPLOYEE
    where Dept = 'Production'
```

**A view built on another view:**

```sql
create view JUNIOR_PROD_EMPLOYEE (FirstName, Surname, Salary) as
    select FirstName, Surname, Salary from PROD_EMPLOYEE
    where Salary < 50
```

Once created, a view is queried just like a table:

```sql
select * from JUNIOR_PROD_EMPLOYEE
```

Rules:
- A view **can** be defined using other views.
- Views **cannot be mutually dependent**: view A cannot use view B if B also uses A.

> **Analogy:** a view is a saved question, not a saved answer. Every time you look at it, the question is asked again.

## Part D: SQL in programming languages

SQL statements can be **embedded** in a host language such as C or Java to build application programs.

- A **precompiler** handles the SQL statements.
- Embedded statements are marked with a special prefix, such as `$` or `EXEC SQL`.
- **Program variables** can be used as parameters in the SQL. They are preceded by a colon (`:`).
- A **cursor** lets a program access the rows of a table **one at a time**. This is needed because SQL works on whole sets of rows, while most programming languages handle one value at a time.
- A predefined variable **`sqlcode`** describes the status of the last SQL execution.

## What to remember

- `= any` is **`in`**. `<> all` is **`not in`**.
- `any`: at least one row matches. `all`: every row matches.
- Read nested queries **from the inside out**.
- `exists` is true if the nested query returns at least one row.
- "None" and "never" questions need `not in`, `except` or `not exists`.
- Watch for **nulls** in a nested query used with `all`.
- `insert`, `delete` and `update` are **set-oriented**. No `where` means **all rows**.
- `delete` empties a table. `drop table` removes it.
- `check` is a constraint inside a table. An **assertion** is one outside. MySQL has no assertions.
- A **view** is a virtual table defined by a query.

---

## Quiz

Use the EMPLOYEE and DEPARTMENT tables from Lesson 7.

**Q1.** What are the short forms of `= any` and `<> all`?

<details><summary>Show answer</summary>

`= any` is **`in`**. `<> all` is **`not in`**.
</details>

**Q2.** Write a nested query for the names of the employees who work in a department located in Toulouse.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname
from EMPLOYEE
where Dept in (select DeptName
               from DEPARTMENT
               where City = 'Toulouse')
```

Result: Mairead Green and Pauline Bradshaw (both in Production).
</details>

**Q3.** Rewrite the query from Q2 without a nested query.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName and D.City = 'Toulouse'
```
</details>

**Q4.** Write a query for the employees who earn more than the average salary.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname
from EMPLOYEE
where Salary > any (select avg(Salary)
                    from EMPLOYEE)
```

The average is 52, so the result is Charles Brown (80) and Laurence Chen (73).
</details>

**Q5.** What does this query return?

```sql
select FirstName, Surname
from EMPLOYEE
where Salary >= all (select Salary from EMPLOYEE)
```

<details><summary>Show answer</summary>

**Nothing.** The nested query includes a null salary. No salary is "greater than or equal to" null, so the condition cannot hold for **all** rows. Adding `where Salary is not null` to the nested query fixes it and returns Charles Brown.
</details>

**Q6.** Write a query using `exists` for the names of the departments that have at least one employee in office 10.

<details><summary>Show answer</summary>

```sql
select D.DeptName
from DEPARTMENT D
where exists (select *
              from EMPLOYEE E
              where E.Dept = D.DeptName and
                    E.Office = 10)
```

Result: Administration, Planning, Research.
</details>

**Q7.** Write a query for the names of the departments that have **no** employee earning less than 45.

<details><summary>Show answer</summary>

```sql
select D.DeptName
from DEPARTMENT D
where not exists (select *
                  from EMPLOYEE E
                  where E.Dept = D.DeptName and
                        E.Salary < 45)
```

Result: Distribution, Planning, Research. (Administration has Alice O'Neil on 40 and Production has Mairead Green on 36. Research has only a null salary, and `null < 45` is not true.)
</details>

**Q8.** What is the difference in effect between these two statements?

```sql
delete from EMPLOYEE
```
```sql
drop table EMPLOYEE
```

<details><summary>Show answer</summary>

`delete from EMPLOYEE` removes **all the rows** but keeps the table and its schema. `drop table EMPLOYEE` removes the **schema** of the table, so the table no longer exists.
</details>

**Q9.** Write a statement that moves every employee in office 16 to office 18.

<details><summary>Show answer</summary>

```sql
update EMPLOYEE
set Office = 18
where Office = 16
```
</details>

**Q10.** After `insert into DEPARTMENT(DeptName, City) values ('Finance', 'Dublin')`, what is the Address of the Finance department?

<details><summary>Show answer</summary>

**null** (or the default value, if one had been defined for Address). An attribute left out of the attribute list gets its default or null.
</details>

**Q11.** Write a `check` constraint that makes sure Salary is between 20 and 150.

<details><summary>Show answer</summary>

```sql
check (Salary >= 20 and Salary <= 150)
```
</details>

**Q12.** What is the difference between a `check` clause and an assertion?

<details><summary>Show answer</summary>

A `check` clause is written **inside a table definition**. An **assertion** is defined **outside** table definitions with `create assertion`, which makes it suitable for general constraints across relations. MySQL does not support assertions.
</details>

**Q13.** True or false: a view stores its own copy of the data.

<details><summary>Show answer</summary>

**False.** A view is a virtual table. Its contents depend on the contents of other tables in the database.
</details>

**Q14.** In embedded SQL, what is a cursor for?

<details><summary>Show answer</summary>

It allows a program to access the rows of a table **one at a time**.
</details>
