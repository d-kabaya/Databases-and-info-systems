# Lesson 6: SQL Part 2, Constraints, Reaction Policies and Schema Updates

[← Previous: SQL data definition](05-sql-data-definition.md) · [Back to index](../README.md) · [Next: Simple queries →](07-sql-simple-queries.md)

## The big idea

A table that accepts anything will soon contain rubbish: two students with the same number, an exam for a course that doesn't exist. **Constraints** are rules the DBMS enforces on every insert, update and delete, so that bad data is **rejected** instead of stored.

> **Analogy:** a bouncer at a door with a checklist. "No ticket number already used. No blank names. No ticket for an event that isn't on the list." Anyone who fails a check doesn't get in.

A constraint is a property that **every database instance must satisfy** to ensure data integrity. This lesson covers how to declare constraints, what happens when a referenced row changes (**reaction policies**), and how to change a table after it has been created.

## 1. Two kinds of constraint

| Kind | Involves | Examples |
|---|---|---|
| **Intra-relational** | a single relation | `not null`, `unique`, `primary key` |
| **Inter-relational** | more than one relation | foreign keys (referential integrity) |

There is also `check`, the most powerful kind, which can express both. It is covered in [Lesson 9](09-sql-nested-queries-and-data-modification.md).

## 2. Inline and out-of-line

A constraint can be written in two places:

- **Inline:** on the same line as the attribute it applies to.
- **Out-of-line:** on its own line after the attributes. This is the only way to write a constraint that covers **several** attributes.

```sql
create table CUSTOMERS(
    CustomerID integer primary key,        -- inline
    FirstName varchar(20) not null,        -- inline
    LastName varchar(20) not null,         -- inline
    PhoneNumber varchar(15),
    Eircode char(7),
    unique(PhoneNumber, Eircode)           -- out-of-line
)
```

## 3. Intra-relational constraints

### `not null`

A null value is not allowed for the attribute. It is always written **inline**.

### `unique`

No two rows may have the same value. It can cover one attribute or a set of attributes, and can be inline or out-of-line.

### `primary key`

Specifies the identifier of the rows. It can cover one attribute or a set, inline or out-of-line, but may appear **only once per table**.

✅ A primary key is automatically unique **and** not null.

### ⚠️ The classic trap: two ways to write `unique`

These two tables look almost the same and mean different things.

**Version A: one constraint on the pair**

```sql
PhoneNumber varchar(15),
Eircode char(7),
unique(PhoneNumber, Eircode)
```

No two rows can have the same **combination** of PhoneNumber and Eircode.

**Version B: a separate constraint on each**

```sql
PhoneNumber varchar(15) unique,
Eircode char(7) unique
```

No two rows can have the same PhoneNumber, **and** no two rows can have the same Eircode.

Test them with two customers who share a house:

| Row | PhoneNumber | Eircode |
|---|---|---|
| 1 | 0871111111 | D04X123 |
| 2 | 0872222222 | D04X123 |

| | Result | Why |
|---|---|---|
| Version A | ✅ accepted | the two **pairs** are different |
| Version B | ❌ rejected | the Eircode D04X123 is repeated |

Version B is the stricter of the two.

## 4. Inter-relational constraints: foreign keys

The most important inter-relational constraint is the **referential integrity constraint**, declared with a foreign key. There are two syntaxes.

**Inline** (one attribute only):

```
references ExternalTable(Attribute)
```

```sql
create table EXAMS(
    StudentID integer
        references STUDENTS(StudentID),
    Grade varchar(2),
    CourseID smallint
        references COURSES(CourseID),
    primary key (StudentID, CourseID)
)
```

**Out-of-line** (one or more attributes):

```
foreign key ( Attribute {, Attribute} )
    references ExternalTable ( Attribute {, Attribute} )
```

```sql
create table EXAMS(
    StudentID integer,
    Grade varchar(2),
    CourseID smallint,
    primary key (StudentID, CourseID),
    foreign key (StudentID)
        references STUDENTS(StudentID),
    foreign key (CourseID)
        references COURSES(CourseID)
)
```

A foreign key made of **several attributes** must be out-of-line:

```sql
foreign key (CourseName, SchoolName)
    references COURSES(Course, School)
```

⚠️ The attributes referred to in the external table must have a **unique** constraint (which a primary key provides). You cannot reference a column that might contain duplicates.

Remember the vocabulary from [Lesson 2](02-relational-model.md): EXAMS is the **internal** table (it holds the foreign key) and COURSES is the **external** or referenced table.

## 5. Reaction policies

A foreign key can be broken from the **other side**. Suppose EXAMS contains rows for course 04. What should happen if someone:

1. **changes** CourseID 04 to 02 in COURSES, or
2. **deletes** the row for course 04 from COURSES?

Either would leave exam rows pointing at a course that no longer exists. A **reaction policy** tells the DBMS what to do.

✅ **Reactions operate on the internal table** (the one holding the foreign key), **after a change to the external table.**

```
on < delete | update > < cascade | set null | set default | no action >
```

| Policy | What happens to the rows in the internal table |
|---|---|
| `cascade` | the change is **propagated**: on delete, they are deleted too. On update, their foreign key is updated to the new value |
| `set null` | their foreign key is set to **null** |
| `set default` | their foreign key is set to its **default** value |
| `no action` | nothing, because the change to the external table is **forbidden**. Same as `restrict` |

### Example

```sql
create table EXAMS(
    StudentID integer,
    Grade varchar(2),
    CourseID smallint,
    primary key (StudentID, CourseID),
    foreign key (StudentID)
        references STUDENTS(StudentID)
        on delete no action
        on update cascade,
    foreign key (CourseID)
        references COURSES(CourseID)
        on delete cascade
        on update no action
)
```

Each foreign key has its own policy for delete and for update. With the data from [Lesson 2](02-relational-model.md):

| Action on the external table | Policy that applies | Result |
|---|---|---|
| Delete course 04 from COURSES | `on delete cascade` | allowed. Both exam rows with CourseID 04 are **deleted too** |
| Change course 04's ID to 02 | `on update no action` | **rejected**, because exams refer to 04 |
| Delete student 276545 from STUDENTS | `on delete no action` | **rejected**, because that student has exams |
| Change student 276545's ID to 999999 | `on update cascade` | allowed. Both of that student's exam rows are **updated** to 999999 |
| Delete course 03 from COURSES | none needed | allowed. No exam refers to course 03, so nothing is violated |

### Choosing a policy (beyond the notes)

The notes define the four policies but don't say how to pick one. A useful question to ask: **do the child rows mean anything without the parent?**

- If not, `cascade` on delete. Exam results for a course that has been removed are meaningless.
- If the child rows are records you must not lose, `no action`. You should not be able to delete a student who has exam results.
- If the link is optional, `set null`. The child row stays, but is no longer attached to anything.

## 6. Changing a schema: `alter table`

`alter table` modifies an existing table.

```
alter table TableName
    < add column AttributeDef |
      drop column AttributeName |
      alter column AttributeName < set default DefaultValue | drop default > |
      add constraint ConstraintDef |
      drop constraint Constraint >
```

One option per statement:

| Option | What it does |
|---|---|
| `add column` | adds a new column |
| `drop column` | removes a column and its data |
| `alter column … set default` | gives a column a default value |
| `alter column … drop default` | removes a column's default |
| `add constraint` | adds a constraint |
| `drop constraint` | removes a constraint |

```sql
alter table STUDENTS
    add column Email varchar(30)
```

```sql
alter table STUDENTS
    add constraint unique(Email)
```

```sql
alter table STUDENTS
    drop column Email
```

⚠️ In the notes, `alter column` can only **set or drop a default**. There is no option to rename a column or change its domain.

**Beyond the notes:** MySQL adds its own options, such as `modify column` (change a column's definition), `change column` (rename and redefine) and `rename column`. They are useful in labs but are not part of the syntax taught in the lectures.

## 7. Removing things: `drop`

`drop` removes a whole component.

```
drop < schema | domain | table | view | assertion > ComponentName [ restrict | cascade ]
```

| Option | Meaning |
|---|---|
| `restrict` | only drop if **nothing depends on** the component |
| `cascade` | drop the component **and everything that depends on it** |

```sql
drop table STUDENTS      -- deletes the table if no component depends on it
drop schema L06DB        -- deletes the schema named L06DB
```

### Three statements that are easy to confuse

| Statement | Removes | Table still exists? |
|---|---|---|
| `delete from STUDENTS` | all the **rows** | ✅ yes, empty |
| `drop table STUDENTS` | the **table** itself, schema and rows | ❌ no |
| `alter table STUDENTS drop column Email` | one **column** | ✅ yes |

## What to remember

- **Intra-relational:** `not null`, `unique`, `primary key`. **Inter-relational:** foreign keys.
- Constraints on several attributes must be **out-of-line**.
- `unique(A, B)` constrains the **pair**. `A unique, B unique` constrains **each one**.
- Only **one** `primary key` per table.
- A foreign key must reference attributes that are **unique** in the external table.
- Reaction policies act on the **internal** table after a change to the **external** table.
- `cascade` propagates, `set null` nullifies, `set default` uses the default, `no action` forbids.
- `alter table` changes a table's structure. `drop` removes a component completely.

---

## Quiz

**Q1.** Classify each as intra-relational or inter-relational: `not null`, `foreign key`, `unique`, `primary key`.

<details><summary>Show answer</summary>

`not null`, `unique` and `primary key` are **intra-relational** (they involve a single relation). `foreign key` is **inter-relational** (it involves two relations).
</details>

**Q2.** How many `primary key` constraints can one table have?

<details><summary>Show answer</summary>

**One.** It can cover several attributes, but it is specified only once per table.
</details>

**Q3.** A table has `unique(PhoneNumber, Eircode)`. It already contains ('0871111111', 'D04X123'). Is the row ('0871111111', 'A65F4E2') accepted?

<details><summary>Show answer</summary>

**Yes.** The constraint is on the **combination**. The phone number repeats, but the pair ('0871111111', 'A65F4E2') is new.
</details>

**Q4.** Same two rows, but the table declares `PhoneNumber varchar(15) unique, Eircode char(7) unique`. Is the second row accepted?

<details><summary>Show answer</summary>

**No.** PhoneNumber must be unique on its own, and '0871111111' is already used.
</details>

**Q5.** Why can't a foreign key made of two attributes be declared inline?

<details><summary>Show answer</summary>

The inline form `references ExternalTable(Attribute)` is attached to a **single attribute**. A foreign key on a set of attributes needs the out-of-line form `foreign key (A, B) references T(X, Y)`.
</details>

**Q6.** What property must the referenced attribute(s) in the external table have?

<details><summary>Show answer</summary>

They must have a **unique** constraint. (A primary key satisfies this.)
</details>

**Q7.** Reaction policies operate on which table: the internal table or the external table?

<details><summary>Show answer</summary>

The **internal** table, the one containing the foreign key. They are triggered by a change to the **external** (referenced) table.
</details>

**Q8.** EXAMS has `foreign key (CourseID) references COURSES(CourseID) on delete set null`. Course 01 is deleted from COURSES. What happens to the exam rows for course 01?

<details><summary>Show answer</summary>

Their CourseID is set to **null**. The exam rows stay in the table but no longer refer to any course.

(In the lecture's EXAMS table this particular policy would not actually work, because CourseID is part of the primary key and a key cannot be null. It works when the foreign key is an ordinary column.)
</details>

**Q9.** Using the example in section 5, what happens when you try to change student 276545's StudentID to 111111 in STUDENTS?

<details><summary>Show answer</summary>

The policy is `on update cascade`, so the change is **allowed** and both of that student's rows in EXAMS are updated to 111111.
</details>

**Q10.** Using the same example, what happens when you try to delete student 200768 from STUDENTS?

<details><summary>Show answer</summary>

It is **rejected**. The policy is `on delete no action`, and student 200768 has a row in EXAMS.
</details>

**Q11.** Write the statement that gives the Grade column of EXAMS a default value of 'B'.

<details><summary>Show answer</summary>

```sql
alter table EXAMS
    alter column Grade set default 'B'
```
</details>

**Q12.** What is the difference between `delete from COURSES` and `drop table COURSES`?

<details><summary>Show answer</summary>

`delete from COURSES` removes all the **rows** but keeps the table and its schema. `drop table COURSES` removes the **table itself**.
</details>

**Q13.** What is the difference between `drop table T restrict` and `drop table T cascade`?

<details><summary>Show answer</summary>

`restrict` only drops T if **no other component depends on it**. `cascade` drops T **together with** everything that depends on it.
</details>
