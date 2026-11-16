# Lesson 7: SQL Part 3, Simple Queries

[← Previous: Constraints and schema updates](06-sql-constraints-and-schema-updates.md) · [Back to index](../README.md) · [Next: Aggregates and set queries →](08-sql-aggregates-and-set-queries.md)

## The big idea

A query asks the database a question. Every SQL query is a `select` statement with three main parts:

```sql
select  what columns do I want?        -- the target list
from    which tables are they in?      -- the from clause
where   which rows do I want?          -- the where clause
```

SQL queries are **declarative**: you describe the **result**, not the steps. The DBMS's **query optimiser** works out how to get it. So when you write SQL, aim for **readability**, not efficiency.

> **Analogy:** ordering in a restaurant. You say "the soup, no croutons". You don't walk into the kitchen and explain how to make it.

## The practice database

Every query in lessons 7, 8 and 9 uses these two tables. Build them with [`practice/company.sql`](../practice/company.sql) and run the queries yourself.

**EMPLOYEE** (City is where the employee **lives**)

| FirstName | Surname | Dept | Office | Salary | City |
|---|---|---|---|---|---|
| Mary | Brown | Administration | 10 | 45 | London |
| Mairead | Green | Production | 20 | 36 | Toulouse |
| Alice | O'Neil | Administration | 20 | 40 | Cork |
| Jackson | Neri | Distribution | 16 | 45 | Dover |
| Charles | Brown | Planning | 10 | 80 | Limerick |
| Laurence | Chen | Planning | 20 | 73 | Worthing |
| Pauline | Bradshaw | Production | 20 | 45 | Brighton |
| Alice | Brown | Research | 10 | null | Dublin |

**DEPARTMENT** (City is where the department is **located**)

| DeptName | Address | City |
|---|---|---|
| Administration | Bond Street | London |
| Production | Rue Victor Hugo | Toulouse |
| Distribution | Pond Road | Brighton |
| Planning | Bond Street | London |
| Research | Sunset Street | San Jose |

- PrimaryKey(EMPLOYEE) = {FirstName, Surname}
- PrimaryKey(DEPARTMENT) = {DeptName}
- Dept is a foreign key of EMPLOYEE that references DeptName in DEPARTMENT.

## 1. The `select` statement

```
select AttrExpr [ [as] Alias ] { , AttrExpr [ [as] Alias ] }
from Table [ [as] Alias ] { , Table [ [as] Alias ] }
[ where Condition ]
```

### How a query is evaluated

Think of it as three steps, in this order:

1. **`from`**: take the **Cartesian product** of the tables listed.
2. **`where`**: **select** only the rows that satisfy the condition.
3. **`select`**: for each remaining row, evaluate the expressions in the target list (**projection**).

So this SQL:

```sql
select T1.A, T2.B
from Table1 T1, Table2 T2
where Condition
```

means this relational algebra:

Π<sub>T1.A, T2.B</sub>(σ<sub>Condition</sub>(Table1 × Table2))

⚠️ You **write** `select` first, but it is **evaluated** last.

## 2. The target list

### Named columns

**Q1: Find the salaries of employees whose surname is Brown.**

```sql
select Salary
from EMPLOYEE
where Surname = 'Brown'
```

| Salary |
|---|
| 45 |
| 80 |
| null |

### Renaming a column with `as`

```sql
select E.Salary as Remuneration
from EMPLOYEE E
where Surname = 'Brown'
```

Same rows, but the column heading is `Remuneration`. The word `as` is optional.

### All columns with `*`

**Q2: Find all the information about employees whose surname is Brown.**

```sql
select *
from EMPLOYEE
where Surname = 'Brown'
```

The asterisk stands for **all attributes** of the tables in the `from` clause.

### Expressions

The target list can contain calculations.

**Q3: Find the monthly salary of the employees whose surname is O'Neil.**

```sql
select Salary / 12 as MonthlySalary
from EMPLOYEE
where Surname = 'O''Neil'
```

Result: 3.33 (40 ÷ 12).

⚠️ **An apostrophe inside a string is written twice**: `'O''Neil'`. A single apostrophe would end the string early.

## 3. The `from` clause: joining tables

To use two tables, list both in `from` and give the **join condition** in `where`.

**Q4: Find the names of the employees and the cities in which they work.**

The city an employee **works** in is the city of their department, which is in DEPARTMENT.

```sql
select EMPLOYEE.FirstName, EMPLOYEE.Surname, DEPARTMENT.City
from EMPLOYEE, DEPARTMENT
where EMPLOYEE.Dept = DEPARTMENT.DeptName
```

| FirstName | Surname | City |
|---|---|---|
| Mary | Brown | London |
| Mairead | Green | Toulouse |
| Alice | O'Neil | London |
| Jackson | Neri | Brighton |
| Charles | Brown | London |
| Laurence | Chen | London |
| Pauline | Bradshaw | Toulouse |
| Alice | Brown | San Jose |

**Why write `DEPARTMENT.City`?** Both tables have a column called City. The table name in front says which one you mean. Without it the query is ambiguous.

⚠️ **Never forget the join condition.** Without the `where` line you get the full Cartesian product: 8 × 5 = **40 rows**, pairing every employee with every department.

### Table aliases

Give each table a short name to make the query easier to read:

```sql
select E.FirstName, E.Surname, D.City
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName
```

### The explicit join syntax

SQL has another way to write joins, inside the `from` clause:

```
from Table [ JoinType ] join Table on JoinConditions
```

where *JoinType* is `inner`, `left [outer]`, `right [outer]` or `full [outer]`, optionally preceded by `natural`.

✅ **This module only uses the simpler syntax above** (tables separated by commas, condition in `where`). You need to recognise the explicit form but not write it.

## 4. The `where` clause

### `and`, `or`

**Q5: Find the employees who work in office number 20 of the Administration department.**

```sql
select FirstName, Surname
from EMPLOYEE
where Office = 20 and Dept = 'Administration'
```

Result: Alice O'Neil. **Both** conditions must hold.

**Q6: Find the employees who work in either the Administration or the Production department.**

```sql
select FirstName, Surname
from EMPLOYEE
where Dept = 'Administration' or Dept = 'Production'
```

Result: Mary Brown, Mairead Green, Alice O'Neil, Pauline Bradshaw. **At least one** condition must hold.

### Brackets

**Q7: Find the first names of the employees with surname Brown who work in the Administration department or the Production department.**

```sql
select FirstName
from EMPLOYEE
where Surname = 'Brown' and
      (Dept = 'Administration' or Dept = 'Production')
```

Result: Mary.

⚠️ **The brackets are essential.** `and` is applied before `or`. Without brackets the condition is read as `(Surname='Brown' and Dept='Administration') or Dept='Production'`, which also returns Mairead and Pauline: everyone in Production, whatever their surname.

### Pattern matching with `like`

| Symbol | Matches |
|---|---|
| `%` | any string of characters, **including none** |
| `_` | exactly **one** character |

**Q8: Find the employees whose first names start with 'Ma' and contain a letter 'r'.**

```sql
select *
from EMPLOYEE
where FirstName like 'Ma%r%'
```

Result: **Mary** (Ma, nothing, r, y) and **Mairead** (Ma, i, r, ead).

More examples:

| Pattern | Matches | Does not match |
|---|---|---|
| `'B%'` | Brown, Bradshaw | Chen |
| `'%n'` | Brown, Green, Chen | Neri |
| `'_e%'` | Neri | Green |
| `'____'` (four underscores) | Chen, Neri | Brown |

## 5. Null values

A null can mean a value is not applicable, is applicable but unknown, or that we don't even know which.

To test for null, use the special predicate `is null` or `is not null`:

```sql
select *
from EMPLOYEE
where Salary is not null
```

This returns everyone except Alice Brown.

⚠️ **`Salary = null` does not work.** Any comparison with null is not true, so that condition never selects a row. Always use `is null`.

### Why comparisons with null are odd

What is the result of `Salary > 40` when Salary is null? There are two approaches:

| Standard | Logic | A comparison with null returns |
|---|---|---|
| SQL-89 | two-valued | **false** |
| SQL-2 | three-valued | **unknown** |

Either way, the row is **not** selected. That is why Q1 can return a null salary (the condition there was on Surname), but a query with `where Salary > 40` will never return Alice Brown, and neither will one with `where Salary <= 40`.

## 6. Duplicates and `distinct`

In relational algebra, results never contain duplicates. **In SQL they can.**

```sql
select City
from DEPARTMENT
```

returns five rows: London, Toulouse, Brighton, **London**, San Jose.

```sql
select distinct City
from DEPARTMENT
```

returns four: London, Toulouse, Brighton, San Jose.

## 7. Table variables: joining a table to itself

**Q9: Find the first names and surnames of the employees who share an office with an employee of the Administration department and earn a higher salary than that Administration employee.**

You need to compare **two different employees**, but they are both rows of the same table. Use the table twice, with two aliases:

```sql
select E.FirstName, E.Surname
from EMPLOYEE E, EMPLOYEE AD
where AD.Dept = 'Administration'
  and E.Office = AD.Office
  and E.Salary > AD.Salary
```

Read `AD` as "the Administration employee" and `E` as "the employee we're looking for". Each line of the `where` does one job:

| Line | Meaning |
|---|---|
| `AD.Dept = 'Administration'` | AD must be in Administration |
| `E.Office = AD.Office` | E shares AD's office |
| `E.Salary > AD.Salary` | E earns more than AD |

**Working it out.** The Administration employees are Mary Brown (office 10, salary 45) and Alice O'Neil (office 20, salary 40).

- Office 10, earning more than 45: **Charles Brown** (80). Alice Brown has a null salary, so the comparison is not true.
- Office 20, earning more than 40: **Laurence Chen** (73) and **Pauline Bradshaw** (45). Mairead Green (36) does not.

Result: Charles Brown, Laurence Chen, Pauline Bradshaw.

Table aliases used like this are called **table variables**. They correspond to the **renaming operator ρ** of relational algebra: E and AD are two instances of EMPLOYEE.

## 8. Ordering with `order by`

By default the rows of a result are in **no particular order**. Add `order by` at the **end** of the query to sort them.

```
order by OrderingAttribute [ asc | desc ] { , OrderingAttribute [ asc | desc ] }
```

- `asc` is ascending (A to Z, small to large). It is the default.
- `desc` is descending.

**Q10: Return the EMPLOYEE table in ascending order of Surname and FirstName.**

```sql
select *
from EMPLOYEE
order by Surname asc, FirstName asc
```

| FirstName | Surname |
|---|---|
| Pauline | Bradshaw |
| Alice | Brown |
| Charles | Brown |
| Mary | Brown |
| Laurence | Chen |
| Mairead | Green |
| Jackson | Neri |
| Alice | O'Neil |

(The other columns are returned too. Only these two are shown.)

The rows are sorted by Surname first. The **second** attribute is only used to break ties, which is why the three Browns come out as Alice, Charles, Mary.

## What to remember

- `select` (target list), `from`, `where`. Evaluated as: **product, then selection, then projection**.
- Two tables need a **join condition** in `where`, or you get every combination.
- Use `Table.Column` when two tables share a column name. Aliases keep it short.
- `and` binds tighter than `or`. **Use brackets.**
- `like`: `%` is any string, `_` is one character.
- Test nulls with `is null`, never `= null`.
- SQL keeps duplicates unless you write `distinct`.
- Use one table twice with two aliases to compare rows of the same table.
- `order by` goes last. Default is `asc`.
- A quote inside a string is doubled: `'O''Neil'`.

---

## Quiz

Use the EMPLOYEE and DEPARTMENT tables above.

**Q1.** In what order are the three clauses `select`, `from` and `where` evaluated?

<details><summary>Show answer</summary>

**`from`** (Cartesian product of the tables), then **`where`** (selection of rows), then **`select`** (projection onto the target list).
</details>

**Q2.** Write a query for the first names and surnames of the employees who live in London.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname
from EMPLOYEE
where City = 'London'
```

Result: Mary Brown.
</details>

**Q3.** How many rows does this return, and why?

```sql
select *
from EMPLOYEE, DEPARTMENT
```

<details><summary>Show answer</summary>

**40.** With no join condition, the result is the full Cartesian product: 8 employees × 5 departments.
</details>

**Q4.** Write a query for the first name, surname and department address of every employee.

<details><summary>Show answer</summary>

```sql
select E.FirstName, E.Surname, D.Address
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName
```
</details>

**Q5.** What does this query return?

```sql
select FirstName, Surname
from EMPLOYEE
where Dept = 'Planning' or Dept = 'Research' and Office = 20
```

<details><summary>Show answer</summary>

**Charles Brown and Laurence Chen.** `and` is applied first, so the condition means `Dept='Planning' or (Dept='Research' and Office=20)`. Both Planning employees qualify. Alice Brown is in Research but in office 10, so she does not.
</details>

**Q6.** Which surnames match `like '%r%n'`?

<details><summary>Show answer</summary>

The surname must contain an `r` and end in `n`: **Brown** and **Green**. Chen ends in n but has no r. Bradshaw has an r but does not end in n.
</details>

**Q7.** Which first names match `like '_a%'`?

<details><summary>Show answer</summary>

The second letter must be `a`: **Mary, Mairead, Jackson, Laurence, Pauline**. Alice and Charles do not match.
</details>

**Q8.** Write a query that finds the employees whose salary is not recorded.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname
from EMPLOYEE
where Salary is null
```

Result: Alice Brown. Writing `Salary = null` would return nothing.
</details>

**Q9.** How many rows are returned by `select Dept from EMPLOYEE` and by `select distinct Dept from EMPLOYEE`?

<details><summary>Show answer</summary>

**8** and **5**. Without `distinct`, SQL keeps one row per employee. With it, each of the five departments appears once.
</details>

**Q10.** Write a query for the names of the employees who live in the same city as their department is located.

<details><summary>Show answer</summary>

```sql
select E.FirstName, E.Surname
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName
  and E.City = D.City
```

Result: Mary Brown (London) and Mairead Green (Toulouse).
</details>

**Q11.** Write a query for pairs of different employees who work in the same office and the same department. Show both first names.

<details><summary>Show answer</summary>

```sql
select E1.FirstName, E2.FirstName
from EMPLOYEE E1, EMPLOYEE E2
where E1.Dept = E2.Dept
  and E1.Office = E2.Office
  and E1.FirstName < E2.FirstName
```

Result: Mairead and Pauline (Production, office 20).

The last line does two jobs: it stops an employee being paired with themselves, and it stops each pair appearing twice. It works here because the two people have different first names. In general you would compare the whole key.
</details>

**Q12.** Write a query that lists all employees' first names, surnames and salaries with the highest salary first.

<details><summary>Show answer</summary>

```sql
select FirstName, Surname, Salary
from EMPLOYEE
order by Salary desc
```

Charles Brown (80) comes first, then Laurence Chen (73).
</details>

**Q13.** Which relational algebra operator do table variables (aliases such as `E` and `AD`) correspond to?

<details><summary>Show answer</summary>

The **renaming operator ρ**.
</details>
