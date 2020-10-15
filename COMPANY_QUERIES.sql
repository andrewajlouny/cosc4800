################################################
#                                              #
# Andrew Ajlouny                               #
# Homework #2                                  #
# Is this implemented in the best way? No, but #
# it runs and gives us the right answer, and   #
# that's all we care about at this point :)	   #
#                                              #
################################################

#	a - Show the last names of the employees, who are male and have salary less then 35000.
#	3 - Relational algebra
M_EMPS <- σ sex='M' AND salary>35000(EMPLOYEE)
RESULT <- π lname(M_EMPS)

# 	4 - SQL
SELECT lname
FROM EMPLOYEE
WHERE sex='M' AND salary>35000
 
################################################
#	b - Find each employee’s last name and his/her supervisor’s last name.
# 	3 - Relational algebra
SUP <- ρ(s_lname, s_ssn) π lname, ssn(EMPLOYEE)
RESULT <- π lname, s_lname (SUP ⋈ s_ssn=super_ssn EMPLOYEE)

#	4 - SQL
SELECT EMPLOYEE.lname, SUPER.lname AS s_lname
FROM EMPLOYEE, EMPLOYEE AS SUPER
WHERE EMPLOYEE.super_ssn=Super.ssn

# or

SELECT lname, s_lname
FROM (SELECT lname as s_lname, ssn as s_ssn
	  FROM EMPLOYEE) AS SUP 
      JOIN EMPLOYEE on SUP.s_ssn=EMPLOYEE.super_ssn

################################################
#	c - List the project names that John Smith has worked on.
#	3 - Relational Algebra
JOHN_SMITH <- σ fname="John" AND lname="Smith"(EMPLOYEE)
JS_PROJ <- π pno(WORKS_ON ⋈ essn=ssn JOHN_SMITH)
RESULT <- π pname(JS_PROJ ⋈ pno=pnumber PROJECT)

#	4 - SQL
SELECT PROJECT.Pname AS project_name
FROM EMPLOYEE, WORKS_ON, PROJECT
WHERE fname="John" AND lname="Smith" and EMPLOYEE.ssn=WORKS_ON.essn and WORKS_ON.pno=PROJECT.pnumber

# or
SELECT pname
FROM (SELECT pno
	  FROM (SELECT *
	  		FROM EMPLOYEE
	  		WHERE fname="John" AND lname="Smith") AS JOHN_SMITH
      		JOIN WORKS_ON on ssn=essn) as JS_PROJ
      JOIN PROJECT on pno=pnumber

################################################
#	d - Show the last names of the employees, who are in the department 5 and worked on the project “ProductX”.
#	3 - Relational Algebra
P_X <- σ pname="ProductX"(PROJECT)
PX_EMPS <- π essn(WORKS_ON ⋈ pno=pnumber P_X)
RESULT <- π lname(σ dno=5 (EMPLOYEE) ⋈ ssn=essn PX_EMPS)

# 	4 - SQL
SELECT EMPLOYEE.lname
FROM EMPLOYEE, PROJECT, WORKS_ON
WHERE EMPLOYEE.dno=5 AND PROJECT.pname="ProductX" AND WORKS_ON.pno=PROJECT.pnumber AND EMPLOYEE.ssn=WORKS_ON.essn
GROUP BY EMPLOYEE.lname

# or

SELECT lname
from (SELECT essn
 	  from (SELECT *
	   		FROM PROJECT
	   		WHERE pname="ProductX") as P_X
       		JOIN WORKS_ON on P_X.pnumber=WORKS_ON.pno) as PX_EMPS
      JOIN (SELECT *
            FROM EMPLOYEE
            WHERE dno=5) as D5_EMPS
GROUP by lname

################################################
#	4e Count the number of employees for each department, whose salary is higher than 50000.

SELECT COUNT(ssn)
FROM EMPLOYEE
WHERE salary>50000

################################################
#	4f Find the projects controlled by department 5 and the number of people working on each of these projects.

SELECT PROJECT.pname As project_name, COUNT(WORKS_ON.essn) AS employee_count
FROM WORKS_ON, PROJECT
WHERE dnum = 5 AND WORKS_ON.pno=PROJECT.pnumber
GROUP BY PROJECT.pname

# or

SELECT D5_EMP.pnumber, count(essn) as emp_count
FROM (SELECT * 
      FROM (SELECT *
            FROM PROJECT
	        WHERE dnum = 5) AS D5_PROJ
            JOIN WORKS_ON on pnumber=pno) as D5_EMP
GROUP by pno

################################################
#	4g For each project, find the employee who spends the maximum project hours on that project.

SELECT EMPLOYEE.fname, EMPLOYEE.lname, MAX(WORKS_ON.hours)
FROM EMPLOYEE, WORKS_ON
WHEre WORKS_ON.essn=EMPLOYEE.ssn
GROUP by pno

# or

SELECT fname, lname, pno as project_num, max_hours
FROM (SELECT WORKS_ON.essn, MAX_HRS.pno, max_hours
	  FROM (SELECT *, MAX(hours) as max_hours
	  		FROM WORKS_ON
	  		Group BY pno) as MAX_HRS 
      		JOIN WORKS_ON ON MAX_HRS.pno=WORKS_ON.pno AND MAX_HRS.hours=WORKS_ON.hours) as MAX_EMP
      JOIN EMPLOYEE on MAX_EMP.essn=EMPLOYEE.ssn
group by pno

################################################
#	4h Find the last names of the employees who have worked on all the projects that John Smith worked on.

# Select pno from the joined tables of EMPLOYEE and WORKS_ON where the ssn = essn, then from that 
# joined table we only keep the rows with first name John and last name Smith. This "table" is called JS_PROJ

# Select essn from the joined tables of JS_PROJ and WORKS_ON where the pno = pno, then from that joined table
# we now have the list of everyone who worked on the the same projects as John Smith

# Select lname from the joined tables JS_COEMPS and EMPLOYEE where the essn = snn

# Then we want to exclude John Smith from this list I think

# We also want to group my last name incase any of them are on multiple projects that John was on
SELECT lname 																
FROM (SELECT essn									
	  FROM (SELECT pno											
	  		FROM EMPLOYEE JOIN WORKS_ON ON EMPLOYEE.ssn=WORKS_ON.essn		
	  		WHERE fname="John" AND lname="Smith") as JS_PROJ				
      		JOIN WORKS_ON ON JS_PROJ.pno=WORKS_ON.pno) as JS_COEMPS
	  JOIN EMPLOYEE ON JS_COEMPS.essn=EMPLOYEE.ssn
EXCEPT SELECT lname
FROM EMPLOYEE
WHERE fname="John" AND lname="Smith"
GROUP BY lname