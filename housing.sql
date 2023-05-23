Select *
from housing


--Standardize Date Format

Select saleDateConverted, CONVERT(Date,SaleDate)
From housing

Update housing
SET SaleDate = CONVERT(Date,SaleDate)





--Populate Property Address data

Select *
From housing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, NVL(a.PropertyAddress,b.PropertyAddress)
From housing a
JOIN housing b
on a.ParcelID = b.ParcelID
AND a.UniqueID_ <> b.UniqueID_
Where a.PropertyAddress is null

UPDATE housing a
SET PropertyAddress = (SELECT NVL(a.PropertyAddress, b.PropertyAddress)
FROM housing b
WHERE a.ParcelID = b.ParcelID
AND a.UniqueID_ <> b.UniqueID_
AND ROWNUM = 1)
WHERE a.PropertyAddress IS NULL;





-- Breaking out Address into Individual Columns (Address, City)

Select PropertyAddress
From housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
  SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) as Address,
  SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) as City
FROM housing;


ALTER TABLE housing
ADD PropertySplitAddress VARCHAR2(255);



UPDATE housing
SET PropertySplitAddress = SUBSTR(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);


ALTER TABLE housing
ADD PropertySplitCity VARCHAR2(255);


UPDATE housing
SET PropertySplitCity = SUBSTR(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress))
WHERE PropertyAddress IS NOT NULL;





-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM housing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE SoldAsVacant
WHEN 'Y' THEN 'Yes'
WHEN 'N' THEN 'No'
ELSE SoldAsVacant
END AS ConvertedSoldAsVacant
FROM housing;


UPDATE housing
SET SoldAsVacant = CASE SoldAsVacant
WHEN 'Y' THEN 'Yes'
WHEN 'N' THEN 'No'
ELSE SoldAsVacant
END;



--Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


SELECT *
FROM housing



--Delete Unused columns

Select *
From housing

ALTER TABLE housing
DROP COLUMN TaxDistrict;

ALTER TABLE housing
DROP COLUMN SaleDate;

ALTER TABLE housing
DROP COLUMN OwnerAddress;

ALTER TABLE housing
DROP COLUMN PropertyAddress;





























