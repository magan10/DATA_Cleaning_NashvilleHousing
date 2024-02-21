--- Cleaning Data in SQL Queres 
Select *
From Project_Portfolio..NashvilleHousing

---------------------------------------------------------------------------------
-- Standarize Date Format
--Select SaleDate, CONVERT(Date , SaleDate) 
--From Project_Portfolio..NashvilleHousing

Select SaleDateConverted, CONVERT(Date , SaleDate)
From Project_Portfolio..NashvilleHousing

UPDATE NashvilleHousing				
Set SaleDate = CONVERT(Date, SaleDate) -- this removed the time that within the date

ALTER TABLE NashvilleHousing		   -- alter table means that you want to change something in this name of the data_file
Add SaledateConverted Date;            -- this add new column  to the table

UPDATE NashvilleHousing
Set SaledateConverted = CONVERT(Date, SaleDate)



---------------------------------------------------------------------------------
-- Populate Property Address Data 

Select *
From Project_Portfolio..NashvilleHousing
--where PropertyAddress is null				-- in this line of code finds all the null in the column of the data 
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project_Portfolio..NashvilleHousing as a		-- this is "a"
JOIN Project_Portfolio..NashvilleHousing as b		-- this is "b"
	on a.ParcelID = b.ParcelID						-- means that the same ParcelId
	and a.[UniqueID ] <> b.[UniqueID ]				-- but, not the same row of the data
where a.PropertyAddress is null						-- this shows all null in the data

Update a											-- this means that we need to update the data in "a"
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) --means that if "a" is null put the value of "b" in "a"
from Project_Portfolio..NashvilleHousing as a		--this is "a"
JOIN Project_Portfolio..NashvilleHousing as b		-- this is "b"
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


---------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address , City , State) 

Select PropertyAddress						-- this means that choose this columns name in the data
From Project_Portfolio..NashvilleHousing	-- this is the data
--where PropertyAddress is null				-- in this line of code finds all the null in the column of the data 
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address1
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address2
From Project_Portfolio..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);			--this will Create a new Columns in the data of NashvilleHousing

Update NashvilleHousing							
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)
-- Puts the data of the substring that has been created above inside of PropertySplitAddress which is address1

ALTER TABLE NashvilleHousing					--this will Create a new Columns in the data of NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
-- Puts the data of the substring that has been created above inside of PropertySplitCity which is address2

Select *
from Project_Portfolio..NashvilleHousing


Select OwnerAddress
from Project_Portfolio..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), -- Display the Address
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), -- Display the City
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)  -- Display the State
from Project_Portfolio..NashvilleHousing
-- parsename only find the dot sysmbol in the data then use it as output 
-- example parsename('when.where.how', 1) output is "how"
-- select
-- Parsename('when.where.how', 1) output "how"
-- but in the problem above we can't use parsename because the address use comma so we need to convert the comma to dot symbol
-- by using Replace as shown above

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);			--this will Create a new Columns in the data of NashvilleHousing

Update NashvilleHousing							
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
-- Puts the data of the substring that has been created above inside of OwnerSplitAddress which is Address

ALTER TABLE NashvilleHousing					--this will Create a new Columns in the data of NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
-- Puts the data of the substring that has been created above inside of OwnerSplitCity which is City

ALTER TABLE NashvilleHousing					--this will Create a new Columns in the data of NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
-- Puts the data of the substring that has been created above inside of OwnerSplitState which is State

Select *
From Project_Portfolio..NashvilleHousing


---------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant),count(SoldAsVacant)	-- mean that removes any duplicate rows display only unique combinations
From Project_Portfolio..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,Case when SoldAsVacant = 'Y' then 'Yes'
	  when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
From Project_Portfolio..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
					    else SoldAsVacant
					    end


---------------------------------------------------------------------------------
-- Remove Duplicate

with Row_numCTE as(
Select *,
ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) Row_num
From Project_Portfolio..NashvilleHousing
)

Delete
From Row_numCTE
where Row_num > 1
--Order by PropertyAddress




---------------------------------------------------------------------------------
-- Delete Unused Columns
Select *
From Project_Portfolio..NashvilleHousing

Alter Table Project_Portfolio..NashvilleHousing
Drop column OwnerAddress, -- if you forgot to add columns that is suppposed you should add and then you execute the commant create another line of code
			TaxDistrict,
			Saledate,
			PropertyAddress