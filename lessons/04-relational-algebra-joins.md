# Lesson 4: Relational Algebra, Intersection and Joins

[← Previous: Relational algebra basics](03-relational-algebra-basics.md) · [Back to index](../README.md) · [Next: SQL data definition →](05-sql-data-definition.md)

## The big idea

Real questions usually need data from **more than one table**: "What is the title of the course Mary took?" needs EXAMS and COURSES together. The **join** is the operator that glues two tables together along matching values. It is the most used operator in relational algebra.

A join adds no new power. It is a **derived operator**: a Cartesian product followed by a selection, given its own symbol because it is used so often.

> **Analogy:** two lists on paper, one of exam results and one of courses. To join them, you put your finger on a result, read its course number, find the same number in the other list, and copy the two lines out side by side. Repeat for every result.

## Tables used in this lesson

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

## 1. Intersection, ∩

R = P ∩ Q contains the tuples that are in **both** P and Q. The relations must be union-compatible.

**Example:** DEMONSTRATORS ∩ STUDENTS (find the demonstrators who are also students) gives one tuple: (276545, Smith, Mary).

Intersection is derived. It can be written with difference alone:

**P ∩ Q = P − (P − Q)**

**Why that works:** P − Q is "the part of P that is not in Q". Take that away from P and what is left is the part of P that **is** in Q.

| Step | Result with DEMONSTRATORS and STUDENTS |
|---|---|
| P − Q | O'Brien (a demonstrator who is not a student) |
| P − (P − Q) | remove O'Brien from DEMONSTRATORS, leaving Mary Smith |

## 2. Join, ⋈<sub>F</sub>

R = P ⋈<sub>F</sub> Q combines tuples of P and Q that satisfy the **join condition** F.

**P ⋈<sub>F</sub> Q = σ<sub>F</sub>(P × Q)**

In words: pair every row with every row, then keep only the pairs where F is true.

- The **degree** of R is the sum of the degrees of P and Q. **Both** copies of the matching column are kept.

**Example.** For this example only, suppose the key of COURSES is called `Course` instead of `CourseID`, so the two columns have different names.

EXAMS ⋈<sub>CourseID=Course</sub> COURSES

| StudentID | Grade | CourseID | Course | Title | Tutor |
|---|---|---|---|---|---|
| 276545 | C | 01 | 01 | Physics | Grant |
| 276545 | B | 04 | 04 | Chemistry | Clark |
| 937653 | A+ | 01 | 01 | Physics | Grant |
| 200768 | B | 04 | 04 | Chemistry | Clark |

Things to notice:
- The result has 3 + 3 = **6 columns**, including both CourseID and Course.
- The Cartesian product had 4 × 3 = 12 rows. The condition kept **4**.
- **Course 03 has vanished.** No exam refers to it, so it has no partner. A tuple with no match does not appear in a join.

### The condition can be more than an equality

EXAMS ⋈<sub>CourseID=Course ∧ ¬(Grade=C)</sub> COURSES

This keeps the same pairings but drops any with grade C. The first row above disappears, leaving three.

## 3. Natural join, ⋈

The **natural join** is a special case: the condition is "all attributes with the **same name** in both relations must be **equal**". Because the condition is fixed, it is left out of the notation.

R = P ⋈ Q

Two differences from the ordinary join:

1. You don't write a condition. It is implied by the shared attribute names.
2. **Duplicate attributes are removed.** The shared column appears only once.

**Example:** EXAMS ⋈ COURSES (both have CourseID)

| StudentID | Grade | CourseID | Title | Tutor |
|---|---|---|---|---|
| 276545 | C | 01 | Physics | Grant |
| 276545 | B | 04 | Chemistry | Clark |
| 937653 | A+ | 01 | Physics | Grant |
| 200768 | B | 04 | Chemistry | Clark |

Five columns, not six. No renaming is needed.

The shared attributes are usually the **foreign key** between the two relations, which is why natural join is so common.

### Join versus natural join

| | Join ⋈<sub>F</sub> | Natural join ⋈ |
|---|---|---|
| Condition | you write it | implied: equality on all common attribute names |
| Matching columns in the result | both kept | one kept |
| Degree of result | degree(P) + degree(Q) | degree(P) + degree(Q) − number of common attributes |
| Use when | the column names differ, or the condition is not simple equality | the matching columns have the same name |

⚠️ **Natural join only works on names.** If the foreign key and the key it refers to are named differently (`takingcourse` and `coursecode`, say), a natural join finds no common attribute. Use a join with an explicit condition instead.

## 4. The recipe for multi-table queries

1. **Which tables hold the data I need?** Include the table with the answer, the table with the condition, and any table needed to link them.
2. **Join them.**
3. **σ** to apply the condition.
4. **Π** to keep the answer columns.

### Worked example 1

Using EMPLOYEES and DEPARTMENTS from [Lesson 2](02-relational-model.md#8-worked-example-which-inserts-are-allowed):

**Q: Find the department names of the departments of employees named Verdi.**

- The answer (DeptName) is in DEPARTMENTS. The condition (Name) is in EMPLOYEES. They share DeptNum.
- Join, select, project:

Π<sub>DeptName</sub>(σ<sub>Name='Verdi'</sub>(DEPARTMENTS ⋈ EMPLOYEES))

Verdi is in department 10, so the result is **Civil Engineering**.

**You can select before joining.** This gives the same answer:

Π<sub>DeptName</sub>(DEPARTMENTS ⋈ σ<sub>Name='Verdi'</sub>(EMPLOYEES))

Both are correct. The second joins a smaller table, because the selection has already cut EMPLOYEES down to one row.

### Worked example 2

**Q: Find the office numbers and managers of the departments of employees whose salaries are higher than 2500.**

Π<sub>Office, Manager</sub>(DEPARTMENTS ⋈ σ<sub>Salary>2500</sub>(EMPLOYEES))

Step by step:
- σ<sub>Salary>2500</sub>(EMPLOYEES) keeps Rosi (dept 20), Blacchi (dept 30), Dara (dept 10) and Verdi (dept 10).
- Joining with DEPARTMENTS attaches the department details to each.
- Projecting gives **(2200, 7566), (5100, 7698), (1100, 7977)**. Department 10 appears once, although two of its employees qualify, because the result is a set.

### Worked example 3: joining a table to itself

```
Employees(Number, Name, Age, Salary)       key = {Number}
Supervision(Head, Employee)                key = {Employee}
    Head and Employee are both foreign keys referencing Employees
```

**Employees**

| Number | Name | Age | Salary |
|---|---|---|---|
| 101 | Mary Smith | 34 | 40 |
| 103 | Mary Bianchi | 23 | 35 |
| 104 | Luigi Neri | 38 | 61 |
| 105 | Nico Bini | 44 | 38 |
| 210 | Marco Celli | 49 | 60 |
| 231 | Siro Bisi | 50 | 60 |
| 252 | Nico Bini | 44 | 70 |
| 301 | Steve Smith | 34 | 70 |
| 375 | Mary Smith | 50 | 65 |

**Supervision**

| Head | Employee |
|---|---|
| 210 | 101 |
| 210 | 103 |
| 210 | 104 |
| 231 | 105 |
| 301 | 210 |
| 301 | 231 |
| 375 | 252 |

**Q: Find the numbers of the supervisors of the employees earning more than 40.**

The column names differ (Employee and Number), so a natural join won't work. Use a join with a condition:

Π<sub>Head</sub>(Supervision ⋈<sub>Employee=Number</sub> σ<sub>Salary>40</sub>(Employees))

- Employees earning more than 40: 104, 210, 231, 252, 301, 375.
- Their rows in Supervision: 104 → head 210, 210 → head 301, 231 → head 301, 252 → head 375. (301 and 375 have no supervisor, so they drop out.)
- Result: **210, 301, 375**.

**Q: Find the names and salaries of those supervisors.**

Take the previous result and join it back to Employees, this time matching Head to Number:

Π<sub>Name, Salary</sub>(Employees ⋈<sub>Number=Head</sub> Π<sub>Head</sub>(Supervision ⋈<sub>Employee=Number</sub> σ<sub>Salary>40</sub>(Employees)))

Result: **(Marco Celli, 60), (Steve Smith, 70), (Mary Smith, 65)**.

The table Employees is used twice, in two different roles: once as "the person being supervised" and once as "the supervisor".

### Worked example 4: "both" and "only"

```
Customer(Customer#, Name, City)
Order(Order#, Date, Customer#)
Info_Ord(Order#, Product, Quantity)
```

Let J = Customer ⋈ Order ⋈ Info_Ord, which lists every product each customer has ordered.

**Q: Find the names of customers from Dublin who ordered Brie.**

Π<sub>Name</sub>(σ<sub>City='Dublin' ∧ Product='Brie'</sub>(J))

**Q: Find the names of customers from Dublin who ordered both Brie and Parmesan.**

⚠️ `Product='Brie' ∧ Product='Parmesan'` is **always false**. A single row has one product, and it cannot be two things at once. Build two sets and intersect them:

- R<sub>Brie</sub> = Π<sub>Name, Customer#</sub>(σ<sub>City='Dublin' ∧ Product='Brie'</sub>(J))
- R<sub>Parmesan</sub> = Π<sub>Name, Customer#</sub>(σ<sub>City='Dublin' ∧ Product='Parmesan'</sub>(J))
- Answer: Π<sub>Name</sub>(R<sub>Brie</sub> ∩ R<sub>Parmesan</sub>)

**Q: Find the names of customers who have ordered only Brie.**

"Only" means "ordered Brie, and never ordered anything else". Use a difference:

- R<sub>Brie</sub> = Π<sub>Name, Customer#</sub>(σ<sub>Product='Brie'</sub>(J))
- R<sub>others</sub> = Π<sub>Name, Customer#</sub>(σ<sub>¬(Product='Brie')</sub>(J))
- Answer: Π<sub>Name</sub>(R<sub>Brie</sub> − R<sub>others</sub>)

**Why Customer# is kept until the end:** two different customers could share a name. Keeping the key in the projection makes sure the intersection or difference compares customers, not names.

### Patterns worth memorising

| The question says | Use |
|---|---|
| "A **or** B" | ∨ inside one selection, or ∪ |
| "**both** A **and** B" (across different rows) | ∩ of two sets |
| "**only** A", "A but **not** B", "**never** B" | − (difference) |

## 5. Summary of relational algebra

- Relational algebra is the formal query language on which SQL is based.
- It has 5 basic operators (∪, −, ×, Π, σ) plus the auxiliary renaming ρ.
- Operators are composed into expressions.
- Common compositions get their own name, such as join.
- Relational algebra has **no data definition language**. It can query relations but cannot create them.

## What to remember

- **P ∩ Q = P − (P − Q)**.
- **P ⋈<sub>F</sub> Q = σ<sub>F</sub>(P × Q)**. Both matching columns stay. Degree is the sum.
- **Natural join** matches on same-named attributes and keeps one copy of them.
- A tuple with no partner does not appear in a join.
- Join, then select, then project. Selecting before joining is also fine.
- "Both" across rows needs ∩. "Only" needs −.
- Intersection and join are derived operators: useful, but they add no expressive power.

---

## Quiz

**Q1.** Write the join P ⋈<sub>F</sub> Q using only basic operators.

<details><summary>Show answer</summary>

**σ<sub>F</sub>(P × Q)**: a Cartesian product followed by a selection.
</details>

**Q2.** Write P ∩ Q using only the difference operator.

<details><summary>Show answer</summary>

**P − (P − Q)**
</details>

**Q3.** EXAMS has degree 3 and COURSES has degree 3. What is the degree of (a) EXAMS ⋈<sub>CourseID=Course</sub> COURSES and (b) the natural join EXAMS ⋈ COURSES?

<details><summary>Show answer</summary>

(a) **6**. An ordinary join keeps every column of both relations. (b) **5**. A natural join keeps only one copy of the common attribute CourseID.
</details>

**Q4.** Why does course 03 not appear in EXAMS ⋈ COURSES?

<details><summary>Show answer</summary>

No tuple in EXAMS has CourseID 03, so course 03 has nothing to be combined with. Tuples without a match are left out of a join.
</details>

**Q5.** Using students(studentid, firstname, lastname, telephone, email, takingcourse) and courses(coursecode, coursename, duration, coursecost), where takingcourse is a foreign key on courses: find the coursename of the courses taken by students with lastname 'Murphy'.

<details><summary>Show answer</summary>

Π<sub>coursename</sub>(σ<sub>lastname='Murphy'</sub>(students) ⋈<sub>takingcourse=coursecode</sub> courses)

A natural join would not work here, because the two linking attributes have different names.
</details>

**Q6.** Using EMPLOYEES and DEPARTMENTS, write an expression for the names of the employees who work in the R&D department.

<details><summary>Show answer</summary>

Π<sub>Name</sub>(σ<sub>DeptName='R&D'</sub>(EMPLOYEES ⋈ DEPARTMENTS))

or equivalently Π<sub>Name</sub>(EMPLOYEES ⋈ σ<sub>DeptName='R&D'</sub>(DEPARTMENTS)).

R&D is department 20, so the result is Rossi, Rosi and Scotti.
</details>

**Q7.** Are these two expressions equivalent?
Π<sub>DeptName</sub>(σ<sub>Name='Verdi'</sub>(DEPARTMENTS ⋈ EMPLOYEES)) and Π<sub>DeptName</sub>(DEPARTMENTS ⋈ σ<sub>Name='Verdi'</sub>(EMPLOYEES))

<details><summary>Show answer</summary>

**Yes.** Both give Civil Engineering. The selection only involves an attribute of EMPLOYEES, so it can be applied before or after the join.
</details>

**Q8.** A student writes σ<sub>Product='Brie' ∧ Product='Parmesan'</sub>(J) to find customers who ordered both. What does it return, and why?

<details><summary>Show answer</summary>

**Nothing** (the empty relation). Each tuple has a single Product value, which can never equal both 'Brie' and 'Parmesan'. The correct approach builds the Brie customers and the Parmesan customers separately and takes the **intersection**.
</details>

**Q9.** With the schema in worked example 4, write an expression for the names of customers who ordered Brie but never ordered Parmesan.

<details><summary>Show answer</summary>

With J = Customer ⋈ Order ⋈ Info_Ord:

Π<sub>Name</sub>(Π<sub>Name, Customer#</sub>(σ<sub>Product='Brie'</sub>(J)) − Π<sub>Name, Customer#</sub>(σ<sub>Product='Parmesan'</sub>(J)))
</details>

**Q10.** With Provides(NameP, Product, Price), key = {NameP, Product}: can a given product be sold at different prices?

<details><summary>Show answer</summary>

**Yes**, as long as it is sold by **different providers**. The key is the pair (NameP, Product), so each provider has one price per product, but two providers can charge different prices for the same product.
</details>

**Q11.** With Order(Order#, Date, Customer#), key = {Order#}: can two different orders have the same order number? Can a given product appear in two different orders?

<details><summary>Show answer</summary>

Two orders **cannot** share an order number, because Order# is the key. A product **can** appear in two different orders: the key of Info_Ord is {Order#, Product}, so the same product may be paired with different order numbers.
</details>

**Q12.** True or false: relational algebra includes statements for creating tables.

<details><summary>Show answer</summary>

**False.** Relational algebra does not include a data definition language. It is a query language only.
</details>
