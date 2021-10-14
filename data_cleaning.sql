
--- JUST A SMALL CHECK

SELECT *
FROM [Portfolio Project]..nashville_housing


--- STANDARDIZE SALEDATE COLUMN

SELECT SaleDateconv, CONVERT(date, SaleDate), CAST(SaleDate AS date)
FROM [Portfolio Project]..nashville_housing

--- Don't know why it isn't working

UPDATE nashville_housing
SET SaleDate = CAST(SaleDate AS date)

--- Can do this

ALTER TABLE nashville_housing
ADD SaleDateconv date;

UPDATE nashville_housing
SET SaleDateconv = CONVERT(date, SaleDate)


--- POPULATE PROPERTY ADDRESS DATA

SELECT PropertyAddress, ParcelID
FROM [Portfolio Project]..nashville_housing
--WHERE PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project]..nashville_housing AS A
JOIN [Portfolio Project]..nashville_housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio Project]..nashville_housing AS A
JOIN [Portfolio Project]..nashville_housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--- SPLIT ADDRESS INTO ADDRESS, CITY AND STATE

SELECT PropertyAddress
FROM [Portfolio Project]..nashville_housing

--- Deriving Address and City
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Portfolio Project]..nashville_housing

ALTER TABLE nashville_housing
ADD PropAddress nvarchar(255);

UPDATE nashville_housing
SET PropAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE nashville_housing
ADD PropCity nvarchar(255);

UPDATE nashville_housing
SET PropCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--- Check our updates which will be added at the end of our table
SELECT *
FROM [Portfolio Project]..nashville_housing

--- Check owner address data
SELECT OwnerAddress
FROM [Portfolio Project]..nashville_housing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM [Portfolio Project]..nashville_housing

--- Adding them to the original table
ALTER TABLE nashville_housing
ADD OwnAddress nvarchar(255);

UPDATE nashville_housing
SET OwnAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE nashville_housing
ADD OwnCity nvarchar(255);

UPDATE nashville_housing
SET OwnCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE nashville_housing
ADD OwnState nvarchar(255);

UPDATE nashville_housing
SET OwnState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [Portfolio Project]..nashville_housing


--- CHANGE THE 'Y' AND 'N' OF SOLDASVACANT TO 'YES' AND 'NO'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..nashville_housing
GROUP BY SoldAsVacant

--- Use CASE Statements to replace them
SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio Project]..nashville_housing

--- Update the original table
UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--- REMOVE DUPLICATE ROWS

--- Create CTE, as WHERE clause won't work with WINDOW functions
WITH RowNumCTE AS(
	SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress, 
					 SaleDate, 
					 SalePrice, 
					 LegalReference
					 ORDER BY
						UniqueID) AS RowNum
FROM [Portfolio Project]..nashville_housing
)

--- The deletion check!
--SELECT *
--FROM RowNumCTE
--WHERE RowNum > 1

DELETE
FROM RowNumCTE
WHERE RowNum > 1


--- TIME TO DELETE UNUSED COLUMNS

SELECT *
FROM [Portfolio Project]..nashville_housing

ALTER TABLE [Portfolio Project]..nashville_housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict, Address, City