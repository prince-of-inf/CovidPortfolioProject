-- standardize date format: varchar->datetime
SELECT SaleDate, CONVERT(SaleDate, Date)
from housing_data hd;

CREATE TEMPORARY TABLE month_lookup (
    month_name VARCHAR(20),
    month_number INT
);

INSERT INTO month_lookup VALUES
    ('January', 1),
    ('February', 2),
    ('March', 3),
    ('April', 4),
    ('May', 5),
    ('June', 6),
    ('July', 7),
    ('August', 8),
    ('September', 9),
    ('October', 10),
    ('November', 11),
    ('December', 12);
   
  SELECT *
  from month_lookup
 
 -- print corrected dates
 select UniqueID, SaleDate,
 DATE(CONCAT(
        SUBSTRING_INDEX(SaleDate , ' ', -1),  -- Year
        '-',
        (SELECT month_number FROM month_lookup 
         WHERE month_name = SUBSTRING_INDEX(SaleDate, ' ', 1)),  -- Month
        '-',
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, ' ', -2), ',', 1))  -- Day
    )) AS converted_date
FROM
    housing_data hd ;
 
-- alter tables
ALTER TABLE housing_data  ADD SaleDateConverted DATE;  -- Adding a new DATE column

UPDATE housing_data
SET SaleDateConverted = (
    DATE(CONCAT(
        SUBSTRING_INDEX(SaleDate, ' ', -1),  -- Year
        '-',
        (SELECT month_number FROM month_lookup 
         WHERE month_name = SUBSTRING_INDEX(SaleDate, ' ', 1)),  -- Month
        '-',
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, ' ', -2), ',', 1))  -- Day
    ))
);

SELECT SaleDateConverted
from housing_data hd;

-- Set NULL in empty cells
update housing_data 
set PropertyAddress  = NULLIF(PropertyAddress, '');

-- -----------
-- ADDRESS
-- fill propertyAdress where ParcelID is same as in other stated Address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress) 
from housing_data a
join housing_data b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is NULL

update housing_data a
set a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
join housing_data b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is NULL

-- find unique non_null addresses
SELECT ParcelID, MAX(PropertyAddress) as non_null_address 
from housing_data hd 
group by ParcelID 

-- update by subquery
UPDATE housing_data hd
inner join (
select ParcelID, MAX(PropertyAddress) as non_null_address
from housing_data 
group by ParcelID 
) as sub
on hd.ParcelID = sub.ParcelID
set hd.PropertyAddress = sub.non_null_address
WHERE hd.PropertyAddress is null;

-- empty
SELECT PropertyAddress 
from housing_data hd 
WHERE PropertyAddress is NULL;

SELECT PropertyAddress 
from housing_data hd 

-- -----------
-- ADDRESS
-- break address into 3 columns (other dbms have SPLIT)
-- TRIM(SUBSTRING(without_1_word, LENGTH(TRIM(SUBSTRING_INDEX(without_1_word, ' ', -1))) + 1)) AS without_2_word -- delete last element
-- in sql server this can be easily done with parsename
SELECT 
PropertyAddress,
TRIM(SUBSTRING_INDEX(PropertyAddress, ' ', 1)) as postal_code, -- split by ' ' take first element
TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)) as city, -- split by ' ' take last element
TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(PropertyAddress, ' ', -4)), ',', 1)) as street -- split by ' ' and , take middle element
from housing_data hd;

-- alter tables
ALTER TABLE housing_data  ADD 
Property_address_code varchar(50);

ALTER TABLE housing_data  ADD 
Property_address_city varchar(50);

ALTER TABLE housing_data  ADD 
Property_address_street varchar(50);

UPDATE housing_data
SET Property_address_code = (
TRIM(SUBSTRING_INDEX(PropertyAddress, ' ', 1))-- split by ' ' take first element
);

UPDATE housing_data
SET Property_address_city = (
TRIM(SUBSTRING_INDEX(PropertyAddress, ' ', -1))-- split by ' ' take first element
);

UPDATE housing_data
SET Property_address_street = (
TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(PropertyAddress, ' ', -4)), ',', 1)) -- split by ' ' take first element
);

-- --------
-- Standarize SoldAs Vacant
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
from housing_data hd 
Group by SoldAsVacant

SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'N' THEN 'No'  -- Compare with '=' for exact match
        WHEN SoldAsVacant = 'Y' THEN 'Yes' -- Compare with '=' for exact match
        ELSE SoldAsVacant  -- Default case if no match is found
    END AS SoldAsVacant_Description
FROM 
    housing_data hd;
   
UPDATE housing_data 
set SoldAsVacant = 
CASE 
        WHEN SoldAsVacant = 'N' THEN 'No'  -- Compare with '=' for exact match
        WHEN SoldAsVacant = 'Y' THEN 'Yes' -- Compare with '=' for exact match
        ELSE SoldAsVacant  -- Default case if no match is found
    END;

-- remove duplicates
  
 
-- -----------
-- OWNER NAME
-- where null - set "NO NAME SPECIFIED"
   
 -- Row numbering
  -- Add an AUTO_INCREMENT column to an existing table
ALTER TABLE housing_data
ADD COLUMN row_num INT AUTO_INCREMENT PRIMARY KEY FIRST; 
 
-- Delete duplicates, keeping the row with the smallest id
DELETE FROM housing_data
WHERE 
    row_num NOT IN (
        SELECT 
            MIN(row_num)  -- Keep the row with the smallest id
        FROM 
            housing_data
        GROUP BY UniqueID -- and other probably repeated values
    );
  
SELECT
	* 
FROM 
    housing_data hd
    order by UniqueID ;
    
alter table housing_data 
drop column row_num;



-- SELECT
--     *, ROW_NUMBER() OVER (ORDER BY UniqueID) AS row_num 
-- FROM 
--     housing_data hd;
--    
--  delete t1 from housing_data t1
--  inner join housing_data t2
--  WHERE 
--  
-- 
-- SELECT *
-- from housing_data hd;
-- 
-- select UniqueID, COUNT(*)
-- from housing_data hd
-- group by UniqueID ;
-- 
-- select UniqueID, COUNT(*) as count
-- from housing_data hd
-- group by UniqueID 
-- HAVING count >1;
-- 
-- ALTER TABLE housing_data  ADD 
-- rn numeric;
-- 
-- INSERT into housing_data (rn)
-- select 
-- row_number() over (partition by UniqueID ORDER by UniqueID) as rn
-- from housing_data hd 
-- ORDER by UniqueID;
-- 
-- select 
-- row_number() over (partition by UniqueID ORDER by UniqueID) as rn
-- from housing_data hd 
-- ORDER by UniqueID;

-- alter table housing_data 
-- drop column rn;
-- 
-- DELETE from housing_data WHERE UniqueID is NULL;
