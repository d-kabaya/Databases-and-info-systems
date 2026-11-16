# Lesson 2: The Relational Model

[← Previous: Information systems](01-information-systems-and-databases.md) · [Back to index](../README.md) · [Next: Relational algebra basics →](03-relational-algebra-basics.md)

## The big idea

The **relational model** stores everything in **tables**. That's it. There are no pointers and no hidden links. Tables are connected only by **values that match** (a student number in one table matching a student number in another). The model was proposed by E. F. Codd in 1970 and has been used by almost every commercial DBMS since 1981.

The lecture uses formal names for ordinary things. Learn the pairs and most of this lesson falls into place.

| Everyday word | Formal word |
|---|---|
| table | **relation** |
| row | **tuple** |
| column | **attribute** |
| column name | **attribute name** |
| data type of a column | **domain** |
| the list of column names | **schema** |

## The running example

Three tables from the lecture. You can build them yourself with [`practice/university.sql`](../practice/university.sql).

**STUDENTS**

| StudentID | Surname | FirstName | BirthDate |
|---|---|---|---|
| 276545 | Smith | Mary | 25/11/1990 |
| 485745 | Black | Anna | 23/04/1991 |
| 200768 | Verdi | Paolo | 12/02/1991 |
| 587614 | Smith | Lucy | 10/10/1990 |
| 937653 | Brown | Mavis | 01/12/1990 |

**EXAMS**

| StudentID | Grade | CourseID |
|---|---|---|
| 276545 | C | 01 |
| 276545 | B | 04 |
| 937653 | A+ | 01 |
| 200768 | B | 04 |

**COURSES**

| CourseID | Title | Tutor |
|---|---|---|
| 01 | Physics | Grant |
| 03 | Chemistry | Beale |
| 04 | Chemistry | Clark |

To answer "What grade did Mary get in Physics?" you look up Mary in STUDENTS (276545), look up Physics in COURSES (01), then find the EXAMS row with both values: **C**. Nothing connects the tables except those matching values.

## 1. Why the relational model?

It supports **data independence**: users and programs refer to data at a high level, ignoring how it is physically stored. It also gives simple **declarative** languages for querying, and it rests on the mathematical idea of a **relation**, so properties of data and operations can be formally proved.

## 2. Structure

- A database is a **collection of relations**.
- A **relation** is a **set of tuples**. Each tuple represents a real-world entity.
- A **tuple** is an ordered list of attribute values.
- All tuples in a relation are **homogeneous**: they all have the same attributes.
- Each **attribute** has a **name** and a **domain**, which is the range of values it may take. Examples: integers between 1 and 99, or strings of at most 20 characters.
- The set of attributes of a relation is its **schema**. A **database schema** is the set of relation schemas.

Because a relation is a **set**, two things follow:
- there are no duplicate tuples, and
- the tuples have no particular order.

## 3. Degree and cardinality

- **Degree** = the number of **attributes** (columns).
- **Cardinality** = the number of **tuples** (rows).

**Example:** STUDENTS has degree **4** and cardinality **5**. EXAMS has degree **3** and cardinality **4**.

⚠️ These two are easy to swap. Degree is about the **headings**, so it only changes if the schema changes. Cardinality is about the **rows**, so it changes every time a row is inserted or deleted.

## 4. Notation

| What | Notation | Example |
|---|---|---|
| Schema | R(A<sub>1</sub>, A<sub>2</sub>, …, A<sub>k</sub>) | STUDENTS(StudentID, Surname, FirstName, BirthDate) |
| Tuple | t = (v<sub>1</sub>, v<sub>2</sub>, …, v<sub>k</sub>) | t = (276545, Smith, Mary, 25/11/1990) |
| A value in a tuple | t[A<sub>i</sub>] | t[FirstName] = Mary |
| Domain | dom(A<sub>i</sub>) | dom(FirstName) is String |

## 5. Null values

A **null** value means an **absence of information**. The value may be missing, irrelevant or not applicable. It is written `NULL` or `?`.

**Example:** in the EMPLOYEES table below, a Bonus of `?` means no bonus is recorded for that employee.

⚠️ Null is not zero and not an empty string. Zero is a known value. Null means "we don't have a value".

## 6. Keys

A **key** is a set of attributes that **uniquely identifies** each tuple.

Formally, a set X of attributes of relation R is a key if:

1. **Uniqueness:** no two different tuples can ever have the same values for all the attributes in X.
2. **Minimality:** no proper subset of X also satisfies property 1. (A proper subset is a subset that is not X itself.)

**Example: the CITIES relation**

| City | Country | Population |
|---|---|---|
| Dublin | Ireland | 593,000 |
| Dublin | USA | 49,000 |
| London | UK | 8,866,000 |
| London | Canada | 422,000 |
| Limerick | Ireland | 102,000 |

- {City} is **not** a key: Dublin appears twice.
- {Country} is **not** a key: Ireland appears twice.
- {City, Country} **is** a key: every pair is different, and neither attribute works alone.
- {City, Country, Population} is **not** a key. It is unique, but it is not minimal, because {City, Country} already does the job.

**The key depends on the meaning, not just the rows you can see.** For COURSES(Code, Name, School, Credits):
- key = {Code} says there can never be two courses with the same code.
- key = {Code, School} says the same code may be reused, but only in different schools.

### Three more rules

- A key **cannot have null values**.
- A relation may have more than one key. These are **candidate keys**.
- The **primary key** is the one candidate key chosen to identify tuples.

## 7. Foreign keys and referential integrity

A **foreign key** links tuples in two relations. It is how the relational model represents associations.

```mermaid
flowchart LR
    E["EXAMS<br/>(internal relation)<br/>StudentID, Grade, <b>CourseID</b>"] -- "CourseID must match" --> C["COURSES<br/>(external / referenced relation)<br/><b>CourseID</b>, Title, Tutor"]
```

- The relation that **holds** the foreign key is the **internal** relation (EXAMS).
- The relation it **points to** is the **external** or **referenced** relation (COURSES).

**The rule (referential integrity constraint):** every value of the foreign key in the internal relation must appear as a value of the **primary key** in the referenced relation.

So every CourseID in EXAMS (01, 04, 01, 04) must exist in COURSES. An EXAMS row with CourseID 07 would be rejected, because there is no course 07.

✅ **A foreign key can be null.** That just means the row is not linked to any row in the other table.
❌ **A primary key can never be null.**

The arrows you see in diagrams are only for illustration. The relational model stores no pointers, only the matching values.

## 8. Worked example: which inserts are allowed?

This is the classic exam question. The database is:

```
EMPLOYEES(EmpNum, Name, Job, StartDate, Salary, Bonus, DeptNum)
    key(EMPLOYEES) = {EmpNum}
    foreign-key(EMPLOYEES) = {DeptNum}, referenced relation: DEPARTMENTS

DEPARTMENTS(DeptNum, DeptName, Office, Division, Manager)
    key(DEPARTMENTS) = {DeptNum}
```

**EMPLOYEES**

| EmpNum | Name | Job | StartDate | Salary | Bonus | DeptNum |
|---|---|---|---|---|---|---|
| 7369 | Rossi | engineer | 17-Dec-90 | 1600 | 500 | 20 |
| 7499 | Andrei | technician | 20-Feb-91 | 800 | ? | 30 |
| 7521 | Bianchi | technician | 20-Feb-91 | 800 | 100 | 30 |
| 7566 | Rosi | manager | 20-Apr-91 | 2975 | ? | 20 |
| 7654 | Martini | secretary | 28-Sep-91 | 800 | ? | 30 |
| 7698 | Blacchi | manager | 01-May-91 | 2850 | ? | 30 |
| 7782 | Neri | engineer | 01-Jun-91 | 2450 | 200 | 10 |
| 7788 | Scotti | secretary | 09-Nov-91 | 800 | ? | 20 |
| 7839 | Dara | engineer | 17-Nov-90 | 2600 | 300 | 10 |
| 7977 | Verdi | manager | 10-Dec-90 | 3000 | ? | 10 |

**DEPARTMENTS**

| DeptNum | DeptName | Office | Division | Manager |
|---|---|---|---|---|
| 10 | Civil Engineering | 1100 | D1 | 7977 |
| 20 | R&D | 2200 | D1 | 7566 |
| 30 | Surveying | 5100 | D2 | 7698 |

### The method: three checks, in order

For any insert, ask:

1. **Is the key value already used?** If yes, reject (key constraint).
2. **Is any part of the key null?** If yes, reject (keys cannot be null).
3. **Does every foreign key value exist in the referenced table, or is it null?** If no, reject (referential integrity).

If all three pass, the insert is valid. Nothing else matters: duplicate names, odd salaries and so on are all fine unless a constraint says otherwise.

| Insert | Check that decides it | Valid? |
|---|---|---|
| (10, Payroll, 2300, D2, 7977) into DEPARTMENTS | DeptNum 10 already exists | ❌ |
| (40, R&D, 2400, D3, 7977) into DEPARTMENTS | 40 is new. A second "R&D" is allowed: nothing says DeptName is unique | ✅ |
| (?, Payroll, 2400, D3, 7977) into DEPARTMENTS | the key DeptNum is null | ❌ |
| (7360, Ciaran, manager, 11-Nov-93, 1900, 0, 40) into EMPLOYEES | DeptNum 40 is not in DEPARTMENTS | ❌ |
| (40, Payroll, 2300, D2, 9999) into DEPARTMENTS | see the note below | ✅ here |

⚠️ **Read the schema before answering the last one.** In the lecture's schema, DEPARTMENTS has **no foreign key on Manager**, so 9999 is accepted. The exercise sheet uses a slightly different schema where Manager **is** a foreign key referencing EMPLOYEES. With that schema the same kind of insert is **invalid**, because employee 9999 does not exist. The data is the same in both; only the declared constraints differ.

## What to remember

- Relation = table, tuple = row, attribute = column, domain = type.
- **Degree** counts columns. **Cardinality** counts rows.
- A **key** is unique **and** minimal. It cannot be null.
- Candidate keys are all the keys. The **primary key** is the chosen one.
- A **foreign key** in the internal relation must match a primary key value in the referenced relation, **or be null**.
- Tables are linked by matching values, never by pointers.
- For "can I insert this?" questions: key already used? key null? foreign key missing?

---

## Quiz

**Q1.** What are the formal names for a table, a row and a column?

<details><summary>Show answer</summary>

**Relation**, **tuple** and **attribute**.
</details>

**Q2.** What are the degree and the cardinality of DEPARTMENTS above?

<details><summary>Show answer</summary>

Degree **5** (DeptNum, DeptName, Office, Division, Manager). Cardinality **3** (three rows).
</details>

**Q3.** What is the cardinality of EMPLOYEES?

<details><summary>Show answer</summary>

**10**. There are ten tuples.
</details>

**Q4.** Using the STUDENTS table, let t be the tuple for student 200768. What is t[Surname]?

<details><summary>Show answer</summary>

**Verdi**.
</details>

**Q5.** In CITIES, why is {City, Country, Population} not a key, even though no two rows share all three values?

<details><summary>Show answer</summary>

It fails **minimality**. Its proper subset {City, Country} already identifies every tuple, so the larger set is not a key.
</details>

**Q6.** True or false: a relation can have more than one key.

<details><summary>Show answer</summary>

**True.** They are called candidate keys. One of them is chosen as the primary key.
</details>

**Q7.** True or false: a foreign key can contain a null value.

<details><summary>Show answer</summary>

**True.** A null foreign key means the row is not associated with any row in the referenced table. A **primary key** is what can never be null.
</details>

**Q8.** In the link between EXAMS and STUDENTS on StudentID, which is the internal relation and which is the referenced relation?

<details><summary>Show answer</summary>

**EXAMS** is the internal relation, because it holds the foreign key. **STUDENTS** is the external (referenced) relation.
</details>

**Q9.** Using the exercise-sheet schema, where Manager is a foreign key of DEPARTMENTS referencing EMPLOYEES: is it valid to insert (20, H&R, 3710, D2, 7566) into DEPARTMENTS?

<details><summary>Show answer</summary>

**Invalid.** There is already a tuple with DeptNum = 20, and DeptNum is the key.
</details>

**Q10.** Same schema: is it valid to insert (7980, Mary, technician, 11-Oct-89, 3000, 5000, 50) into EMPLOYEES?

<details><summary>Show answer</summary>

**Invalid.** DeptNum is a foreign key referencing DEPARTMENTS, and there is no department 50.
</details>

**Q11.** Same schema: is it valid to insert (50, Payroll, 3110, D5, 8000) into DEPARTMENTS? What about (50, Payroll, 3110, D5, ?)?

<details><summary>Show answer</summary>

The first is **invalid**: Manager 8000 does not exist in EMPLOYEES, so the foreign key is violated.

The second is **valid**: a foreign key may be null. The constraint only requires that a value, **if it exists**, matches a key in the referenced relation.
</details>

**Q12.** Could you add the row (485745, A, 03) to EXAMS? Could you add (485745, A, 02)?

<details><summary>Show answer</summary>

(485745, A, 03) is **valid**: student 485745 exists, course 03 exists, and the pair (485745, 03) is not already in EXAMS. (The key of EXAMS is {StudentID, CourseID}, so it is the pair that must be new.)

(485745, A, 02) is **invalid**: there is no course 02 in COURSES, so referential integrity is violated.
</details>
