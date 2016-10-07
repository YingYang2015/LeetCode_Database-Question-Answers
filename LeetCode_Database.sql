## Leetcode

## Question: Combine two tables
SELECT p.FirstName, p.LastName, a.City, a.State 
FROM Person p 
LEFT JOIN Address a 
ON p.PersonId = a.PersonId

## Question: select the second highest Salary
select max(Salary) As SecondHighestSalary
from Employee 
where Salary < (select max(Salary) from Employee)

## Questin: Employee earning more than their managers
select E1.name as Employee
from Employee E1
where E1.salary > (select E2.salary from Employee E2 where E2.ID = E1.ManagerID)
# alternative
select E1.Name as Employee
from Employee E1 join Employee E2
on E1.ManagerID = E2.ID and E1.Salary>E2.Salary
 
## Duplicate Emails 
select Distinct P1.Email
from Person P1 inner join Person P2
on P1.Email = P2.Email and P1.ID <> P2.ID

## Customers never order
select Name as Customers
from Customers
where Id not in
(select CustomerId from Orders);

# Delete Duplicate Emails
DELETE FROM Person 
WHERE id IN (
  SELECT id FROM (
    SELECT a.id 
    FROM Person a INNER JOIN Person b Using(email)
    WHERE a.id>b.id
  ) c
)
# alternative
delete from Person
where Id not in 
	(select Id 
	from (select min(Id) as Id
          from Person 
          group by Email) a);
          
## Rising Temperature
select w2.Id as Id
from Weather w1 join Weather w2
on TO_DAYS(w1.Date) + 1 = TO_DAYS(w2.Date)
where w1.Temperature < w2.Temperature

# Nth Highest Salary  
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
     select distinct E.salary
     from Employee E, (select Salary, @row_num := @row_num + 1 as Rank 
                        from (select salary from Employee group by Salary Desc) t1
                        join
                        (select @row_num := 0 from dual) t2 ) as t
     where E.salary = t.Salary and t.Rank = N
  );
END


#  Rank scores
SELECT t.Score, t.Rank 
FROM (SELECT Score, @prev := @curr, @curr := Score, @rank := IF(@prev = @curr, @rank, @rank + 1) AS Rank
      FROM Scores, (SELECT @curr := null, @prev := null, @rank := 0) as sel1 
      ORDER BY Score DESC) t;
      
# or       
select s.Score, t.Rank 
from (
    select @row_num:=@row_num+1 Rank, Score 
    from (
         select Score 
         from Scores 
         group by Score desc
         ) t1 
    join (
         select @row_num := 0 from dual
         ) t2
) t, Scores s 
where s.Score=t.Score 
order by Score desc, Rank asc, Id;      

# consecutive numbers 
select distinct l1.Num as ConsecutiveNums
from Logs l1, Logs l2, Logs l3
where l1.ID + 1 = l2.ID and l2.ID + 1 = l3.ID and
      l1.Num = l2.Num and l2.Num = l3.Num
      
# department highest salary_dataselect D.Name as Department, E.Name as Employee, E.Salary
select D.Name as Department, E.Name as Employee, E.Salary
from Department D, Employee E
where D.ID = E.DepartmentID and E.DepartmentID in (
                                select DepartmentID 
                                from Employee 
                                group by DepartmentID 
                                having Salary = max(Salary))

# department top 3 salaries
select d.Name Department, e1.Name Employee, e1.Salary
from Employee e1 
join Department d
on e1.DepartmentId = d.Id
where 3 > (select count(distinct(e2.Salary)) 
                  from Employee e2 
                  where e2.Salary > e1.Salary 
                  and e1.DepartmentId = e2.DepartmentId
                  );
                  
# Trips and Uswers
SELECT Request_at as Day,
       ROUND(COUNT(IF(Status != 'completed', TRUE, NULL)) / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE (Request_at BETWEEN '2013-10-01' AND '2013-10-03')
      AND Client_id NOT IN (SELECT Users_Id FROM Users WHERE Banned = 'Yes')
GROUP BY Request_at;
                  