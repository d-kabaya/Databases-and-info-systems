# Databases and Information Systems

Plain-language lessons for the Databases and Information Systems module, built from the lecture notes (L01 to L15), the relational algebra exercise solutions and the MySQL lab solutions. Every lesson explains the ideas simply, works through examples step by step, and ends with a quiz.

## How to use this

1. Work through the lessons in order. Each one builds on the one before.
2. Read "The big idea" first, then the numbered sections.
3. At the end of each lesson, try the **quiz** before opening the answers. Click "Show answer" to check yourself.
4. For the SQL lessons, build the practice databases and **run the queries yourself**. Typing a query teaches more than reading one.

## Lessons

### Part 1: Foundations

| # | Lesson | What you'll learn |
|---|---|---|
| 1 | [Information systems and databases](lessons/01-information-systems-and-databases.md) | DB, DBMS, file-based vs database approach, schema vs instance, DDL vs DML |
| 2 | [The relational model](lessons/02-relational-model.md) | relations, tuples, attributes, keys, foreign keys, which inserts are valid |

### Part 2: Relational algebra

| # | Lesson | What you'll learn |
|---|---|---|
| 3 | [The five basic operators](lessons/03-relational-algebra-basics.md) | union, difference, Cartesian product, projection, selection, renaming |
| 4 | [Intersection and joins](lessons/04-relational-algebra-joins.md) | intersection, join, natural join, writing multi-table expressions |

### Part 3: SQL

| # | Lesson | What you'll learn |
|---|---|---|
| 5 | [Defining schemas, tables and domains](lessons/05-sql-data-definition.md) | syntax notation, `create table`, data types, defaults, basic `insert` |
| 6 | [Constraints and schema updates](lessons/06-sql-constraints-and-schema-updates.md) | `not null`, `unique`, `primary key`, foreign keys, reaction policies, `alter`, `drop` |
| 7 | [Simple queries](lessons/07-sql-simple-queries.md) | `select`, `from`, `where`, joins, `like`, nulls, `distinct`, `order by` |
| 8 | [Aggregates, grouping and set queries](lessons/08-sql-aggregates-and-set-queries.md) | `count`, `sum`, `avg`, `group by`, `having`, `union`, `intersect`, `except` |
| 9 | [Nested queries and data modification](lessons/09-sql-nested-queries-and-data-modification.md) | `any`, `all`, `in`, `exists`, `insert`, `delete`, `update`, `check`, views |

### Part 4: Database design

| # | Lesson | What you'll learn |
|---|---|---|
| 10 | [Introduction to database design](lessons/10-intro-to-database-design.md) | the life cycle, conceptual, logical and physical design |
| 11 | [The Entity-Relationship model](lessons/11-entity-relationship-model.md) | entities, relationships, cardinalities, identifiers, generalisations |
| 12 | [Conceptual design](lessons/12-conceptual-design.md) | analysing requirements, choosing constructs, building an ER schema |
| 13 | [Logical design: restructuring](lessons/13-logical-design-restructuring.md) | redundancies, removing generalisations, partitioning and merging, primary identifiers |
| 14 | [Logical design: translation](lessons/14-logical-design-translation.md) | turning entities and relationships into tables: many-to-many, one-to-many, one-to-one |
| 15 | [Design theory and normalisation](lessons/15-design-theory-and-normalisation.md) | anomalies, functional dependencies, 1NF, 2NF, 3NF |

## Practice databases

Two scripts build the example tables used in the lectures, so you can run every query in the lessons.

| Script | Tables | Used in |
|---|---|---|
| [`practice/university.sql`](practice/university.sql) | STUDENTS, COURSES, EXAMS | lessons 2 to 6 |
| [`practice/company.sql`](practice/company.sql) | EMPLOYEE, DEPARTMENT | lessons 7 to 9 |

**To use one:** open the file in MySQL Workbench, run the whole script once, then type queries in a new tab. To start again, run `drop schema university;` or `drop schema company;` and run the script again.

`intersect` and `except` need MySQL 8.0.31 or later.

## Conventions used in the lessons

| Mark | Meaning |
|---|---|
| ✅ | a rule or fact worth memorising |
| ⚠️ | a common mistake or an exam trap |
| ❌ | something that is wrong or not allowed |
| **Beyond the notes** | extra explanation that is not in the lecture slides |

Relational algebra is written with these symbols: Π projection, σ selection, ρ renaming, ∪ union, − difference, × Cartesian product, ∩ intersection, ⋈ join.

## What's covered and what isn't

These lessons cover lectures L01 to L15. One thing is not included because the material wasn't available when they were written:

- **Stored procedures**, which are taught in the MySQL practicals.

Where a lecture slide contains a slip, the lesson says so and gives the corrected version.

## A note on accuracy

The results shown for the SQL examples and quiz answers were checked by running the queries against the practice data in SQLite, which uses the same SQL for these queries. The two practice scripts have not been run in MySQL itself, so if one gives an error there, the script is at fault, not you. The explanations follow the lecture notes, but they are a study aid, not a replacement for the notes. If a lesson and a slide disagree, go back to the slide and check with your lecturer.
