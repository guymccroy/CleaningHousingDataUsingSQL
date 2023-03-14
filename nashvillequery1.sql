--Selecting all columns to take am initial look at the table.
SELECT *
FROM nashville_housing_data.dbo.nashville_housing_data

--Adding a column to table, SaleDateConverted in DATE format
ALTER TABLE nashville_housing_data.dbo.nashville_housing_data
ADD SaleDateConverted Date;

--Updating table and converting new column SaleDateConverting into 
--DATE format from SaleDate column
UPDATE nashville_housing_data.dbo.nashville_housing_data
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Looking at converted column, looks fine, 
SELECT SaleDateConverted
FROM nashville_housing_data.dbo.nashville_housing_data

--This query is selecting the parcel and property address from the table, 
--and joining the table with itself with a special request. 
--The request is to join the tables on ParcelID and swap the data from 
--columns where the values are UniqueID
--We are aiming at getting rid of NULL values in the columns.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing_data.dbo.nashville_housing_data a
JOIN nashville_housing_data.dbo.nashville_housing_data b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
-- WHERE a.PropertyAddress IS NULL
--Use ^ line to test if the NULL values were removed after 
--executing the below query, 

--Updating the table
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing_data.dbo.nashville_housing_data a
JOIN nashville_housing_data.dbo.nashville_housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Checking our tables and cleaning progress
SELECT *
FROM nashville_housing_data.dbo.nashville_housing_data


--Seperating columns containing addresses into
--individual columns address - city - state
--                                                      this -1 removes the 
--                                                      delimitter, the ","
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertyStreet
FROM nashville_housing_data.dbo.nashville_housing_data

--Adding column PropertyStreet because it looks like our SUBSTRING() is working
ALTER TABLE nashville_housing_data.dbo.nashville_housing_data
ADD PropertyStreet NVARCHAR(255);

--Updating table to add PropertyStreet
UPDATE nashville_housing_data.dbo.nashville_housing_data
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--Checking the updates on the columns
SELECT *
FROM nashville_housing_data.dbo.nashville_housing_data

------Now we do the same thing for adding a city column
SELECT 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertyCity
FROM nashville_housing_data.dbo.nashville_housing_data

--Adding column PropertyCity because it looks like our SUBSTRING() is working
ALTER TABLE nashville_housing_data.dbo.nashville_housing_data
ADD PropertyCity NVARCHAR(255);

--Updating table to add PropertyCity
UPDATE nashville_housing_data.dbo.nashville_housing_data
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--looks good so far
SELECT *
FROM nashville_housing_data.dbo.nashville_housing_data

--Cleaning up Sold as vacant values, N to No & Y to Yes.
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM nashville_housing_data.dbo.nashville_housing_data

--Updating existing Column in table using UDATE & SET.
UPDATE nashville_housing_data.dbo.nashville_housing_data
 SET SoldAsVacant = CASE 
     WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Deleting Duplicate Rows.
--Creating a Temp Table to Filter out Duplicates.
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress, 
			 SalePrice, 
			 SaleDate, 
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM nashville_housing_data.dbo.nashville_housing_data
)

DELETE
-- Removed SELECT * for DELETE because we found the duplicates.
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress.

--Removing Columns we Don't Want.
SELECT * 
FROM nashville_housing_data.dbo.nashville_housing_data

--Altering the table to drop unwanted columns. 
ALTER TABLE nashville_housing_data.dbo.nashville_housing_data
DROP COLUMN PropertyAddress, 
	        OwnerAddress, 
			TaxDistrict, 
			SaleDate

--Table looks much better than when we downloaded it. 
SELECT * 
FROM nashville_housing_data.dbo.nashville_housing_data

