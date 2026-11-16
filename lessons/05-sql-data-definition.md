# Lesson 5: SQL Part 1, Defining Schemas, Tables and Domains

[← Previous: Joins](04-relational-algebra-joins.md) · [Back to index](../README.md) · [Next: Constraints and schema updates →](06-sql-constraints-and-schema-updates.md)

## The big idea

**SQL** (Structured Query Language) is the standard language for relational databases. It does two jobs:

- **DDL** (data definition language): build the structure. `create schema`, `create table`.
- **DML** (data manipulation language): work with the data. `insert`, `select`, `update`, `delete`.

This lesson is about the DDL: creating a schema, creating tables, and choosing a **domain** (data type) for each column.

> **Analogy:** building a filing cabinet before filing anything. `create schema` is buying the cabinet. `create table` is labelling a drawer and deciding what each form inside must look like. The domain of a column is the rule for one box on the form: "numbers only", or "up to 20 letters".

## 1. What SQL is

- Based on **relational algebra**.
- Primarily **declarative** (non-procedural): you state the properties of the data you want, not how to get it.
- Contains both **DDL and DML**.
- Can be used interactively (a GUI or a prompt) or embedded in programs.
- **Free-form**: no special indentation is required.

**A little history:** Codd's relational model led to two research systems. System R at IBM produced the language SEQUEL, which became SQL. Ingres at Berkeley produced a rival language, QUEL. SQL won.

## 2. Reading the syntax notation

The lecture notes describe SQL syntax using a small set of symbols. You need to read these to understand any syntax definition, and exam questions use them.

| Symbol | Meaning | Example |
|---|---|---|
| `[ ]` | **optional** | `[ DefaultValue ]` may be left out |
| `{ }` | may appear **zero or more times** | `{ , AttributeName Domain }` means "and as many more as you like" |
| `< >` | groups terms together | |
| `\|` | **exactly one** of the alternatives must appear | `< date \| time >` means one or the other |
| `( )` | real SQL brackets that you **type** | |
| *italics* | a term you replace with your own | *TableName* |

⚠️ `[ ]`, `{ }`, `< >` and `|` are **not typed**. They only describe the grammar. Round brackets `( )` **are** typed.

## 3. Creating a schema

A database **schema** is a collection of objects: domains, tables, indexes, assertions, views and privileges. It has a **name** and an **owner** (the authorization).

```
create schema [ SchemaName ] [ [ authorization ] Authorization ]
    { SchemaElementDefinition }
```

```sql
create schema mydb
```

**Beyond the notes:** in MySQL, `create schema` and `create database` mean the same thing. After creating one, run `use mydb;` so that the tables you create go inside it.

## 4. Creating a table

A SQL table consists of an **ordered set of attributes** and a (possibly empty) set of **constraints**. The statement `create table` defines the relation schema and creates an **empty instance**: the table exists but has no rows.

```
create table TableName
(
    AttributeName Domain [ DefaultValue ] [ Constraints ]
    { , AttributeName Domain [ DefaultValue ] [ Constraints ] }
    [ OtherConstraints ]
)
```

Each column is: a **name**, a **domain**, an optional **default**, and optional **constraints**.

```sql
create table STUDENTS(
    StudentID integer primary key,
    Surname varchar(20) not null,
    FirstName varchar(20) not null,
    BirthDate date
)
```

Reading this line by line:

| Line | Name | Domain | Constraint |
|---|---|---|---|
| `StudentID integer primary key` | StudentID | integer | it is the primary key |
| `Surname varchar(20) not null` | Surname | text up to 20 characters | must have a value |
| `FirstName varchar(20) not null` | FirstName | text up to 20 characters | must have a value |
| `BirthDate date` | BirthDate | a date | none, so null is allowed |

A table whose key has two columns puts the key on its own line at the end:

```sql
create table EXAMS(
    StudentID integer,
    Grade varchar(2),
    CourseID smallint,
    primary key (StudentID, CourseID)
)
```

Constraints are the subject of [Lesson 6](06-sql-constraints-and-schema-updates.md).

## 5. Domains

A **domain** specifies the data type of an attribute. There are two categories: **elementary** domains, predefined by the SQL standard, and **user-defined** domains.

### Character

Single characters or strings.

```
character [ varying ] [ ( Length ) ] [ character set CharSetName ]
```

| Domain | Short form | Meaning |
|---|---|---|
| `character` | `char` | a single character |
| `character(10)` | `char(10)` | a string of **exactly** 10 characters |
| `character varying(20)` | `varchar(20)` | a string of **up to** 20 characters |
| `varchar(20) character set Greek` | | uses a character set other than the default |

✅ `char(n)` is **fixed** length. `varchar(n)` is **variable** length with a maximum of n.

### Bit

Single boolean values or strings of them.

```
bit [ varying ] [ ( Length ) ]
```

Examples: `bit`, `bit(8)`, `bit varying(100)`.

### Exact numeric

Exact values, either whole numbers or numbers with a fractional part.

```
numeric [ ( Precision [ , Scale ] ) ]
decimal [ ( Precision [ , Scale ] ) ]
integer
smallint
```

- **Precision** = the total number of significant digits, counting both sides of the decimal point.
- **Scale** = how many of those digits come **after** the decimal point.

**Example:** `numeric(5,3)` has 5 digits in total, 3 of them after the point. That leaves 2 before the point, so it holds values from **−99.999 to +99.999**.

**How to work out a range:** digits before the point = precision − scale. `numeric(6,2)` has 6 − 2 = 4 digits before the point, so its range is −9999.99 to +9999.99.

### Approximate numeric

Real numbers stored in floating-point form, so they are approximate.

```
float [ ( Precision ) ]
double precision
real
```

**Beyond the notes:** use an exact type for money, where every cent must be right. An approximate type suits measurements where tiny rounding errors don't matter.

### Temporal instants

```
date
time [ ( Precision ) ] [ with time zone ]
timestamp [ ( Precision ) ] [ with time zone ]
```

A `date` is a calendar date, a `time` is a time of day, and a `timestamp` is both together.

### Temporal intervals

```
interval FirstUnitOfTime [ to LastUnitOfTime ]
```

The units of time are split into **two groups**, and one interval cannot cross between them:

| Group 1 | Group 2 |
|---|---|
| year, month | day, hour, minute, second |

| Example | Valid? |
|---|---|
| `interval year to month` | ✅ both in group 1 |
| `interval minute to second` | ✅ both in group 2 |
| `interval month to day` | ❌ crosses the two groups |

**Why two groups? (beyond the notes)** A month is not a fixed number of days (28 to 31), so months cannot be converted exactly into days.

### User-defined domains

These work like defining your own variable type in a programming language. A domain has a **name**, an **elementary domain**, a **default value** and a set of **constraints**.

```
create domain DomainName as ElementaryDomain [ DefaultValue ] [ Constraints ]
```

```sql
create domain smallintNULL as smallint default null
```

⚠️ **MySQL does not support user-defined domains.**

## 6. Default values

A **default value** is the value an attribute takes when a row is inserted **without** a value for it.

```
default < GenericValue | user | null >
```

- *GenericValue*: a value compatible with the domain (a constant or an expression).
- `user`: the login name of the user who issues the command.
- `null`: the null value.

```sql
create table EXAMS(
    StudentID integer,
    Grade varchar(2) default 'A+',
    CourseID smallint,
    primary key (StudentID, CourseID)
)
```

If you insert an exam and give no grade, the grade is recorded as `A+`.

**If there is no default and no value is given,** the attribute is set to **null**.

## 7. A first look at inserting rows

```
insert into R(A1, …, An) values (v1, …, vn)
```

This creates a new tuple with value v<sub>i</sub> for attribute A<sub>i</sub>. Any attribute you leave out gets its default value.

**Form 1: no attribute list.** Give a value for every column, in the order the table was defined:

```sql
insert into STUDENTS
values (276545, 'Smith', 'Mary', '1990-11-25')
```

**Form 2: with an attribute list.** Give values in the order of **your list**:

```sql
insert into STUDENTS(FirstName, Surname, StudentID)
values ('Anna', 'Black', 485745)
```

Here BirthDate is not listed. It has no default, so it becomes **null**.

Notes:
- Text and dates go in **single quotes**. Numbers do not.
- Dates are written `'YYYY-MM-DD'`.

`insert` is covered in full in [Lesson 9](09-sql-nested-queries-and-data-modification.md).

## Try it

Run [`practice/university.sql`](../practice/university.sql) in MySQL Workbench. It creates STUDENTS, COURSES and EXAMS with the rows from the lectures. Then try:

```sql
insert into STUDENTS(FirstName, Surname, StudentID)
values ('Ciaran', 'Kelly', 111111);

select * from STUDENTS;
```

The new row shows `NULL` for BirthDate.

## What to remember

- SQL is **declarative** and contains both **DDL** and **DML**.
- Notation: `[ ]` optional, `{ }` zero or more, `|` choose one. Only `( )` is typed.
- `create table` makes an **empty** table. Each column is name, domain, optional default, optional constraints.
- `char(n)` fixed, `varchar(n)` variable.
- `numeric(p,s)`: p digits in total, s after the point.
- `integer`, `smallint`, `numeric`, `decimal` are **exact**. `float`, `real`, `double precision` are **approximate**.
- Intervals cannot mix {year, month} with {day, hour, minute, second}.
- A missing value becomes the **default**, or **null** if there is no default.
- MySQL has no user-defined domains.

---

## Quiz

**Q1.** In the syntax notation, what do `[ ]`, `{ }` and `|` mean?

<details><summary>Show answer</summary>

`[ ]` encloses an **optional** term. `{ }` encloses a term that may **not appear or may be repeated** any number of times. `|` separates alternatives, of which **one must appear**.
</details>

**Q2.** What is the difference between `char(10)` and `varchar(10)`?

<details><summary>Show answer</summary>

`char(10)` is a string of **exactly** 10 characters (fixed length). `varchar(10)` is a string of **up to** 10 characters (variable length).
</details>

**Q3.** What range of values can `numeric(5,3)` hold?

<details><summary>Show answer</summary>

**−99.999 to +99.999.** Five significant digits in total, three of them to the right of the decimal point, leaving two to the left.
</details>

**Q4.** What range can `numeric(4,1)` hold?

<details><summary>Show answer</summary>

4 digits in total, 1 after the point, so 3 before it: **−999.9 to +999.9**.
</details>

**Q5.** Which of these are exact numeric domains: `integer`, `real`, `decimal`, `float`, `smallint`?

<details><summary>Show answer</summary>

`integer`, `decimal` and `smallint` are **exact**. `real` and `float` are **approximate**.
</details>

**Q6.** Which of these intervals is invalid, and why? (a) `interval year to month` (b) `interval day to hour` (c) `interval month to day`

<details><summary>Show answer</summary>

**(c)** is invalid. Units of time are divided into two groups, {year, month} and {day, hour, minute, second}. An interval cannot span both groups.
</details>

**Q7.** After `create table STUDENTS(...)` runs successfully, how many rows does STUDENTS contain?

<details><summary>Show answer</summary>

**None.** `create table` defines the relation schema and creates an **empty instance**.
</details>

**Q8.** Given the STUDENTS table in section 4, what is stored in BirthDate after this statement?

```sql
insert into STUDENTS(StudentID, Surname, FirstName)
values (123456, 'Byrne', 'Sean')
```

<details><summary>Show answer</summary>

**null.** BirthDate is not in the attribute list and has no default value, so it is set to null. (That is allowed, because BirthDate has no `not null` constraint.)
</details>

**Q9.** With `Grade varchar(2) default 'A+'`, what grade is stored by `insert into EXAMS(StudentID, CourseID) values (276545, 3)`?

<details><summary>Show answer</summary>

**A+**, the default value, because no grade was specified.
</details>

**Q10.** What does the default value `user` mean?

<details><summary>Show answer</summary>

It is the **login name of the user who issues the command**.
</details>

**Q11.** Write a `create table` statement for COURSES with CourseID (a small whole number, the primary key), Title (up to 20 characters) and Tutor (up to 20 characters).

<details><summary>Show answer</summary>

```sql
create table COURSES(
    CourseID smallint primary key,
    Title varchar(20),
    Tutor varchar(20)
)
```
</details>

**Q12.** True or false: `create domain` works in MySQL.

<details><summary>Show answer</summary>

**False.** MySQL does not support user-defined domains.
</details>
