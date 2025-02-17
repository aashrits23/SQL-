
use AdventureWorks2022;

--- Q 1) find the average currency rate conversion from USD to Algerian Dinar and Australian Doller  

SELECT * FROM Sales.Currency        -- currency code , currency name
SELECT * FROM Sales.CurrencyRate    -- currency rate id, from currency code, to currency code, avg rate

SELECT 
       scr.FromCurrencyCode,
	   scr.ToCurrencyCode,
	   avg(scr.AverageRate)     
FROM Sales.Currency as sc,
Sales.CurrencyRate as scr
WHERE 
sc.currencycode = scr.ToCurrencyCode
and sc.name in ('Algerian Dinar','Australian Dollar')
GROUP BY scr.FromCurrencyCode,scr.ToCurrencyCode



--- Q 2) Find the products having offer on it and display product name , safety Stock Level, Listprice,  
--- and product model id, type of discount,  percentage of discount,  offer start date and offer end date

SELECT * FROM Production.Product               -- prod id, name, prod num,safety stock level, list price, prod model id
SELECT * FROM Sales.SpecialOffer               -- spe offer id, type discount, discount pct,start,end date
SELECT * FROM Sales.SpecialOfferProduct        -- spe offer id, prod id

SELECT 
      p.name,
	  p.ProductModelID,
	  p.ListPrice,
	  p.SafetyStockLevel,
	  so.type,
	  so.DiscountPct,
	  so.StartDate,
	  so.EndDate
FROM Production.Product as p,
Sales.SpecialOffer as so,
Sales.SpecialOfferProduct as sop
WHERE sop.SpecialOfferID = so.SpecialOfferID
and p.ProductID = sop.ProductID



--- Q 3) create  view to display Product name and Product review

SELECT * FROM Production.Product               -- prod id, name
SELECT * FROM Production.ProductReview         -- prod id, prod review id,comments

SELECT
      p.name,
	  pr.Comments
FROM Production.Product as p,
Production.ProductReview as pr
WHERE p.ProductID = pr.ProductID



--- Q 4) find out the vendor for product paint, Adjustable Race and blade

SELECT * FROM Production.Product               -- prod id, name
SELECT * FROM Purchasing.ProductVendor         -- prod id, business entity id
SELECT * FROM Purchasing.Vendor                -- business id,name

SELECT 
      p.name,
	  v.name as vendor_name
FROM 
Production.Product as p,
Purchasing.ProductVendor as pv,
Purchasing.Vendor as v
WHERE 
p.ProductID = pv.ProductID
and pv.BusinessEntityID = v.BusinessEntityID
and (p.name like ('%paint%')
or p.name = 'Adjustable Race'
or p.name = 'Blade')
GROUP BY p.name,v.name
order by name


--- Q 5) find product details shipped through ZY - EXPRESS 

SELECT * FROM Purchasing.ShipMethod          -- ship method id, name
SELECT * FROM Purchasing.PurchaseOrderHeader -- purchase order id, ship method id
SELECT * FROM Purchasing.PurchaseOrderDetail -- purchasec order id, prod id
SELECT * FROM Production.Product             -- prod id, name

SELECT 
      DISTINCT p.name,
	  sm.name as ship_through_name
FROM Purchasing.ShipMethod as sm,
Purchasing.PurchaseOrderHeader as poh,
Purchasing.PurchaseOrderDetail as pod,
Production.Product as p
WHERE sm.ShipMethodID = poh.ShipMethodID
and poh.PurchaseOrderID = pod.PurchaseOrderID
and pod.ProductID = p.ProductID
and sm.name = 'ZY - EXPRESS'

 
--- Q 6) find the tax amt for products where order date and ship date are on the same day 

SELECT * FROM Production.Product                --- prod id,name
SELECT * FROM Purchasing.PurchaseOrderHeader    --- purchase order id,ship method id, tax amt,order date,ship date
SELECT * FROM Sales.SalesOrderHeader            --- ship method id


SELECT 
      poh.shipdate,
	  soh.OrderDate,
	  poh.TaxAmt
FROM Sales.SalesOrderHeader as soh,

Purchasing.PurchaseOrderHeader as poh
WHERE poh.ShipMethodID = soh.ShipMethodID
and poh.shipdate = soh.OrderDate


--- Q 7) find the average days required to ship the product based on shipment type. 

select* from Purchasing.PurchaseOrderHeader
select* from Purchasing.ShipMethod

SELECT 
    poh.ShipMethodID,
    AVG(DATEDIFF(DAY, poh.OrderDate, poh.ShipDate)) AS avg_days_to_ship
FROM Purchasing.PurchaseOrderHeader poh
GROUP BY poh.ShipMethodID;


--- 8) find the name of employees working in day shift 

SELECT * FROM HumanResources.EmployeeDepartmentHistory     -- Business id, shift id.dept id
SELECT * FROM HumanResources.Shift						   -- shift id,name
SELECT * FROM Person.Person                                -- business entity id,firstname       


SELECT distinct p.FirstName,p.BusinessEntityID
FROM HumanResources.EmployeeDepartmentHistory as ed,
HumanResources.Shift as s,
Person.Person as p
WHERE ed.BusinessEntityID = p.BusinessEntityID
and ed.ShiftID = 1

--------------------------------------------------------

SELECT Firstname FROM Person.Person
WHERE BusinessEntityID in
(SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE ShiftId in
(SELECT ShiftID FROM HumanResources.shift
WHERE name = 'Day'))


--- Q 9) based on product and product cost history find the name , service provider time and average Standardcost   

SELECT * FROM Production.Product                -- prod id, name
SELECT * FROM Production.ProductCostHistory     -- prod id, start date,end date,std cost

SELECT 
      p.name,
	  avg(pc.StandardCost) avg_std_cost,
	  count(datediff(day,pc.StartDate,pc.EndDate)) Service_provided_time
FROM Production.Product as p,
Production.ProductCostHistory as pc
WHERE p.ProductID = pc.ProductID
GROUP BY p.name


--- Q 10) find products with average cost more than 500

SELECT * FROM Production.Product  

SELECT name,
       avg(Standardcost) as avg_cost
FROM Production.Product
GROUP BY name
Having avg(Standardcost) > 500


--- Q 11) find the employee who worked in multiple territory

SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesTerritoryHistory
SELECT * FROM Person.Person

SELECT p.BusinessEntityID,
       p.firstname,
       count(*)TerritoryID
FROM Sales.SalesTerritory as st,
Sales.SalesTerritoryHistory as sth,
Person.Person as p
WHERE
st.TerritoryID = sth.TerritoryID
and sth.BusinessEntityID = p.BusinessEntityID
GROUP BY p.BusinessEntityID,p.FirstName
HAVING count(*) > 1


--- Q 12) find out the Product model name,  product description for culture as Arabic 

SELECT * FROM Production.Product              
SELECT * FROM Production.ProductDescription
SELECT * FROM Production.ProductModelProductDescriptionCulture
SELECT * FROM Production.Culture

SELECT 
      p.name,
	  pd.Description
FROM Production.Product as p,
Production.ProductDescription as pd,
Production.Culture as c,
production.ProductModelProductDescriptionCulture as pdc
WHERE p.ProductModelID = pdc.ProductModelID
and pdc.ProductDescriptionID = pd.ProductDescriptionID
and pdc.CultureID = c.CultureID
and c.Name like '%arabic%'


-----------------------------------------------------------
--- Sub query

---13)Find first 20 employees who joined very early in the company

SELECT top 20 p.BusinessEntityID,p.FirstName,p.LastName,HireDate 
FROM HumanResources.Employee as e,
Person.Person as p
WHERE p.BusinessEntityID = e.BusinessEntityID
ORDER BY HireDate ;


--- 14)Find most trending product based on sales and purchase.
SELECT * FROM Purchasing.PurchaseOrderDetail
SELECT * FROM Sales.SalesOrderDetail

SELECT pod.ProductID
FROM Purchasing.PurchaseOrderDetail as pod
WHERE pod.ProductID in(SELECT sod.ProductID,sum(orderqty)
FROM Sales.SalesOrderDetail as sod
GROUP BY sod.ProductID)


--- Q 15) display EMP name, territory name, saleslastyear salesquota and bonus

SELECT * FROM Sales.SalesTerritory   --- teri id, teri name, group, Sales last year
SELECT * FROM Sales.SalesPerson      ---Business id , teri id , sales quota, bonus, Sales last year
SELECT * FROM HumanResources.Employee --- Business id
SELECT * FROM Person.Person           --- Business id, name
SELECT * FROM Sales.Customer          --- Cust id, teri id
SELECT * FROM Sales.SalesOrderDetail  --- sales id ,sale detail id
SELECT * FROM Sales.SalesTaxRate      --- sales tax rate id

SELECT 
       (SELECT firstname FROM Person.Person pp
	   WHERE pp.BusinessEntityID = sp.BusinessEntityID) Emp_name, 
       (SELECT [Group] FROM Sales.SalesTerritory st
	   WHERE st.TerritoryID = sp.TerritoryID)Territory_group,
	   (SELECT name FROM Sales.SalesTerritory st
	   WHERE st.TerritoryID = sp.TerritoryID)Territory_name,
SalesQuota,Bonus,SalesLastYear 
FROM Sales.SalesPerson sp;


--- Q 16) display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom 

SELECT
      (SELECT firstname FROM Person.Person pp
	   WHERE pp.BusinessEntityID = sp.BusinessEntityID) Emp_name,
	  (SELECT [Group] FROM Sales.SalesTerritory st
	   WHERE st.TerritoryID = sp.TerritoryID)Territory_group,
	  (SELECT name FROM Sales.SalesTerritory st
	   WHERE st.TerritoryID = sp.TerritoryID)Territory_name,	
SalesQuota,Bonus,SalesLastYear 
FROM Sales.SalesPerson sp
WHERE TerritoryID in
            (SELECT TerritoryID FROM Sales.SalesTerritory st
			WHERE Name = 'Germany' or Name = 'United Kingdom')


--- Q 17) Find all employees who worked in all North America territory 

SELECT * FROM Sales.SalesTerritory   --- teri id, teri name, group, Sales last year
SELECT * FROM Sales.SalesPerson      --- Business id , teri id , sales quota, bonus, Sales last year
SELECT * FROM Person.Person          --- Business id, name

SELECT
      (SELECT firstname FROM Person.Person pp
	  WHERE pp.BusinessEntityID = sp.BusinessEntityID) Emp_name,
	  (SELECT [Group] FROM Sales.SalesTerritory st
	  WHERE st.TerritoryID = sp.TerritoryID) 
FROM Sales.SalesPerson sp
WHERE TerritoryID IN
	       (SELECT TerritoryID FROM Sales.SalesTerritory st
	       WHERE [Group] = 'North America') 


--- 18) find all products in the cart 

SELECT * FROM Production.Product       --- productid , prod_name
SELECT * FROM Sales.ShoppingCartItem   -- Prod id

SELECT sc.*,
      (SELECT name FROM Production.Product pp
	   WHERE pp.ProductID = sc.ProductID)Product_name
FROM Sales.ShoppingCartItem sc


--- Q 19) find all the products with special offer 

select * from sales.SpecialOffer               --- spe offer id, 
select * from Purchasing.ShipMethod            --- ship method id , name
select * from Purchasing.ProductVendor         --- prod id, business id, min orde qty, max order qyt
select * from Purchasing.PurchaseOrderDetail   --- 
select * from Production.Product
select * from Sales.SpecialOfferProduct

SELECT sp.*,
     (SELECT ProductID FROM Sales.SpecialOffer so
	 WHERE so.SpecialOfferID=sp.SpecialOfferID) special_offer_product
	 FROM Sales.SpecialOfferProduct sp

SELECT 
	(SELECT name FROM Production.Product as p
	WHERE p.ProductID=so.ProductID) as prodname,
	(SELECT productnumber FROM Production.Product as p
	WHERE p.ProductID = so.ProductID) as prodnum
FROM sales.SpecialOfferProduct so ;


---20)find all employees name,job title, card details whose 
--credit card expired in the month 11 and year as 2008 

SELECT
    (SELECT concat_ws(' ',pp.FirstName,pp.LastName) FROM Person.person as pp
	WHERE pp.BusinessEntityID = pcc.BusinessEntityID) as fullname,
	(SELECT JobTitle FROM HumanResources.Employee as e
	WHERE e.BusinessEntityID = pcc.BusinessEntityID) as jobtitle,
	(SELECT concat_ws(' ',CardType,CardNumber) FROM Sales.CreditCard as cc
	WHERE cc.CreditCardID = pcc.CreditCardID) as cardnum
FROM Sales.PersonCreditCard as pcc;


--- Q 21) Find the employee whose payment might be revised  (Hint : Employee payment history) 

SELECT * FROM HumanResources.EmployeePayHistory            -- Business entity id

SELECT BusinessEntityID,
       count(*) as emp_paymend_revised
FROM HumanResources.EmployeePayHistory emh
GROUP BY BusinessEntityID
Having count(*) > 1 ;

--- person whose salary is not revised

SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID not in (SELECT BusinessEntityID
FROM HumanResources.EmployeePayHistory)


---22)Find total standard cost for the active Product. (Product cost history)

SELECT * FROM Production.ProductCostHistory;
SELECT * FROM Production.Product;

SELECT pch.ProductID,sum(pp.standardcost) as total_stdcost
FROM Production.ProductCostHistory as pch,
Production.Product as pp
WHERE pp.ProductID=pch.ProductID
GROUP BY pch.ProductID


------------------------- JOINS ----------------------------

--- Q 23) Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type) 

SELECT * FROM Person.Address                    -- add id, add line 1,city
SELECT * FROM Person.BusinessEntityAddress      -- business id,add id,add type id
SELECT * FROM Person.AddressType                -- add type id, name
SELECT * FROM Person.Person                     -- business id, first name

SELECT 
       p.FirstName,
       a.AddressLine1,
	   at.name as address_type
FROM Person.Address as a,
Person.BusinessEntityAddress as ba,
Person.AddressType as at,
Person.Person as p
WHERE a.AddressID = ba.AddressID
and ba.AddressTypeID = at.AddressTypeID
and ba.BusinessEntityID = p.BusinessEntityID 


 --- Q 24) Find the name of employees working in group of North America territory 

 SELECT * FROM HumanResources.Employee
 SELECT * FROM Sales.SalesTerritory
 SELECT * FROM Person.Person
 SELECT * FROM Sales.SalesTerritoryHistory

 SELECT 
        p.FirstName,
		s.[Group]
 FROM HumanResources.Employee as e,
 Sales.SalesTerritory as s,
 Person.Person as p,
 Sales.SalesTerritoryHistory as st
 WHERE e.BusinessEntityID = p.BusinessEntityID
 and p.BusinessEntityID = st.BusinessEntityID
 and st.TerritoryID = s.TerritoryID
 and [Group] = 'North America'


 --- Q 25) Find the employee whose payment is revised for more than once  

 SELECT * FROM HumanResources.EmployeePayHistory            -- Business entity id

SELECT BusinessEntityID,
       count(*) as emp_paymend_revised
FROM HumanResources.EmployeePayHistory emh
GROUP BY BusinessEntityID
Having count(*) > 1 ;


--- Q 26) display the personal details of  employee whose payment is revised for more than once.

 SELECT * FROM HumanResources.EmployeePayHistory            -- Business entity id
 SELECT * FROM Person.Person

SELECT p.firstname,
       p.BusinessEntityID,
       count(*) as emp_paymend_revised
FROM HumanResources.EmployeePayHistory as emh,
Person.Person as p
WHERE emh.BusinessEntityID = p.BusinessEntityID
GROUP BY p.BusinessEntityID,p.firstname
Having count(*) > 1 ;


---27) Which shelf is having maximum quantity (product inventory)

SELECT shelf,sum(quantity) as qt
FROM Production.ProductInventory
GROUP BY Shelf
ORDER BY qt desc;


---28)Which shelf is using maximum bin(product inventory)

SELECT shelf,sum(bin) as tot_bin
FROM Production.ProductInventory
GROUP BY Shelf
ORDER BY tot_bin desc;


---29)Which location is having minimum bin (product inventory)

SELECT * FROM Production.ProductInventory

SELECT LocationID,sum(bin) as tot_bin
FROM Production.ProductInventory
GROUP BY LocationID
ORDER BY tot_bin asc;


---30)Find out the product available in most of the locations (product inventory)

SELECT * FROM Production.ProductInventory

SELECT LocationID,sum(ProductID) as prod
FROM Production.ProductInventory
GROUP BY LocationID
ORDER BY prod desc;


---31)Which sales order is having most order quantity.

SELECT * FROM Sales.SalesOrderDetail

SELECT SalesOrderID,sum(orderqty) as tot_quant
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY tot_quant desc;


--- Q 32) check if any employee from jobcandidate table is having any payment revisions 

SELECT * FROM HumanResources.JobCandidate
SELECT * FROM HumanResources.EmployeePayHistory

SELECT jc.BusinessEntityID,
       count(*)emp_pament_revision
FROM HumanResources.JobCandidate as jc,
HumanResources.EmployeePayHistory as eph
WHERE jc.BusinessEntityID = eph.BusinessEntityID
GROUP BY jc.BusinessEntityID
HAVING count(*) > 0


--- Q 34) check the department having more salary revision 
  
SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeePayHistory
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT 
      d.name,
	  d.DepartmentID,
	  count(*) 
FROM HumanResources.Department as d,
HumanResources.EmployeePayHistory as eph,
HumanResources.EmployeeDepartmentHistory as edh
WHERE d.DepartmentID = edh.DepartmentID
and eph.BusinessEntityID = edh.BusinessEntityID
GROUP BY d.name,d.DepartmentID
Having count(*) > 0
ORDER BY count(*) DESC


--- Q 35) check the employee whose payment is not yet revised 

SELECT * FROM HumanResources.EmployeePayHistory
SELECT * FROM HumanResources.Employee

SELECT 
       e.BusinessEntityID,
	   count(*)
FROM HumanResources.EmployeePayHistory as eh,
HumanResources.Employee as e
WHERE eh.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID 
HAVING count(*) = 0


--- Q 36) find the job title having more revised payments

SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.EmployeePayHistory

---- USING INLINE

SELECT jobtitle,count(*) FROM
(SELECT e.JobTitle as jobTitle,
	   eph.BusinessEntityID as ID,
	   count(*) as cnt
FROM HumanResources.Employee as e,
HumanResources.EmployeePayHistory as eph
WHERE eph.BusinessEntityID = e.BusinessEntityID
GROUP BY e.JobTitle,eph.BusinessEntityID
HAVING count(*) > 1) as t
Group BY t.jobtitle
ORDER BY count(*) DESC

-----------------------------------------------------

--- subquery
SELECT JobTitle,count(*)
FROM HumanResources.Employee as e
WHERE e.BusinessEntityID in (SELECT eph.BusinessEntityID
      FROM HumanResources.EmployeePayHistory as eph
	  GROUP BY eph.BusinessEntityID
	  HAVING count(*) > 1)
GROUP BY e.JobTitle


--- Q 37) find the employee whose payment is revised in shortest duration (inline view) 

SELECT * FROM HumanResources.EmployeePayHistory eph
WHERE eph.BusinessEntityID = 4


select t2.businessEntityID, p.firstname,p.lastname,ratechangedate,
concat(year_,'.',month_,'years') as duration
from
(select t1.BusinessEntityID,t1.RateChangeDate,t1.rate_dense_rank,t1.Lagged,
datediff(month,Lagged,RateChangeDate)/12 as year_,
datediff(month,Lagged,RateChangeDate)%12 as month_
from
(select eph.RateChangeDate,eph.BusinessEntityID,
row_number()over(partition by businessentityid order by ratechangedate) as rate_dense_rank,
lag(RateChangeDate,1) over (Partition by BusinessEntityID order by ratechangedate) as Lagged
from HumanResources.EmployeePayHistory eph) as t1
where t1.rate_dense_rank > 1) as t2,PERSON.Person p
where p.BusinessEntityID=t2.BusinessEntityID
order by duration;


--- Q 38)  find the colour wise count of the product (tbl: product) 

SELECT * FROM Production.Product

SELECT 
p.name,
p.color,
count(*)
FROM Production.Product as p
WHERE color is not null
GROUP BY p.color,p.name
ORDER BY count(*) DESC;


--- Q 39) find out the product who are not in position to sell (hint: check the sell start and end date) 

SELECT p.name,
       p.ProductID,
       p.SellStartDate,
	   p.SellEndDate 
FROM Production.Product p
WHERE p.SellEndDate IS NOT NULL


--- Q 40) find the class wise, style wise average standard cost

SELECT * FROM Production.Product 

SELECT p.Class,
       p.Style,
	   avg(p.StandardCost)
FROM Production.Product p
WHERE p.style is not null or p.class is not null
GROUP BY p.Class,p.Style


--- Q 41) check colour wise standard cost 

SELECT * FROM Production.Product

SELECT p.color,
       sum(p.StandardCost)
FROM Production.Product as p
WHERE p.Color is not NULL
GROUP BY p.color


--- Q 42) find the product line wise standard cost 

SELECT 
      p.ProductLine,
      sum(p.StandardCost) Standard_cost
FROM Production.Product p
WHERE p.ProductLine is not null
GROUP BY p.ProductLine


--- Q 43) Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 

SELECT * FROM Sales.SalesTaxRate
SELECT * FROM Person.StateProvince

SELECT
      st.StateProvinceID,
	  sp.name,
	  sum(st.TaxRate)
FROM Sales.SalesTaxRate as st,
Person.StateProvince as sp
WHERE st.StateProvinceID = sp.StateProvinceID
GROUP BY st.StateProvinceID,sp.name  


--- Q 44) Find the department wise count of employees 

SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory


SELECT 
      d.name,
	  count(*) dept_wise_count
FROM HumanResources.Department as d,
HumanResources.EmployeeDepartmentHistory as ed
WHERE d.DepartmentID = ed.DepartmentID
GROUP BY d.name 
ORDER BY count(*) DESC


--- Q 45) Find the department which is having more employee

SELECT 
      top(1) d.name,
	  count(*) dept_wise_count
FROM HumanResources.Department as d,
HumanResources.EmployeeDepartmentHistory as ed
WHERE d.DepartmentID = ed.DepartmentID
GROUP BY d.name 
ORDER BY count(*) DESC


--- Q 46) Find the job title having more employees 

SELECT 
       e.JobTitle,
	   count(e.BusinessEntityID) as count
FROM HumanResources.Employee e
GROUP BY e.JobTitle
ORDER BY count(e.BusinessEntityID) DESC;


SELECT 
      top(1)e.JobTitle,
	   count(e.BusinessEntityID) as count
FROM HumanResources.Employee e
GROUP BY e.JobTitle
ORDER BY count(e.BusinessEntityID) DESC;


--- Q 47 Check if there is mass hiring of employees on single day 

SELECT * FROM HumanResources.JobCandidate
SELECT * FROM HumanResources.Employee

SELECT 
       e.HireDate,
	   count(e.BusinessEntityID) count_of_employee
FROM HumanResources.Employee as e
GROUP BY e.HireDate
-- HAVING count(e.BusinessEntityID) > 1
ORDER BY count(e.BusinessEntityID) DESC;


---48)	Which product is purchased more? (purchase order details)

SELECT * FROM Purchasing.PurchaseOrderDetail;
SELECT * FROM Production.Product;

SELECT distinct top 1 pod.ProductID,pp.Name,
sum(pod.OrderQty) OVER (partition by pod.ProductID) as total_orderqty
FROM Purchasing.PurchaseOrderDetail as pod,
Production.Product as pp
WHERE pp.ProductID = pod.ProductID
ORDER BY total_orderqty desc;


---49)	Find the territory wise customers count   (hint: customer)
---select * from Sales.SalesTerritory

SELECT * FROM Sales.SalesTerritoryHistory
SELECT * FROM Sales.Customer

SELECT distinct territoryid,
count(CustomerID) OVER (partition by territoryid) as cust_cnt
FROM Sales.Customer;


---50)	Which territory is having more customers (hint: customer)

SELECT distinct top 1 territoryid,
count(CustomerID) OVER (partition by territoryid) as cust_cnt
FROM Sales.Customer
ORDER BY cust_cnt desc


--51.	Which territory is having more stores (hint: customer)

SELECT * FROM Sales.Customer

SELECT distinct top 1 territoryid,
count(StoreID) OVER (partition by territoryid) as store_cnt
FROM Sales.Customer
ORDER BY store_cnt desc


--52. Is there any person having more than one credit card (hint: PersonCreditCard)

SELECT * FROM Sales.PersonCreditCard;

SELECT BusinessEntityID,count(Creditcardid)
FROM Sales.PersonCreditCard
GROUP BY BusinessEntityID
HAVING count(Creditcardid) > 1;
--there is no person having more than one credit card


--53.	Find the product wise sale price (sales order details)

SELECT * FROM Sales.SalesOrderDetail;

SELECT distinct ProductID,
sum(UnitPrice) OVER (partition by productid) as salesprice
FROM Sales.SalesOrderDetail


--54.	Find the total values for line total product having maximum order

SELECT * FROM Sales.SalesOrderDetail

SELECT distinct linetotal,
sum(OrderQty) OVER (partition by linetotal) as ord
FROM Sales.SalesOrderDetail
ORDER BY ord desc


----------------- Date queries ----------------------

--55.	Calculate the age of employees

SELECT BusinessEntityID,
DATEDIFF(year,BirthDate,HireDate) as age
FROM HumanResources.Employee;


--56.	Calculate the year of experience of the employee based on hire date

SELECT BusinessEntityID,
sum(DATEDIFF(year,StartDate,EndDate)) as tot_yrs_exp
FROM HumanResources.EmployeeDepartmentHistory
GROUP BY BusinessEntityID
HAVING sum(DATEDIFF(year,StartDate,EndDate)) is not null


--57.	Find the age of employee at the time of joining

SELECT e.BusinessEntityID,
DATEDIFF(year,e.BirthDate,edh.StartDate) currentage
FROM HumanResources.EmployeeDepartmentHistory as edh,
HumanResources.Employee as e
WHERE edh.BusinessEntityID = e. BusinessEntityID


--58.	Find the average age of male and female

SELECT gender,
avg(DATEDIFF(year,BirthDate,HireDate)) as avg_age
FROM HumanResources.Employee
GROUP BY Gender;


--59.	 Which product is the oldest product as on the date (refer  the product sell start date)

SELECT ProductID,Name,SellStartDate 
FROM Production.Product
ORDER BY SellStartDate;


--60.Display the product name, standard cost, 
--and time duration for the same cost. (Product cost history)

SELECT * FROM Production.ProductCostHistory
SELECT * FROM Production.Product

SELECT p.Name,p.StandardCost,pch.startdate,pch.enddate,
DATEDIFF(YEAR,pch.StartDate,pch.EndDate) as timeduration
FROM Production.ProductCostHistory as pch
join Production.Product as p
on p.ProductID = pch.ProductID
WHERE pch.enddate is not null
ORDER BY p.Name,p.StandardCost


---61.	Find the purchase id where shipment is done 1 month later of order date  

SELECT distinct PurchaseOrderID,
datediff(month,OrderDate,ShipDate) dt
FROM Purchasing.PurchaseOrderHeader
WHERE datediff(month,OrderDate,ShipDate) = 1 


---62.	Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

SELECT PurchaseOrderID,sum(TotalDue) as sumtot
FROM Purchasing.PurchaseOrderHeader
WHERE datediff(month,OrderDate,ShipDate) = 1
GROUP BY PurchaseOrderID


---63.	 Find the average difference in due date and ship date 
--based on  online order flag

SELECT * FROM sales.SalesOrderHeader

SELECT avg(datediff(day ,ShipDate,DueDate)) as avg_due_ship_diff , 
       OnlineOrderFlag
FROM sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;


------------------WINDOWS FUNCTION ---------------------

--- 64. Display business entity id, marital status, gender, vacationhr, 
--- average vacation based on marital status

SELECT * FROM HumanResources.Employee;

SELECT e.BusinessEntityID,e.MaritalStatus,e.Gender,e.VacationHours,
       avg(e.VacationHours) OVER (partition by e.MaritalStatus) avg_vacation_based_on_marritalStatus
FROM HumanResources.Employee e;

--- 65. Display business entity id, marital status, gender, vacationhr, 
--- average vacation based on gender

SELECT e.BusinessEntityID,e.MaritalStatus,e.Gender,e.VacationHours,
       avg(e.VacationHours) OVER (partition by e.Gender) avg_vacation_based_on_marritalStatus
FROM HumanResources.Employee e;

--- 66. Display business entity id, marital status, gender, vacationhr, 
--- average vacation based on organizational level

SELECT e.BusinessEntityID,e.MaritalStatus,e.Gender,e.VacationHours,e.OrganizationLevel,
       avg(e.VacationHours) OVER (partition by e.OrganizationLevel) avg_vacation_based_on_marritalStatus
FROM HumanResources.Employee e;

--- 67. Display entity id, hire date, department name 
--- and department wise count of employee 
--- and count based on organizational level in each dept

SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT e.BusinessEntityID,d.Name,e.HireDate,
       count(e.BusinessEntityID) OVER (partition by d.Name)dept_wise_cnt_employee,
	   count(e.OrganizationLevel) OVER (partition by d.Name) orgLevel_wise_cnt_employee
FROM HumanResources.Employee as e,
HumanResources.Department as d,
HumanResources.EmployeeDepartmentHistory as edh
WHERE e.BusinessEntityID = edh.BusinessEntityID
and d.DepartmentID = edh.DepartmentID


---68.	Display department name, average sick leave and sick leave per department

SELECT d.Name AS DepartmentName ,
       avg( e.SickLeaveHours) over (partition by d.departmentid) sickleaves ,
       sum( e.SickLeaveHours) over ( partition by d.DepartmentID) avg_sick_leaves
FROM  HumanResources.Employee e
join HumanResources.EmployeeDepartmentHistory h
on h.BusinessEntityID=e.BusinessEntityID
join HumanResources.Department d
on h.DepartmentID= d.DepartmentID  


---69.	Display the employee details first name, last name,  with total count of various shift done by the person and shifts count per department

SELECT CONCAT_WS(' ',p.firstname, p.lastname),
       h.shiftid, d.name d_name, s.name shift_name,
	   count(s.ShiftID) OVER (partition by d.name) dpt_count
FROM Person.Person p
join  HumanResources.EmployeeDepartmentHistory h
on p.BusinessEntityID = h.BusinessEntityID
join HumanResources.Department d
on d.DepartmentID = h.DepartmentID
join HumanResources.Shift s
on s.shiftid = h.shiftid 


---70.	Display country region code, group average sales quota based on territory id

SELECT  distinct(t.TerritoryID),
        t.CountryRegionCode ,
        t.[Group],
		avg(p.SalesQuota) OVER (partition by p.territoryId)
FROM sales.SalesPerson p
join  Sales.SalesTerritory t
on t.TerritoryID = p.TerritoryID


---71.	Display special offer description, category and avg(discount pct) per the category

SELECT s.[description],
       s.Category,s.DiscountPct,
       avg(s.discountpct) OVER (partition by s.category) avg_disc_per_cat
FROM sales.SpecialOffer s


---72.	Display special offer description, category and avg(discount pct) per the month

SELECT s.[description],
       s.Category,s.DiscountPct,s.startdate,
       avg(s.discountpct) OVER (partition by MONTH(startdate)) avg_disc_per_month
FROM  sales.SpecialOffer s


---73.	Display special offer description, category and avg(discount pct) per the year

SELECT s.[description],
       s.Category,
	   s.DiscountPct,s.startdate,
       avg(s.discountpct) over (partition by year(startdate)) avg_disc_per_yr
FROM  sales.SpecialOffer s


---74.	Display special offer description, category and avg(discount pct) per the type

SELECT s.[description],
       s.Category,
	   s.DiscountPct,
	   s.[type],
       avg(s.discountpct) over (partition by s.[type]) avg_disc_per_month
FROM  sales.SpecialOffer s;


---75.	Using rank and dense rand find territory wise top sales person

SELECT p.firstname,sth.TerritoryID,
sum(p.FirstName) OVER (partition by sth.territoryid),
rank() OVER (order by p.FirstName) as rankper,
dense_rank() OVER (order by p.FirstName) as denserankper
FROM Sales.SalesTerritoryHistory as sth,
Sales.SalesPerson as sp,
Person.Person as p
WHERE sp.BusinessEntityID = sth.BusinessEntityID
and p.BusinessEntityID = sp.BusinessEntityID