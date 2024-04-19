create database Employee_Data;

use Employee_Data;

#imported table and ER diagram

select * from employee_data;
select * from training;
select * from Survey_data;
#Question1
#What is the gender distribution among employees in the company?

#To get count
select GenderCode,count(GenderCode) as Gender_count from employee_data group by GenderCode;

#To get percentage
select GenderCode,count(*) * 100.0/ (select count(*) from employee_data) as percentage from employee_data group by GenderCode;

#Question2
#What is the Dept count among employees in the company?
select DepartmentType,count(*) as Employee_Count from employee_data group by DepartmentType;

#Question3
#Training Program Popularity:
#Which training program has been attended by the most employees?
select count(EmployeeID),TrainingProgram from training group by TrainingProgram 
order by count(EmployeeID) desc limit 1;

#Question4
#Exit Reasons:
#What are the most common reasons for employee termination?
select count(EmpID),TerminationType from employee_data group by TerminationType;

#Question4
#Top Rated Employees and their JD and Training Program they attended
select e.EmpID,e.JobFunctionDescription,e.CurrentEmployeeRating,t.TrainingProgram from employee_data e 
left join training t on e.EmpID=t.EmployeeID 
where CurrentEmployeeRating=5;

#Question5
#Distribution of Employees by TrainingOutcome
select TrainingOutcome,count(EmployeeID) as count,count(*) * 100.0/(select count(*) from training) as percentage
from training group by TrainingOutcome;

#Question6
#Which training program costs the most on average?
select TrainingProgram,avg(TrainingCost) from training 
group by TrainingProgram
order by avg(TrainingCost) desc;

#Question7
#Count of TrainingOutcome
select count(EmployeeID) as count_,TrainingOutcome from training
group by TrainingOutcome;

#Question8
#EmployeeID and their Satisfaction Score and job type
select e.EmpID,e.JobFunctionDescription,s.SatisfactionScore from employee_data e
right join Survey_data s on e.EmpID=s.EmployeeID;

#create view
#empid,concat name,jobtype,currentrating,trainingprogram,trainingoutcome
create view Employee as
select e.EmpID,concat(e.FirstName,' ',e.LastName) as FullName,e.DepartmentType,e.CurrentEmployeeRating,
t.TrainingProgram,t.TrainingOutcome,t.TrainingCost from employee_data e
right join training t on e.EmpID=t.EmployeeID;

select * from Employee;

#Stored Procedure
#To get the Training Outcome from EmpID
delimiter //
create procedure GetTrainingOutcome(IN ID int)
begin
     select TrainingOutcome from training where EmployeeID=ID;
end //
delimiter ;

call GetTrainingOutcome(1001);

#Windows
#Top Rated Employees in each department
WITH cte AS
(
   SELECT concat(FirstName,' ',LastName) as FullName , DepartmentType,CurrentEmployeeRating,
         dense_rank() OVER (PARTITION BY DepartmentType ORDER BY CurrentEmployeeRating DESC) AS TopEmp
   FROM employee_data
)
SELECT *
FROM cte
WHERE TopEmp = 1;

# get all the area sales manager
select Concat(FirstName,' ',LastName) as FullName,Title from employee_data
where Title='Area Sales Manager';

#what is the avg of training cost accross Different Locations
select distinct Location,TrainingProgram,
avg(TrainingCost) as avgCost from training
group by Location,TrainingProgram
order by TrainingProgram,avg(TrainingCost) desc;

#Case
#TrainingProgram completed Employees are marked as Trained else not trained
with TrainingStatus as
( select *, case 
    when TrainingOutcome = 'Completed' then "Trained"
    when TrainingOutcome = 'Passed' then "Trained"
    else "Not Trained"
end as TrainingStatus 
from training) select * from TrainingStatus;

#get all the employees whose performance score is low and check whether they completed training program and their job type
WITH low_employee AS (
    SELECT e.EmpID,CONCAT(e.FirstName, ' ', e.LastName) AS FullName,e.PerformanceScore,e.JobFunctionDescription,t.TrainingOutcome,
        CASE 
            WHEN t.TrainingOutcome = 'Completed' THEN 'Trained'
            WHEN t.TrainingOutcome = 'Passed' THEN 'Trained'
            ELSE 'Not Trained'
        END AS TrainingStatus
    FROM employee_data e
    RIGHT JOIN training t ON e.EmpID = t.EmployeeID 
    WHERE e.PerformanceScore = 'Needs Improvement')SELECT * FROM low_employee;
    









