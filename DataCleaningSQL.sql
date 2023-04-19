/*

Cleaning Data in SQL Queries

*/


Select *
From Project..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------


-- Standarized Date Format


Select SaleDateConverted
From Project..NashvilleHousing



Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;


Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)








---------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data



Select *
From Project..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Now all Property Address is not Null Populated 
Select PropertyAddress
From Project..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Project..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Project..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySpiltAddress Nvarchar(255);


Update NashvilleHousing
SET PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)



ALTER TABLE NashvilleHousing
Add PropertySpiltCity Nvarchar(255);


Update NashvilleHousing
SET PropertySpiltCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))




Select * 
From Project..NashvilleHousing


-- Using Parse to Spilt Address and City


Select OwnerAddress
From Project..NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From Project..NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSpiltAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)



ALTER TABLE NashvilleHousing
Add OwnerSpiltCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)




ALTER TABLE NashvilleHousing
Add OwnerSpiltState Nvarchar(255);

Update NashvilleHousing
SET OwnerSpiltState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)



Select OwnerSpiltAddress, OwnerSpiltCity, OwnerSpiltState
From Project..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as CountOf
From Project..NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Project..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num
From Project..NashvilleHousing
)

Select * 
From RowNumCTE
Where row_num > 1


-----------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select * 
From Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE Project..NashvilleHousing
DROP COLUMN SaleDate

-------------------------------------------------------------------------------------------------------------