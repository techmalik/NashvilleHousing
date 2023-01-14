-- *****Cleaning Nashville Housing data***** --

SELECT *
FROM PortfolioProject..Nashville as nash

-- Standardize Date format
SELECT SaleDate2, CONVERT(Date, SaleDate)
FROM PortfolioProject..Nashville as nash

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville
ADD SaleDate2 Date;

UPDATE Nashville
SET SaleDate2 = CONVERT(Date, SaleDate)

-- Property Address
SELECT *
FROM PortfolioProject..Nashville as nash
ORDER BY ParcelId

SELECT N.ParcelID, N.PropertyAddress, M.ParcelID, M.PropertyAddress, ISNULL(N.PropertyAddress,M.PropertyAddress)
FROM PortfolioProject..Nashville as N
JOIN PortfolioProject..Nashville as M
	ON N.ParcelId = M.ParcelID
	AND N.UniqueID <> M.UniqueID
WHERE N.PropertyAddress is null

UPDATE N
SET PropertyAddress = ISNULL(N.PropertyAddress,M.PropertyAddress)
FROM PortfolioProject..Nashville as N
JOIN PortfolioProject..Nashville as M
	ON N.ParcelId = M.ParcelID
	AND N.UniqueID <> M.UniqueID
WHERE N.PropertyAddress is null

-- SPLITTING PROPERTY ADDRESS
--SELECT 
--	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address1,
--	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  as Address2
--FROM PortfolioProject..Nashville
------------------------------------------------------------------------------------------------------
ALTER TABLE Nashville
ADD Address1 NVARCHAR(255);

UPDATE Nashville
SET Address1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE Nashville
ADD Address2 NVARCHAR(255);

UPDATE Nashville
SET Address2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..Nashville as nash

-- SPLITTING OWNER'S ADDRESS
--SELECT 
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
--	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--FROM PortfolioProject..Nashville 
--------------------------------------------------------------------------------------------------------
ALTER TABLE Nashville
ADD OwnerAddress1 NVARCHAR(255);

UPDATE Nashville
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE Nashville
ADD OwnerAddress2 NVARCHAR(255);

UPDATE Nashville
SET OwnerAddress2 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE Nashville
ADD OwnerAddress3 NVARCHAR(255);

UPDATE Nashville
SET OwnerAddress3 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..Nashville 

-- FIX SOLDASVACANT COLUMN
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville 
GROUP BY SoldAsVacant
ORDER BY 2

--SELECT SoldAsVacant,
--	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--		 WHEN SoldAsVacant = 'N' THEN 'No'
--		 ELSE SoldAsVacant
--		 END as SoldAsVacant_new
--FROM PortfolioProject..Nashville

UPDATE Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END
FROM PortfolioProject..Nashville

-- Remove duplicates
WITH RownumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID
						) as row_num
FROM PortfolioProject..Nashville
)

DELETE
FROM RownumCTE
WHERE row_num > 1

--REMOVE UNUSED COLUMNS
ALTER TABLE PortfolioProject..Nashville
DROP COLUMN OwnerAddress, TaxDistrict, SaleDate, PropertyAddress

