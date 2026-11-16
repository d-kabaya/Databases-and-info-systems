# Lesson 3: Relational Algebra, the Five Basic Operators

[← Previous: The relational model](02-relational-model.md) · [Back to index](../README.md) · [Next: Joins →](04-relational-algebra-joins.md)

## The big idea

**Relational algebra** is a small set of operators that take tables in and give a table out. It is the theory underneath SQL. It is a **procedural** language: you describe the **steps** to get the answer. (SQL, which comes later, is non-procedural: you describe the answer you want.)

> **Analogy:** ordinary arithmetic has operators like + and × that take numbers and give a number, so you can chain them: (2 + 3) × 4. Relational algebra works the same way, but on tables. Because every operator returns a table, you can feed one result into the next operator. This is called the **closure property**.

By the end of this lesson you can read and write expressions like this one, which finds Mavis Brown's date of birth:

Π<sub>BirthDate</sub>(σ<sub>FirstName='Mavis' ∧ Surname='Brown'</sub>(STUDENTS))

## The operators at a glance

| Operator | Symbol | What it does | Type |
|---|---|---|---|
| Union | ∪ | rows in either table | basic |
| Difference | − | rows in the first table but not the second | basic |
| Cartesian product | × | every row paired with every row | basic |
| Projection | Π | keep some **columns** | basic |
| Selection | σ | keep some **rows** | basic |
| Renaming | ρ | change column names | auxiliary |

Everything else (intersection, join) is a **derived** operator: a shortcut that can be written using the five basic ones. Derived operators are convenient but add no extra power. They are covered in [Lesson 4](04-relational-algebra-joins.md).

## Tables used in this lesson

**DEMONSTRATORS**

| RegNum | LastName | FirstName |
|---|---|---|
| 186790 | O'Brien | Ciarán |
| 276545 | Smith | Mary |

**STUDENTS**

| StudentID | Surname | FirstName |
|---|---|---|
| 276545 | Smith | Mary |
| 485745 | Black | Anna |
| 200768 | Verdi | Paolo |

**MODULES**

| ModuleCode | ModuleName | Credits |
|---|---|---|
| COMP30110 | Spatial Info Sys | 5 |
| COMP20070 | DB & Info Sys I | 5 |

## 1. Union, ∪

R = P ∪ Q contains the tuples that are in P, **or** in Q, **or** in both.

The two relations must be **union-compatible**:
- they have the **same degree** (same number of columns), and
- corresponding attributes are based on the **same domain** (first with first, second with second, and so on).

**Example:** DEMONSTRATORS ∪ STUDENTS (find all demonstrators and students)

| RegNum | LastName | FirstName |
|---|---|---|
| 186790 | O'Brien | Ciarán |
| 276545 | Smith | Mary |
| 485745 | Black | Anna |
| 200768 | Verdi | Paolo |

Three things to notice:
- **Mary Smith appears once**, not twice. The result is a set, so tuples are distinct.
- The column names come from the **first** relation (RegNum, LastName), by convention.
- The degree of the result is the same as the degree of P and Q.

❌ **Not union-compatible:** if DEMONSTRATORS were (RegNum, Name, DateOfBirth), its third attribute would be a date while the third attribute of STUDENTS is a string. Same degree, but the domains don't match, so the union is not possible.

## 2. Difference, −

R = P − Q contains the tuples that are in P **but not** in Q. The relations must be union-compatible.

**Example:** DEMONSTRATORS − STUDENTS (find the demonstrators who are not students)

| RegNum | LastName | FirstName |
|---|---|---|
| 186790 | O'Brien | Ciarán |

⚠️ **Order matters.** STUDENTS − DEMONSTRATORS gives a different answer: Anna Black and Paolo Verdi, the students who are not demonstrators.

## 3. Cartesian product, ×

R = P × Q pairs **every** tuple of P with **every** tuple of Q.

- **Degree** of R = degree(P) + degree(Q). The columns of P come first, then the columns of Q.
- **Cardinality** of R = cardinality(P) × cardinality(Q).

**Example:** STUDENTS × MODULES has 3 + 3 = **6 columns** and 3 × 2 = **6 rows**:

| StudentID | Surname | FirstName | ModuleCode | ModuleName | Credits |
|---|---|---|---|---|---|
| 276545 | Smith | Mary | COMP30110 | Spatial Info Sys | 5 |
| 485745 | Black | Anna | COMP30110 | Spatial Info Sys | 5 |
| 200768 | Verdi | Paolo | COMP30110 | Spatial Info Sys | 5 |
| 276545 | Smith | Mary | COMP20070 | DB & Info Sys I | 5 |
| 485745 | Black | Anna | COMP20070 | DB & Info Sys I | 5 |
| 200768 | Verdi | Paolo | COMP20070 | DB & Info Sys I | 5 |

On its own this is rarely useful, because most of the pairings are meaningless. Its job is to be the first step of a **join**, where a selection then keeps only the pairings that make sense.

⚠️ If P and Q have an attribute with the **same name**, you must rename one of them first (see renaming below).

## 4. Projection, Π

R = Π<sub>A1, A2, …, Am</sub>(P) keeps **only the listed columns**.

- R has degree m.
- The columns appear in the order you list them.
- Projection is also called **vertical decomposition**: it cuts the table vertically.

**Example:**

Π<sub>ModuleCode, ModuleName</sub>(MODULES)

| ModuleCode | ModuleName |
|---|---|
| COMP30110 | Spatial Info Sys |
| COMP20070 | DB & Info Sys I |

Writing Π<sub>ModuleName, ModuleCode</sub>(MODULES) instead gives the same data with the two columns swapped.

⚠️ **Projection can reduce the number of rows.** Π<sub>Credits</sub>(MODULES) has just **one** row (5), because a relation is a set and duplicates disappear.

## 5. Selection, σ

R = σ<sub>F</sub>(P) keeps **only the rows** that satisfy the predicate F.

- R has the same degree and the same attribute names as P.
- If no row satisfies F, the result is the **empty relation**, written ∅.
- Selection is also called **horizontal decomposition**: it cuts the table horizontally.

### Predicates

A **simple predicate** is one of:
- attribute *operator* constant, such as `FirstName = 'Mavis'`
- attribute *operator* attribute, such as `Salary ≤ Bonus`

where the operator is a comparison: <, >, ≤, ≥, =.

Simple predicates are combined with **∧** (AND), **∨** (OR) and **¬** (NOT):
- `FirstName = 'Mavis' ∧ Surname = 'Brown'`
- `Bonus = 0 ∨ Bonus < Salary`
- `¬(FirstName = 'Mavis')`

**Example:** with CITIES(City, Country, Population):

| City | Country | Population |
|---|---|---|
| Dublin | Ireland | 593,000 |
| Dublin | USA | 49,000 |
| London | UK | 8,866,000 |
| London | Canada | 422,000 |
| Limerick | Ireland | 102,000 |

σ<sub>Country='Ireland'</sub>(CITIES) gives Dublin (Ireland) and Limerick.

σ<sub>(Country='Ireland' ∨ Country='UK') ∧ Population>500,000</sub>(CITIES) gives London (UK) and Dublin (Ireland). Limerick is in Ireland but is too small.

### Don't mix up Π and σ

| | Projection Π | Selection σ |
|---|---|---|
| Chooses | **columns** | **rows** |
| Subscript is | a list of attribute names | a condition |
| Cut direction | vertical | horizontal |
| SQL equivalent | the `select` list | the `where` clause |

⚠️ The SQL keyword `select` corresponds to **projection**, not to the selection operator. Selection corresponds to `where`.

## 6. Renaming, ρ

R = ρ<sub>A1, …, Am ← B1, …, Bm</sub>(P) changes the attribute names A<sub>1</sub>…A<sub>m</sub> to the new names B<sub>1</sub>…B<sub>m</sub>.

- The **contents** of P are unchanged. Only the **schema** changes.
- The names in the result must all be distinct.

**In the notes' notation, the old name is on the left of the arrow and the new name is on the right.**

**Example:** ρ<sub>StudentID ← RegNum</sub>(STUDENTS) gives the same three rows with the schema (RegNum, Surname, FirstName).

### Why you need it

Suppose both tables call their key `ID`: STUDENTS(ID, Surname, FirstName) and MODULES(ID, Name, Credits). The Cartesian product can't be formed, because two columns would share the name ID. Rename one first:

ρ<sub>ID ← RegNum</sub>(STUDENTS) × MODULES

The result has the schema (RegNum, Surname, FirstName, ID, Name, Credits).

## 7. Combining operators

Work **from the inside out**. The usual recipe for a one-table question is:

1. **σ** to pick the rows you want.
2. **Π** to pick the columns you want.

Using the EMPLOYEES table from [Lesson 2](02-relational-model.md#8-worked-example-which-inserts-are-allowed):

**Q: Find the names of the employees whose salary is higher than 2000.**

- Step 1: σ<sub>Salary>2000</sub>(EMPLOYEES) keeps Rosi, Blacchi, Neri, Dara and Verdi.
- Step 2: project the Name column.

Π<sub>Name</sub>(σ<sub>Salary>2000</sub>(EMPLOYEES)) → Rosi, Blacchi, Neri, Dara, Verdi

**Q: Find the names and salaries of the engineers who receive a bonus higher than 200.**

Π<sub>Name, Salary</sub>(σ<sub>Job='engineer' ∧ Bonus>200</sub>(EMPLOYEES)) → (Rossi, 1600), (Dara, 2600)

Neri is an engineer but has a bonus of exactly 200, which is not higher than 200.

**Q: Find the employee numbers of those who (i) work in department 30 and (ii) are engineers or technicians.**

Π<sub>EmpNum</sub>(σ<sub>DeptNum=30 ∧ (Job='engineer' ∨ Job='technician')</sub>(EMPLOYEES)) → 7499, 7521

⚠️ **The brackets matter.** Without them, `DeptNum=30 ∧ Job='engineer' ∨ Job='technician'` would also return technicians from other departments.

### Why the order of σ and Π matters

Π<sub>Name</sub>(σ<sub>Salary>2000</sub>(EMPLOYEES)) works. σ<sub>Salary>2000</sub>(Π<sub>Name</sub>(EMPLOYEES)) does **not**: after projecting on Name, the Salary column is gone, so there is nothing to test.

## What to remember

- Five basic operators: **∪, −, ×, Π, σ**. Renaming **ρ** is auxiliary.
- Every operator returns a relation (**closure**), so operators can be nested.
- ∪ and − need **union-compatible** relations: same degree, matching domains.
- × gives degree = sum of degrees, cardinality = product of cardinalities.
- **Π picks columns** (vertical). **σ picks rows** (horizontal).
- Results are sets: **no duplicate tuples**.
- Usually select first, then project.

---

## Quiz

**Q1.** List the five basic operators of relational algebra. Is renaming one of them?

<details><summary>Show answer</summary>

**Union, difference, Cartesian product, projection, selection.** Renaming is **not** basic. It is an auxiliary operator.
</details>

**Q2.** What does the closure property say?

<details><summary>Show answer</summary>

Applying an operator to relations **always produces a relation**. That is why operators can be combined into expressions.
</details>

**Q3.** What two conditions make relations P and Q union-compatible?

<details><summary>Show answer</summary>

They have the **same degree**, and corresponding attributes are based on the **same domain**.
</details>

**Q4.** P has degree 4 and 10 tuples. Q has degree 3 and 6 tuples. What are the degree and cardinality of P × Q?

<details><summary>Show answer</summary>

Degree = 4 + 3 = **7**. Cardinality = 10 × 6 = **60**.
</details>

**Q5.** Using the tables in this lesson, what is STUDENTS − DEMONSTRATORS?

<details><summary>Show answer</summary>

The tuples in STUDENTS that are not in DEMONSTRATORS: **(485745, Black, Anna)** and **(200768, Verdi, Paolo)**. Mary Smith is removed because she is in both.
</details>

**Q6.** How many tuples are in Π<sub>Job</sub>(EMPLOYEES)?

<details><summary>Show answer</summary>

**4**: engineer, technician, manager, secretary. There are ten employees, but duplicates are removed because the result is a set.
</details>

**Q7.** Write a relational algebra expression to find the office of department number 30.

<details><summary>Show answer</summary>

Π<sub>Office</sub>(σ<sub>DeptNum=30</sub>(DEPARTMENTS))

Result: 5100.
</details>

**Q8.** Write an expression to find the employee numbers and jobs of the employees who work in department 30.

<details><summary>Show answer</summary>

Π<sub>EmpNum, Job</sub>(σ<sub>DeptNum=30</sub>(EMPLOYEES))

Result: (7499, technician), (7521, technician), (7654, secretary), (7698, manager).
</details>

**Q9.** What is wrong with σ<sub>Salary>2000</sub>(Π<sub>Name</sub>(EMPLOYEES))?

<details><summary>Show answer</summary>

The projection runs first and keeps only Name, so the Salary attribute no longer exists when the selection tries to use it. Select first, then project: Π<sub>Name</sub>(σ<sub>Salary>2000</sub>(EMPLOYEES)).
</details>

**Q10.** What is the schema of ρ<sub>StudentID ← RegNum</sub>(STUDENTS), where STUDENTS is (StudentID, Surname, FirstName)? Do the rows change?

<details><summary>Show answer</summary>

**(RegNum, Surname, FirstName).** The rows do not change. Renaming changes the schema only.
</details>

**Q11.** Using Employees(Number, Name, Age, Salary), write an expression for the numbers, names and ages of employees earning more than 40.

<details><summary>Show answer</summary>

Π<sub>Number, Name, Age</sub>(σ<sub>Salary>40</sub>(Employees))
</details>

**Q12.** Which relational algebra operator corresponds to the `where` clause in SQL, and which to the list of columns after `select`?

<details><summary>Show answer</summary>

`where` corresponds to **selection σ**. The column list after `select` corresponds to **projection Π**.
</details>
