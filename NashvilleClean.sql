-- DATA CLEANING
-- 1. Populate Property Address Data
SELECT *
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID
    , a.PropertyAddress
    , b.ParcelID
    , b.PropertyAddress
    , ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] a
JOIN [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning] b
    ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- 2. Break out 'PropertyAddress' into individual columns for Address, City, State using Substring method
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

-- Step I
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
    , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

-- Step II Create New Tables
Alter TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress NVARCHAR(255)

Alter TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
Add PropertySplitCity NVARCHAR(255)

-- Step III Update Main Table
UPDATE [Nashville Housing Data for Data Cleaning]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE [Nashville Housing Data for Data Cleaning]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

-- 3. Break out 'OwnerAddress' into individual columns for Address, City, State using Parse method
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

Alter TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress NVARCHAR(255)

Alter TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity NVARCHAR(255)

Alter TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
Add OwnerSplitState NVARCHAR(255)

UPDATE [Nashville Housing Data for Data Cleaning]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE [Nashville Housing Data for Data Cleaning]
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE [Nashville Housing Data for Data Cleaning]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

-- 4. Change Y & N to Yes & No
SELECT DISTINCT (SoldAsVacant)
    , COUNT(SoldAsVacant)
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
    , CASE 
        WHEN soldasvacant = 'Y'
            THEN 'Yes'
        WHEN SoldAsVacant = 'N'
            THEN 'No'
        ELSE SoldAsVacant
        END
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

UPDATE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE 
        WHEN soldasvacant = 'Y'
            THEN 'Yes'
        WHEN SoldAsVacant = 'N'
            THEN 'No'
        ELSE SoldAsVacant
        END

-- 5. Remove duplicates
WITH RowNumCTE
AS (
    SELECT *
        , ROW_NUMBER() OVER (
            PARTITION BY parcelid
            , propertyaddress
            , saleprice
            , saledate
            , legalreference ORDER BY UniqueID
            ) row_num
    FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
    )
Delete
FROM RowNumCTE
WHERE row_num > 1

-- 6. Delete unused columns
SELECT *
FROM [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]

ALTER TABLE [PortfolioProject].[dbo].[Nashville Housing Data for Data Cleaning]
drop COLUMN saledate, OwnerAddress, propertyaddress, TaxDistrict