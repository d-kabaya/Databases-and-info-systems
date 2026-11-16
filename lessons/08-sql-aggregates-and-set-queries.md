# Lesson 8: SQL Part 4, Aggregates, Grouping and Set Queries

[← Previous: Simple queries](07-sql-simple-queries.md) · [Back to index](../README.md) · [Next: Nested queries and data modification →](09-sql-nested-queries-and-data-modification.md)

## The big idea

The queries in Lesson 7 look at **one row at a time**: "is this employee in Administration?". Some questions are about **a whole set of rows**: "how many employees are there?", "what is the highest salary?". **Aggregate operators** answer those. They take many rows and give back **one value**.

Aggregates are an important **extension** of SQL: relational algebra, as taught in this course, has nothing like them.

> **Analogy:** a teacher with a pile of exam scripts. A simple query pulls out individual scripts ("everyone who got an A"). An aggregate query produces a number about the pile ("the class average"). `group by` sorts the pile into smaller piles first ("the average for each tutorial group").

All examples use the EMPLOYEE and DEPARTMENT tables from [Lesson 7](07-sql-simple-queries.md#the-practice-database).

## 1. The five aggregate operators

| Operator | Returns |
|---|---|
| `count` | the number of rows or values |
| `sum` | the total |
| `max` | the largest value |
| `min` | the smallest value |
| `avg` | the average |

```sql
select max(Salary)
from EMPLOYEE
where Dept = 'Administration'
```

Result: **45**. The `where` picks the Administration rows (salaries 45 and 40), then `max` reduces them to one value.

## 2. `count`

```
count ( < * | [ distinct | all ] AttributeList > )
```

| Form | Counts | On EMPLOYEE |
|---|---|---|
| `count(*)` | the number of **rows** | **8** |
| `count(all Salary)` | the rows where Salary is **not null** | **7** |
| `count(Salary)` | the same. `all` is the default | **7** |
| `count(distinct Salary)` | the number of **different** values of Salary | **5** |

Why 5 distinct values? The salaries are 45, 36, 40, 45, 80, 73, 45 and null. The different values are 36, 40, 45, 73 and 80.

⚠️ **`count(*)` counts nulls. `count(Attribute)` does not.** This is the difference between 8 and 7 above.

## 3. `sum`, `avg`, `max`, `min`

```
< sum | max | min | avg > ( [ distinct | all ] AttributeExpr )
```

- `distinct` ignores duplicate values.
- `all` (the default) uses every value that is **not null**.

**Find the sum of the salaries of employees in the Administration department.**

```sql
select sum(Salary) as SumSalary
from EMPLOYEE
where Dept = 'Administration'
```

Result: **85** (45 + 40).

**Find the maximum salary among the employees who work in a department based in London.**

Aggregates work on joins too. Join first, then aggregate:

```sql
select max(Salary) as MaxLondonSalary
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName and
      D.City = 'London'
```

Result: **80**. The London departments are Administration and Planning. Their salaries are 45, 40, 80 and 73.

**Find the maximum and minimum salaries of all employees.**

```sql
select max(Salary) as MaxSal,
       min(Salary) as MinSal
from EMPLOYEE
```

Result: 80 and 36.

**Nulls are ignored.** `avg(Salary)` over all employees is 364 ÷ 7 = **52**, not 364 ÷ 8. Alice Brown's null salary is left out of both the total and the count.

## 4. ⚠️ The target-list rule

This query is **incorrect**:

```sql
select FirstName, Surname, max(Salary)    -- INCORRECT
from EMPLOYEE
```

**Why?** `max(Salary)` produces **one** value for the whole table. `FirstName` and `Surname` have **eight** values each. There is no sensible way to put one value and eight values in the same result.

**The rule:** aggregate functions and ordinary attributes cannot appear together in the same target list, **unless** the query has a `group by` clause.

(Finding *who* earns the highest salary needs a nested query. See [Lesson 9](09-sql-nested-queries-and-data-modification.md).)

## 5. `group by`

`group by` applies an aggregate to **each subset** of rows, not to the whole table.

**Find the sum of the salaries of all employees of the same department.**

```sql
select Dept, sum(Salary) as TotSal
from EMPLOYEE
group by Dept
```

| Dept | TotSal |
|---|---|
| Administration | 85 |
| Distribution | 45 |
| Planning | 153 |
| Production | 81 |
| Research | null |

### How to work out a `group by` query by hand

**Step 1.** Pretend there is no `group by`, and write out the columns involved:

| Dept | Salary |
|---|---|
| Administration | 45 |
| Production | 36 |
| Administration | 40 |
| Distribution | 45 |
| Planning | 80 |
| Planning | 73 |
| Production | 45 |
| Research | null |

**Step 2.** Divide the rows into subsets with the same value of the grouping attribute:

| Group | Salaries |
|---|---|
| Administration | 45, 40 |
| Distribution | 45 |
| Planning | 80, 73 |
| Production | 36, 45 |
| Research | null |

**Step 3.** Apply the aggregate to each subset separately. You get **one row per group**.

Research gives null, because its only salary is null and there is nothing to add up.

✅ Include the grouping attribute (`Dept`) in the target list even if the question doesn't ask for it. Without it, the result is a list of totals with no way of telling which department each belongs to.

## 6. ⚠️ The target-list rule for `group by`

**Every attribute in the target list must also be in the `group by` clause.** (Aggregates are exempt.)

The reason is the same as before: each group becomes one row, so every column must have a single value per group.

| Query | Verdict |
|---|---|
| `select Office from EMPLOYEE group by Dept` | ❌ Office is not a grouping attribute. One department can have several offices |
| `select D.City, count(*), D.DeptName … group by D.City` | ❌ DeptName is not a grouping attribute. One city can have several departments |
| `select D.City, count(*) … group by D.City` | ✅ |
| `select D.City, count(*), D.DeptName … group by D.City, D.DeptName` | ✅ |

The two correct queries in full:

```sql
select D.City, count(*)
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName
group by D.City
```

| City | count(*) |
|---|---|
| Brighton | 1 |
| London | 4 |
| San Jose | 1 |
| Toulouse | 2 |

```sql
select D.City, count(*), D.DeptName
from EMPLOYEE E, DEPARTMENT D
where E.Dept = D.DeptName
group by D.City, D.DeptName
```

| City | count(*) | DeptName |
|---|---|---|
| Brighton | 1 | Distribution |
| London | 2 | Administration |
| London | 2 | Planning |
| San Jose | 1 | Research |
| Toulouse | 2 | Production |

Grouping by two attributes makes one group for each **combination**, so London now splits in two.

**Note:** some DBMSs do not strictly enforce this rule. Follow it anyway. It is the SQL standard, and it is what is examined.

## 7. `having`: conditions on groups

`where` filters **rows**. `having` filters **groups**. It comes after `group by` and keeps only the groups that satisfy a **group predicate**.

**Find the names of the departments which spend more than 100 on salaries.**

```sql
select Dept
from EMPLOYEE
group by Dept
having sum(Salary) > 100
```

Result: **Planning** (153). The other totals are 85, 45, 81 and null.

### `where` or `having`?

| | `where` | `having` |
|---|---|---|
| Filters | individual **rows** | whole **groups** |
| Applied | **before** grouping | **after** grouping |
| Can use an aggregate? | ❌ no | ✅ yes |

✅ **Rule from the notes:** only predicates containing **aggregate operators** should appear in `having`. Everything else belongs in `where`.

**Find the names of the departments in which the average salary of employees working in office number 20 is higher than 25.**

```sql
select Dept
from EMPLOYEE
where Office = 20
group by Dept
having avg(Salary) > 25
```

There are two conditions, and each goes in a different place:

| Condition | About | Goes in |
|---|---|---|
| works in office 20 | a single employee | `where` |
| average salary higher than 25 | a group of employees | `having` |

Step by step:
1. `where Office = 20` keeps Mairead (Production, 36), Alice O'Neil (Administration, 40), Laurence (Planning, 73) and Pauline (Production, 45).
2. `group by Dept` gives Administration {40}, Planning {73}, Production {36, 45}.
3. `having avg(Salary) > 25` keeps all three: the averages are 40, 73 and 40.5.

Result: Administration, Planning, Production.

## 8. The full shape of a query

```
select TargetList
from TableList
[ where Condition ]
[ group by GroupingAttributeList ]
[ having AggregateCondition ]
[ order by OrderingAttributeList ]
```

**The clauses must be written in this order.**

The order in which they are **evaluated** is different. (The notes describe this step by step for `group by`. The diagram is a summary, not a slide.)

```mermaid
flowchart LR
    A[from] --> B[where] --> C[group by] --> D[having] --> E[select] --> F[order by]
```

That explains two rules at once: `where` cannot use an aggregate (the groups don't exist yet), and `having` can (they do).

## 9. Set queries

SQL has set operators like those of relational algebra. They combine the results of two `select` statements.

```
SelectSQL { < union | intersect | except > [ all ] SelectSQL }
```

| SQL | Relational algebra | Returns |
|---|---|---|
| `union` | ∪ | rows in either result |
| `intersect` | ∩ | rows in both results |
| `except` | − | rows in the first result but not the second |

⚠️ **Set operators remove duplicates by default.** This is the opposite of the rest of SQL, where you must ask for `distinct`. Add `all` to **keep** duplicates.

**Find the cities that have either a department or an employee residing in them.**

```sql
select City
from DEPARTMENT
union
select City
from EMPLOYEE
```

Result: **9 rows**. Brighton, Cork, Dover, Dublin, Limerick, London, San Jose, Toulouse, Worthing. London, Toulouse and Brighton appear in both tables but are listed once.

With `union all` the result has **13 rows**: all 5 department cities followed by all 8 employee cities, duplicates included.

**Find the cities that have a department and also have an employee residing in them.**

```sql
select City
from DEPARTMENT
intersect
select City
from EMPLOYEE
```

Result: Brighton, London, Toulouse.

An alternative without `intersect`, using a join:

```sql
select distinct E.City as Name
from EMPLOYEE E, DEPARTMENT D
where E.City = D.City
```

Here `distinct` is needed, because this is an ordinary query and keeps duplicates.

**Find the cities that have a department but have no employee residing in them.**

```sql
select City
from DEPARTMENT
except
select City
from EMPLOYEE
```

Result: **San Jose**.

`except` is the same as difference in relational algebra. In some DBMSs it is called `minus`. As with difference, **the order matters**: swapping the two halves gives the cities with an employee but no department (Cork, Dover, Dublin, Limerick, Worthing).

## What to remember

- Five aggregates: `count`, `sum`, `max`, `min`, `avg`.
- `count(*)` counts rows. `count(A)` skips nulls. `count(distinct A)` counts different values.
- Aggregates **ignore nulls**.
- No mixing of aggregates and plain attributes in the target list **without `group by`**.
- With `group by`, every plain attribute in the target list must be a **grouping attribute**.
- `where` filters rows **before** grouping. `having` filters groups **after**, and is where aggregate conditions go.
- Write: `select, from, where, group by, having, order by`.
- `union`, `intersect`, `except` **remove duplicates** unless you add `all`.

---

## Quiz

Use the EMPLOYEE and DEPARTMENT tables from Lesson 7.

**Q1.** What do `count(*)`, `count(Salary)` and `count(distinct Salary)` return on EMPLOYEE?

<details><summary>Show answer</summary>

**8**, **7** and **5**. There are 8 rows, 7 of them have a non-null salary, and there are 5 different salary values (36, 40, 45, 73, 80).
</details>

**Q2.** What does `select count(distinct Surname) from EMPLOYEE` return?

<details><summary>Show answer</summary>

**6**: Brown, Green, O'Neil, Neri, Chen, Bradshaw.
</details>

**Q3.** Why is this query incorrect?

```sql
select Surname, min(Salary)
from EMPLOYEE
```

<details><summary>Show answer</summary>

It mixes an ordinary attribute (`Surname`) and an aggregate (`min(Salary)`) in the target list **without a `group by`**. The aggregate produces one value, while Surname has one value per row.
</details>

**Q4.** Write a query for the number of employees in each department.

<details><summary>Show answer</summary>

```sql
select Dept, count(*)
from EMPLOYEE
group by Dept
```

Result: Administration 2, Distribution 1, Planning 2, Production 2, Research 1.
</details>

**Q5.** Is this query correct? If not, fix it.

```sql
select Dept, Office, avg(Salary)
from EMPLOYEE
group by Dept
```

<details><summary>Show answer</summary>

**Incorrect.** `Office` is in the target list but is not a grouping attribute. Either remove it, or group by both:

```sql
select Dept, Office, avg(Salary)
from EMPLOYEE
group by Dept, Office
```
</details>

**Q6.** Write a query for the offices that have at least two employees, with the number of employees in each.

<details><summary>Show answer</summary>

```sql
select Office, count(*)
from EMPLOYEE
group by Office
having count(*) >= 2
```

Result: office 10 has 3 and office 20 has 4. Office 16 has only one employee, so it is removed by `having`.
</details>

**Q7.** A student writes this. What is wrong, and how is it fixed?

```sql
select Dept
from EMPLOYEE
where sum(Salary) > 100
group by Dept
```

<details><summary>Show answer</summary>

`where` is applied to individual rows **before** grouping, so it cannot contain an aggregate. A condition on a group belongs in `having`:

```sql
select Dept
from EMPLOYEE
group by Dept
having sum(Salary) > 100
```
</details>

**Q8.** Write a query for the highest salary in each department, listed in alphabetical order of department.

<details><summary>Show answer</summary>

```sql
select Dept, max(Salary)
from EMPLOYEE
group by Dept
order by Dept
```

Result: Administration 45, Distribution 45, Planning 80, Production 45, Research null.
</details>

**Q9.** What is `avg(Salary)` for the Production department, and for the whole table?

<details><summary>Show answer</summary>

Production: (36 + 45) ÷ 2 = **40.5**. Whole table: 364 ÷ 7 = **52**. The null salary is ignored, so the total is divided by 7, not 8.
</details>

**Q10.** In what order must these clauses be written: `having`, `where`, `order by`, `group by`?

<details><summary>Show answer</summary>

**`where`, `group by`, `having`, `order by`** (after `select` and `from`).
</details>

**Q11.** How many rows do these return?

```sql
select Dept from EMPLOYEE union select DeptName from DEPARTMENT
```
```sql
select Dept from EMPLOYEE union all select DeptName from DEPARTMENT
```

<details><summary>Show answer</summary>

**5** and **13**. `union` removes duplicates, leaving the five department names. `union all` keeps everything: 8 rows from EMPLOYEE plus 5 from DEPARTMENT.
</details>

**Q12.** Write a set query for the cities where an employee lives but no department is located.

<details><summary>Show answer</summary>

```sql
select City
from EMPLOYEE
except
select City
from DEPARTMENT
```

Result: Cork, Dover, Dublin, Limerick, Worthing.
</details>

**Q13.** True or false: `select City from DEPARTMENT` and `select City from DEPARTMENT union select City from DEPARTMENT` return the same number of rows.

<details><summary>Show answer</summary>

**False.** The first returns 5 rows, with London twice. The second returns 4, because `union` eliminates duplicates.
</details>
