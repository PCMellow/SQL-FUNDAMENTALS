-- Creating the Database named SQLFUNDAMENTALS 

CREATE DATABASE SQLFUNDAMENTALS 

--Creating Some Tables, Let us suppose its a business based SQL where we monitor analyse and maintain data 

CREATE TABLE EmployeeDemographics 
(Id int not null identity,
EmployeeId int,
FirstName varchar(255),
LastName varchar(255),
Age int,
Gender varchar(255),
Primary Key (Id)
)

CREATE TABLE EmployeeSalary
(Id int not null identity,
EmployeeId int,
JobTitle varchar(255),
Salary int,
General_Id int not null
Primary Key (Id),
Foreign Key (General_Id) References EmployeeDemographics(Id)
)

--Now after creating the Tables, addidng some datas next 

/*General Approach*/

INSERT INTO EmployeeDemographics(EmployeeId,FirstName,LastName,Age,Gender)
values
(1001, 'Jim', 'Halpert', 30, 'Male'),
(1002, 'Pam', 'Beasley', 30, 'Female'),
(1003, 'Dwight', 'Schrute', 29, 'Male'),
(1004, 'Angela', 'Martin', 31, 'Female'),
(1005, 'Toby', 'Flenderson', 32, 'Male'),
(1006, 'Michael', 'Scott', 35, 'Male'),
(1007, 'Meredith', 'Palmer', 32, 'Female'),
(1008, 'Stanley', 'Hudson', 38, 'Male'),
(1009, 'Kevin', 'Malone', 31, 'Male')

--Checking The Updated Table
select * from EmployeeDemographics

/*Different Approach*/
INSERT INTO EmployeeSalary(EmployeeId,JobTitle,Salary,General_Id)
values (1001, 'Salesman', 45000,1),
(1002, 'Receptionist', 36000,2),
(1003, 'Salesman', 63000,3),
(1004, 'Accountant', 47000,4),
(1005, 'HR', 50000,5),
(1006, 'Regional Manager', 65000,6),
(1007, 'Supplier Relations', 41000,7),
(1008, 'Salesman', 48000,8),
(1009, 'Accountant', 42000,9),
(1009, ' Coustomer Service', 30000,9)

SELECT * from EmployeeSalary


--Joining TABLES and Using of Where Statement, 
--For say people with their full name whose salary is less than 45000 also is female and next where people have similar jobs and age is less than 35.

/* For say people with their full name whose salary is less than 45000 also is female*/

select dem.EmployeeId,FirstName+' '+LastName 'Full Name',JobTitle,Salary,Gender,
count(gender) over(partition by gender) TotalGender
from EmployeeSalary sal
inner join EmployeeDemographics dem
on sal.EmployeeId=dem.EmployeeId
where Salary <45000 and Gender = 'Female'


--USING ORDER BY, GROUP BY, HAVING CLAUSE,PARTITION BY

/*For people who have similar Jobs and under 35 years*/
select dem.EmployeeId,FirstName+' '+LastName 'Full Name', JobTitle 'Job Title',age 'Age',
count(Jobtitle) over (partition by Jobtitle) 'Total People with same Jobs' 
from EmployeeDemographics dem
join EmployeeSalary sal
on dem.EmployeeId = sal.EmployeeId
where age <= 35 
  

--More Simpler and Clear Approach

select Jobtitle, count(JobTitle) 'Total People with Job Description'
from EmployeeSalary sal
join EmployeeDemographics dem
on dem.EmployeeId = sal.EmployeeId
where age <= 35
group by JobTitle
order by count(Jobtitle) desc

--Or Just showing the Job having more than one people with the help of HAVING clause 

select Jobtitle, count(JobTitle) 'Total People with Job Description'
from EmployeeSalary sal
join EmployeeDemographics dem
on dem.EmployeeId = sal.EmployeeId
where age <= 35
group by JobTitle 
having count(jobtitle) >1
order by count(Jobtitle) desc

/*UNION syntax is a syntax that makes us join the two tables, gets rid of duplicates, like DISTINCT syntax and UNION ALL syntax takes all the duplicate datas aswell*/


--USING CASES 
/* Lets give the salary raise to SALESMAN because of the profit they made selling and also a but raise to the Supplier Relations and provided the updated Column*/

select Jobtitle,Salary,
Case 
when Jobtitle = 'Salesman' then Salary+(Salary*0.08)
when JobTitle = 'Supplier Relations' then Salary +(Salary*0.04)
else Salary
end 'Revised Salary'
From EmployeeSalary
Group By JobTitle , Salary
Order by Salary Desc

--Now Updating, Altering and Deleting datas in Table (Maintaining)

/* Lets say we need to change the name from Supplier Relations to just Supplier Relation */

SELECT * FROM EmployeeSalary

update EmployeeSalary
set JobTitle = 'Supplier Relation'
Where EmployeeId = 1007 


/* Deleting the row 10 i.e., Customer Service */

delete EmployeeSalary
where Id = 10

--CTE (Common Table Expression) like a subquery but only created in memory 

/* Creating The CTE that determines the Job, the total gender and whose average salary is less than 45000, also the use of partition by function */
 
 With CTE_Employee as
 (
 select JobTitle,FirstName +' '+LastName 'Full Name',Gender, Salary
 ,avg(salary) over (partition by gender) 'Average Salary'
 ,COUNT(Gender) over (partition by Gender) ' Total People of same Gender' 
 from SQLFUNDAMENTALS.dbo.EmployeeDemographics d
 full outer join SQLFUNDAMENTALS.dbo.EmployeeSalary s
 on d.EmployeeId=s.EmployeeId
 group by JobTitle,FirstName,LastName,Gender,Salary
 having avg(salary) < 45000
 )
 select JobTitle,[Full Name],[Average Salary],Gender
 from CTE_Employee

 --USING TEMP TABLES
 /*Creation and Insertion of DATA*/
 
 --BASIC

 CREATE TABLE #temp_Employee
 (
 EmployeeId int not null,
 JobTitle varchar(50),
 Salary int
 )

 select*
 from #temp_Employee

-- INSERT INTO #temp_Employee(Jobtitle) values ('Video Production Intern') 
--delete #temp_Employee 

/* We can also retrive the datas from other tables and use it in TEMP TABLES*/

--For Example 

INSERT INTO #temp_Employee
select EmployeeId,JobTitle,Salary
from EmployeeSalary

SELECT * FROM #temp_Employee
order by EmployeeId,Salary

/*More Technical Approach To Temp Table*/

DROP TABLE if exists #temp_EMP
CREATE TABLE #temp_EMP
(
JobTitle varchar(50),
EmployeesPerJob int,
AverageSalary float,
AverageAge float
)


INSERT INTO #temp_EMP
select JobTitle,count(JobTitle),Avg(Salary),Avg(Age)
from EmployeeDemographics dem join EmployeeSalary sal on dem.EmployeeId=sal.EmployeeId
group by JobTitle


SELECT * FROM #temp_EMP


/*Use of String Functions - TRIM, LTRIM, RTRIM, Replace, Substring, Upper, Lower */

--Drop Table EmployeeErrors;


CREATE TABLE EmployeeErrors (
EmployeeID varchar(50)
,FirstName varchar(50)
,LastName varchar(50)
)

Insert into EmployeeErrors Values 
('1001  ', 'Jimbo', 'Halbert'),
('  1002', 'Pamela', 'Beasely'),
('1005', 'TOby', 'Flenderson - Fired')

Select *
From EmployeeErrors

-- Using Trim, LTRIM, RTRIM

Select EmployeeID, TRIM(employeeID) AS IDTRIM
FROM EmployeeErrors 

Select EmployeeID, RTRIM(employeeID) as IDRTRIM
FROM EmployeeErrors 

Select EmployeeID, LTRIM(employeeID) as IDLTRIM
FROM EmployeeErrors 

	

-- Using Replace can also be used as nested i.e., Replace(Replace(),)

Select LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed
FROM EmployeeErrors


-- Using Substring

Select Substring(err.FirstName,1,3)'FIRST TABLE FIRST NAME', Substring(dem.FirstName,1,3)'SECOND TABLE FIRST NAME', 
       Substring(err.LastName,1,3)'FIRST TABLE LAST NAME', Substring(dem.LastName,1,3)'SECOND TABLE LAST NAME'
FROM EmployeeErrors err
JOIN EmployeeDemographics dem
	on Substring(err.FirstName,1,3) = Substring(dem.FirstName,1,3)
	and Substring(err.LastName,1,3) = Substring(dem.LastName,1,3)

--As it is not that reliable and thus called, "FUZZY MATCH",
--RESULTS can be more precise by the use of more data like GENDER,AGE,DATE OF BIRTH etc.  


-- Using UPPER and lower

Select firstname, LOWER(firstname) 'when lowered case'
from EmployeeErrors

Select Firstname, UPPER(FirstName) 'when uppered case'
from EmployeeErrors


/*USE of STORED PROCEDURES*/

--BASIC 
CREATE PROCEDURE TEST 
as
select *
from EmployeeDemographics

EXEC TEST


-- More TECHNICAL APPROACH using TEMP TABLE 

CREATE PROCEDURE TEST1 
as 
Drop Table if exists #temp_table 
Create TABLE #temp_table
(JobTitle varchar(255),
EmployeesPerJob int,
AverageSalary float,
AverageAge float
) 
INSERT INTO #temp_table
select JobTitle, Count(JobTitle), Avg(salary), Avg(Age)
from SQLFUNDAMENTALS.dbo.EmployeeDemographics d
join SQLFUNDAMENTALS.dbo.EmployeeSalary s
on d.EmployeeId=s.EmployeeId
group by JobTitle
select * from #temp_table

Exec TEST1 

--Altering or modifying the stored procedures can help to derive particular output, for example particular Jobtitle 

/* Modifing the stored procedure adding @Jobtitle nvarchar (255) and providing the condition where JobTitle = @JobTitle ,
-- Then We Can Execute the Stored Procedure as, */

EXEC TEST1 @JobTitle = 'Accountant'
EXEC TEST1 @JobTitle = 'Salesman' 


/*Subqueries (in the Select, From, and Where Statement)*/

Select EmployeeID, JobTitle, Salary
From EmployeeSalary

-- Subquery in Select

Select EmployeeID, Salary, (Select AVG(Salary) From EmployeeSalary) as AllAvgSalary
From EmployeeSalary

-- How to do it with Partition By
Select EmployeeID, Salary, AVG(Salary) over () as AllAvgSalary
From EmployeeSalary

-- Why Group By doesn't work
Select EmployeeID, Salary, AVG(Salary) as AllAvgSalary
From EmployeeSalary
Group By EmployeeID, Salary
order by EmployeeID


-- Subquery in From

Select a.EmployeeID, AllAvgSalary
From 
	(Select EmployeeID, Salary, AVG(Salary) over () as AllAvgSalary
	 From EmployeeSalary) a
Order by a.EmployeeID


-- Subquery in Where


Select EmployeeID, JobTitle, Salary
From EmployeeSalary
where EmployeeID in (
	Select EmployeeID 
	From EmployeeDemographics
	where Age > 30)